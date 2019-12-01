///////////////////////////////////////////////////////////////////////////////////////////////
//
// FileUtils.pas
// --------------------------
// GPo 2003
// Last change:
//   GPo 2012
//     Unicode
//   GPo 2005
//     RemoveBackslash does not change root string, e.g. "C:\"
//

unit FileUtils;

interface

uses Windows, SysUtils, vcl.Forms, ShellAPI, Classes, vcl.Controls, Messages,
     Shlobj, ActiveX ,ComObj;

var ProgramPath : string; // Path to program executable including '\'
    PlugInDir: String;

// Umrechnung von SystemFiletime oder LocaleFileTime zu TDateTime inc. Formatierung zb. 'ddd. MMM, yyy','HH:MM:SS'
function FileTimeToDateTimeStr(const FTime:TFileTime; IsLocaleTime: boolean; const DFormat,TFormat:string): string;
// mit GB, MB, KB, Byte Rückgabe, AllowGB=false dann größter Wert MB
function FileSizeToStr(Size: Int64; const AllowGB:boolean=true): String;
// Append text line to file
procedure WriteLog(const FileName, LogLine: string);
function ExecuteExplorer(const FileName: WideString; ShowCmd: Integer= 3): THandle;
// Execute file. Failure if Result<=32
function ExecuteFile(const FileName: WideString; const Params: WideString='';
  const DefaultDir: WideString=''; ShowCmd: Integer=SW_SHOW): THandle;
function ExecuteFileWith(const FileName: WideString): THandle;
// Return file name without extension
function RemoveFileExt(FileName: string): string;
// Extract file extension without .
function ExtractFileExtNoDot(const FileName: string): string;
// Dateiname ohne Erweiterung extrahieren
function  ExtractFileNameNoExt(FileName: String): String;
// Returne first Drive or Pathname with Backslash
function ExtractMainPath(const FileName: String): String;
// Return path name with a \ as the last character
function ForceBackslash(const S: string): string;
// Remove \ from end of path if not drive root e.g. "C:\"
function RemoveBackslash(const S: string): string;
// If S<> '' then Result= .S else Result = ''
function ForceDot(const S: String; FirstDot: boolean): String;
// Remove Last Dir from Dir is Dir> C:\
function RemoveLastDir(const Dir: String): String;
function ExtractLastDir(const Dir: String): String;
// Remove Left and Right Chars for Valide PathName
function FileNameTrimLeftRight(const Str: string): string;
// Gibt bei exestierender Datei 'Kopie (int) von' zurück, sonst FileName
function GetNewFileName(const FileName: String;
  ForceKopievon: boolean=false; Counter: Integer=2): String;
// Get size of file
function GetFileSize(const FileName: string): Int64;
function SearchRecFileSize64(const SearchRec: TSearchRec): Int64;

function GetFreeDiskSize(const FileName: string): Int64;
procedure GetDiskSize(const FileName: string; FreeSize,TotalSize: Int64);

procedure GetDirList(const InitialDir: string; const List: TStrings;
  Recursive,CheckDouble,Force_Backslash: Boolean);
// Returne a List with MainPaths
procedure GetMainPathList(Paths, MainPaths: TStrings; ForceSlash: boolean);
  
function GetFileList(const Path,Mask: String; const List: TStrings;
  WithPathName,Recursive,RemoveExtension: boolean; const MaskDelimiter: String='|'): Int64; overload

function GetFileList(const Path,Mask: String; const List: TStrings;
  MaskIsFileExt,WithPathName,Recursive,RemoveExtension: boolean): Int64; overload

// Read CreateTime from Source and set it to dest
function ChangeFileCreateTime(const source: String;  const dest1: String; const dest2: String): Integer;

// Delete file(s).
// Default is flags will recycle: FOF_ALLOWUNDO|FOF_NOCONFIRMATION|FOF_SILENT|FOF_NOERRORUI
// Multiple files can be seperated by #0, wildcards are allowed, full path must be specified
function DeleteFileEx(const FileName: string; Flags: FILEOP_FLAGS=0): Boolean;
// Move file(s).
// Default is flags will overwrite: FOF_NOCONFIRMMKDIR or FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOERRORUI
// Multiple files can be seperated by #0, wildcards are allowed, full path must be specified
function MoveFile(aWND: HWND; const Source,Dest: string; Flags: FILEOP_FLAGS=0): Boolean; overload;
function Sh_FileCopyMove(aWND: HWND; const Source,Dest: string; DoMove: boolean;
  var IsAborted: boolean; Flags: FILEOP_FLAGS=0): Boolean;

