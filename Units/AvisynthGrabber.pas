(*
//- GPo @2019
//- Avisynth frame reader, extracted from another project
//- and largely reduced to the bare minimum.
*)

unit AvisynthGrabber;

interface
uses
  Windows,System.SysUtils,System.Math, System.Classes,vcl.Graphics,avisynth;

{$IFDEF WIN32}
  {$SetPEOptFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$endif}

type
  //- Frame caching not used for AvsPThump
  PDataEntry = ^TDataEntry;
  TDataEntry = record
    frame: PAVS_VideoFrame;
    FrameNr: Integer;
   end;

  //- Must check the frame, frame can be nil on error!
  TOnReadFrame = procedure(const FrameNr: Integer; Frame: PAVS_VideoFrame) of Object;

  TAvisynthGrabber = Class
  protected
    FCacheCount: Integer;
    FSwapFrame: boolean;
    FCacheFrames: boolean;
    FIsInit: boolean;
    FDataList: TList;
    FOnReadFrame: TOnReadFrame;
    FInProgess: boolean;
    procedure SetCacheCount(Value: Integer);
    procedure DataList_Create;
    procedure DataList_Clear;
    procedure DataList_Add(FrameNo: Integer; frame: PAVS_VideoFrame);
    function DataList_FindFrame(FrameNo: Integer): PAVS_VideoFrame;
  private
    env: PAVS_ScriptEnvironment;
    clip: PAVS_Clip;
    clip2: PAVS_Clip;
    vi: PAVS_VideoInfo;
    display_vi: PAVS_VideoInfo;
    FClipError: String;
    FFrameError: String;
    FColorSpace: String;
  public
    constructor Create(const FrameCacheCount: Integer= 0; const DoCacheFrames: boolean=false);
    destructor Destroy; override;
    function OpenAvs(const FileName: String; const Dest: TBitmap=nil;
      const Nr: Integer=0): Integer;
    function OpenFromTxt(const Txt: String; const fileName: String; const Dest: TBitmap=nil;
      const Nr: Integer=0):Integer;
    function GrabbFrame(const FrameNr: Integer; const Dest: TBitmap): boolean;
    function ReadFrame(const FrameNr: Integer): boolean;
    function GetCachedFrameData(FrameNr: Integer): PByte;
    procedure ClearFrameCache;

    //- Normal Close, frees all Instances except the avisynth.dll
    procedure Close;
    //- Only for hard cut, there are memory leaks when the grabber is loading.
    //- written for thread loading. if thread termination needed.
    procedure Cancel;

    property VideoInfo: PAVS_VideoInfo read vi default nil;
    //- the video info but convertet to RGB32
    property DisplayInfo: PAVS_VideoInfo read display_vi default nil;
    property ColorSpace: String read FColorSpace;
    property FrameCacheCount: Integer read FCacheCount write SetCacheCount;
    property CacheFrames: boolean read FCacheFrames write FCacheFrames;
    property SwapFrame: boolean read FSwapFrame write FSwapFrame;
    property OnReadFrame: TOnReadFrame read FOnReadFrame write FOnReadFrame;
    property IsInit: Boolean read FIsInit default False;
    property ClipError: String read FClipError;
    property FrameError: String read FFrameError;
  end;

  //- For test purpose (OpenFromTxt)
  TAvisynthGrabber2 = record
  private
    FCacheCount: Integer;
    FSwapFrame: boolean;
    FCacheFrames: boolean;
    FIsInit: boolean;
    //FDataList: TList;
    FOnReadFrame: TOnReadFrame;
    //FInProgess: boolean;
    env: PAVS_ScriptEnvironment;
    clip: PAVS_Clip;
    source_clip: PAVS_Clip;
    vi: PAVS_VideoInfo;
    display_vi: PAVS_VideoInfo;
    FClipError: String;
    FFrameError: String;
    FColorSpace: String;
  public
    FrameCacheCount: Integer;
    procedure Init();
    function OpenFromTxt(const Txt: String; const fileName: String; const Dest: TBitmap=nil;
                        const Nr: Integer=0): Integer;
    function GrabbFrame(const FrameNr: Integer; const Dest: TBitmap): boolean;

    //- Normal Close, frees all Instances except the avisynth.dll
    procedure Close;
    //- Only for hard cut, there are memory leaks when the grabber is loading.
    //- written for thread loading. if thread termination needed.
    procedure Cancel;

    property IsInit: Boolean read FIsInit;
    property OnReadFrame: TOnReadFrame read FOnReadFrame write FOnReadFrame;
    property ColorSpace: String read FColorSpace;
    property VideoInfo: PAVS_VideoInfo read vi;
    property DisplayInfo: PAVS_VideoInfo read display_vi;
    property ClipError: String read FClipError;
    property FrameError: String read FFrameError;
  end;