function CopyFile(const Source,Dest: string; CanOverwrite: Boolean): Boolean;
// Wenn FILEOP_FLAGS=0 wird Datei bei vorhandener Datei umbenannt
function CopyFileEx(aWND: HWND; const Source,Dest: string; Flags: FILEOP_FLAGS=0): Boolean;
function RenameFileEx(const FileName,NewName: String): Boolean;
// Dos Compatible FileName mit Path Rückgabe
function MakeValidFileName(const Str: string): string;
// Ersetzt ungültige Zeichen,in Dateinamen (Wenn FileName einen Path enthält muß WithPath True sein) 
function MakeValidFileNameEx(const FileName: string; const WithPath: Boolean=False): string;
// Convert s in Upper and Lower Case
// eg. test_NEW ok = Test_New Ok
// Next Formater for Upper: ' ' _ ( ) [ ]
function UpperLowerCase(const s: String): String;
// Show standard Windows dialogs
procedure ShowFileProperties(const FileName: string);
procedure ShowSearchDialog(const Directory: string);
function MakeValideIntegerStr(str: String; RemoveTo: Char): String;
function StrGetDigit(const s: String; const start: Integer = 1): String;
function GetParameterFileName: string;
function GetLongParamFileName(Index:Integer): String;
// Drive Information mit SerialNr
function GetDriveInfo(const Drive: String; out DriveName,FileSystem: String;
  out SerialNr: DWord): boolean; overload;
function GetDriveInfo(const Drive: String; out DriveName: String;
  out SerialNr: DWord): boolean; overload;
// Get file dropped by WM_DROPFILES
function GetDroppedFile(const Msg: TWMDropFiles; Index: Integer=0): string;

function GetTempDir: String;
function GetTempFileName(const FileName: String): String;

procedure RegisterFileFormat(Extension,AppID: string; Description: string='';
  Executable: string=''; DoIconChange: Boolean=True; IconIndex: Integer=0);
procedure UnregisterFileFormat(Extension,AppID,Executable: string);

function GetSpezialFolder(SpezialFolder: Cardinal= CSIDL_DESKTOPDIRECTORY): String;
// If Result then Result LinkFileName else Result:= ''
function CreateLink(TargetExe,LinkName,Param,Titel,IconPath: String;
     SpezialFolder: Integer=CSIDL_DESKTOPDIRECTORY): String;
//  out: Object,Arguments, Description
procedure GetLinkInfo(const LinkName: String;
  var LinkObject,Arguments,Description: String);

implementation
uses StrUtils, Registry;

const
  faFile      = faReadOnly or faHidden or faSysFile or faArchive;
  faFileOrDir = (faFile or faDirectory) - faSysFile;

function FileTimeToDateTimeStr(const FTime:TFileTime; IsLocaleTime: boolean; const DFormat,TFormat:string): string;
var
  SysTime       : TSystemTime;
  DateTime      : TDateTime;
  LocalFileTime : TFileTime;