var
  AS_DllLoader: TAS_DllLoader = nil;
implementation

// helper func
function ForceBackslash(const S: string): string;
begin
  Result:= S;
  if (Result<>'') and (Result[Length(Result)]<> '\') then
    Result:= Result+ '\';
end;

function RemoveBackslash(const S: string): string;
begin
  Result:= S;
  If (Length(S)> 3) and (S[Length(S)] = '\') then
    SetLength(Result, Length(Result)- 1);
end;

//------------------------
//- test test test
//------------------------

procedure TAvisynthGrabber2.Init();
begin
  If not Assigned(AS_DllLoader) then
    AS_DllLoader:= TAS_DllLoader.Create;
  AS_DllLoader.LoadAvisynth();
  FIsInit:= AS_DllLoader.IsInit;
  env:= nil;
  vi:= nil;
  display_vi:= nil;
  Clip:= nil;
  source_clip:= nil;
  FClipError:= '';
  FFrameError:= '';
  FColorSpace:= '';
  FSwapFrame:= false;
  FCacheCount:= 0;
  FCacheFrames:= False;
  //~DataList_Create;
end;

// Does not work if MCTD in the script used. Now it works !
// disabled all exceptions (e.g. float div zero) on app creating
function TAvisynthGrabber2.OpenFromTxt(const Txt: String; const fileName: String;
  const Dest: TBitmap; const Nr: Integer): Integer;
var
  avsval, avsval2: AVS_Value;
  argval: array[0..1] of AVS_Value;
  //argname: array[0..1] of PAnsiChar;
  uFile, uDir, uName, uTxt, uwDir: AnsiString;
  n: Integer;
  //ST: TStringList;
  myFile: AnsiString;

  procedure ConvertErr(const s: String);
  begin
    FClipError:= StringReplace(s, String(myFile), String(uName), [rfIgnoreCase]);
  end;

begin
  Result:= -1; // must <> -2
  FClipError:= '';
  FColorSpace:= '';

  If not Assigned(AS_DllLoader) then
  begin
    FClipError:= 'Error: AVS_DllLoader not initialized';
    exit;
  end;

  if not AS_DllLoader.IsInit then
  begin
    FClipError:= 'Cannot load the avisynth.dll';
    exit;
  end;

  //~If FCacheCount > 0 then
    //DataList_Create;

  If not Assigned(env) then
  begin
    env:= avs_create_script_environment;
    FClipError:= String(avs_get_error(env));
  end;

  If (env = nil) or (FClipError <> '') then
  begin
    If FClipError = '' then
      FClipError:= 'Cannot create the avisynth script_environment';
    exit;
  end;

  if clip <> nil then
    avs_release_clip(clip);
  vi:= nil;
  display_vi:= nil;
  clip:= nil;

  uName:= UTF8Encode(fileName);
  uFile:= UTF8Encode(ExtractFileName(fileName));
  uDir := UTF8Encode(ForceBackslash(ExtractFilePath(fileName)));
  uwDir:= UTF8Encode(RemoveBackslash(ExtractFilePath(fileName)));
  //uTxt := UTF8Encode(Txt);
  //uTxt := UTF8String(Txt);
  uTxt:= AnsiString(Txt);

  Try
    avs_set_working_dir(env, PAnsiChar(uwDir));
    avs_set_global_var(env, '$ScriptName$', avs_new_value_string(PAnsiChar(uName)));
    avs_set_global_var(env, '$ScriptFile$', avs_new_value_string(PAnsiChar(uFile)));
    avs_set_global_var(env, '$ScriptDir$', avs_new_value_string(PAnsiChar(uDir)));

///////////  AviSource
    {
    myFile:= UTF8Encode(ExtractFilePath(Application.Exename) + 'pv.avs');
    ST:= TStringList.Create;
    Try
      ST.Text:= uTxt;
      Try
        ST.SaveToFile(myFile);
      except
        FClipError:= 'Cannot write to the program directory.'#13+ myFile;
        exit;
      end
    Finally
      ST.Free;
    End;
    argval[0]:= avs_new_value_string(PAnsiChar(myFile));
    avsval:= avs_invoke(env,'AviSource',avs_new_value_array(@argval, 1));
    }
//////////

//////////  Eval and Import get's Error if MCTD() in the script used

    argval[0]:= avs_new_value_string(PAnsiChar(uTxt));  // the script text
    argval[1]:= avs_new_value_string(PAnsiChar(uName)); // the file with path
    //avsval:= avs_invoke(env,'Import', avs_new_value_string(PChar(sName)));
    avsval:= avs_invoke(env,'Eval',avs_new_value_array(@argval, 2));
    //- On 32bit: avs_is_error(avsval) does not return an error! must check with avs_get_error(env)! Why?

/////////

    if avs_is_error(avsval) then
    begin
      ConvertErr(String(avs_as_error(avsval)));  // replace pv.avs with the filename
      Abort;
    end;

    clip:= avs_take_clip(avsval, env);
    FClipError:= String(avs_clip_get_error(clip));
    If (FClipError <> '') or not Assigned(clip) then
    begin
      If FClipError = '' then
        FClipError:= 'Cannot create the clip';
      ConvertErr(FClipError);
      Abort;
    end;

    if avs_function_exists(env, 'PixelType') then
    begin
      avsval2:= avs_new_value_clip(clip); // result must be release (memory leak)
      FColorSpace:= String(avs_as_string(avs_invoke(env, 'PixelType', avsval2)));
      avs_release_value(avsval2);
    end
    else begin
      // TODO classic avs
    end;

    vi:= avs_get_video_info(clip);
    avs_release_clip(clip);

    If not Assigned(vi) or (vi.width < 1) then
    begin
      If Assigned(vi) and (vi.width < 1) then
        FClipError:= 'The clip has no video'
      else FClipError:= 'Cannot get the video info';
      Abort;
    end;

    //avs_set_var(env, 'last', avsval);
    avsval2:= avs_invoke(env, 'ConvertToRGB32', avsval);
    avs_release_value(avsval);
    if avs_is_error(avsval2) then
    begin
      FClipError:= String(avs_as_error(avsval2));
      ConvertErr(FClipError);
      Abort;
    end;

    clip:= avs_take_clip(avsval2, env);
    avs_release_value(avsval2);

    FClipError:= String(avs_clip_get_error(clip));
    If (FClipError <> '') or not Assigned(clip) then
    begin
      If FClipError = '' then
        FClipError:= 'Cannot create the display clip';
      ConvertErr(FClipError);
      Abort;
    end;

    display_vi:= avs_get_video_info(clip);
    If (display_vi= nil) or not avs_is_rgb32(display_vi) then
    begin
      FClipError:= 'Cannot get the display video info';
      Abort;
    end;
  except
    If FClipError = '' then
      FClipError:= String(avs_get_error(env));
    If FClipError = '' then
      FClipError:= ('Unknown Error: Cannot create the clip');
    if Assigned(clip) then
      avs_release_clip(clip);
    vi:= nil;
    display_vi:= nil;
    clip:= nil;
    exit;
  end;

  Result:= display_vi.num_frames;

  If Assigned(Dest) then
  begin
    Dest.PixelFormat:= pf32bit;
    Dest.SetSize(display_vi.width, display_vi.height);
    if Nr < display_vi.num_frames then
      n:= Nr
    else
      n:= display_vi.num_frames-1;
    if n > -1 then
      GrabbFrame(n, Dest);
  end
  else
    //if Assigned(FOnReadFrame) then
      //ReadFrame(n);
end;

function TAvisynthGrabber2.GrabbFrame(const FrameNr: Integer; const Dest: TBitmap): boolean;
var
  frame: PAVS_VideoFrame;
  i,rs,pitch: Integer;
  rp: PByte;
  DoCache: boolean;
begin
  Result:= false;
  FFrameError:= '';
  DoCache:= FCacheFrames;
  frame:= nil;

  Try
    if (clip= nil) or not avs_is_rgb32(display_vi) then
    begin
      FFrameError:= 'Not a RGB32 clip for display';
      exit;
    end;

    {If DoCache then
    begin
      frame:= DataList_FindFrame(FrameNr);
      If not Assigned(frame) then
      begin
        frame:= avs_get_frame(clip, FrameNr);
        If frame= nil then
        begin
          FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
          exit;
        end;
        DataList_Add(FrameNr, frame);
      end;
    end
    else begin }
      frame:= avs_get_frame(clip, FrameNr);
      If frame = nil then
      begin
        FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
        exit;
      end;
    //end;

    If Assigned(Dest) then
    Try
      rp:= avs_get_read_ptr(frame);
      pitch:= avs_get_pitch(frame);
      rs:= avs_get_row_size(frame);

      If not FCacheFrames then
      begin
        avs_release_video_frame(frame);
        frame:= nil;
      end;

      if not FSwapFrame then
        for i:= display_vi^.height-1 downto 0 do
        begin
          CopyMemory(Dest.ScanLine[i],rp,rs);
          Inc(rp,pitch);
        end
      else
        for i:= 0 to display_vi^.height-1 do
        begin
          CopyMemory(Dest.ScanLine[i],rp,rs);
          Inc(rp,pitch);
        end;

      {
      // alternative BitBlt
      with Dest do
        avs_bit_blt(
          env,ScanLine[display_vi.height-1],Integer(ScanLine[0])-
          Integer(ScanLine[1]),avs_get_read_ptr(frame),avs_get_pitch(frame),
          avs_get_row_size(frame),display_vi.height);
      }
    except
      FFrameError:= 'Error: Cannot draw the video frame';
      exit;
    end;
    Result:= true;
  finally
    if Assigned(FOnReadFrame) then
        FOnReadFrame(FrameNr, frame);
    If Assigned(frame) and not DoCache then
      avs_release_video_frame(frame);
  end;
end;

procedure TAvisynthGrabber2.Close;
begin
  //DataList_Clear;
  If Assigned(AS_DllLoader) and AS_DllLoader.IsInit then
  begin
    If Assigned(clip) then
      avs_release_clip(clip);
    If Assigned(source_clip) then
      avs_release_clip(source_clip);
    Try
      If Assigned(env) and Assigned(avs_delete_script_environment) then
        avs_delete_script_environment(env);
      env:= nil;
    except
    End;
  end;
  clip:= nil;
  source_clip:= nil;
  vi:= nil;
  display_vi:= nil;
end;

//- Only for hard cut, there are memory leaks when the grabber is loading.
//- written for thread loading. if thread termination needed.
procedure TAvisynthGrabber2.Cancel;
begin
  clip:= nil;
  source_clip:= nil;
  vi:= nil;
  display_vi:= nil;
  env:= nil;
end;

// test end

//----------------------------------------
//- Class AvisynthGrabber for AvsThumb
//----------------------------------------

constructor TAvisynthGrabber.Create(const FrameCacheCount: Integer;
  const DoCacheFrames: boolean);
begin
  inherited Create;
  If not Assigned(AS_DllLoader) then
    AS_DllLoader:= TAS_DllLoader.Create;
  AS_DllLoader.LoadAvisynth();
  FIsInit:= AS_DllLoader.IsInit;
  env:= nil;
  vi:= nil;
  display_vi:= nil;
  Clip:= nil;
  Clip2:= nil;
  FClipError:= '';
  FFrameError:= '';
  FColorSpace:= '';
  FSwapFrame:= false;
  FCacheCount:= FrameCacheCount;
  FCacheFrames:= DoCacheFrames;
  DataList_Create;
end;

// We do not close the avisynth.dll, it's designed for
// multiple Grabber instances.
destructor TAvisynthGrabber.Destroy;
begin
  Close;
  If Assigned(FDataList) then
    FDataList.Free;

  inherited Destroy;
end;

procedure TAvisynthGrabber.Close;
begin
  DataList_Clear;
  If Assigned(AS_DllLoader) and AS_DllLoader.IsInit then
  begin
    If Assigned(clip) then
      avs_release_clip(clip);
    If Assigned(clip2) then
      avs_release_clip(clip2);
    If Assigned(env) and Assigned(avs_delete_script_environment) then
        avs_delete_script_environment(env);
  end;

  env:= nil;
  clip:= nil;
  clip2:= nil;
  vi:= nil;
  display_vi:= nil;
end;

//- Only for hard cut, there are memory leaks when the grabber is loading.
//- written for loading with thread if thread termination needed (Avisynth hangs).
procedure TAvisynthGrabber.Cancel;
begin
  DataList_Clear;
  clip:= nil;
  clip2:= nil;
  vi:= nil;
  display_vi:= nil;
end;

procedure TAvisynthGrabber.SetCacheCount(Value: Integer);
begin
  FCacheCount:= Value;
  If Value < 1 then
    DataList_Clear
  else DataList_Create;
end;

procedure TAvisynthGrabber.ClearFrameCache;
begin
  DataList_Clear;
end;

procedure TAvisynthGrabber.DataList_Create;
begin
  If not Assigned(FDataList) then
    FDataList:= TList.Create
  else
    DataList_Clear;
end;

procedure TAvisynthGrabber.DataList_Clear;
var
  i: Integer;
  P: PDataEntry;
begin
  If not Assigned(FDataList) then exit;
  For i:= 0 to FDataList.Count-1 do
  begin
    P:= FDataList[i];
    If Assigned(P^.frame) then
      avs_release_video_frame(P^.frame);
    Dispose(PDataEntry(P))
  end;
  FDataList.Clear;
end;

function TAvisynthGrabber.DataList_FindFrame(FrameNo: Integer): PAVS_VideoFrame;
var
  i: Integer;
begin
  For i:= FDataList.Count- 1 downto 0 do
    if PDataEntry(FDataList[i]).FrameNr = FrameNo then
    begin
      Result:= PDataEntry(FDataList[i])^.frame;
      exit;
    end;
  Result:= nil;
end;

function TAvisynthGrabber.GetCachedFrameData(FrameNr: Integer): PByte;
var
  frame: PAVS_VideoFrame;
begin
  frame:= DataList_FindFrame(FrameNr);
  If Assigned(Frame) then
    Result:= frame^.vfb.data
  else Result:= nil;
end;

procedure TAvisynthGrabber.DataList_Add(FrameNo: Integer; frame: PAVS_VideoFrame);
var
  P: PDataEntry;
begin
  New(P);
  P^.frame:= frame;
  P^.FrameNr:= FrameNo;
  FDataList.Add(P);

  While FDataList.Count > FCacheCount do
  begin
    P:= FDataList[0];
    If Assigned(P^.frame) then
      avs_release_video_frame(P^.frame);
    Dispose(PDataEntry(P));
    FDataList.Delete(0);
  end;
end;

function TAvisynthGrabber.OpenAvs(const FileName: String; const Dest: TBitmap;
  const Nr: Integer): Integer;
var
  avsval, avsval2: AVS_Value;
  argval: array[0..1] of AVS_Value;
  n: Integer;
  myFile: AnsiString;

begin
  Result:= -1;
  FClipError:= '';
  FColorSpace:= '';

  If not Assigned(AS_DllLoader) then
  begin
    FClipError:= 'Error: AVS_DllLoader not initialized';
    exit;
  end;

  if not AS_DllLoader.IsInit then
  begin
    FClipError:= 'Cannot load the avisynth.dll';
    exit;
  end;

  If FCacheCount > 0 then
    DataList_Create;

  If not Assigned(env) then
  begin
    env:= avs_create_script_environment;
    FClipError:= String(avs_get_error(env));
  end;

  If (env = nil) or (FClipError <> '') then
  begin
    If FClipError = '' then
      FClipError:= 'Cannot create the avisynth script_environment';
    exit;
  end;

  if clip <> nil then
    avs_release_clip(clip);
  vi:= nil;
  display_vi:= nil;
  clip:= nil;


{   test
  unistring:=  FileName+#0;
  Bytes:= TEncoding.UTF8.GetBytes(unistring);
  source:= TEncoding.UTF8.GetBytes('AviSource');
  //SetLength(Bytes, length(Bytes)-3);
  ShowMessage(TEncoding.UTF8.GetString(Bytes));

  Try
    argval_p[0]:= avs_new_value_string_p(PChar(Bytes));
    avsval:= avs_invoke_p(env,PChar(source),avs_new_value_array_p(@argval_p, 1));
    if avs_is_error(avsval) then
    begin
      FClipError:= String(avs_as_error(avsval)) + ' 1';
      Abort;
    end;
 }


  MyFile:= AnsiString(FileName);
  Try
    Try
      argval[0]:= avs_new_value_string(PAnsiChar(MyFile));
      //avsval:= avs_invoke(env,'AviSource',avs_new_value_array(@argval, 1));
      avsval:= avs_invoke(env,'import', avs_new_value_array(@argval, 1));
      if avs_is_error(avsval) then
      begin
        FClipError:= String(avs_as_error(avsval));
        Abort;
      end;

      clip:= avs_take_clip(avsval, env);
      FClipError:= String(avs_clip_get_error(clip));
      If (FClipError <> '') or not Assigned(clip) then
      begin
        If FClipError = '' then
          FClipError:= 'Cannot create the clip';
        Abort;
      end;

      if avs_function_exists(env, 'PixelType') then
      begin
        avsval2:= avs_new_value_clip(clip); // result must be release (memory leak)
        FColorSpace:= String(avs_as_string(avs_invoke(env, 'PixelType', avsval2)));
        avs_release_value(avsval2);
      end
      else begin
        // TODO classic avs
      end;

      vi:= avs_get_video_info(clip);
      avs_release_clip(clip);

      If not Assigned(vi) or (vi.width < 1) then
      begin
        If Assigned(vi) and (vi.width < 1) then
          FClipError:= 'The clip does not contain video'
        else FClipError:= 'Cannot get the video info';
        Abort;
      end;

      //avs_set_var(env, 'last', avsval);
      avsval2:= avs_invoke(env, 'ConvertToRGB32', avsval);
      avs_release_value(avsval);
      if avs_is_error(avsval2) then
      begin
        FClipError:= String(avs_as_error(avsval2));
        Abort;
      end;

      clip:= avs_take_clip(avsval2, env);
      avs_release_value(avsval2);

      FClipError:= String(avs_clip_get_error(clip));
      If (FClipError <> '') or not Assigned(clip) then
      begin
        If FClipError = '' then
          FClipError:= 'Cannot create the display clip';
        Abort;
      end;

      display_vi:= avs_get_video_info(clip);
      If (display_vi= nil) or not avs_is_rgb32(display_vi) then
      begin
        FClipError:= 'Cannot get the display video info';
        Abort;
      end;
    except
      If FClipError = '' then
        FClipError:= String(avs_get_error(env));
      If FClipError = '' then
        FClipError:= ('Unknown Error: Cannot create the clip');
      if Assigned(clip) then
        avs_release_clip(clip);
      vi:= nil;
      display_vi:= nil;
      clip:= nil;
      exit;
    end;

    Result:= display_vi.num_frames;

    if Nr < display_vi.num_frames then
      n:= Nr
    else
      n:= display_vi.num_frames-1;

    If Assigned(Dest) then
    begin
      Dest.PixelFormat:= pf32bit;
      Dest.SetSize(display_vi.width, display_vi.height);
      if n > -1 then
        GrabbFrame(n, Dest);
    end
    else
      if Assigned(FOnReadFrame) then
        ReadFrame(n);
  Finally
     //
  End;
end;

function TAvisynthGrabber.OpenFromTxt(const Txt: String; const fileName: String;
  const Dest: TBitmap; const Nr: Integer): Integer;
var
  avsval, avsval2: AVS_Value;
  argval: array[0..1] of AVS_Value;
  //argname: array[0..1] of PAnsiChar;
  uFile, uDir, uName, uTxt, uwDir: AnsiString;
  n: Integer;
  //ST: TStringList;
  myFile: AnsiString;

  procedure ConvertErr(const s: String);
  begin
    FClipError:= StringReplace(s, String(myFile), String(uName), [rfIgnoreCase]);
  end;

begin
  Result:= -1;
  FClipError:= '';
  FColorSpace:= '';

  If not Assigned(AS_DllLoader) then
  begin
    FClipError:= 'Error: AVS_DllLoader not initialized';
    exit;
  end;

  if not AS_DllLoader.IsInit then
  begin
    FClipError:= 'Cannot load the avisynth.dll';
    exit;
  end;

  If FCacheCount > 0 then
    DataList_Create;

  If not Assigned(env) then
  begin
    env:= avs_create_script_environment;
    FClipError:= String(avs_get_error(env));
  end;

  If (env = nil) or (FClipError <> '') then
  begin
    If FClipError = '' then
      FClipError:= 'Cannot create the avisynth script_environment';
    exit;
  end;

  if clip <> nil then
    avs_release_clip(clip);
  vi:= nil;
  display_vi:= nil;
  clip:= nil;

  uName:= UTF8Encode(fileName);
  uFile:= UTF8Encode(ExtractFileName(fileName));
  uDir := UTF8Encode(ForceBackslash(ExtractFilePath(fileName)));
  uwDir:= UTF8Encode(RemoveBackslash(ExtractFilePath(fileName)));
  uTxt := UTF8Encode(Txt);
  //uTxt := UTF8String(Txt);

  Try
    avs_set_working_dir(env, PAnsiChar(uwDir));
    avs_set_global_var(env, '$ScriptName$', avs_new_value_string(PAnsiChar(uName)));
    avs_set_global_var(env, '$ScriptFile$', avs_new_value_string(PAnsiChar(uFile)));
    avs_set_global_var(env, '$ScriptDir$', avs_new_value_string(PAnsiChar(uDir)));

///////////  AviSource
    {
    myFile:= UTF8Encode(ExtractFilePath(Application.Exename) + 'pv.avs');
    ST:= TStringList.Create;
    Try
      ST.Text:= uTxt;
      Try
        ST.SaveToFile(myFile);
      except
        FClipError:= 'Cannot write to the program directory.'#13+ myFile;
        exit;
      end
    Finally
      ST.Free;
    End;
    argval[0]:= avs_new_value_string(PAnsiChar(myFile));
    avsval:= avs_invoke(env,'AviSource',avs_new_value_array(@argval, 1));
    }
//////////

//////////  Eval and Import get's Error if MCTD() in the script used

    argval[0]:= avs_new_value_string(PAnsiChar(uTxt));  // the script text
    argval[1]:= avs_new_value_string(PAnsiChar(uName)); // the file with psth
    //avsval:= avs_invoke(env,'Import', avs_new_value_string(PChar(sName)));
    avsval:= avs_invoke(env,'Eval',avs_new_value_array(@argval, 2));
    //- On 32bit: avs_is_error(avsval) does not return an error! must check with avs_get_error(env)! Why?

/////////

    if avs_is_error(avsval) then
    begin
      ConvertErr(String(avs_as_error(avsval)));  // replace pv.avs with the filename
      Abort;
    end;

    clip:= avs_take_clip(avsval, env);
    FClipError:= String(avs_clip_get_error(clip));
    If (FClipError <> '') or not Assigned(clip) then
    begin
      If FClipError = '' then
        FClipError:= 'Cannot create the clip';
      ConvertErr(FClipError);
      Abort;
    end;

    if avs_function_exists(env, 'PixelType') then
    begin
      avsval2:= avs_new_value_clip(clip); // result must be release (memory leak)
      FColorSpace:= String(avs_as_string(avs_invoke(env, 'PixelType', avsval2)));
      avs_release_value(avsval2);
    end
    else begin
      // TODO classic avs
    end;

    vi:= avs_get_video_info(clip);
    avs_release_clip(clip);

    If not Assigned(vi) or (vi.width < 1) then
    begin
      If Assigned(vi) and (vi.width < 1) then
        FClipError:= 'The clip does not contain video'
      else FClipError:= 'Cannot get the video info';
      Abort;
    end;

    //avs_set_var(env, 'last', avsval);
    avsval2:= avs_invoke(env, 'ConvertToRGB32', avsval);
    avs_release_value(avsval);
    if avs_is_error(avsval2) then
    begin
      FClipError:= String(avs_as_error(avsval2));
      ConvertErr(FClipError);
      Abort;
    end;

    clip:= avs_take_clip(avsval2, env);
    avs_release_value(avsval2);

    FClipError:= String(avs_clip_get_error(clip));
    If (FClipError <> '') or not Assigned(clip) then
    begin
      If FClipError = '' then
        FClipError:= 'Cannot create the display clip';
      ConvertErr(FClipError);
      Abort;
    end;

    display_vi:= avs_get_video_info(clip);
    If (display_vi= nil) or not avs_is_rgb32(display_vi) then
    begin
      FClipError:= 'Cannot get the display video info';
      Abort;
    end;
  except
    If FClipError = '' then
      FClipError:= String(avs_get_error(env));
    If FClipError = '' then
      FClipError:= ('Unknown Error: Cannot create the clip');
    if Assigned(clip) then
      avs_release_clip(clip);
    vi:= nil;
    display_vi:= nil;
    clip:= nil;
    exit;
  end;

  Result:= display_vi.num_frames;

  if Nr < display_vi.num_frames then
    n:= Nr
  else
    n:= display_vi.num_frames-1;

  If Assigned(Dest) then
  begin
    Dest.PixelFormat:= pf32bit;
    Dest.SetSize(display_vi.width, display_vi.height);
    if n > -1 then
      GrabbFrame(n, Dest);
  end
  else
    if Assigned(FOnReadFrame) then
      ReadFrame(n);
end;

function TAvisynthGrabber.GrabbFrame(const FrameNr: Integer; const Dest: TBitmap): boolean;
var
  frame: PAVS_VideoFrame;
  i,rs,pitch: Integer;
  rp: PByte;
  DoCache: boolean;
begin
  Result:= false;
  FFrameError:= '';
  DoCache:= FCacheFrames;
  frame:= nil;
  Try
    if (clip= nil) or not avs_is_rgb32(display_vi) then
    begin
      FFrameError:= 'No RGB32 clip for the display';
      exit;
    end;

    If DoCache then
    begin
      frame:= DataList_FindFrame(FrameNr);
      If not Assigned(frame) then
      begin
        frame:= avs_get_frame(clip, FrameNr);
        If frame= nil then
        begin
          FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
          exit;
        end;
        DataList_Add(FrameNr, frame);
      end;
    end
    else begin
      frame:= avs_get_frame(clip, FrameNr);
      If frame = nil then
      begin
        FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
        exit;
      end;
    end;

    If Assigned(Dest) then
    Try
      rp:= avs_get_read_ptr(frame);
      pitch:= avs_get_pitch(frame);
      rs:= avs_get_row_size(frame);

      If not FCacheFrames then
      begin
        avs_release_video_frame(frame);
        frame:= nil;
      end;

      if not FSwapFrame then
        for i:= display_vi^.height-1 downto 0 do
        begin
          CopyMemory(Dest.ScanLine[i],rp,rs);
          Inc(rp,pitch);
        end
      else
        for i:= 0 to display_vi^.height-1 do
        begin
          CopyMemory(Dest.ScanLine[i],rp,rs);
          Inc(rp,pitch);
        end;
      {
      // alternative BitBlt
      with Dest do
        avs_bit_blt(
          env,ScanLine[display_vi.height-1],Integer(ScanLine[0])-
          Integer(ScanLine[1]),avs_get_read_ptr(frame),avs_get_pitch(frame),
          avs_get_row_size(frame),display_vi.height);
      }
    except
      FFrameError:= 'Error: Cannot draw the video frame';
      exit;
    end;
    Result:= true;
  finally
    if Assigned(FOnReadFrame) then
        FOnReadFrame(FrameNr, frame);
    If Assigned(frame) and not DoCache then
      avs_release_video_frame(frame);
  end;
end;

function TAvisynthGrabber.ReadFrame(const FrameNr: Integer): boolean;
var
  frame: PAVS_VideoFrame;
  DoCache: boolean;
begin
  Result:= false;
  frame:= nil;
  DoCache:= FCacheFrames;

  Try
    if (clip= nil) or not avs_is_rgb32(display_vi) then
    begin
      FFrameError:= 'Not a RGB32 clip for display';
      exit;
    end;

    If DoCache then
    begin
      frame:= DataList_FindFrame(FrameNr);
      If not Assigned(frame) then
      begin
        frame:= avs_get_frame(clip, FrameNr);
        If frame = nil then
        begin
          FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
          exit;
        end;
        DataList_Add(FrameNr, frame);
      end;
    end
    else begin
      frame:= avs_get_frame(clip, FrameNr);
      If frame = nil then
        FFrameError:= 'Cannot get the frame ' + IntToStr(FrameNr);
    end;

    Result:= Assigned(frame);
  finally
    If Assigned(FOnReadFrame) then
      FOnReadFrame(FrameNr, frame);
    If (not DoCache) and Assigned(frame) then
      avs_release_video_frame(frame);
  end;
end;

initialization
  AS_DllLoader:= nil;
finalization
  If Assigned(AS_DllLoader) then
  begin
    AS_DllLoader.UnloadAvisynth;
    AS_DllLoader.Free;
  end;

end.