begin
  Try
    If IsLocaleTime then FileTimeToSystemTime(FTime, SysTime)
    else begin
      FillChar(LocalFileTime, SizeOf(TFileTime), #0);
      FileTimeToLocalFileTime(Ftime, LocalFileTime);
      FileTimeToSystemTime(LocalFileTime, SysTime);
    end;
    DateTime := SystemTimeToDateTime(SysTime);
    Result := FormatDateTime(DFormat + ' ' + TFormat, DateTime);
  except
    Result:= '';
  end;
end;

function FileSizeToStr(Size: Int64; const AllowGB:boolean=true): String;
begin
  If AllowGB and (Size div 1024 div 1024 div 1024 > 0) then
    Result:= Format('%.2f GB',[Size/1024/1024/1024])
  else if Size div 1024 div 1024  > 0 then
    Result:= Format('%.2f MB',[Size/1024/1024])
  else if Size div 1024 > 0 then
    Result:= Format('%.2f KB',[Size/1024])
  else if Size> 0 then Result:= IntToStr(Size)+ ' Byte'
  else Result:= '0 Byte';
end;

function MakeValidFileName(const Str: string): string;
const
  FileNameChars = ['A'..'Z','0'..'9','.','_','~','-','@','='];
  ReplaceChar = '_';

var
  I : Integer;
begin
  Result:=Str;
  for I:=1 to Length(Result) do
    if not CharInSet(UpCase(Result[I]), FileNameChars) then
      Result[I]:= ReplaceChar;
  if Result='' then Result:='-';
  if Result[1]='.' then Result:=ReplaceChar+Result;
  if Length(Result)> 255 then SetLength(Result, 255);
end;

function MakeValideIntegerStr(str: String; RemoveTo: Char): String;
const
  IntegerChars = ['0'..'9'];
var  I : Integer;
begin
  Result:=Str;
  for I:= 1 to Length(Result) do
    if not CharInSet(Result[I], IntegerChars) then
      Result[I]:= RemoveTo;
  If Result= '' then Result:= RemoveTo;
end;

function MakeValidFileNameEx(const FileName: string; const WithPath: Boolean=False): string;
const
  InvalideChars = [':','\','/','<','>','*','|','?','"'];
  ReplaceChar = '_';
var
  I : Integer;
  Path: String;
begin
  If WithPath then
  begin
     Path:= ExtractFilePath(FileName);
     If Length(Path)< 3 then Path:= ProgramPath;
     If (Path[2]<> ':')or(Path[3]<>'\') then Path:= ProgramPath;
     Result:= ExtractFileName(FileName);
  end
  else begin
    Path:= '';
    Result:= FileName;
  end;

  For I:= 1 to Length(Result) do
    if CharInSet(Result[I], InvalideChars) then
      Result[I]:= ReplaceChar;

  If Result= '' then Result:= 'Umbenannt';
  Result:= Path+ Result;
end;

function StrGetDigit(const s: String; const start: Integer = 1): String;
const
   digit = ['0'..'9'];
var i: Integer;
begin
  Result:= '';
  For i:= start to Length(s) do
    if CharInSet(s[i], digit) then
      Result:= Result + s[i];
end;

function UpperLowerCase(const s: String): String;
const
   Flags = [' ','_','(',')','[',']'];
var
  i: Integer;
begin
  If Length(s)> 1 then
  begin
    Result:= UpperCase(s[1]) + LowerCase(Copy(s,2,MAXINT));
    i:= 2;
    while i<= Length(Result) do
    begin
      If CharInSet(Result[i], Flags) and (i < Length(Result)) then
        Result[i+1]:= UpperCase(Result[i+1])[1];
      inc(i);
    end;
  end
  else Result:= UpperCase(s);
end;

procedure GetDirList(const InitialDir: string; const List: TStrings;
  Recursive,CheckDouble,Force_Backslash: Boolean);
{$B-}
var
  SRec : TSearchRec;
  E : Integer;
  Path,s : string;
begin
  Path:=ForceBackslash(InitialDir);
  E:=FindFirst(Path+'*.*',faFileOrDir,SRec);
  try
    while E=0 do
    begin
      if (SRec.Attr and faDirectory<> 0) and
         ((SRec.Name<>'.') and (SRec.Name<>'..')) then
      begin
        If Force_Backslash then s:= ForceBackslash(Path+ SRec.Name)
        else s:= Path+ SRec.Name;
        If CheckDouble then
        begin
          If List.IndexOf(s)< 0 then List.Append(s);
        end
        else List.Append(s);
        If Recursive then GetDirList(Path+ SRec.Name,List,True,CheckDouble,Force_Backslash);
      end;
      E:=FindNext(SRec);
    end;
  finally
    FindClose(SRec);
  end;
end;

procedure GetMainPathList(Paths, MainPaths: TStrings; ForceSlash: boolean);
var z,i: Integer;
    Path: TStringList;
    s: String;
begin
  Path:= TStringList.Create;
  Path.AddStrings(Paths);
  Try
    For z:= 0 to Path.Count-1 do if z< Path.Count then
    begin
      s:= ForceBackslash(Path.Strings[z]);
      For i:= Path.Count-1 downto 0 do
        if (SameText(Copy(Path.Strings[i],1,Length(s)), s))and(i<>z) then Path.Delete(i)
      else if ForceSlash then Path.Strings[i]:= ForceBackSlash(Path.Strings[i]);
    end;
    MainPaths.Assign(Path);
  finally
    Path.Free;
  end;
end;

procedure WriteLog(const FileName, LogLine: string);
var Log : TextFile;
begin
  try
    Assign(Log,FileName);
    {$I-} Append(Log); {$I+}
    if IOResult<>0 then Rewrite(Log);
    try
      WriteLn(Log,LogLine);
    finally
      CloseFile(Log);
    end;
  except
  end;
end;

// Execute file. ShowCmd is often SW_SHOW
function ExecuteFile(const FileName, Params, DefaultDir: WideString;
  ShowCmd: Integer): THandle;
begin
  Result:=ShellExecuteW(0,nil,
                       PWideChar(FileName),
                       PWideChar(Params),
                       PWideChar(DefaultDir),ShowCmd);
end;

function ExecuteFileWith(const FileName: WideString): THandle;
begin
  Result:= ShellExecuteW(Application.Handle, 'Open', 'rundll32.exe',
              PWideChar('shell32.dll,OpenAs_RunDLL "' + FileName + '"'), nil, SW_SHOW);
end;

// Öffnet Explorer und selektiert angegebene Datei.
function ExecuteExplorer(const FileName: WideString; ShowCmd: Integer): THandle;
begin
  Result:= ShellExecuteW(Application.Handle, 'Open', 'explorer.exe',
                PWideChar('/e,/select, '+ '"'+ FileName+ '"'), nil, ShowCmd);

  //Result:= WinExec(PChar('Explorer.exe /e,/select, '+'"'+FileName+'"'), ShowCmd);
end;

function ExtractFileExtNoDot(const FileName: string): string;
var I : Integer;
begin
  I := LastDelimiter('.\:',FileName);
  if (I>0) and (FileName[I]='.') then Result:=Copy(FileName,I+1,MaxInt)
  else Result:='';
end;

function ExtractFileNameNoExt(FileName: String): String;
begin
  Result:= ChangeFileExt(ExtractFileName(FileName),'');
end;

function ForceDot(const S: String; FirstDot: boolean): String;
begin
  If (S<>'')then
  begin
    If FirstDot and (S[1]<>'.') then Result:= '.'+ S
    else if not FirstDot and (S[Length(S)]<> '.') then Result:= S + '.'
    else Result:= S;
  end
  else Result:= S;
end;

function ExtractMainPath(const FileName: String): String;
var z: Integer;
begin
  Result:= ForceBackslash(FileName);
  z:= PosEx('\',Result,4);
  If z> 0 then Result:= Copy(Result,1,z)
  else
    Result:= ForceBackslash(ExtractFileDrive(FileName));
end;

function RemoveFileExt(FileName: string): string;
var P : Integer;
begin
  for P:=Length(FileName) downto 1 do
    if FileName[P]='\' then Break
    else if FileName[P]='.' then
    begin
      Result:=Copy(FileName,1,P-1);
      Exit;
    end;
  Result:=FileName;
end;

function RemoveLastDir(const Dir: String): String;
begin
  Result:= ForceBackslash(Dir);
  If Length(Result)< 4 then exit;
  Result:= Copy(Result, 1, LastDelimiter('\',RemoveBackslash(Result)));
end;

function ExtractLastDir(const Dir: String): String;
begin
  Result:= RemoveBackslash(Dir);
  If Length(Result)< 3 then exit;
  Result:= Copy(Result,LastDelimiter('\',RemoveBackslash(Result))+1, MaxInt);
end;

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

// Unerwünschte Zeichen aus einer Pfadangabe entfernen zb. '67.55 MB  E:\Ablage\MyPicture.bmp'
function FileNameTrimLeftRight(const Str: string): string;
const
  BreakChars = [' ', ',', ';'];
var
  i,z : Integer;
begin
  Result:=Str;
  for i:=0 to Length(Result) do
   If (Result[i]= ':')and(Result[i+1]='\') then
   begin
     Result:= Copy(Result,i-1,Length(Result));
     break;
   end;

   For i:= Length(Result) downto 4 do
     if Result[i]= '.' then
      begin
        For z:= i to Length(Result) do
          if CharInSet(Result[z], BreakChars) then
            begin
              Result:= Copy(Result,1,i-1);
              exit;
            end;
      end;
end;

function GetNewFileName(const FileName: String;
  ForceKopievon: boolean; Counter: Integer): String;
var
    s1,s2: String;
begin
  If FileExists(FileName) then
  begin
    if Counter< 2 then Counter:= 2;
    If ForceKopievon then
    begin
      s1:= ExtractFilePath(FileName);
      s2:= ExtractFileName(FileName);
      If FileExists(s1+ 'Kopie von '+ s2) then
      begin
        While FileExists(s1+ 'Kopie (' + IntToStr(Counter)+ ') von '+ s2) do inc(Counter);
        Result:= s1+ 'Kopie (' + IntToStr(Counter)+ ') von '+ s2;
      end
      else Result:= s1+ 'Kopie von '+ s2;
    end
    else begin
      s1:= ChangeFileExt(FileName,'');
      s2:= ExtractFileExt(FileName);
      While FileExists(s1 + ' ('+ IntToStr(Counter)+ ')'+ s2) do inc(Counter);
      Result:= s1+ ' ('+ IntToStr(Counter)+ ')'+ s2;
    end;
  end
  else Result:= FileName;
end;

function GetTempDir: String;
begin
  SetLength(Result,Max_Path);
  SetLength(Result,GetTempPath(Max_Path,@Result[1]));
  Result:= ForceBackslash(Result);
end;

function GetTempFileName(const FileName: String): String;
var s: String;
begin
  s:= IntToStr(GetTickCount)+ '_'+ MakeValidFileNameEx(FileName,false);
  Result:= GetTempDir;
  if Length(Result)+ Length(s) > Max_Path then
   while Length(Result)+ Length(s)> Max_Path do Delete(s,1,1);
  Result:= Result+ s;
end;

function GetFileSize(const FileName: string): Int64;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Result:=-1;
  Handle:=FindFirstFile(PChar(FileName),FindData);
  if Handle<>INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)=0 then
    begin
      Result:=FindData.nFileSizeLow or (Int64(FindData.nFileSizeHigh) shl 32);
    end;
  end;
end;

function GetFreeDiskSize(const FileName: string): Int64;
var TotalSize: Int64;
begin
  GetDiskFreeSpaceEx(PChar(ExtractFileDrive(FileName)),
    Result, TotalSize, nil);
end;

procedure GetDiskSize(const FileName: string; FreeSize,TotalSize: Int64);
begin
  GetDiskFreeSpaceEx(PChar(ExtractFileDrive(FileName)),
    FreeSize, TotalSize, nil);
end;

// Eigenartig, ohne Backslash gibst keine Informationen
// wenn Application's Drive = Drive ist
function GetDriveInfo(const Drive: String; out DriveName: String;
  out SerialNr: DWord): boolean;
var
  Flags,MaxL: DWord;
  PDriveName: PChar;
begin
  GetMem(PDriveName,Max_Path);
  Try
    Result:= GetVolumeInformation(
               PChar(ForceBackslash(Drive)),PDriveName,Max_Path,
               @SerialNr,MaxL,Flags,nil,0
               );
    DriveName:= PDriveName;
  finally
    FreeMem(PDriveName);
  end;
end;

function GetDriveInfo(const Drive: String; out DriveName,FileSystem: String;
  out SerialNr: DWord): boolean;
var
  Flags,MaxL: DWord;
  PDriveName,PFileSystem: PChar;
begin
  GetMem(PDriveName,Max_Path);
  GetMem(PFileSystem,10);
  Try
    Result:= GetVolumeInformation(
               PChar(ForceBackslash(Drive)),PDriveName,Max_Path,
               @SerialNr,MaxL,Flags,PFileSystem,10
               );
    DriveName:= PDriveName;
    FileSystem:= PFileSystem;
  finally
    FreeMem(PDriveName,Max_Path);
    FreeMem(PFileSystem,10);
  end;
end;

function GetFileList(const Path,Mask: String;
  const List: TStrings; WithPathName,Recursive,RemoveExtension: boolean; const MaskDelimiter: String='|'): Int64;
var DirList: TStringList;
    MaskList: TStringList;
    i,z: Integer;

  procedure _GetFileList(const Path,Mask: String; const List: TStrings; WithPathName: boolean);
  var Find: WIN32_FIND_DATAW;
      h: THandle;
      aPath: String;
  begin
    If not Assigned(List) then exit;
    aPath:= ForceBackslash(Path);
    h:= FindFirstFileW(PWideChar(aPath+ Mask),Find);
    If h<> INVALID_HANDLE_VALUE then
    begin
      inc(Result,Find.nFileSizeLow or (Int64(Find.nFileSizeHigh) shl 32));
      If not WithPathName then aPath:= '';
      If (Find.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)= 0 then
      begin
        if RemoveExtension then
          List.Append(aPath+ ChangeFileExt(Find.cFileName,''))
        else List.Append(aPath+ Find.cFileName);

        While FindNextFileW(h,Find) do
          if (Find.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)= 0 then
          begin
            inc(Result,Find.nFileSizeLow or (Int64(Find.nFileSizeHigh) shl 32));
            if RemoveExtension then
              List.Append(aPath+ ChangeFileExt(Find.cFileName,''))
            else List.Append(aPath+ Find.cFileName);
          end;
      end;
      Windows.FindClose(h);
    end;
  end;

begin
  Result:= 0;
  MaskList:= TStringList.Create;
  //MaskList.Duplicates := [dupIgnore];
  If MaskDelimiter <> '' then
  begin
    MaskList.Delimiter:= MaskDelimiter[1];
    MaskList.StrictDelimiter:= true;
    MaskList.DelimitedText:= Mask;
    //MaskList.SaveToFile(ProgramPath+ 'Deli.txt');
    z:= MaskList.IndexOf('');
    If z> -1 then MaskList.Delete(z);
  end
  else
    MaskList.Append(Mask);

  Try
    For z:= 0 to MaskList.Count- 1 do
    begin
      If Recursive then
      begin
        DirList:= TStringList.Create;
        Try
          DirList.Append(Path);
          GetDirList(Path,DirList,true,false,true);
          For i:= 0 to DirList.Count-1 do
            _GetFileList(DirList[i],MaskList[z],List,WithPathName);
        finally
          DirList.Free;
        end;
      end
      else _GetFileList(Path,MaskList[z],List,WithPathName);
    end;
  finally
    MaskList.Free;
  end;
end;

function GetFileList(const Path,Mask: String; const List: TStrings;
  MaskIsFileExt,WithPathName,Recursive,RemoveExtension: boolean): Int64;
begin
  If MaskIsFileExt then
     Result:= GetFileList(Path,Mask, List,WithPathName,Recursive,RemoveExtension, ',')
  else
     Result:= GetFileList(Path,Mask, List,WithPathName,Recursive,RemoveExtension, '');
end;

function DeleteFileEx(const FileName: string; Flags: FILEOP_FLAGS): Boolean;
var
  fos : TSHFileOpStruct;
  f: String;
begin
  if FileName='' then
  begin
    Result:=False;
    Exit;
  end;
  if FileName[Length(FileName)]<>#0 then f:= FileName+#0
  else f:= FileName;
  ZeroMemory(@fos,SizeOf(fos));
  with fos do
  begin
    Wnd:=Application.Handle;
    wFunc:=FO_DELETE;
    pFrom:=PChar(f);
    if Flags=0 then fFlags:=FOF_ALLOWUNDO or FOF_NOCONFIRMATION  or FOF_NOERRORUI
    else fFlags:=Flags;
    hNameMappings := nil;
  end;
  Result:=SHFileOperation(fos)=0;
end;

function ChangeFileCreateTime(const source: String;  const dest1: String; const dest2: String): Integer;
var
  h: THandle;
  Find: WIN32_FIND_DATAW;
  cTime: TFileTime;

   function ChangeTime(const aFile: String; const cTime: TFileTime): boolean;
   begin
       h:= CreateFile(PChar(afile), FILE_WRITE_ATTRIBUTES, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
       If h <> INVALID_HANDLE_VALUE then
       begin
         Result:= Windows.SetFileTime(h, @cTime, nil, nil);
         Windows.FindClose(h);
         exit;
      end;
       Result:= false;
   end;

begin
  Result:= -1;

  h:= FindFirstFileW(PWideChar(source),Find);
  If h <> INVALID_HANDLE_VALUE then
  begin
    cTime:= Find.ftCreationTime;
    Windows.FindClose(h);
  end
  else exit;

  Result:= 0;

  If (dest1 <> '') and ChangeTime(dest1, cTime) then inc(Result);
  If (dest2 <> '') and ChangeTime(dest2, cTime) then inc(Result);

end;

function CopyFile(const Source,Dest: string; CanOverwrite: Boolean): Boolean;
begin
  Result:=Windows.CopyFile(PChar(Source),PChar(Dest),not CanOverwrite);
end;

function CopyFileEx(aWND: HWND; const Source,Dest: string; Flags: FILEOP_FLAGS=0): Boolean;
var
  fFlags: Integer;
  IsAborted: boolean;
begin
  If Flags= 0 then fFlags:= FOF_RENAMEONCOLLISION or FOF_NOCONFIRMATION
  else fFlags:= Flags;
  Result:= Sh_FileCopyMove(aWND,Source,Dest,False,IsAborted,fFlags);
  If Result then Result:= not IsAborted;
end;

function MoveFile(aWND: HWND; const Source,Dest: string; Flags: FILEOP_FLAGS=0): Boolean;
var IsAborted: boolean;
begin
  Result:= Sh_FileCopyMove(aWND,Source,Dest,True,IsAborted,Flags);
  If Result then Result:= not IsAborted;
end;

function Sh_FileCopyMove(aWND: HWND; const Source,Dest: string; DoMove: boolean;
 var IsAborted: boolean; Flags: FILEOP_FLAGS=0): Boolean;
var
  fos : TSHFileOpStruct;
  S,D: String;
begin
  if (Source='') or (Dest='') then
  begin
    Result:=False;
    Exit;
  end;
  S:= Source;
  D:= Dest;
  if Source[Length(S)]<> #0 then S:= S+ #0;
  if D[Length(D)]<> #0 then D:= D+ #0;
  ZeroMemory(@fos,SizeOf(fos));
  with fos do
  begin
    Wnd:= aWND;
    If DoMove then wFunc:= FO_Move
    else wFunc:= FO_COPY;
    if Flags=0 then fFlags:=FOF_NOCONFIRMMKDIR or FOF_NOCONFIRMATION or FOF_SILENT or FOF_NOERRORUI
    else fFlags:=Flags;
    fAnyOperationsAborted:= IsAborted;
    pFrom:=PChar(S);
    pTo:=PChar(D);
  end;
  Result:= SHFileOperation(fos)=0;
  IsAborted:= fos.fAnyOperationsAborted;
end;

function RenameFileEx(const FileName,NewName: String): Boolean;
var fos : TSHFileOpStruct;
    f,nf: String;
begin
  If (FileName='')or(NewName='') then
  begin
    Result:=False;
    exit;
  end;
  If FileName[Length(FileName)]<>#0 then f:= FileName+#0
  else f:= FileName;
  If NewName[Length(NewName)]<>#0 then nf:= NewName+#0
  else nf:= NewName;
  ZeroMemory(@fos,SizeOf(fos));
  With fos do
  begin
    Wnd:=Application.Handle;
    wFunc:=FO_RENAME;
    pFrom:=PChar(f);
    pTo:= PChar(nf);
    fFlags:= FOF_NOCONFIRMATION;
  end;
  Result:= SHFileOperation(fos)=0;
end;

function GetParameterFileName: string;
var
  I : Integer;
begin
  Result:=ParamStr(1);
  for I:=2 to ParamCount do Result:=Result+' '+ParamStr(I);
end;

function GetLongParamFileName(Index:Integer): String;
var h: THandle;
    Find: WIN32_FIND_DATAW;
    p1,p2: PChar;
begin
  h:= FindFirstFileW(PWideChar(ParamStr(Index)),Find);
  If h<> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(h);
    GetMem(p1,255);
    SetCurrentDirectory(PChar(ExtractFilePath(ParamStr(Index))));
    GetFullPathName(Find.cFileName,255,p1,p2);
    Result:= String(p1);
    FreeMem(p1,255);
  end
  else Result:= '';
end;

procedure ShowFileProperties(const FileName: string);
var
  SEI : SHELLEXECUTEINFO;
  pidl: PItemIDList;
begin
 ZeroMemory(@SEI,SizeOf(SEI));
 with SEI do
 begin
   cbSize:=SizeOf(SEI);
   fMask:=SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
   If UpperCase(FileName)='DRIVES' then
   begin
     SHGetSpecialFolderLocation(0, CSIDL_DRIVES, pidl);
     fMask:= fMask or SEE_MASK_IDLIST;
     lpIDList:= pidl;
   end
   else lpFile:=PChar(FileName);
   Wnd:=Application.Handle;
   lpVerb:='properties';
  end;
  if not ShellExecuteEx(@SEI) then RaiseLastOSError;
end;

procedure ShowSearchDialog(const Directory: string);
var
  SEI : SHELLEXECUTEINFO;
begin
 ZeroMemory(@SEI,SizeOf(SEI));
 with SEI do
 begin
   cbSize:=SizeOf(SEI);
   fMask:=SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
   Wnd:=Application.Handle;
   lpVerb:='find';
   lpFile:=PChar(Directory);
  end;
  if not ShellExecuteEx(@SEI) then RaiseLastOSError ;
end;

function GetDroppedFile(const Msg: TWMDropFiles; Index: Integer): string;
begin
  SetLength(Result,DragQueryFile(Msg.Drop,Index,nil,0));
  DragQueryFile(Msg.Drop,Index,@Result[1],Length(Result)+1);
end;

function SearchRecFileSize64(const SearchRec: TSearchRec): Int64;
begin
  Result:=(Int64(SearchRec.FindData.nFileSizeHigh) shl 32) or SearchRec.FindData.nFileSizeLow
end;

// Geändert GPo 2004 (Erklärung zu AppID,  zb. ExeName ohne Erweiterung )
// Wenn DoIconChange= False und Dateityp exestiert wird nur Anwendung im Explorer
// als Hauptanwendung regestriert und keine Icons oder andere Verküpfungen geändert
// (nur mit WinXP getestet)
procedure RegisterFileFormat(Extension,AppID,Description,Executable: string;
  DoIconChange: Boolean; IconIndex: Integer);
var
  Reg: TRegistry;
  P : Integer;
  IsIcon : Boolean;
begin
  Extension:=LowerCase(Extension);
  if Extension[1]<>'.' then Extension:='.'+Extension;
  if Executable='' then Executable:=ParamStr(0);
  IsIcon:=(Extension='.ico') or (Extension='.cur') or (Extension='.ani');
  repeat
    P:=Pos(' ',AppID);
    if P=0 then Break;
    Delete(AppID,P,1);
  until False;

  if (Description='') and not IsIcon then AppID:= AppID+'.'+IntToStr(IconIndex)
  else AppID:=AppID+Extension;

  Reg := TRegistry.Create;
  try
    // Add HKEY_CLASSES_ROOT\.<Extension>\(Default) = <AppID>
    Reg.RootKey:=HKEY_CLASSES_ROOT;
    If DoIconChange or not Reg.KeyExists(Extension) then
    begin
      Reg.OpenKey(Extension,True);
      Reg.WriteString('',AppID);
      Reg.CloseKey;

      // Now create an association for that file type
      // This adds HKEY_CLASSES_ROOT\<AppID>\(Default) = <Description>
      Reg.OpenKey(AppID,True);
      Reg.WriteString('',Description);
      Reg.CloseKey;

      if (IconIndex>=0) then
      begin
        // Now write the default icon for my file type
        // This adds HKEY_CLASSES_ROOT\<AppID>\DefaultIcon\(Default) = <Executable>,<IconIndex>
        Reg.OpenKey(AppID+'\DefaultIcon', True);
        if IsIcon then Reg.WriteString('','"%1"')
        else Reg.WriteString('','"'+Executable+'",'+IntToStr(IconIndex));
        Reg.CloseKey;
      end;

      // Write what application to open it with
      // This adds HKEY_CLASSES_ROOT\<AppID>\Shell\Open\Command\ (Default) = "<Executable>" "%1"
      Reg.OpenKey(AppID+'\Shell\Open\Command',True);
      Reg.WriteString('', '"'+Executable+'" "%1"');
      Reg.CloseKey;

      // GPo 2004 Im Explorer Anwendung als Default setzen
      {Reg.RootKey:=HKEY_CURRENT_USER;
      Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\'+Extension, True);
      Reg.WriteString('ProgID',AppID);
      Reg.CloseKey; }
    end

    // Nur im Explorer als Hauptanwendung regestrieren, keine Icons und bestehende Verknüpfungen ändern.
    else begin
      Reg.RootKey:=HKEY_CURRENT_USER;
      Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\'+Extension, True);
      Reg.WriteString('Application',Executable);
      Reg.DeleteValue('ProgID'); // Eventuell vorhandenes Programm entfernen
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  // Finally, we want the Windows Explorer to realize we added our file type
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

procedure UnregisterFileFormat(Extension,AppID,Executable: string);
var reg: TRegistry;
begin
  Extension:=LowerCase(Extension);
  if Extension[1]<>'.' then Extension:='.'+Extension;
  if Executable='' then Executable:= Application.ExeName;

  reg := TRegistry.Create;
  try
    Reg.RootKey:=HKEY_CLASSES_ROOT;
    If Reg.OpenKey(Extension,False)then
    begin
      If Reg.ReadString('')= AppID+Extension then Reg.WriteString('','');
      Reg.CloseKey;
    end;

    Reg.DeleteKey(AppID+Extension);

    Reg.RootKey:=HKEY_CURRENT_USER;
    If Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\'+Extension, False)then
    begin
      If ExtractFileName(Reg.ReadString('Application'))= ExtractFileName(Application.ExeName) then
       Reg.DeleteValue('Application');
      If Reg.ReadString('ProgID')= AppID+Extension then Reg.DeleteValue('ProgID');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

// SpezialFolder: -1 dann muß LinkName Vollen Pfad enthalten
// CSIDL_DESKTOPDIRECTORY = Desktop
// CSIDL_STARTMENU = Startmenü direkt
// CSIDL_SENDTO	= Send To menu
// CSIDL_STARTUP = Autostart

function GetSpezialFolder(SpezialFolder: Cardinal= CSIDL_DESKTOPDIRECTORY): String;
var p: PItemIDList;
    s: array[0..MAX_PATH] of char;
begin
  FillChar(s,sizeof(s),0);
  SHGetSpecialFolderLocation(Application.Handle,SpezialFolder, p);
  SHGetPathFromIDList(p, @s);
  Result:= s;
end;

function CreateLink(TargetExe,LinkName,Param,Titel,IconPath: String;
     SpezialFolder: Integer=CSIDL_DESKTOPDIRECTORY): String;
var IObject: IUnknown;
    ILink: IShellLink;
    IFile: IPersistFile;
    s: String;
    LinkFile: WideString;
begin
  If SpezialFolder<> -1 then s:= GetSpezialFolder(SpezialFolder);
  IObject := CreateComObject(CLSID_ShellLink);
  ILink := IObject as IShellLink;
  IFile := IObject as IPersistFile;

  With ILink do
  begin
    SetPath(PChar(TargetExe));
    SetArguments(PChar(Param));
    SetWorkingDirectory(PChar(ExtractFilePath(TargetExe)));
    SetIconLocation(PChar(IconPath),0);
    SetDescription(PChar(Titel));
  end;
  If SpezialFolder <> -1 then LinkName:= '\'+ LinkName;
  If ExtractFileExt(LinkName)= '' then LinkName:= LinkName+ '.lnk';
  LinkFile := s +  LinkName;       //Name der Verknüpfung
  If Succeeded(IFile.Save(PWChar(LinkFile),false)) then Result:= LinkFile
  else Result:= '';
end;


// Arguments: Retrieves the command-line arguments associated with a Shell link object.
// Description: Retrieves the description string for a Shell link object.
// LinkObject: Retrieves the filename of Shell link object
procedure GetLinkInfo(const LinkName: String;
  var LinkObject,Arguments,Description: String);
var
  IObject: IUnknown;
  ILink: IShellLink;
  IFile: IPersistFile;
  sObj,sArg,sDcr: Array [0..Max_Path] of Char;
  Find: WIN32_FIND_DATA;
  LinkFile: WideString;
  h: THandle;
begin
  LinkFile:= LinkName;
  IObject:= CreateComObject(CLSID_ShellLink);
  ILink:= IObject as IShellLink;
  IFile:= IObject as IPersistFile;

  h:= FindFirstFile(PChar(LinkName), Find);
  If h<> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(h);
    IFile.Load(PWChar(LinkFile), STGM_READ);
    ILink.GetPath(@sObj, Max_Path, Find, SLGP_RAWPATH);
    ILink.GetArguments(@sArg, Max_Path);
    ILink.GetDescription(@sDcr, Max_Path);
  end;
  LinkObject:= sObj;
  Arguments:= sArg;
  Description:= sDcr;
end;

var P : Integer;
initialization
  ProgramPath:=ParamStr(0); P:=Length(ProgramPath);
  while (P>0) and (ProgramPath[P]<>'\') do Dec(P);
  SetLength(ProgramPath,P);
  PlugInDir:= ProgramPath+'PlugIns\';

finalization
  
end.

