(*
----------------------------
  AvsPmod bookmark reader

  GPo 2020.02  Version 2.0.5

----------------------------
*)

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, CommCtrl, Vcl.StdCtrls, AvisynthGrabber, JPEG,
  IniFiles, Vcl.Menus, Vcl.Themes, Vcl.ExtCtrls, SingleInstance, Vcl.Tabs, System.UITypes,
  System.Types, ListViewEx, System.Threading, SyncObjs;

type
  //- forward
  TClip = class;

  pFrameRec = ^TFrameRec;
  TFrameRec = record
    bmp : TBitmap;
    FrameNr : Integer;
    Title: String;
    BitInt: Integer;  //- Bitwise options flag  GetBit, SetBit, RemoveBit
    tmp: Integer;     //- temporal functions flag
  end;

  TBookStream = class(TFileStream)
  public
    RefCount: Integer;
    constructor Create(const FileName: String); overload;
  end;

  TClipIdx = record
    Clip: TClip;
    ActiveList: TList;
    TabViewIdx: Integer;
    TabSetIdx: Integer;
    FrameIdx: Integer;
  end;

  TClip = class
    NextPart: TClip;
    PrevPart: TClip;
    NeedSave: boolean;
    FrameList: TList;
    FavorList: TList;
    Favor2List: TList;
    FileStream: TBookStream;
    StoredStream: TBookStream;
    ThumbWidth, ThumbHeight: Integer;
    MultiThumbSize: boolean;
    AR: Single;
    LastViewOriginLV, LastViewOriginFV, LastViewOriginFV2: TPoint;
    LastIndexLV, LastIndexFV, LastIndexFV2: Integer;
    LV_PreveusIndex: Integer;
    LastOpen: String;
    LastFile: String;
    AvsWnd: THandle;
    AvsP_video_w: Integer;
    AvsP_video_h: Integer;
    AvsP_vid_wnd_w : Integer;
    AvsP_vid_wnd_h : Integer;
    TabSet_LastIndex: Integer;
    Splits: String;
    constructor Create;
    destructor Destroy; override;
  end;

  TForm1 = class(TForm)
    LV: TListViewEx;
    OpenDlg: TOpenDialog;
    PopupMenu: TPopupMenu;
    popOpen: TMenuItem;
    popZoom: TMenuItem;
    popZ50: TMenuItem;
    popZ100: TMenuItem;
    popZ150: TMenuItem;
    popZ200: TMenuItem;
    popSaveToStream: TMenuItem;
    popLoadFromStream: TMenuItem;
    SaveDlg: TSaveDialog;
    N1: TMenuItem;
    Option1: TMenuItem;
    popResetDefaultPos: TMenuItem;
    SaveDefaultPos1: TMenuItem;
    N2: TMenuItem;
    popDefThumbWidth: TMenuItem;
    popSaveImages: TMenuItem;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    btnStop: TButton;
    N3: TMenuItem;
    popReOpenSize: TMenuItem;
    popReOpen240: TMenuItem;
    popReOpen480: TMenuItem;
    popReOpen640: TMenuItem;
    popReOpen720: TMenuItem;
    N4: TMenuItem;
    popReOpenCustom: TMenuItem;
    popReOpenCustomSize: TMenuItem;
    popFormAutoMove: TMenuItem;
    popSingleInstance: TMenuItem;
    popRunAvsP: TMenuItem;
    popReOpenSizeCustom: TMenuItem;
    N5: TMenuItem;
    TabSet: TTabSet;
    popClearFavorites: TMenuItem;
    popSaveFavorites: TMenuItem;
    N6: TMenuItem;
    popShowTitle: TMenuItem;
    popTitleAutoAddFavor: TMenuItem;
    popTitleAddFavor: TMenuItem;
    popBackupFavor: TMenuItem;
    popRestoreFavor: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    popSortFavorites: TMenuItem;
    N251: TMenuItem;
    popUpdateBookmarks: TMenuItem;
    N9: TMenuItem;
    popZFit: TMenuItem;
    popSaveBookmarks: TMenuItem;
    N10: TMenuItem;
    JPEGQuality1: TMenuItem;
    popZ100Fit: TMenuItem;
    popSendCommand: TMenuItem;
    popAfterSaveToStreamOpenStream: TMenuItem;
    popOpenLastSavedStream: TMenuItem;
    popClearBasket: TMenuItem;
    popAvsPscrollreverse: TMenuItem;
    N11: TMenuItem;
    popAvsPscrolldiv2: TMenuItem;
    popClearFileHistory: TMenuItem;
    popMaxHistoryCount: TMenuItem;
    N12: TMenuItem;
    popAvsPTabsChange: TMenuItem;
    popReOpen360: TMenuItem;
    popExtraMenu: TMenuItem;
    popMoveFrameNr: TMenuItem;
    TabView: TTabSet;
    PopUpTab: TPopupMenu;
    popCloseTab: TMenuItem;
    popCloseAllTabs: TMenuItem;
    N13: TMenuItem;
    popForceAvsPWnd: TMenuItem;
    TaskDlg: TTaskDialog;
    popShowPreview: TMenuItem;
    popThemes: TMenuItem;
    N14: TMenuItem;
    popStyle_0: TMenuItem;
    N15: TMenuItem;
    popBackgroundColor: TMenuItem;
    ColorDialog: TColorDialog;
    popCloseOtherTabs: TMenuItem;
    popSendTab: TMenuItem;
    N16: TMenuItem;
    popRunAvsPAllTabs: TMenuItem;
    popClipsToClip: TMenuItem;
    popSaveGroup: TMenuItem;
    N17: TMenuItem;
    popGroupMenu: TMenuItem;
    popOpenGroupsFolder: TMenuItem;
    popTabSaveGroup: TMenuItem;
    popCloseNextTabs: TMenuItem;
    popAddTabToGroup: TMenuItem;
    paMem: TPanel;
    popSplitClip: TMenuItem;
    popJoinClipParts: TMenuItem;
    popAutoSplitClip: TMenuItem;
    popClipExtraMenu: TMenuItem;
    popSaveCurrentSplits: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    popSplitMergeNext: TMenuItem;
    popSplitMergePrev: TMenuItem;
    N20: TMenuItem;
    popSortClipParts: TMenuItem;
    popHideClipMenu: TMenuItem;
    procedure LVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure LVData(Sender: TObject; Item: TListItem);
    procedure LVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure LVResize(Sender: TObject);
    procedure LVDataStateChange(Sender: TObject; StartIndex, EndIndex: Integer;
      OldState, NewState: TItemStates);
    procedure popOpenClick(Sender: TObject);
    procedure popZ50Click(Sender: TObject);
    procedure popSaveToStreamClick(Sender: TObject);
    procedure popLoadFromStreamClick(Sender: TObject);
    procedure SaveDefaultPos1Click(Sender: TObject);
    procedure popResetDefaultPosClick(Sender: TObject);
    procedure popDefThumbWidthClick(Sender: TObject);
    procedure popSaveImagesClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure popReOpen240Click(Sender: TObject);
    procedure popReOpenCustomSizeClick(Sender: TObject);
    procedure popRunAvsPClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure LVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure LVStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure LVEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure popClearFavoritesClick(Sender: TObject);
    procedure popSaveFavoritesClick(Sender: TObject);
    procedure popTitleAddFavorClick(Sender: TObject);
    procedure popBackupFavorClick(Sender: TObject);
    procedure popRestoreFavorClick(Sender: TObject);
    procedure popSortFavoritesClick(Sender: TObject);
    procedure popUpdateBookmarksClick(Sender: TObject);
    procedure LVDblClick(Sender: TObject);
    procedure popSaveBookmarksClick(Sender: TObject);
    procedure JPEGQuality1Click(Sender: TObject);
    procedure popZ100FitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure popOpenLastSavedStreamClick(Sender: TObject);
    procedure popClearBasketClick(Sender: TObject);
    procedure LVMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LVMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure popClearFileHistoryClick(Sender: TObject);
    procedure popMaxHistoryCountClick(Sender: TObject);
    procedure popMoveFrameNrClick(Sender: TObject);
    procedure TabViewChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure popCloseTabClick(Sender: TObject);
    procedure TabViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure popCloseAllTabsClick(Sender: TObject);
    procedure TabViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure popStyle_0Click(Sender: TObject);
    procedure TabViewDrawTab(Sender: TObject; TabCanvas: TCanvas; R: TRect;
      Index: Integer; Selected: Boolean);
    procedure popBackgroundColorClick(Sender: TObject);
    procedure popCloseOtherTabsClick(Sender: TObject);
    procedure PopUpTabPopup(Sender: TObject);
    procedure popRunAvsPAllTabsClick(Sender: TObject);
    procedure popClipsToClipClick(Sender: TObject);
    procedure TabViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TabViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure popSaveGroupClick(Sender: TObject);
    procedure popOpenGroupsFolderClick(Sender: TObject);
    procedure popExtraMenuClick(Sender: TObject);
    procedure popCloseNextTabsClick(Sender: TObject);
    procedure popSplitClipClick(Sender: TObject);
    procedure popJoinClipPartsClick(Sender: TObject);
    procedure popAutoSplitClipClick(Sender: TObject);
    procedure popClipExtraMenuClick(Sender: TObject);
    procedure popSaveCurrentSplitsClick(Sender: TObject);
    procedure popSplitMergeNextClick(Sender: TObject);
    procedure popSplitMergePrevClick(Sender: TObject);
    procedure popSortClipPartsClick(Sender: TObject);
    procedure popHideClipMenuClick(Sender: TObject);
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure AppOnMessages(var Msg: TMsg; var Handled: Boolean);
  private
    Fbmp: TBitmap;
    FZoom: Single;
    FTaskCount: Integer;
    LV_LastPreviewIndex: Integer;
    FDefStyle: String;
    SItemIndex: Integer;
    DummyImL: THandle;
    FStop: boolean;
    FLVMouseDown: TPoint;
    FInProgress: boolean;
    FMaxHistoryCount: Integer;
    DefaultThumbWidth: Integer;
    FDefLeft, FDefWidth: Integer;
    FJPEGQuality: Integer;
    FHide_SB_HORZ : Boolean;
    FListViewWndProc: TWndMethod;
    FHistoryList: TStringList;
    FEnumWndFindFile: String;
    //- if true script can mix 1920 16/9 clips with 1440 4/3 clips, force Assume FPS and kill audio
    FClipsToClipTweak: boolean;
    //- max bookmark count 1000, new AvsP 2.6.1.1r2 1500, change in ini Tweaks
    FMaxBmCount: Integer;
    procedure ListView_SetWidth;
    procedure Clear;
    function AddFavorList(Source, Targed : TList; Index: Integer): Integer;
    procedure SaveFavoritesToStream();
    procedure AddLastSavedStream(const filename: String);
    procedure AddGroups(SL: TStringList); overload;
    procedure AddGroups(); overload;
    procedure OpenGroup(Sender: TObject);
    procedure AddTabToGroup(Sender: TObject);
    procedure ListViewWndProc(var Msg: TMessage);
    procedure OnCommand(Sender: TObject);
    procedure BlockInput;
    procedure UnblockInput;
    procedure SendClipToAvsWnd(Sender: TObject);
    procedure TabView_SetTabText(const idx: Integer = -1);
    //~procedure WaitProc(Proc: TProc; const Priority: TThreadPriority = tpNormal);
    //~procedure AppOnIdle(Sender: TObject; var Done: boolean);

  public
    CurrentClip: TClip;
    AvsGrabber : TAvisynthGrabber;
    ActiveList: TList;
    BackFavorList: TStringList;
    fRunProg: String;
    function SendCopyData(const WND: HWND; const s: String; const id: Integer; const timeout: Integer): Integer;
    function NewClip(const FileName: String=''): TClip;
    function GetClip(const idx: Integer): TClip;
    function GetCurrentClip: TClip;
    function GetClipFromAddr(const int: Integer): TClip;
    function TabView_IndexOfClip(Clip: TClip): Integer; inline;
    function TabView_IndexOfFrameList(FrameList: TList; const FindFrameNr: Integer =-1): TClipIdx; inline;
    procedure TabView_SetTabIndex(const idx: Integer);
    procedure TabView_SplitSort(Source: TClip);
    procedure FavorLists_Clear(const Clip: TClip=nil);
    function LoadBookmarksFromFile(const fileName: String; FrList,FavList: TList): Integer;
    procedure GetBookmarksThumbs(const fileName: String);
    procedure SetZoom;
    procedure OpenBookFile(const fileName : String = ''; const AddNewClip: boolean=True);
    function SaveToStream(const fileName : String): boolean;
    function LoadFromStream(const fileName : String; const AddNewClip: boolean=True): Integer;
    procedure ProzessParamStr(const fFile, fParam1 :  String);
    procedure UpdateBookmarks(const BookFile, avsFile: String);
    function UpdateStream(const direct: boolean): Integer;
    function FindAvsWnd(const timeout: Integer=0): boolean;
    function FindVDubWnd(const force: boolean=false): boolean;
    procedure MoveFrameNr(idxStart, idxEnd, Amount: Integer; direct: boolean);
    procedure CloseTabs(tabs: array of Integer; const CanCloseSplitPart: boolean=False);
    procedure ShowAvsWnd;
    procedure SetCaption(const str: String='');
    procedure LV_MakeItemVisible(const idx: Integer; const DoSelect: boolean = True;
      const AddToTop: boolean = False);
    procedure LV_StyleBugFix;
    procedure LV_SaveOrigin;
    procedure ClipsToClip(const SaveName: String);
    function Clip_IndexOfFrameNr(Clip: TClip; const Nr: Integer): Integer; inline;
    procedure Clip_FillFavorLists(Clip: TClip; const CheckTabSet: boolean); inline;

    //- Split Clips
    procedure SplitClip(idxList: Array of Integer; const MakeItemVisible: Integer=0);
    procedure SplitMove(Source: TClip; idx: Integer; prev: boolean);
    function GetSplitFirstClip(Clip: TClip): TClip; inline;
    function IsSplitClip(Clip: TClip): boolean; inline;
    procedure SplitUpdateWnd(Source: TClip); inline;
    function SplitFindFrameNr(Source: TClip; const Nr: Integer): TClipIdx; inline;
    procedure SplitsSetCaption(Source: TClip);
    //-
    //~function Clips_IndexOfAvsWnd(const hWnd : THandle): Integer;
  end;

  {
  pAddOn = ^TAddOn;
  TAddOn = record
    _Start : Integer;
    _Size : Integer;
    _Name : String;
    //_Data : TMemoryStream;
  end;

  TAddOnRec = record
    Start : Integer;
    Count : Byte;
    AddOn : Array of pAddOn;
  end;
  }

const
  HeaderFlag: Integer = 1001002;
  Header2Flag: Integer = 2001002;
  AddOnFlag: Integer = 3043043;
  AVSP_INFORM = 32770;
  AVSP_SET_FRAME_NR = 32771;
  AVSP_SCROLL_STEP = 32772;
  AVSP_SCROLL = 32773;
  AVSP_VIDEO_SIZE = 32800;
  AVSP_VIDEO_WND_SIZE = 32801;
  AVSP_VIRTUAL_SIZE = 32802;
  AVSP_GET_FRAME_NR = 32803;
  AVSP_CLIP_RETURN = 33000;

{$IFDEF WIN32}
  {$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
const
  fext = '.bk3';
  myName = 'AvsPThumb x32';
{$else}
const
  fext = '.bk6';
  myName = 'AvsPThumb x64';
{$endif}

var
  Form1: TForm1;

implementation
uses StretchF, FileUtils, Math, GPoUtils, System.Generics.Collections,
     System.Generics.Defaults, System.StrUtils;

{$R *.dfm}

const
  bookErr = 'Bookmark not found';
  wndErr  = 'AvsP Wnd not found';
  //- file extension for group files
  GroupExt = '.grp.txt';

var
  VDubWnd: THandle = 0;
  double_click: boolean = False;
  //AddOnRec: TAddOnRec;
  rect_down: TRect;

function SortListFunc_Bookmarks(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:= CompareValue(StrToInt(List.KeyNames[Index1]), StrToInt(List.KeyNames[Index2]));
end;

function GetFreeMem(): Int64;
var
  memStatus : TMemoryStatus;
begin
  memStatus.dwLength:= SizeOf(memStatus);
  GlobalMemoryStatus( memStatus );
  Result:= memStatus.dwAvailPhys;

  {
  with Memo1.Lines, GlobalMemoryStatus do
  begin
    Add( 'Length: ' + IntToStr(dwLength) );
    Add( 'MemoryLoad: ' + IntToStr(dwMemoryLoad) );
    Add( 'TotalPhys: ' + IntToStr(dwTotalPhys) );
    Add( 'AvailPhys: ' + IntToStr(dwAvailPhys) );
    Add( 'TotalPageFile: ' + IntToStr(dwTotalPageFile) );
    Add( 'AvailPageFile: ' + IntToStr(dwAvailPageFile) );
    Add( 'TotalVirtual: ' + IntToStr(dwTotalVirtual) );
    Add( 'AvailVirtual: ' + IntToStr(dwAvailVirtual) );
  end;
  }
end;

constructor TBookStream.Create(const FileName: string);
begin
  RefCount:= 0;
  inherited Create(FileName, fmOpenReadWrite);
  RefCount:= 1;
end;

//******************************************************************************
//- Clip
//******************************************************************************

constructor TClip.Create;
begin
  inherited Create;
  FrameList:= TList.Create;
  FavorList:= TList.Create;
  Favor2List:= TList.Create;
  FileStream:= nil;
  StoredStream:= nil;
  NextPart:= nil;
  PrevPart:= nil;
  LastFile:= '';
  LastOpen:= '';
  NeedSave:= false;
  LastIndexLV:= -1;
  LastIndexFV:= -1;
  LastIndexFV2:= -1;
  LV_PreveusIndex:= -1;
  TabSet_LastIndex:= 0;
  AvsWnd:= 0;
  AvsP_video_w:= -1;
  AvsP_video_h:= -1;
  AvsP_vid_wnd_w:= -1;
  AvsP_vid_wnd_h:= -1;
end;

destructor TClip.Destroy;
var
  i: Integer;
  P: PFrameRec;
begin
  If Assigned(FileStream) then
    FileStream.Free;
  If Assigned(StoredStream) then
    StoredStream.Free;
  For i:= 0 to FrameList.Count-1 do
  begin
    P:= PFrameRec(FrameList[i]);
    P^.bmp.Free;
    Dispose(P);
  end;
  FrameList.Free;
  FavorList.Free;
  Favor2List.Free;
  inherited Destroy;
end;

function TForm1.NewClip(const FileName: String=''): TClip;
var
  Clip: TClip;
  s: String;
begin
  TabView.OnChange:= nil;
  TabSet.OnChange:= nil;
  LV_SaveOrigin;  //- Save the CurrentClip LV view origin
  Clip:= TClip.Create;
  Try
    If TabView.Tabs.Count < 9 then
      s:=  ' ' + IntToStr(TabView.Tabs.Count+1) + ' '
    else s:= IntToStr(TabView.Tabs.Count+1);
    TabView.Tabs.AddObject(s,Pointer(Clip));
    TabView.TabIndex:= TabView.Tabs.Count-1;
    Clip.LastFile:= FileName;
    CurrentClip:= Clip;
    ActiveList:= Clip.FrameList;
    LV.Items.BeginUpdate;
    LV.Items.Count:= 0;
    LV.Items.EndUpdate;
    LV_StyleBugFix;
    TabSet.TabIndex:= 0;
  Finally
    Result:= Clip;
    TabView.OnChange:= TabViewChange;
    TabSet.OnChange:= TabSetChange;
  End;
end;

function TForm1.GetClip(const idx: Integer): TClip;
begin
  Result:= TClip(Integer(TabView.Tabs.Objects[idx]));
end;

function TForm1.GetCurrentClip: TClip;
begin
  CurrentClip:= TClip(Integer(TabView.Tabs.Objects[TabView.TabIndex]));
  Result:= CurrentClip;
end;

function TForm1.GetClipFromAddr(const int: Integer): TClip;
var
  i: Integer;
begin
   For i:= 0 to TabView.Tabs.Count -1 do
   begin
     If Integer(TabView.Tabs.Objects[i]) = int then
     begin
       Result:= GetClip(i);
       exit;
     end;
   end;
   Result:= nil;
end;

{
function TForm1.Clips_IndexOfAvsWnd(const hWnd : THandle): Integer;
var
  i: Integer;
begin
  For i:= 0 to TabView.Tabs.Count - 1 do
    if GetClip(i).AvsWnd = hWnd then
    begin
      Result:= i;
      exit;
    end;
  Result:= -1;
end;
}

//******************************************************************************
//- Helper func
//******************************************************************************

function GetBit(var i: Integer; Bit: Byte): Boolean;  inline;
begin
  if (i = 1) and (Bit = 1) then
  begin  // Hack for older Version
    i:= 1 shl Bit;
    Result:= True
  end
  else
    Result:= i and (1 shl Bit) > 0;
end;

procedure SetBit(var i: Integer; Bit: Byte; Add: boolean); inline;
begin
  if Bit = 0 then
    i:= 0
  else if Add then
    i:= i or (1 shl Bit)
  else
    i:= 1 shl Bit;
end;

procedure RemoveBit(var i: Integer; Bit: Byte);  inline;
begin
  i:= i and (not (1 shl Bit));
end;

function IsBookmarkExt(const filename: String): boolean;
var
  i: Integer;
begin
  Result:= false;
  i:= Length(filename);
  If i < 7 then
    exit;

  Result:= SameText(Copy(filename, i-6, 7), '.cr.txt');
end;

function MakeAVSExt(const s : String): String;
var
  e: String;
begin
  if SameText(ExtractFileExt(s), '.avs') then
    Result:= s
  else if SameText(ExtractFileExt(s), fext) then  //- .bk6, .bk3
  begin
    Result:= ChangeFileExt(s, '.avs');
    If not FileExists(Result) then
    begin
      e:= RemoveFileExt(s);
      If (Length(e) > 2) and (StrGetDigit(e, Length(e)) <> '') and (e[Length(e)-1] = '_') then
        Result:= Copy(e, 1, Length(e)-2) + '.avs';
    end;
  end
  else if IsBookmarkExt(s) then  //- .cr.txt
    Result:= ChangeFileExt(ChangeFileExt(s, ''), '.avs')
  else Result:= s + '.avs';
end;

function SortListFunc_FrameNr(p1,p2: Pointer): Integer;  inline;
begin
  Result:= CompareValue(PFrameRec(p1)^.FrameNr, PFrameRec(p2)^.FrameNr);
end;

function List_IndexOfFrameNr(List: TList; Nr: Integer): Integer; inline;
var
  i: Integer;
begin
  For i:= 0 to List.Count-1 do
    if PFrameRec(List[i])^.FrameNr = Nr then
    begin
      Result:= i;
      exit;
    end;
  Result:= -1;
end;

{$J+}
//- not used
function IsWow64Process: Boolean;
type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: Boolean): Boolean; stdcall;
var
  DLL: THandle;
  pIsWow64Process: TIsWow64Process;
const
  Called: Boolean = False;
  IsWow64: Boolean = False;
begin
  if (Not Called) then //- only check once
  begin
    DLL := LoadLibrary('kernel32.dll');
    if (DLL <> 0) then
    begin
      pIsWow64Process := GetProcAddress(DLL, 'IsWow64Process');
      if (Assigned(pIsWow64Process)) then
      begin
        pIsWow64Process(GetCurrentProcess, IsWow64);
      end;
      Called := True; //- avoid unnecessary loadlibrary
      FreeLibrary(DLL);
    end;
  end;
  Result := IsWow64;
end;
{$J-}

function enumWindows(H: HWND; L : LPARAM): boolean; stdcall;
var
  r: TRect;
  s: String;
  Clip: TClip;
begin
  If isWindow(H) and IsWindowVisible(H) and GetWindowRect(H, r) then
  begin
    SetLength(s,512);
    SetLength(s, GetWindowText(H, @s[1], 512));

    //- Send to all AvsP a message to find the filename in tabs
    If Pos(' - AvsPmod', s) > 0 then
    begin
      Clip:= Form1.CurrentClip;
      If L > 0 then  //- force all AvsPmod to find the tab
      begin
        Clip.AvsWnd:= 0; //- at first
        Form1.SendCopyData(H, Form1.FEnumWndFindFile, Integer(Clip), L);
        sleep(40); //- wait short time for AvsPmod returned value
        Application.ProcessMessages; //- process messages from AvsP
        Result:= Clip.AvsWnd = 0;    //- break if tab found > 0 = False then break
      end
      else begin
        Clip.AvsWnd:= H;
        Result:= False; //- if not force then break if a AvsP WND found
      end;
    end
    {else if (L = 1) and (Pos('VirtualDub2', s) > 0) then
    begin
      Result:= false;
      VDubWnd:= H;
    end}
    else Result:= true;
  end
  else Result:= True;
end;

//- Grab sub menu for a Window (by handle), given by (0 based) indices in menu hierarchy
function GetASubmenu(const hW: HWND; const MenuInts: array of Integer): HMENU;
var
  hSubMenu: HMENU;
  I: Integer;
begin
  Result := 0;
  if (Length(MenuInts) = 0) then
    Exit;

  hSubMenu := GetMenu(hW);
  if not IsMenu(hSubMenu) then
    Exit;

  for I in MenuInts do
  begin
    Assert(I < GetMenuItemCount(hSubMenu), format('GetASubmenu: tried %d out of %d items',[I, GetMenuItemCount(hSubMenu)]));
    hSubMenu := GetSubMenu(hSubMenu, I);
    if not IsMenu(hSubMenu) then
      Exit;
  end;

  Result := hSubMenu;
end;

//- Get the caption for MenuItem ID
function GetMenuItemCaption(const hSubMenu: HMENU; const Id: Integer): string;
var
  MenuItemInfo: TMenuItemInfo;
begin
  MenuItemInfo.cbSize := SizeOf(TMenuItemInfo);
  MenuItemInfo.fMask := MIIM_STRING;
  //- get the menu caption, 1023 chars should be enough
  SetLength(Result, 1023 + 1);
  MenuItemInfo.dwTypeData := PChar(Result);
  MenuItemInfo.cch := Length(Result)-1;
  if not GetMenuItemInfo(hSubMenu, Id, False, MenuItemInfo) then
    RaiseLastOSError;
  SetLength(Result, MenuItemInfo.cch);
end;

function SendCommand(const WND: HWND; const command: String): Boolean;
var
  hSubMenu: HMENU;
  id,id2 : UInt64;
  i: Integer;
  //~count: Integer;
  dCommand: String;

  function GetDigit(const s: String):String;
  const
    digit = ['0'..'9'];
  var i: Integer;
  begin
    Result:= '';
    If s <> '' then
      for i:= 1 to Length(s) do
        if CharInSet(s[i], digit) then
          Result:= Result + s[i]
        else if (Result <> '') then  //- break at first "no digit"
          break
  end;

begin
  Result:= False;
  If WND <= 0 then
    exit;
  hSubMenu := GetASubmenu(WND, [2]); //- 'Video'

  if hSubMenu > 0 then
  begin
    id := GetSubmenu(hSubMenu, 3); //- 'Navigate' in new AvsPmod = 3
    if id > 0 then
    begin
      id := GetSubmenu(id, 0);  //- Menu 'Goto Bookmark'
      if id > 0 then
      begin
         i := 0;
         dCommand:= GetDigit(command); //- remove title
         Try
           //~count:= GetMenuItemCount(id)-1;
           id2 := GetMenuItemID(id, 0);

           //~while (id2 > 0) and (i < count) do   // dann kein beep bei nicht finden
           while (id2 > 0) do
           begin
              // title ignorieren und nur FrameNr verwenden
              if GetDigit(GetMenuItemCaption(hSubMenu, id2)) = dCommand then
              begin
                 Result:= true;
                 PostMessage(WND, WM_COMMAND, id2, 0);
                 exit;
              end;
             inc(i);
             id2 := GetMenuItemID(id, i);
           end;
         Except
           beep;
           exit;
           //~RaiseLastOSError;
         End;

         //ShowMessage('Done: ' + GetMenuItemCaption(hSubMenu, id));

       end
    end
    else
      beep; //RaiseLastOSError;
  end
  else
    beep; //RaiseLastOSError;
end;


//- Menustruct: 3,4 = 4.Menü + suche im 5. Untermenü nach command
//- Menüstruct: 2 = 3.Menü + suche in diesem Menü nach command
function SendCommand_ext(const WND: HWND; MenuStruct: String; const command: String): boolean;
var
  hSubMenu: HMENU;
  id: int64;
  i: Integer;
  ar: TArray<String>;
  Count: Integer;
  s: String;

  //* shortcut ignorieren
  function GetMenuCaption(const s: String):String;
  var i: Integer;
  const
    Valid = ['A'..'Z', '0'..'9', '-', '_', ' ','Ä','Ü','Ö', '(', ')', '[',']'];
    //~notValid = ['§','$','|','#','`','>','<','&','''','/','^'];
  begin
    Result:= UpperCase(trim(s));
    If Result = '' then
      exit;
    For i:= 1 to Length(Result) do
      if not CharInSet(Result[i],Valid) then
      begin
        Result:= TrimRight(copy(s, 1, i-1));
        exit;
      end;
  end;

begin
  Result:= False;
  //-  Find first the submenu
  Try
    If Pos(',', MenuStruct) > -1 then
    begin
      ar:= MenuStruct.Split([',']);
      hSubMenu:= GetASubmenu(WND, StrToInt(Trim(ar[0])));
      for i:= 1 to High(ar) do
      begin
        id:= GetSubmenu(hSubMenu, StrToInt(Trim(ar[i])));
        If id < 1 then
        begin
          If IsWindow(WND) then
            MessageDlg('Submenu ' + ar[i] + ' not found.',mtError,[mbOK],0)
          else beep;
          exit;
        end;
        hSubMenu:= id;
      end;
    end
    else
      hSubMenu:= GetASubmenu(WND, StrToInt(MenuStruct));
  except
    If IsWindow(WND) then
      MessageDlg('Error to find Submenu.',mtError,[mbOK],0)
    else beep;
    exit;
  end;

  //- We are now in the right branch and looking for the menu caption
  If hSubMenu > 0 then
  begin
    Try
      Count:= GetMenuItemCount(hSubMenu);
      For i:= 0 to Count-1 do
      begin
        if GetSubmenu(hSubMenu, i) > 0 then  //- skip all submenus
          Continue;
        id:= GetMenuItemID(hSubMenu, i);
        if id <= 0 then                     //- skip if ?
          Continue;
        //ShowMessage('Found: ' + GetMenuCaption(GetMenuItemCaption(hSubMenu, id)));
        s:= GetMenuCaption(GetMenuItemCaption(hSubMenu, id));

        if s = '' then   //- skip empty menus
          Continue;
        if SameText(Copy(s,1,Length(command)), command) then
        begin
          Result:= True;
          PostMessage(WND, WM_COMMAND, id, 0);
          break;
        end;
      end;
      if not Result then
        beep;
    except
      beep;
      //~RaiseLastOSError;
    end;
  end
  else
    RaiseLastOSError;
end;

//******************************************************************************
//- Main
//******************************************************************************

procedure TForm1.BlockInput;
begin
  LV.Enabled:= false;
  TabView.Enabled:= false;
  TabSet.Enabled:= False;
  FInProgress:= True;
end;

procedure TForm1.UnblockInput;
begin
  LV.Enabled:= True;
  TabView.Enabled:= True;
  TabSet.Enabled:= True;
  FInProgress:= False;
end;

procedure TForm1.TabView_SetTabText(const idx: Integer = -1);
var
  i: Integer;
begin
  If idx < 0 then
    For i:= 0 to TabView.Tabs.Count-1 do
      If GetClip(i).AvsWnd > 0 then
      begin
        if i < 9 then TabView.Tabs[i]:= ' ' + IntToStr(i+1) + '.'
        else TabView.Tabs[i]:= IntToStr(i+1) + '.';
      end
      else begin
        if i < 9 then TabView.Tabs[i]:= ' ' + IntToStr(i+1) + ' '
        else TabView.Tabs[i]:= IntToStr(i+1);
      end
  else begin
    If idx >= TabView.Tabs.Count then
      exit;
    If GetClip(idx).AvsWnd > 0 then
      if idx < 9 then TabView.Tabs[idx]:= ' ' + IntToStr(idx+1) + '.'
      else TabView.Tabs[idx]:= IntToStr(idx+1) + '.'
    else
      if idx < 9 then TabView.Tabs[idx]:= ' ' + IntToStr(idx+1) + ' '
      else TabView.Tabs[idx]:= IntToStr(idx+1);
  end;
end;

function TForm1.TabView_IndexOfClip(Clip: TClip): Integer;
begin
  Result:= TabView.Tabs.IndexOfObject(Clip);
end;

function TForm1.FindAvsWnd(const timeout: Integer=0): boolean;
var
  s: String;
begin
  If (CurrentClip.AvsWnd = 0) or not isWindow(CurrentClip.AvsWnd) or (timeout > 0) then
  begin
    CurrentClip.AvsWnd:= 0;
    s:= MakeAVSExt(CurrentClip.LastOpen);
    s:= s + ' - AvsPmod';
    CurrentClip.AvsWnd:= FindWindow('wxWindowClassNR', PWideChar(s));
    if CurrentClip.AvsWnd = 0 then
    begin
      FEnumWndFindFile:= ExtractFileNameNoExt(s);
      EnumDesktopWindows(0,@enumWindows,timeout);
    end;
  end;

  Result:= CurrentClip.AvsWnd <> 0;
  TabView_SetTabText(TabView_IndexOfClip(CurrentClip));
end;

procedure TForm1.TabView_SetTabIndex(const idx: Integer);
var
  b: boolean;
begin
  If (TabView.TabIndex = idx) or (idx < 0) or (idx >= TabView.Tabs.Count)  then
    TabViewChange(Self, TabView.TabIndex, b)
  else TabView.TabIndex:= idx;
end;

//- test only
function TForm1.FindVDubWnd(const force: boolean=false): boolean;
var
  s: String;
begin
  If (VDubWnd = 0) or not isWindow(VDubWnd) or force then
  begin
    VDubWnd:= 0;
    s:= MakeAVSExt(CurrentClip.LastOpen);
    s:= 'VirtualDub2 - [' + s + ']';
    VDubWnd:= FindWindow('VirtualDub', PWideChar(s));
    if (VDubWnd = 0) and Assigned(CurrentClip.FileStream) then
    begin
      s:= RemoveFileExt(CurrentClip.LastOpen);        // find num 'FileName.avs_2.bk3'
      If (Length(s) > 2) and (StrGetDigit(s, Length(s)) <> '') and (s[Length(s)-1] = '_') then
      begin
        s:= Copy(s, 1, Length(s)-2)+ '.avs';
        VDubWnd:= FindWindow('VirtualDub', PWideChar(s));
      end;
    end;
    if VDubWnd = 0 then
      EnumDesktopWindows(0,@enumWindows,1);
  end;
  Result:= VDubWnd <> 0;
end;

procedure TForm1.WndProc(var Message: TMessage);
var
  Handled: Boolean;
  i: Integer;
  Clip: TClip;
  clipIdx: TClipIdx;
begin
  Handled:= false;
  //inherited;
{  Case Message.Msg of
    WM_SYSCOMMAND:
      begin
        Case Message.WParam of  // Reagiert nur bei Titelleiste Buttons
          SC_MINIMIZE:          // WM_SIZE/SIZE_RESTORED wird zu oft über Application aufgerufen
            begin

            end;
          SC_MAXIMIZE,SC_RESTORE:
            begin

            end;
          WM_ACTIVATEAPP:
            If Bool(Message.WParam)then // nur beim Aktivieren
            begin

            end;
        end;
      end;
  end;
}

  Case Message.Msg of
    WM_Size:
      begin
        Case Message.WParam of
          SIZE_MAXIMIZED:
            begin
              inherited;
              Handled:= True;
              LV_MakeItemVisible(-1);
            end;
          SIZE_RESTORED:
            if (LV.Items.Count > 0) and (FTaskCount < 1) then
            begin
              inherited;
              Handled:= True;
              Try
                If popZFit.Tag = 0 then
                begin
                  FZoom:= ((LV.ClientWidth-GetSystemMetrics(SM_CYVSCROLL)+11)/CurrentClip.ThumbWidth)*100;
                  SetZoom;
                end;
                LV_MakeItemVisible(-1);
              except
              End;
            end;
        End;
      end;

    WM_MOUSEWHEEL:
      begin
        If FInProgress then
          exit;
        if LoWord(Message.WParam)= MK_CONTROL then
        begin
          Handled:= True;
          if CurrentClip.AvsP_video_w <= 0 then
            exit;
          if HiWord(Message.WParam) > 120 then
            i:= -2
          else
            i := -1;
          PostMessage(CurrentClip.AvsWnd, AVSP_SET_FRAME_NR, 0, i);
          if Assigned(LV.Selected) then    //- cancel mouse down/up event
            LV.Selected:= nil;
        end;
      end;

    AVSP_VIDEO_SIZE:
      with CurrentClip do begin
        AvsP_video_w := Message.WParam;
        AvsP_video_h := Message.LParam;
        Handled:= True;
        SplitUpdateWnd(CurrentClip);
      end;

    AVSP_VIDEO_WND_SIZE:
      with CurrentClip do begin
        AvsP_vid_wnd_w := Message.WParam;
        AvsP_vid_wnd_h := Message.LParam;
        Handled:= True
      end;

    AVSP_GET_FRAME_NR:
      begin
        Handled:= True;
        Try
          if Message.LParam > 0 then //- FrameCount
          begin
            clipIdx:= TabView_IndexOfFrameList(ActiveList, Integer(Message.WParam));
            If Assigned(clipIdx.Clip) then
            begin
              If (clipIdx.FrameIdx < 0) and IsSplitClip(clipIdx.Clip) then
              begin
                clipIdx:= SplitFindFrameNr(clipIdx.Clip, Integer(Message.WParam));
                If clipIdx.FrameIdx < 0 then
                  exit;
              end
              else if clipIdx.FrameIdx < 0 then
                exit;

              TabView.TabIndex:= clipIdx.TabViewIdx;
              TabSet.TabIndex:= clipIdx.TabSetIdx;
              LV_MakeItemVisible(clipIdx.FrameIdx, True);
            end;
          end;
        except
          exit;
        end;
      end;

    AVSP_CLIP_RETURN:  //- If the tab of the filename found, (FindAvsWND with timeout > 0)
      begin            //- AvsP return his Wnd and the Addr of the Clip that has send the request
        Handled:= True;
        Try
          Clip:= GetClipFromAddr(Message.WParam);
          If Assigned(Clip) then
          begin
            Clip.AvsWnd:= Message.LParam;
            SplitUpdateWnd(Clip);
            //PostMessage(Clip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_SIZE);
            //PostMessage(Clip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_WND_SIZE);
          end;
        except
          //
        End;
      end;
  End;

  If not Handled then inherited;
end;

function TForm1.TabView_IndexOfFrameList(FrameList: TList; const FindFrameNr: Integer): TClipIdx;
var
  i, idx: Integer;
  Clip: TClip;
begin
  ZeroMemory(@Result,SizeOf(Result));
  For i:= 0 to TabView.Tabs.Count -1 do
  begin
    Clip:= GetClip(i);
    idx:= -1;
    if Clip.FrameList = FrameList then
      idx:= 0
    else if Clip.FavorList = FrameList then
      idx:= 1
    else if Clip.Favor2List = FrameList then
      idx:= 2;

    If idx > -1 then
    begin
      Result.Clip:= Clip;
      Result.TabViewIdx:= i;
      Result.TabSetIdx:= idx;
      Case idx of
        1: Result.ActiveList:= Clip.FavorList;
        2: Result.ActiveList:= Clip.Favor2List;
        else Result.ActiveList:= Clip.FrameList;
      end;
      Result.FrameIdx:= -1;
      If FindFrameNr > -1 then
        For idx:= 0 to Result.ActiveList.Count -1 do
          if pFrameRec(Result.ActiveList[idx])^.FrameNr = FindFrameNr then
          begin
            Result.FrameIdx:= idx;
            break;
          end;
      exit;
    end;
  end;
end;

function TForm1.Clip_IndexOfFrameNr(Clip: TClip; const Nr: Integer): Integer;
var
  i: Integer;
begin
  For i:= 0 to Clip.FrameList.Count -1 do
    if PFrameRec(Clip.FrameList[i])^.FrameNr = Nr then
    begin
      Result:= i;
      exit;
    end;
  Result:= -1;
end;

procedure TForm1.Clip_FillFavorLists(Clip: TClip; const CheckTabSet: boolean);
var
  i: Integer;
  P: PFrameRec;
begin
  Clip.FavorList.Clear;
  Clip.Favor2List.Clear;
  For i:= 0 to Clip.FrameList.Count -1 do
  begin
    P:= PFrameRec(Clip.FrameList[i]);
    If GetBit(P^.BitInt, 1) then
      Clip.FavorList.Add(P);
    If GetBit(P^.BitInt, 2) then
      Clip.Favor2List.Add(P);
  end;

  If CheckTabSet then
  begin
    i:= TabSet.Tabs.IndexOf('Basket');
    If Clip.Favor2List.Count > 0 then
      if i < 0 then TabSet.Tabs.Add('Basket')
    else if i > -1 then
      TabSet.Tabs.Delete(i);
  end;
end;

//- Point(TabView Index, FrameList Index)
function TForm1.SplitFindFrameNr(Source: TClip; const Nr: Integer): TClipIdx;
var
  Clip: TClip;
  i: Integer;
begin
  ZeroMemory(@Result,SizeOf(Result));
  Clip:= GetSplitFirstClip(Source);
  While Assigned(Clip) do
  begin
    If PFrameRec(Clip.FrameList[Clip.FrameList.Count-1]).FrameNr >= Nr then
    begin
      i:= Clip_IndexOfFrameNr(Clip,Nr);
      If i < 0 then
        exit;
      Result.FrameIdx:= i;
      Result.Clip:= Clip;
      Result.ActiveList:= Clip.FrameList;
      Result.TabViewIdx:= TabView_IndexOfClip(Clip);
      Result.TabSetIdx:= 0;
      exit;
    end;
    Clip:= Clip.NextPart;
  end;
end;

procedure TForm1.ListViewWndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_NCCALCSIZE) then
    ShowScrollBar(LV.Handle, SB_HORZ, false);

  FListViewWndProc(Msg); // process message
end;

{procedure TForm1.ListViewWndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_NCCALCSIZE) then
  begin
    if getWindowLong(LV.handle, GWL_STYLE ) and SB_HORZ <> 0 then
      ShowScrollBar(LV.Handle, SB_HORZ, false);
  end;
  FListViewWndProc(Msg); // process message
end;}

procedure TForm1.AppOnMessages(var Msg: TMsg; var Handled: Boolean);
begin
  Handled:= false;
  If FInProgress then
    exit;

  Try
    if Msg.message = WM_KEYUP then
    begin
      Case Msg.wParam of
        107: if popZFit.Tag > -1 then
        begin
          Handled:= true;
          FZoom:= FZoom + 10;
          //~inc(FZoom, 10);
          If FZoom > 500 then
            FZoom:= 500;
          SetZoom();
          if WindowState = wsNormal then
            ListView_SetWidth;
        end;
        109: if popZFit.Tag > -1 then
        begin
          Handled:= true;
          FZoom:= FZoom - 10;
          //~dec(FZoom, 10);
          if FZoom < 10 then
            FZoom:= 10;
          SetZoom();
          if WindowState = wsNormal then
            ListView_SetWidth;
        end;
        112: popZ100Fit.Click;
        113: popResetDefaultPos.Click;
      End;
    end
    else if Msg.message = WM_KEYDOWN then
    begin
      Case Msg.wParam of
        107,109: if popZFit.Tag > -1 then   //ListView gebimmel abschalten
          Handled:= true;
        VK_RETURN:
          if Assigned(LV.Selected) then
          begin
            Handled:= True;
            double_click:= False;
            //~SendCommand(AvsWnd, IntToStr(PFrameRec(ActiveList[LV.Selected.Index])^.FrameNr));
            LVMouseDown(self, mbLeft, [ssLeft], Mouse.CursorPos.X, Mouse.CursorPos.y);
          end;
        {
        vkUp, vkDown, vkLeft, vkRight, vkControl:
        begin

        end
        }
      End;
    end
    else if (Msg.message = WM_MBUTTONDOWN) and (Msg.hwnd = LV.Handle) then
    begin
      Handled:= True;
      FindAvsWnd(800); //- only block the App for a short time
      if CurrentClip.AvsWnd > 0 then
        PostMessage(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_GET_FRAME_NR);
    end
    else if (Msg.message = WM_XBUTTONDOWN) and (Msg.hwnd = LV.Handle) then
    begin
      if (LV.Items.Count > 0) and (CurrentClip.LV_PreveusIndex >= 0) and (CurrentClip.LV_PreveusIndex < LV.Items.Count) then
      begin
        Handled:= True;
        LV_MakeItemVisible(CurrentClip.LV_PreveusIndex, True);
        double_click:= False;
        LVMouseDown(self, mbLeft, [ssLeft], Mouse.CursorPos.X, Mouse.CursorPos.y);
      end;
    end;

  except
    Application.HandleException(Self);
  end;
end;

{
procedure TForm1.AppOnIdle(Sender: TObject; var Done: Boolean);
begin
  //
end;
}

procedure TForm1.SetCaption(const str: String='');
var
  s: String;
begin
  If str <> '' then
  begin
    If Caption <> str then
      Caption:= str;
    exit;
  end;

  If CurrentClip.FrameList.Count < 1 then
    Caption:= myName
  else begin
    if Assigned(CurrentClip.FileStream) then
      s := 'Bookstream - ' + ExtractFileNameNoExt(CurrentClip.LastOpen)
    else s:= ExtractFileNameNoExt(CurrentClip.LastFile);
    Caption:= s + ' (' + IntToStr(CurrentClip.FrameList.Count) + ') ' + IntToStr(CurrentClip.ThumbWidth) +
                  'x' + IntToStr(CurrentClip.ThumbHeight);
  end;
end;

procedure TForm1.LV_StyleBugFix;
begin
  If LV.Enabled then
  begin
    LV.Enabled:= False;
    LV.Enabled:= True;
  end;
end;

//- Bug fix for Delphi Styles
procedure TForm1.LV_MakeItemVisible(const idx: Integer; const DoSelect: boolean;
  const AddToTop: boolean);
begin
  LockWindowUpdate(LV.Handle);
  Try
    If AddToTop then
      LV.Items[LV.Items.Count-1].MakeVisible(False);
    if idx > -1 then
    begin
      If DoSelect then
        LV.Items[idx].Selected:= True;
      LV.Items[idx].MakeVisible(False);
    end
    else
      If Assigned(LV.Selected) then
        LV.Selected.MakeVisible(False);
  finally
    LockWindowUpdate(0);
    LV_StyleBugFix;
    If LV.Enabled then
      LV.SetFocus;
    LV.Invalidate;
  end;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  FStop:= true;
end;

procedure TForm1.FavorLists_Clear(const Clip: TClip);
var
  i : Integer;
begin
  If Assigned(Clip) then
  begin
    Clip.FavorList.Clear;
    Clip.Favor2List.Clear;
  end
  else begin
    CurrentClip.FavorList.Clear;
    CurrentClip.Favor2List.Clear;
  end;

  i:= TabSet.Tabs.IndexOf('Basket');
  If i > -1 then
    TabSet.Tabs.Delete(i);
end;

procedure TForm1.CloseTabs(tabs: array of Integer; const CanCloseSplitPart: boolean);
var
  i, idx: Integer;
  Clip: TClip;
  b: Boolean;
begin
  idx:= TabView.TabIndex;
  TabView.OnChange:= nil;
  LV.ClearSelection;

  if Length(tabs) > 1 then
    TArray.Sort<Integer>(tabs);
  for i:= High(tabs) downto 0 do
  begin
    Clip:= GetClip(tabs[i]);
    If not IsSplitClip(Clip) or CanCloseSplitPart then
    begin
      Clip.Free;
      TabView.Tabs.Delete(tabs[i]);
    end
  end;

  If TabView.Tabs.Count < 1 then
  begin
    TabView.OnChange:= TabViewChange;
    NewClip('');
    Clear();
  end
  else begin
    idx:= Min(idx, TabView.Tabs.Count-1);
    Clip:= GetClip(idx);
    CurrentClip:= Clip;
    TabSet.OnChange:= nil;
    TabView_SetTabText();

    Case Clip.TabSet_LastIndex of
      1: ActiveList:= Clip.FavorList;
      2: ActiveList:= Clip.Favor2List;
      else begin
        ActiveList:= Clip.FrameList;
        Clip.TabSet_LastIndex:= 0;
      end;
    End;

    i:= TabSet.Tabs.IndexOf('Basket');
    If (Clip.Favor2List.Count < 1) and (i > -1) then
      TabSet.Tabs.Delete(i)
    else if (Clip.Favor2List.Count > 0) and (i < 0) then
       TabSet.Tabs.Add('Basket');
    Try
      TabSet.TabIndex:= Clip.TabSet_LastIndex;
    except
      ActiveList:= Clip.FrameList;
      Clip.TabSet_LastIndex:= 0;
    end;

    LV.Items.Count:= ActiveList.Count;

    TabSet.OnChange:= TabSetChange;

    TabView.TabIndex:= idx;
    TabView.OnChange:= TabViewChange;
    TabViewChange(nil, idx, b);
  end;
end;

procedure TForm1.popCloseTabClick(Sender: TObject);
begin
  If not IsSplitClip(CurrentClip) then
    CloseTabs([TabView.TabIndex])
  else beep;
end;

procedure TForm1.popCloseAllTabsClick(Sender: TObject);
var
  a: Array of Integer;
  i: Integer;
begin
  If TabView.Tabs.Count < 2 then
    CloseTabs([0])
  else begin
    SetLength(a, TabView.Tabs.Count);
    For i:= 0 to High(a) do
      a[i]:= i;
    CloseTabs(a, True);
  end;
end;

procedure TForm1.popCloseOtherTabsClick(Sender: TObject);
var
  a: Array of Integer;
  i: Integer;
  CanCloseSplitClip: boolean;
begin
  If TabView.Tabs.Count < 2 then
    exit;

  CanCloseSplitClip:= not IsSplitClip(CurrentClip);

  For i:= 0 to TabView.Tabs.Count -1 do if i <> TabView.TabIndex then
  begin
    If IsSplitClip(GetClip(i)) and not CanCloseSplitClip then
      Continue;
    SetLength(a, Length(a)+1);
    a[High(a)]:= i;
  end;
  If Length(a) > 0 then
    CloseTabs(a, True)
  else beep;
end;

procedure TForm1.popCloseNextTabsClick(Sender: TObject);
 var
  a: Array of Integer;
  i: Integer;
begin
  If TabView.TabIndex = TabView.Tabs.Count-1 then
    exit;

  For i:= TabView.TabIndex+1 to TabView.Tabs.Count-1 do
  begin
    If IsSplitClip(GetClip(i)) then
      Continue;
    SetLength(a, Length(a)+1);
    a[High(a)]:= i;
  end;
  If Length(a) > 0 then
    CloseTabs(a)
  else beep;
end;

procedure TForm1.Clear();
var
  i: Integer;
  P: PFrameRec;
begin

  //- TODO Clear split clip at once
  If IsSplitClip(CurrentClip) then
  begin
    NewClip;
    exit;
  end;

  TabSet.OnChange:= nil;
  TabSet.TabIndex:= 0;
  TabSet.OnChange:= TabSetChange;
  LV.Selected:= nil;
  LV.Items.BeginUpdate;
  LV.Items.Count:= 0;
  LV.Items.EndUpdate;
  LV_StyleBugFix;

  with CurrentClip do
  begin
    FavorLists_Clear(CurrentClip);
    NeedSave:= False;
    LV_PreveusIndex:= -1;
    If Assigned(FileStream) then
      FileStream.Free;
    FileStream:= nil;
    If Assigned(StoredStream) then
      StoredStream.Free;
    StoredStream:= nil;
    For i:= 0 to FrameList.Count-1 do
    begin
      P:= PFrameRec(FrameList[i]);
      P^.bmp.Free;
      Dispose(P);
    end;
    FrameList.Clear;
    ThumbWidth:= DefaultThumbWidth;
    ActiveList:= FrameList;
  end;

  FZoom:= 100;
  popZFit.Tag:= -1; //- WNDProc AutoZoom
  WindowState:= wsNormal;
  Caption:= myName;
  If popFormAutoMove.Checked then
  begin
    Left:= FDefLeft;
    Width:= FDefWidth;
  end;

  if not popZFit.Checked then
    popZ100.Checked:= true
  else
    popZFit.Tag:= 0;

  Screen.Cursor:= crDefault;
end;

procedure TForm1.popClearFileHistoryClick(Sender: TObject);
begin
  FHistoryList.Clear;
  popOpenLastSavedStream.Clear;
end;

procedure TForm1.popClipExtraMenuClick(Sender: TObject);
var
  idx: Integer;
begin
  //- do not get split indexes from the FavorLits, indexes only valid from the FrameList
  If Assigned(LV.Selected) and (TabSet.TabIndex = 0) then
    idx:= LV.Selected.Index
  else idx:= -1;

  popAutoSplitClip.Enabled:= (CurrentClip.Splits <> '') and not IsSplitClip(CurrentClip);
  popSplitClip.Enabled:= idx > 0; //- min two frames, and index from the FrameList
  popJoinClipParts.Enabled:= IsSplitClip(CurrentClip);
  popSortClipParts.Enabled:= popJoinClipParts.Enabled;
  popSaveCurrentSplits.Enabled:= popJoinClipParts.Enabled or (CurrentClip.Splits <> '');
  popSplitMergeNext.Enabled:= Assigned(CurrentClip.NextPart);
                              //and Assigned(CurrentClip.PrevPart);
  popSplitMergePrev.Enabled:= Assigned(CurrentClip.PrevPart);


  //~popEditSplits.Enabled:= CurrentClip.FrameList.Count > 1;
end;

procedure TForm1.popClipsToClipClick(Sender: TObject);
begin
  If FInProgress then
  begin
    beep;
    exit;
  end;

  With SaveDlg do
  begin
    Filter:= 'Bookmarks (' + fext + ')|*' + fext;
    DefaultExt:= fext;
    InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
    If not Execute(Handle) then
      exit;
  end;

  ClipsToClip(RemoveFileExt(SaveDlg.FileName));
end;

procedure TForm1.popClearBasketClick(Sender: TObject);
var
  i: Integer;
begin
  If CurrentClip.Favor2List.Count < 1 then
    exit;
  LV.Items.BeginUpdate;
  For i:= 0 to CurrentClip.Favor2List.Count-1 do
    RemoveBit(PFrameRec(CurrentClip.Favor2List[i])^.BitInt, 2);
  TabSet.TabIndex:= 0;
  CurrentClip.Favor2List.Clear;
  i:= TabSet.Tabs.IndexOf('Basket');
  if i > -1 then
    TabSet.Tabs.Delete(i);
  LV.Items.EndUpdate;
  LV.Invalidate;
end;

procedure TForm1.popBackgroundColorClick(Sender: TObject);
begin
  ColorDialog.Color:= LV.Color;
  If not ColorDialog.Execute(Handle) then
    exit;
  LV.Color:= ColorDialog.Color;
  LV.Repaint;
end;

procedure TForm1.popBackupFavorClick(Sender: TObject);
var
  i: Integer;
  SL: TStringList;
  P: PFrameRec;
begin
  With SaveDlg do
  begin
    Filter:= 'Favoriten Backup|*_Favor.txt|Textfiles (*.txt)|*.txt';
    InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
    FileName:= ExtractFileName(CurrentClip.LastOpen)+ '_Favor.txt';
  end;
  If not SaveDlg.Execute then
    exit;
  SL:= TStringList.Create;
  Try
    For i:= 0 to CurrentClip.FrameList.Count-1 do
    begin
      P:= CurrentClip.FrameList[i];
      if GetBit(P^.BitInt, 1) or GetBit(P^.BitInt, 2) then
        SL.Add(IntToStr(P^.FrameNr) + '=' + IntToStr(P^.BitInt));
    end;
    SL.SaveToFile(SaveDlg.FileName);
  Finally
     SL.Free;
  End;
end;

procedure TForm1.popRestoreFavorClick(Sender: TObject);
var
  i,z,x,e: Integer;
  SL: TStringList;
  P: PFrameRec;
begin
  With OpenDlg do
  begin
    Filter:= 'Favoriten Backup|*_Favor.txt|Textfiles (*.txt)|*.txt';
    InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
    FileName:= ExtractFileName(CurrentClip.LastOpen)+ '_Favor.txt';
    If not Execute then
      exit;
  end;

  SL:= TStringList.Create;
  TabSet.TabIndex:= 0;
  LV.Items.BeginUpdate;
  FavorLists_Clear(nil);
  z:= 0;

  Try
    SL.LoadFromFile(OpenDlg.FileName);
    For i:= 0 to CurrentClip.FrameList.Count-1 do
    begin
      P:= CurrentClip.FrameList[i];
      x:= SL.IndexOfName(IntToStr(P^.FrameNr));
      if x > -1 then
      begin
        inc(z);
        e:= StrToIntDef(SL.ValueFromIndex[x], 0);
        if GetBit(e, 1) then
          AddFavorList(CurrentClip.FrameList, CurrentClip.FavorList, i);
        if GetBit(e, 2) then
          AddFavorList(CurrentClip.FrameList, CurrentClip.Favor2List, i);
      end
      else P^.BitInt:= 0;
    end;
    z:= SL.Count - z;
  Finally
    SL.Free;
    LV.Items.EndUpdate;
    LV.Invalidate;
  End;
  if z > 0 then
    ShowMessage(IntToStr(z) + ' Favorites not found.');
end;

procedure TForm1.popClearFavoritesClick(Sender: TObject);
var
  i: Integer;
begin
  If CurrentClip.FavorList.Count < 1 then
    exit;
  For i:= 0 to CurrentClip.FavorList.Count-1 do
    RemoveBit(PFrameRec(CurrentClip.FavorList[i])^.BitInt, 1);
  TabSet.TabIndex:= 0;
  CurrentClip.FavorList.Clear;
  LV.Invalidate;
end;

procedure TForm1.AddLastSavedStream(const filename: String);
var
  item: TMenuItem;
begin
  if (filename = '') or (FHistoryList.IndexOf(filename) > -1) then
    exit;
  FHistoryList.Add(filename);

  item:= TMenuItem.Create(popOpenLastSavedStream);
  item.Hint:= filename;
  item.Caption:= ExtractFileName(filename);
  item.OnClick:= popOpenLastSavedStreamClick;
  If not popOpenLastSavedStream.Enabled then
    popOpenLastSavedStream.Enabled:= True;
  popOpenLastSavedStream.Add(item);
  if FHistoryList.Count > FMaxHistoryCount then
  begin
    FHistoryList.Delete(0);
    popOpenLastSavedStream.Delete(0);
  end;
end;

procedure TForm1.AddGroups();
var
  SL: TStringList;
begin
  SL:= TStringList.Create;
  Try
    FileUtils.GetFileList(ProgramPath + 'Groups','*' + GroupExt,SL,True,False,False);
    AddGroups(SL);
  finally
    SL.Free;
  end;
end;

procedure TForm1.AddGroups(SL: TStringList);
var
  item,item2: TMenuItem;
  i: Integer;
  s: String;
begin
  popGroupMenu.Clear;
  popAddTabToGroup.Clear;
  SL.Sort;
  i:= SL.IndexOf(ProgramPath + 'Groups\Last' + GroupExt);
  If i > 0 then
    SL.Move(i, 0);
  For i:= 0 to SL.Count -1 do
  begin
    //- remove GroupExt '.grp.txt'
    s:= ExtractFileNameNoExt(ExtractFileNameNoExt(SL[i]));
    item:= TMenuItem.Create(self);
    item.Hint:= SL[i];
    If Length(s) > 30 then
    begin
      SetLength(s, 27);
      s:= s + '...';
    end;
    item.Caption:= s;
    item.OnClick:= OpenGroup;
    popGroupMenu.Add(item);
    //- Extras\AddTabToGroup
    item2:= TMenuItem.Create(self);
    item2.Hint:= item.Hint;
    item2.Caption:= item.Caption;
    item2.OnClick:= AddTabToGroup;
    popAddTabToGroup.Add(item2);
    //- max 150 must be enough
    if i >= 150 then
      break;
  end;
  popGroupMenu.Enabled:= popGroupMenu.Count > 0;
  popAddTabToGroup.Enabled:= popGroupMenu.Enabled;
end;

function TForm1.AddFavorList(Source, Targed : TList; Index: Integer): Integer;
var
  P: PFrameRec;
  i: Integer;
begin
  Result:= -1;
  P:= PFrameRec(Source.Items[Index]);

  For i:= 0 to Targed.Count-1 do
    if PFrameRec(Targed.Items[i])^.FrameNr = P^.FrameNr then
      exit;

  If Targed = CurrentClip.FavorList then
  begin
    SetBit(P^.BitInt, 1, True);
    CurrentClip.NeedSave:= true;
  end
  else if Targed = CurrentClip.Favor2List then
  begin
    If TabSet.Tabs.IndexOf('Basket') < 0 then
      TabSet.Tabs.Add('Basket');
    SetBit(P^.BitInt, 2, True);
  end;

  Targed.Add(P);
  Result:= Targed.Count-1;
end;

procedure TForm1.ListView_SetWidth;
begin
  UpdateWindow(LV.Handle);
  If WindowState = wsMaximized then
    exit;
  ClientWidth:= Round((CurrentClip.ThumbWidth/100)*FZoom)+ GetSystemMetrics(SM_CYVSCROLL) + 10;//;28;
  If popFormAutoMove.Checked then
    Left:= Max((Screen.WorkAreaWidth - Width)- (Screen.WorkAreaWidth - (FDefLeft + FDefWidth)), 0);
end;

procedure TForm1.LVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  R,RB: TRect;
  P: PFrameRec;
  s: String;
  w,h,x,y: Integer;
begin
  DefaultDraw:= false;
  LV.Canvas.Font.Pitch:= fpFixed;
  If (item=nil)or(item.Index>= ActiveList.Count) then exit;

  ListView_GetItemRect(LV.Handle,item.Index,R,LVIR_ICON);
  ListView_GetItemRect(LV.Handle,item.Index,RB,LVIR_LABEL);
  P:= PFrameRec(ActiveList[item.Index]);

  If FZoom = 100 then with P^.bmp do
    BitBlt(LV.Canvas.Handle,R.Left+2,R.Top+2,Width,Height,
           Canvas.Handle,0,0,SRCCOPY)
  else begin
    SetStretchBltMode(LV.Canvas.Handle,HALFTONE);
    with P^.bmp do
    begin
      (*StretchBlt(LV.Canvas.Handle,R.Left+2,R.Top+2,
                 Round((Width/100)*FZoom),
                 Round((Height/100)*FZoom),
                 Canvas.Handle,0,0,Width,Height,SRCCOPY);*)

      w:= Min((R.Right - R.Left) - 4, Trunc((R.Bottom-R.Top)*(Width/Height))-4);
      h:= Min(Trunc(w/(Width/Height)), (R.Bottom-R.Top)-3);
      x:= Max(((R.Right-R.Left))-w, 2);
      y:= Max(((R.Bottom-R.Top))-h, 2);
      If x > 3 then
        x:= x div 2;
      If y > 3 then
        y:= y div 2;

      StretchBlt(LV.Canvas.Handle,R.Left+x,R.Top+y,
                 w,h,
                 Canvas.Handle,0,0,Width,Height,SRCCOPY);
    end;
  end;

  If item.Selected then
  begin
    LV.Canvas.Brush.Color:= clYellow;
    LV.Canvas.FrameRect(R);
  end;

  If (P^.Title = '') or not popShowTitle.Checked then
    s:= IntToStr(P^.FrameNr)
  else s:= IntToStr(P^.FrameNr) + ' ' + P^.Title;

  if GetBit(P^.BitInt, 1) then
    SetTextColor(LV.Canvas.Handle, clYellow)
  else
    SetTextColor(LV.Canvas.Handle, clWhite);

  LV.Canvas.Brush.Color:= LV.Color;
  SetBkMode(LV.Canvas.Handle,TRANSPARENT);
  DrawTextEx(LV.Canvas.Handle,PChar(s),-1,RB,DT_CENTER,nil);
end;

procedure TForm1.LVData(Sender: TObject; Item: TListItem);
var
  P: PFrameRec;
begin
  If Assigned(Item) and (item.Index < ActiveList.Count) then
  begin
    P:= ActiveList[item.Index];
    If (P^.Title = '') or not popShowTitle.Checked then
      item.Caption:= IntToStr(P^.FrameNr)
    else item.Caption:= IntToStr(P^.FrameNr) + ' ' + P^.Title;
  end;
end;

procedure TForm1.LVDataStateChange(Sender: TObject; StartIndex,
  EndIndex: Integer; OldState, NewState: TItemStates);
 var i,s,e,ee: Integer;
    LVH: LV_HITTESTINFO;
begin
  If LV.Dragging then exit;
  s:= SItemIndex;
  LVH.pt:= LV.ScreenToClient(Mouse.CursorPos);
  LVH.flags:= LVHT_ONITEMICON	or LVHT_ONITEMLABEL;
  ListView_HitTest(LV.Handle,LVH);
  e:= LVH.iItem;

  If (s < 0) or (e < 0) then exit;

  If s > e then
  begin
    ee:= s;
    s:= e;
    e:= ee;
  end;

  If s > StartIndex then
  begin
    For i:= StartIndex to s do
      if LV.Items[i].Index< s then
       LV.Items[i].Selected:= false;
  end;

  If e < EndIndex then
  begin
    For i:= EndIndex downto e do
      If LV.Items[i].Index> e then
        LV.Items[i].Selected:= false;
  end;
end;

procedure TForm1.LVDblClick(Sender: TObject);
var
  i: Integer;
begin
  double_click:= true;
  i:= popZFit.Tag;
  popZFit.Tag:= -1;

  if WindowState = wsNormal then
    WindowState:= wsMaximized
  else
    If Byte(GetKeyState(vkControl)) < 100 then
      WindowState:= wsNormal
    else if FZoom <> 100 then
    begin
      FZoom:= 100;
      SetZoom;
      LV_MakeItemVisible(-1);
      popZFit.Tag:= i;
      exit;
    end;

  popZFit.Click;
end;

procedure TForm1.LVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Sel: Integer;
  Strg: boolean;
begin
  If (Source <> LV) or (LV.SelCount < 1) then
    exit;
  Sel:= LV.Selected.Index;
  If Sel < 0 then
    exit;

  //- SplitMove  Key Alt
  If Byte(GetKeyState(vkMenu)) > 100 then
  begin
    SplitMove(CurrentClip, Sel, FLVMouseDown.X > X);
    exit;
  end;

  //- AddFavorList
  Strg:= Byte(GetKeyState(vkControl)) > 100;

  If TabSet.TabIndex = 0 then
  begin
    If Strg then
      AddFavorList(CurrentClip.FrameList, CurrentClip.Favor2List, Sel)
    else
      AddFavorList(CurrentClip.FrameList, CurrentClip.FavorList, Sel);
  end
  else if TabSet.TabIndex = 1 then
  begin
    If Strg then
      AddFavorList(CurrentClip.FavorList, CurrentClip.Favor2List, Sel)
    else begin
      RemoveBit(PFrameRec(CurrentClip.FavorList[Sel])^.BitInt, 1);
      CurrentClip.FavorList.Delete(Sel);
      CurrentClip.NeedSave:= true;
      LV.Items.BeginUpdate;
      LV.Items.Count:= ActiveList.Count;
      LV.Items.EndUpdate;
      LV_StyleBugFix;
    end;
  end
  else if TabSet.TabIndex = 2 then
  begin
    If Strg then
    begin
      RemoveBit(PFrameRec(CurrentClip.FavorList[Sel])^.BitInt, 2);
      CurrentClip.Favor2List.Delete(Sel);
      LV.Items.BeginUpdate;
      LV.Items.Count:= ActiveList.Count;
      LV.Items.EndUpdate;
      LV_StyleBugFix;
      If CurrentClip.Favor2List.Count < 1 then
      begin
        Sel:= TabSet.Tabs.IndexOf('Basket');
        If Sel > -1 then
          TabSet.Tabs.Delete(Sel);
        TabSet.TabIndex:= 0;
      end;
    end
    else
      AddFavorList(CurrentClip.Favor2List, CurrentClip.FavorList, Sel);
  end;
  LV.EndDrag(false);
end;

procedure TForm1.LVDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:= Assigned(LV.Selected) and (Source=LV);
  rect_down.Left:= X;
  rect_down.Top:= Y;
end;

procedure TForm1.LVEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  LV.Cursor:= crDefault;
end;

procedure TForm1.ShowAvsWnd();
var
  h: THandle;
  Clip: TClip;
  i: Integer;
begin
  if CurrentClip.AvsWnd = 0 then
    exit;
  if not IsWindow(CurrentClip.AvsWnd) then with CurrentClip do
  begin
    AvsP_video_w:= -1;
    AvsP_video_h:= -1;
    AvsWnd:= 0;
    exit;
  end;

  If IsIconic(CurrentClip.AvsWnd) then
  begin
    ShowWindow(CurrentClip.AvsWnd, SW_RESTORE);
    BringWindowToTop(CurrentClip.AvsWnd);
    SetForegroundWindow(Handle);
    SetActiveWindow(LV.Handle);
  end
  else begin
    h:= WindowFromPoint(Point(100,20)); //- only run the loop isn't the wnd in forground
    if h <> CurrentClip.AvsWnd then
    begin
      For i:= 0 to TabView.Tabs.Count -1 do
      begin
        Clip:= GetClip(i);
        if Clip.AvsWnd > 0 then
        begin
          If (Clip.AvsWnd <> CurrentClip.AvsWnd) and not IsIconic(Clip.AvsWnd) then
            ShowWindow(Clip.AvsWnd, SW_FORCEMINIMIZE)
          else if Clip.AvsWnd = CurrentClip.AvsWnd then
            BringWindowToTop(CurrentClip.AvsWnd);
        end;
      end;
    end;

    ShowWindow(CurrentClip.AvsWnd, SW_SHOWNA);
    SetForegroundWindow(Handle);
    SetActiveWindow(LV.Handle);
  end;
end;

procedure TForm1.LVMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{
Kompliziertes handling,
Maus Down Links oder Rechts wird erst nach Mouse up aktuallisiert,
und ein Maus up Ereigniss wird im MouseUp Event nur bei linker Maustaste
ausgelöst, rechte Taste wird ignoriert.
}
var
  LeftDown: boolean;
  wt: Integer;
  THR: TThread;
  TH: THandle;
{$J+}
const
  LV_LastIndex: Integer = -1;
  LV_LastActiveList: TList= nil;
{$J-}

begin
  //- stored for mouse move
  rect_down:= Rect(X,Y,X+1,Y+1);
  FLVMouseDown:= Point(X,Y);

  if double_click then
  begin
    double_click:= False;
    exit;
  end;

  If FInProgress then
    exit;

  LeftDown := getKeyState(VK_LBUTTON) < 0; //- left down is only fired up on button down and mouse move
  if (Button = mbRight) and not LeftDown then
     PopupMenu.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y)
  else begin

    if not Assigned(LV.Selected) then
      exit;

    // Set LV_PreveusIndex for mouse event, TabView.OnChange init the index
    If LV_LastActiveList = ActiveList then
    begin
      If (LV_LastIndex <> LV.ItemIndex) then
        CurrentClip.LV_PreveusIndex:= LV_LastIndex;
    end;
    LV_LastActiveList:= ActiveList;
    LV_LastIndex:= LV.ItemIndex;

    // Test
    {
    if FindVDubWnd then
    begin
      //PostMessage(VDubWnd, WM_USER, Integer(PChar('SetRangeFrames(1000,1200)')), 0);
      //SendCommand_ext(VDubWnd, '2', 'Set selection start');
      //SendCommand_ext(VDubWnd, '4', 'Selection start');
      //Caption:= 'Found Wnd';
    end;
    }

    //- Find the wnd and change the AvsP tab if found
    With CurrentClip do
    begin
      If (AvsWnd = 0) or not IsWindow(AvsWnd) then
      begin
        FInProgress:= True;
        LV.Enabled:= False;
        Try
          THR:= TThread.CreateAnonymousThread(procedure
          begin
            FindAvsWnd(30000);
          end);
          TH:= THR.Handle;
          wt:= 1000;
          FTaskCount:= 1;
          THR.Start;

          Repeat
            Case MsgWaitForMultipleObjectsEx(1, TH, wt, QS_ALLINPUT, 0) of
              WAIT_OBJECT_0+1: Application.ProcessMessages;
              WAIT_TIMEOUT:
                  If wt = 1000 then
                  begin
                    wt:= 30000;
                    Screen.Cursor:= crHourGlass;
                    Application.ProcessMessages;
                  end
                  else break; //- break if timeout larger 31000
              else break;
            end;
          Until False;

        finally
          FInProgress:= False;
          LV.Enabled:= True;
          LV.SetFocus;
          FTaskCount:= 0;
        end;
      end;

      //~TabView_SetTabText(TabView.TabIndex); //-Moved to FindAvsWnd
      If AvsWnd = 0 then
      begin
        AvsP_video_w:= -1;
        AvsP_video_h:= -1;
        AvsWnd:= 0;
        Screen.Cursor:= crDefault;
        SetCaption(wndErr);
        SplitUpdateWnd(CurrentClip);
        exit;
      end
      else begin
        if Caption = wndErr then
          SetCaption();
      end;
    end;

    if (Button = mbLeft) and not LeftDown then
    begin
      LV.Enabled:= False;
      FInProgress:= True;
      FTaskCount:= 1;
      Try
        THR:= TThread.CreateAnonymousThread(procedure
        begin
          ShowAvsWnd;
          //- Find and change the AvsP tab
          SendCopyData(CurrentClip.AvsWnd, ExtractFileNameNoExt(CurrentClip.LastOpen), 1, 30000);
        end);
        TH:= THR.Handle;
        wt:= 1000;
        THR.Start;

        Repeat
          Case MsgWaitForMultipleObjectsEx(1, TH, wt, QS_ALLINPUT, 0) of
            WAIT_OBJECT_0+1: Application.ProcessMessages;
            WAIT_TIMEOUT:
                If wt = 1000 then
                begin
                  wt:= 30000;
                  Screen.Cursor:= crHourGlass;
                  Application.ProcessMessages;
                end
                else break;
            else break;
          end;
        Until False;

        sleep(10);
        Application.ProcessMessages;

        //- Find the bookmark in the AvsP Menu
        //- Alternative, but without returned result
        //~PostMessage(CurrentClip.AvsWnd, AVSP_SET_FRAME_NR, 0, PFrameRec(ActiveList[LV.Selected.Index])^.FrameNr);
        If not SendCommand(CurrentClip.AvsWnd, IntToStr(PFrameRec(ActiveList[LV.Selected.Index])^.FrameNr))
          then with CurrentClip do
          begin
             //- Reset if AvsP Wnd closed or wrong Wnd or tab not exists
            AvsP_video_w:= -1;
            AvsP_video_h:= -1;
            AvsWnd:= 0;
            SetCaption(bookErr);
          end
          else if Caption = bookErr
            then SetCaption();
      finally
        FInProgress:= false;
        FTaskCount:= 0;
        Screen.Cursor:= crDefault;
        LV.Enabled:= True;
        LV.SetFocus;
      end;

      //- call for video info
      if (CurrentClip.AvsWnd > 0) and ((CurrentClip.AvsP_video_w <= 0) or (CurrentClip.AvsP_video_h <= 0)) then
      begin
        PostMessage(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_SIZE);
        //~PostMessage(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_WND_SIZE);
        sleep(40);
        Application.ProcessMessages;
      end;
    end;
  end;
end;

procedure TForm1.LVMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  R: TRect;
  xm, ym: Integer;
  w,h: Integer;
  LVHIT: tagLVHITTESTINFO;
begin
  If LV_LastPreviewIndex <> -1 then
  begin
    LV_LastPreviewIndex:= -1;
    SetCaption();
    LV.Invalidate;
  end;

  if (Shift = [ssLeft]) then
  begin
    //- enable mouse move after frame step (Maus move nach Frame Step ermöglichen)
    if not Assigned(LV.Selected) then
    begin
      LVHIT.pt:= Point(X,Y);
      ListView_HitTest(LV.Handle,LVHIT);
      if LVHit.iItem > -1 then
        LV.Items[LVHit.iItem].Selected:= true;
      if not Assigned(LV.Selected) then
        exit;
    end;

    if CurrentClip.AvsP_video_w <= 0 then
      exit;

    //- scroll step
    ListView_GetItemRect(LV.Handle,LV.Selected.Index,R,LVIR_ICON);
    w:= R.Right - R.Left;
    h:= R.Bottom - R.Top;
    xm:= -Round((X-rect_down.Left)*CurrentClip.AvsP_video_w/w);
    ym:= -Round((Y-rect_down.Top)*CurrentClip.AvsP_video_h/h);
    if popAvsPscrolldiv2.Checked then
    begin
     xm:= xm div 2;
     ym:= ym div 2;
    end;
    if popAvsPscrollreverse.Checked then
    begin
      xm:= -xm;
      ym:= -ym;
    end;

    PostMessage(CurrentClip.AvsWnd, AVSP_SCROLL_STEP, 50000+xm, ym);
    rect_down.Left:=  X;
    rect_down.Top:= Y;
  end                                                    //- SplitMove
  else if ((ssLeft in Shift) and (ssRight in Shift)) and
    ((ABS(X - rect_down.Left) > 8) or (ABS(Y - rect_down.Top) > 8)) then
      LV.BeginDrag(False);



    // direct scroll
    {
    ListView_GetItemRect(LV.Handle,LV.Selected.Index,R,LVIR_ICON);
    w:= R.Right - R.Left;
    h:= R.Bottom - R.Top;
    PostMessage(AvsWnd, AVSP_SCROLL,Round((X-R.Left)*AvsP_video_w/w),
                                    Round((Y-R.Top)*AvsP_video_h/h));
    exit;

    // direct scroll and draw rect
    ListView_GetItemRect(LV.Handle,LV.Selected.Index,R,LVIR_ICON);
    w:= R.Right - R.Left;
    h:= R.Bottom - R.Top;
    Caption:= IntTostr(Left) + '-' + IntToStr(w);
    BorderW:= AvsP_video_w-Left;
    BorderW:= Round(BorderW/(AvsP_video_w/w));
    BorderH:= AvsP_video_h - AvsP_vid_wnd_h;
    R.Left:= X;
    R.Top:= Y;
    rr:= R.Right-1;
    rb:= R.Bottom-1;
    R.Right:= min(X + (w - BorderW), rr);
    R.Bottom:= min(Y + round(h-(BorderH/(AvsP_video_h/h))), rb);

    with LV.Canvas do
    begin
      Pen.Style:= psSolid;
      Pen.Mode:= pmXor;
      Pen.Width:= 1;
      Pen.Color:= clGray;
      Brush.Style:=bsclear;
      Rectangle(rect_down);
      rect_down:= R;
      Rectangle(rect_down);
    end;
  end                              // Begin Drag
  else if ((ssLeft in Shift) and (ssRight in Shift)) and
    ((ABS(X - rect_down.Left) > 8) or (ABS(Y - rect_down.Top) > 8)) then
       LV.BeginDrag(False);
  }
end;

procedure TForm1.LVResize(Sender: TObject);
begin
  LV.Invalidate;
end;

procedure TForm1.LVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  If LV.SelCount = 1 then
    SItemIndex:= LV.ItemIndex;
end;

procedure TForm1.LVStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  LV.Cursor:= crDrag;
end;

procedure TForm1.OnCommand(Sender: TObject);
var
  sa,sb: TArray<String>;
  i: Integer;
begin
  If CurrentClip.AvsWnd = 0 then
  begin
    beep;
    exit;
  end;

  If TMenuItem(Sender).Hint.Contains('|') then
    sa:= TMenuItem(Sender).Hint.Split(['|'])
  else begin
    SetLength(sa, 1);
    sa[0]:= TMenuItem(Sender).Hint;
  end;

  For i:= 0 to High(sa) do
  begin
    sb:= sa[i].Split(['=']);
    If Length(sb) < 2 then
    begin
      beep;
      continue;
    end;

    SendCommand_ext(CurrentClip.AvsWnd, sb[1] , sb[0]);
  end;
  //SendCommand_ext(CurrentClip.AvsWnd, TMenuItem(Sender).Hint , TMenuItem(Sender).Caption);
end;

procedure TForm1.SetZoom;
begin
  If CurrentClip.MultiThumbSize and (FZoom = 100) then
    FZoom:= 100.0001;
  LV.Items.BeginUpdate;
  ListView_SetItemCountEx(LV.Handle, ActiveList.Count, LVSICF_NOSCROLL or LVSICF_NOINVALIDATEALL);
  ImageList_SetIconSize(DummyImL,Round((CurrentClip.ThumbWidth/100)*FZoom) {-12 ?},
                                 Round((CurrentClip.ThumbHeight/100)*FZoom));
  ListView_SetImageList(LV.Handle,DummyIML,LVSIL_NORMAL);
  ListView_SetIconSpacing(LV.Handle,Round((CurrentClip.ThumbWidth/100)*FZoom)+ 5,
                                       Round((CurrentClip.ThumbHeight/100)*FZoom)+ 25);
  ListView_SetItemCountEx(LV.Handle, ActiveList.Count, LVSICF_NOSCROLL or LVSICF_NOINVALIDATEALL);
  LV.Items.EndUpdate;
  LV.Invalidate;
end;

procedure TForm1.popSortFavoritesClick(Sender: TObject);
begin
  LV.Items.BeginUpdate;
  CurrentClip.FavorList.Sort(@SortListFunc_FrameNr);
  CurrentClip.Favor2List.Sort(@SortListFunc_FrameNr);
  LV.Items.EndUpdate;
  LV.Invalidate;
end;

procedure TForm1.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  AllowChange:= (NewTab = 0) or ((CurrentClip.FavorList.Count > 0) and (NewTab = 1)) or
    ((CurrentClip.Favor2List.Count > 0) and (NewTab = 2)) and (not FInProgress);
  If not AllowChange then
    exit;

  LV_SaveOrigin;
  //- Bug Fix for Delphi Styles. Scrollbar does not set the right range and position
  //LV.Enabled:= False;
  LV.ClearSelection;

  Try
    Case NewTab of
      0: begin
           ActiveList:= CurrentClip.FrameList;
           LV.Items.BeginUpdate;
           LV.Items.Count:= CurrentClip.FrameList.Count;
           LV.Items.EndUpdate;
           If CurrentClip.LastIndexLV > -1 then
             LV.Items[CurrentClip.LastIndexLV].Selected:= true;
           LV.Scroll(0, CurrentClip.LastViewOriginLV.Y - LV.ViewOrigin.Y);
         end;
      1: begin
           ActiveList:= CurrentClip.FavorList;
           LV.Items.BeginUpdate;
           LV.Items.Count:= CurrentClip.FavorList.Count;
           LV.Items.EndUpdate;
           If CurrentClip.LastIndexFV > -1 then
             LV.Items[CurrentClip.LastIndexFV].Selected:= true;
           LV.Scroll(0, CurrentClip.LastViewOriginFV.Y - LV.ViewOrigin.Y);
         end;
      2: begin
           ActiveList:= CurrentClip.Favor2List;
           LV.Items.BeginUpdate;
           LV.Items.Count:= CurrentClip.Favor2List.Count;
           LV.Items.EndUpdate;
           If CurrentClip.LastIndexFV2 > -1 then
             LV.Items[CurrentClip.LastIndexFV2].Selected:= true;
           LV.Scroll(0, CurrentClip.LastViewOriginFV2.Y - LV.ViewOrigin.Y);
         end;
    End;
  Finally
    CurrentClip.TabSet_LastIndex:= NewTab;
    //LV.Enabled:= True;   //- Bug fix Delphi Styles
  End;

  //- Or remove it, then last scroll pos is used
  If Assigned(LV.Selected) then
    LV_MakeItemVisible(-1)
  else begin
    LV.Enabled:= False;   //- Bug fix Delphi Styles
    LV.Enabled:= True;
    LV.SetFocus;
  end;
  //- Reset LV_PreveusIndex to current index
  CurrentClip.LV_PreveusIndex:= LV.ItemIndex;
  LV.Invalidate;
end;

procedure TForm1.LV_SaveOrigin();
var
  VO : TPoint;
begin
  If not Assigned(CurrentClip) or (CurrentClip.FrameList.Count < 1) then
    exit;
  //- on split I need the selected thumb at top
  If (LV.SelCount > 0) and IsSplitClip(CurrentClip) then
    VO:= Point(LV.ViewOrigin.X, LV.ViewOrigin.Y+ClientHeight)
  else VO:= LV.ViewOrigin;


   Case TabSet.TabIndex of
    0: begin
         CurrentClip.LastViewOriginLV:= VO;
         If LV.SelCount > 0 then
            CurrentClip.LastIndexLV:= LV.Selected.Index
         else CurrentClip.LastIndexLV:= -1;
       end;
    1: begin
         CurrentClip.LastViewOriginFV:= VO;
         If LV.SelCount > 0 then
            CurrentClip.LastIndexFV:= LV.Selected.Index
         else CurrentClip.LastIndexFV:= -1;
       end;
    2: begin
         CurrentClip.LastViewOriginFV2:= VO;
         If LV.SelCount > 0 then
            CurrentClip.LastIndexFV2:= LV.Selected.Index
         else CurrentClip.LastIndexFV2:= -1;
       end;
  End;
  //- Save the last TabSet index from Clip
  CurrentClip.TabSet_LastIndex:= TabSet.TabIndex;
end;

{
procedure TForm1.WaitProc(Proc: TProc; const Priority: TThreadPriority = tpNormal);
var
  THR: TThread;
  TH: THandle;
  wt: Integer;
  wt_changed: Boolean;
begin
  THR:= TThread.CreateAnonymousThread(procedure
  begin
    Proc;
  end);
  THR.FreeOnTerminate:= True;
  THR.Priority:= Priority;
  TH:= THR.Handle;
  wt:= 1000;
  wt_changed:= false;
  THR.Start;
  Repeat
    Case MsgWaitForMultipleObjectsEx(1, TH, wt, QS_ALLINPUT, 0) of
      WAIT_OBJECT_0:   Break;
      WAIT_OBJECT_0+1: Application.ProcessMessages;
      WAIT_TIMEOUT:
          If not wt_changed then
          begin
            wt_changed:= True;
            wt:= 30000;
            Screen.Cursor:= crHourGlass;
            UpdateWindow(Handle);
          end
          else break; //- break if timeout larger 31000
      else break;
    end;
  Until False;
end;
}

procedure TForm1.TabViewChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
var
  Clip: TClip;
  i: Integer;
  THR: TThread;
  TH: THandle;
  item: TListItem;
  //mem: Int64;
begin
  AllowChange:= False;
  If (NewTab >= TabView.Tabs.Count) or (NewTab < 0) or FInProgress then
    exit;

  Try
    Clip:= GetClip(NewTab);
  except
    exit;
  End;
  If not Assigned(Clip) then
    exit;

  //- Store the LV origin of the CurrentClip
  If Sender <> nil then  //- On delete tab we only restore the clip view origin  TabViewChange(nil)
    LV_SaveOrigin;

  //- Bug Fix for Delphi Styles. Scrollbar does not set the right range and position
  //LV.Enabled:= false;

  LV.ClearSelection;
  TabSet.OnChange:= nil;
  CurrentClip:= Clip;
  CurrentClip.LV_PreveusIndex:= -1;

  Try
    i:= TabSet.Tabs.IndexOf('Basket');
    If (Clip.Favor2List.Count < 1) and (i > -1) then
      TabSet.Tabs.Delete(i)
    else if (Clip.Favor2List.Count > 0) and (i < 0) then
       TabSet.Tabs.Add('Basket');

    //- Reset Zoom Fit
    If CurrentClip.FrameList.Count > 0 then
    begin
      If popZFit.Checked then
      begin
        FZoom:= 100;
        popZFit.Tag:= 0;
        SendMessage(Handle, WM_SIZE, SIZE_RESTORED, 0);
      end
      else SetZoom;
    end;

    //- Restore the old LV Origin
    Case Clip.TabSet_LastIndex of
      1: begin
           ActiveList:= Clip.FavorList;
           LV.Items.BeginUpdate;
           LV.Items.Count:= Clip.FavorList.Count;
           LV.Items.EndUpdate;
           If Clip.LastIndexFV > -1 then
             LV.Items[Clip.LastIndexFV].Selected:= true;
           LV.Scroll(0, Clip.LastViewOriginFV.Y - LV.ViewOrigin.Y);
         end;
      2: begin
           ActiveList:= Clip.Favor2List;
           LV.Items.BeginUpdate;
           LV.Items.Count:= Clip.Favor2List.Count;
           LV.Items.EndUpdate;
           If Clip.LastIndexFV2 > -1 then
             LV.Items[Clip.LastIndexFV2].Selected:= true;
           LV.Scroll(0, Clip.LastViewOriginFV2.Y - LV.ViewOrigin.Y);
         end;
      else begin
        Clip.TabSet_LastIndex:= 0;
        ActiveList:= Clip.FrameList;
        LV.Items.BeginUpdate;
        LV.Items.Count:= Clip.FrameList.Count;
        LV.Items.EndUpdate;
        If Clip.LastIndexLV > -1 then
          LV.Items[Clip.LastIndexLV].Selected:= true;
        LV.Scroll(0, Clip.LastViewOriginLV.Y - LV.ViewOrigin.Y);
      end;
    end;
  Finally
    TabSet.TabIndex:= Clip.TabSet_LastIndex;
    TabSet.OnChange:= TabSetChange;;
  End;

  AllowChange:= True;
  SetCaption;

  //- on added and loading clip exit;
  If CurrentClip.FrameList.Count < 1 then
    exit;

  {- Bullshit, available ist not free mem
  mem:= GetFreeMem;

  If mem < 5242880000 then //- 5000 MB
  begin
    //Caption:= Format('Mem:%d %s',[Round(mem/1024),StringReplace(Caption,'Bookstream','',[])]);
    paMem.Caption:= Format('Mem %d MB',[mem div 1024 div 1024]);
    paMem.Visible:= True;
  end
  else
    paMem.Visible:= False;
  }

  //- Or remove it, then last scroll pos is used
  If Assigned(LV.Selected) then //- Bring to top if split
    LV_MakeItemVisible(-1, True, IsSplitClip(CurrentClip))  //- Bug fix Delphi Styles
  else begin
    LV.Enabled:= False;
    LV.Enabled:= True;
    LV.SetFocus;
  end;
  CurrentClip.LV_PreveusIndex:= LV.ItemIndex;

  //- force do bring the AvsP Wnd to front
  //- doesn't force to find the AvsP Wnd, force to find wnd only on LV mouse down event
  if popForceAvsPWnd.Checked then
  begin
    If CurrentClip.AvsWnd > 0 then
    begin
      //- forces AvsP do find and change the tab (1 = change tab; 2 = open file; > 100 = Clip Addr)
      //- Send only one command to the same AvsP Wnd otherwise AvsP can block or crash
      Application.ProcessMessages;

      THR:= TThread.CreateAnonymousThread(procedure
      var
        tWnd: HWND;
      begin
        tWnd:= CurrentClip.AvsWnd;
        Try
          ShowAvsWnd;
          SendCopyData(tWnd, ExtractFileNameNoExt(CurrentClip.LastOpen) , 1, 30000);
        finally
          TThread.Queue(nil, procedure
          begin
            FInProgress:= False;
            LV.Enabled:= True;
            LV.SetFocus;
            dec(FTaskCount);
            Screen.Cursor:= crDefault;
          end);
        end;
      end);

      FInProgress:= True;
      LV.Enabled:= False;
      TH:= THR.Handle;
      THR.Priority:= tpHigher;
      inc(FTaskCount);
      THR.Start;
      //- Show the wait cursor delayed
      Repeat
        Case MsgWaitForMultipleObjectsEx(1, TH, 1000, QS_ALLINPUT, 0) of
          WAIT_TIMEOUT:
            begin
              Screen.Cursor:= crHourGlass;
              Application.ProcessMessages;
              Break;
            end;
          WAIT_OBJECT_0+1: Application.ProcessMessages;
          else Break;
        end;
      Until False;

      If IsSplitClip(CurrentClip) then
      begin
        i:= 0;
        If Assigned(LV.Selected) then
          i:= LV.Selected.Index
        else begin
          item:= LV.GetNearestItem(Point(0,40),sdRight);
          If Assigned(item) then i:= item.Index;
        end;
        PostMessage(CurrentClip.AvsWnd, AVSP_SET_FRAME_NR, 0, PFrameRec(ActiveList[i])^.FrameNr);
      end;
    end;
  end;

  TabView_SetTabText(NewTab);
end;

procedure TForm1.TabViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  idx: Integer;
begin
  If Source <> TabView then
    exit;
  idx:= TabView.ItemAtPos(Point(X,Y));
  If (idx < 0) or (idx = TabView.TabIndex) then
    exit;
  TabView.Tabs.Move(TabView.TabIndex, idx);
  TabView.TabIndex:= idx;
  CurrentClip:= GetCurrentClip;
  TabView_SetTabText();
end;

procedure TForm1.TabViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  idx: Integer;
begin
  idx:= TabView.ItemAtPos(Point(X,Y));
  Accept:= (idx > -1) and (Source = TabView);
end;

procedure TForm1.TabViewDrawTab(Sender: TObject; TabCanvas: TCanvas; R: TRect;
  Index: Integer; Selected: Boolean);
//var
  //S: String;
begin (*
  If Selected then
     TabCanvas.Font.Color := clLime
  else TabCanvas.Font.Color := clMenuText;
  S:= TabView.Tabs.Strings[Index];
  TabCanvas.TextRect(R, S, [tfVerticalCenter,tfSingleLine]); *)
end;

procedure TForm1.TabViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If FInProgress then
    exit;
  If Shift = [ssRight] then
    PopUpTab.Popup(ClientToScreen(Point(X,Y)).X, ClientToScreen(Point(X,Y)).Y)
  else begin
    If (Caption = wndErr) or (Caption = bookErr) then
      SetCaption();
    If (Shift = [ssLeft]) then
    begin
      If TabView.ItemAtPos(Point(X,Y)) = TabView.TabIndex then
        TabView.BeginDrag(False, 10);
    end;
  end;
end;

procedure TForm1.TabViewMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  idx: Integer;
  p: pFrameRec;
  Clip: TClip;
  w,h: Integer;
  s: String;
begin
  //- Show Clip name and show a preview from the tab under the mouse cursor
  //- if LV_LastPreviewIndex <> -1 on leave the function, LV.OnMouseMove does handle it.
  If FInProgress or TabView.Dragging then
    exit;

  idx:= TabView.ItemAtPos(Point(X,Y));

  //- reset on CurrentClip and empty idx
  If ((idx = TabView.TabIndex) or (idx < 0)) then
  begin
    if LV_LastPreviewIndex <> -1 then
    begin
      SetCaption();
      LV_LastPreviewIndex:= -1;
      LV.Invalidate;
    end
    else if
     ((Caption = wndErr) or (Caption = bookErr)) then
       SetCaption();
    exit;
  end;

  //- paint only once
  If LV_LastPreviewIndex = idx then
    exit;
  LV_LastPreviewIndex:= idx;

  Clip:= GetClip(idx);

  //- show clip name
  If Assigned(Clip.FileStream) then
    s:= ExtractFileName(Clip.LastOpen)
  else s:= ExtractFileName(Clip.LastFile);
  SetCaption(s);

  If not popShowPreview.Checked or (Clip.FrameList.Count < 1) then
    exit;

  //- show preview
  LV.Repaint; //- clear the previous draw
  Try
    Case Clip.TabSet_LastIndex of
      0: If Clip.LastIndexLV > -1 then
           p:= PFrameRec(Clip.FrameList[Clip.LastIndexLV])
         else p:= PFrameRec(Clip.FrameList[0]);
      1: If Clip.LastIndexFV > -1 then
           p:= PFrameRec(Clip.FavorList[Clip.LastIndexFV])
         else p:= PFrameRec(Clip.FavorList[0]);
      2: If Clip.LastIndexFV2 > -1 then
           p:= PFrameRec(Clip.Favor2List[Clip.LastIndexFV2])
         else p:= PFrameRec(Clip.Favor2List[0])
      else p:= PFrameRec(Clip.FrameList[0]);
    end;
  except
    p:= PFrameRec(Clip.FrameList[0]);
  end;

  w:= Min(p^.bmp.Width, LV.ClientWidth-6);
  h:= round(w / (p^.bmp.Width/p^.bmp.Height));

  LV.Canvas.Pen.Color:= clBlue;
  LV.Canvas.Pen.Width:= 6;
  LV.Canvas.Brush.Style:= bsClear;
  LV.Canvas.Rectangle(Rect(0,0,w+2,h+3));
  SetStretchBltMode(LV.Canvas.Handle, COLORONCOLOR);
  StretchBlt(LV.Canvas.Handle,2,2,w,h,p^.bmp.Canvas.Handle,0,0,p^.bmp.Width,p^.bmp.Height,SRCCOPY);
end;

//- id 1 = change tab; id 2 = open file; id > 100 = Clip Addr
function TForm1.SendCopyData(const WND: HWND; const s: String; const id: Integer; const timeout: Integer): Integer;
var
  Data: TCopyDataStruct;
  pc : PWideChar;
begin
  Result:= 0;
  If WND = 0 then
    exit;
  pc:= PWideChar(s);
  Data.dwData := id;  //- < 100 = command; > 100 Addr Clip
  Data.cbData := (StrLen(pc)*2) + 1; //- Changes for Unicode (Änderung wegen Unicode String)
  Data.lpData := pc;
  Result:= SendMessageTimeoutW(WND, WM_COPYDATA, Handle, Integer(@Data),
                      SMTO_ABORTIFHUNG {or SMTO_NOTIMEOUTIFNOTHUNG},timeout, nil);
end;

procedure TForm1.popZ50Click(Sender: TObject);
var
  i: Integer;
begin
  if TMenuItem(Sender).Tag > 1 then
  begin
    popZFit.Tag:= -1;    //- Tag für WNDProc
    popZFit.Checked:= false;
    TMenuItem(Sender).Checked:= true;
  end;

  If TMenuItem(Sender).Tag <= 0 then
  begin  //- Fit
    popZFit.Checked:= True;
    If WindowState = wsNormal then
      FZoom:= ((LV.ClientWidth-GetSystemMetrics(SM_CYVSCROLL)+11)/CurrentClip.ThumbWidth)*100
    else
    if WindowState= wsMaximized then
      FZoom:= Min(((LV.ClientWidth-GetSystemMetrics(SM_CYVSCROLL)+11)/CurrentClip.ThumbWidth)*100,
                  ((LV.ClientHeight-10)/CurrentClip.ThumbHeight)*100);
    popZFit.Tag:= 0;
  end
  else if TMenuItem(Sender).Tag = 1 then
  begin //- 100 Fit
    FZoom:= 100;
    popZFit.Checked:= True;
    popZFit.Tag:= 0;
  end
  else
    FZoom:= TMenuItem(Sender).Tag;
  SetZoom;
  If TMenuItem(Sender).Tag >= 1 then
    ListView_SetWidth
  else
    for i := 0 to popZoom.Count -3 do
      TMenuItem(popZoom.Items[i]).Checked:= false;
  LV_MakeItemVisible(-1);
end;

procedure TForm1.popResetDefaultPosClick(Sender: TObject);
var
  ini: TInifile;
begin
  ini:= TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  If Assigned(ini) then
  begin
    If WindowState = wsMaximized then
      WindowState:= wsNormal;
    Try
      Left:= ini.ReadInteger('Main', 'Left', 100);
      Top:=  ini.ReadInteger('Main', 'Top', 100);
      Width:= ini.ReadInteger('Main', 'Width', 280);
      Height:= ini.ReadInteger('Main', 'Height', 500);
    Finally
      ini.Free;
    End;
    if popFormAutoMove.Checked then
      ListView_SetWidth;
  end;
end;

procedure TForm1.popRunAvsPAllTabsClick(Sender: TObject);
var
  param,s: String;
  i: Integer;
begin
  For i:= 0 to TabView.Tabs.Count -1 do
  begin
    s:= MakeAVSExt(GetClip(i).LastOpen);
    If FileExists(s) and (Pos(s, param) < 1) then
      param:= param + '"' + s + '" ';
    if i > 19 then //- more ?
      break;
  end;

  If FileUtils.ExecuteFile(fRunProg, param) < 33 then
    MessageBeep(MB_ICONERROR)
  else sleep(100);
end;

procedure TForm1.popRunAvsPClick(Sender: TObject);
var
  avs: String;
begin
  If not FileExists(fRunProg) or (Byte(GetKeyState(VK_CONTROL)) > 100) then
  with OpenDlg do
  begin
    Filter:= 'AvsPmod|AvsPmod.exe|Executables|*.exe|All|*.*';
    FileName:= '';
    If not Execute(Handle) then
      exit;
    fRunProg:= FileName;
  end;

  If CurrentClip.AvsWnd > 0 then
  begin
    If not IsWindow(CurrentClip.AvsWnd) then
    begin
      CurrentClip.AvsWnd:= 0;
      CurrentClip.AvsP_video_w:= 0;
      SplitUpdateWnd(CurrentClip);
    end
    else
      if MessageDlg('AvsPmod already opened, do you want to open it again?',
                    mtConfirmation,[mbCancel,mbYes],0,mbCancel) <> mrYes then
                      exit;
  end;

  avs:= MakeAVSExt(CurrentClip.LastOpen);

  If FileExists(avs) then
  begin
    if Byte(GetKeyState(vkControl)) > 100 then
    begin
      if FindAvsWnd() then
      begin
        SendCopyData(CurrentClip.AvsWnd, avs, 2, 1000);
        exit;
      end;
    end;
    screen.Cursor:= crHourGlass;
    Application.ProcessMessages;

    If FileUtils.ExecuteFile(fRunProg, '"'+avs+'"') < 33 then
      MessageBeep(MB_ICONERROR)
    else sleep(100);

    screen.Cursor:= crDefault;
    Application.ProcessMessages;

    if (LV.Items.Count > 0) and FindAvsWnd(1000) then
    begin
      sleep(100);
      PostMessage(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_SIZE);
      sleep(20);
      Application.ProcessMessages;
    end;
    BringWindowToTop(Handle);
    SetActiveWindow(Handle);
  end
  else ShowMessage('Cannot find the avs file.'#13#13 + ExtractFileName(avs));

end;

procedure TForm1.popSaveBookmarksClick(Sender: TObject);
var
  i,shift: Integer;
  s: String;
  SL: TStringList;
  P: PFrameRec;
  w: TWindowState;
begin
  w:= WindowState;
  WindowState:= wsMinimized;
  SetForegroundWindow(Handle);
  SL:= TStringList.Create;
  Try
    s:= InputBox('Shift Bookmarks', 'choose - or + to shift frame by number.', '0');
    if s = '' then
      exit;
    shift:= StrToIntDef(s, 0);
    s:=  ChangeFileExt(CurrentClip.LastOpen, '.cr.txt');
    For i:= 0 to CurrentClip.FrameList.Count-1 do
    begin
      P:= PFrameRec(CurrentClip.FrameList[i]);
      if P^.Title = '' then
        SL.Add(IntToStr(P^.FrameNr + shift))
      else
        SL.Add(IntToStr(P^.FrameNr + shift) + ' ' + P^.Title);
    end;
    SL.SaveToFile(GetNewFileName(s));
  Finally
    SL.Free;
    WindowState:= w;
  End;
end;

procedure TForm1.popSaveGroupClick(Sender: TObject);
var
  SL: TStringList;
  i, NoStream: Integer;
  Clip: TClip;
  idxLV: Integer;
  addIdx: boolean;
  tabset_lastidx: Integer;
  s: String;
begin
  addIdx:= Byte(GetKeyState(vkControl)) > 100;

  if not addIdx then
    addIdx:= TaskMessageDlgPos('Option','Add the selected ListView Indexes ?',
                          mtConfirmation,[mbNo,mbYes],0,
                          Min(Left+5, Screen.Width-380),Top+25) = mrYes;
  NoStream:= 0;
  SL:= TStringList.Create;
  Try
    For i:= 0 to TabView.Tabs.Count -1 do
    begin
      Clip:= GetClip(i);
      if Assigned(Clip.FileStream) then //- also not added on Split clip
      begin
        tabset_lastidx:= 0;
        If addIdx then
        begin
          If Clip = CurrentClip then
          begin
            tabset_lastidx:= TabSet.TabIndex;
            idxLV:= LV.ItemIndex;
          end
          else begin
            tabset_lastidx:= Clip.TabSet_LastIndex;
            Case tabset_lastidx of
              1: idxLV:= Clip.LastIndexFV;
              2: idxLV:= Clip.LastIndexFV2;
              else idxLV:= Clip.LastIndexLV;
            end;
          end;
        end
        else idxLV:= -1;

        SL.Add(Clip.LastOpen+'|'+IntToStr(tabset_lastidx)+','+IntToStr(idxLV))
      end
      else inc(NoStream);

    end;
    if SL.Count > 0 then with SaveDlg do
    begin
      InitialDir:= ProgramPath + 'Groups';
      FileName:= 'New group';
      Filter:= 'Groups (' + GroupExt + ')|*' + GroupExt;
      Options:= Options - [ofOverwritePrompt];
      Try
        If not SaveDlg.Execute(Handle) then
           exit;
      finally
        Options:= Options + [ofOverwritePrompt];
      end;

      s:= ChangeFileExt(RemoveFileExt(FileName), GroupExt);
      If FileExists(s) then
      begin
        If MessageDlg('File allready exists. Override the existing file?',
                       mtConfirmation, [mbYes, mbNo],0) <> mrYes then
                         exit;
      end;

      SL.SaveToFile(s);
      //- read groups new
      SL.Clear;
      FileUtils.GetFileList(ProgramPath + 'Groups','*' + GroupExt,SL,True,False,False);
      AddGroups(SL);
    end
    else begin
      MessageDlg('Nothing saved, no bookstream available.', mtInformation, [mbOK],0);
      exit;
    end;

    if NoStream > 0 then
      MessageDlg(IntToStr(NoStream) +
        ' Clips not saved, becourse no bookstream available.', mtInformation,[mbOK],0);
  finally
    SL.Free;
  end;

end;

procedure TForm1.popOpenGroupsFolderClick(Sender: TObject);
begin
  FileUtils.ExecuteExplorer(ProgramPath + 'Groups\')
end;

procedure TForm1.SaveDefaultPos1Click(Sender: TObject);
var ini: TInifile;
begin
  ini:= TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  If Assigned(ini) then
  begin
    Try
      ini.WriteInteger('Main', 'Left', Left);
      ini.WriteInteger('Main', 'Top', Top);
      ini.WriteInteger('Main', 'Width', Width);
      ini.WriteInteger('Main', 'Height', Height);
    Finally
      ini.Free;
    End;
  end;
  FDefLeft:= Left;
  FDefWidth:= Width;
end;

procedure TForm1.popSaveImagesClick(Sender: TObject);
var
  i,e, error: Integer;
  s,SaveName: String;
  P: PFrameRec;
begin
  If ActiveList.Count < 1 then
    exit;
  With SaveDlg do
  begin
    Filter:= 'Bitmap|*.bmp';
    If CurrentClip.LastFile <> '' then
    begin
      InitialDir:= ForceBackslash(ExtractFilePath(CurrentClip.LastFile));
      If IsBookmarkExt(CurrentClip.LastFile) then
        FileName:= ExtractFileNameNoExt(ChangeFileExt(CurrentClip.LastFile, '')) + '.bmp'
      else FileName:= ExtractFileNameNoExt(CurrentClip.LastFile) + '.bmp';
    end;
    if not Execute then
      exit;
  end;
  SaveName:= ChangeFileExt(SaveDlg.FileName, '');
  error:= 0;
  Screen.Cursor:= crHourGlass;
  Application.ProcessMessages;
  Try
    Try
       For i:= 0 to ActiveList.Count-1 do
       begin
         e:= 0;
         P:= ActiveList[i];
         s:=  SaveName + '_' + IntTostr(P^.FrameNr);
         While FileExists(s + '.bmp') and (e < 6) do
         begin
           s:= s + '_';
           inc(e);
         end;
         If e < 6 then
           P^.bmp.SaveToFile(s + '.bmp')
         else inc(error);
       end;
    Except
      MessageDlg('Unknown error',mtError,[mbOK],0);
    End;
  Finally
    Screen.Cursor:= crDefault;
  End;

  If error > 0 then
     MessageDlg(IntToStr(error) + ' Pictures not saved.'+#13+
                'File name already exists.',mtWarning,[mbOK],0)
end;

procedure TForm1.OpenBookFile(const fileName : String = ''; const AddNewClip: boolean=True);
var
  avs, errFile, errBook: String;
  aFiles: Array of String;
  i: Integer;
begin
  errFile:= '';
  errBook:= '';
  Try
    If fileName = '' then with OpenDlg do
    begin
      Filter:= 'All supported files|*.avs;*.cr.txt;*'+fext+'|'+
               'Avisynht (*.avs)|*.avs|'+
               'Bookmarks (*.cr.txt)|*.cr.txt|'+
               'Bookstream (*' + fext +')|*' + fext;
      If CurrentClip.LastFile <> '' then
      begin
        InitialDir:= ExtractFilePath(CurrentClip.LastFile);
        OpenDlg.FileName:= ExtractFileName(CurrentClip.LastFile);
      end
      else if (CurrentClip.LastOpen <> '') then
      begin
        InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
        OpenDlg.FileName:= MakeAVSExt(CurrentClip.LastOpen);
      end;
      If not Execute then
        exit;
      SetLength(aFiles, OpenDlg.Files.Count);
      For i:= 0 to High(aFiles) do
         aFiles[i]:= OpenDlg.Files[i];
    end
    else begin
      SetLength(aFiles, 1);
      aFiles[0]:= fileName;
    end;

    For i:= 0 to High(aFiles) do
    begin
      //- Load from bookstream
      If SameText(ExtractFileExt(aFiles[i]), fext) then
      begin
        LoadFromStream(aFiles[i]);
        Continue;
      end;

      //- Find and open avs
      avs:= MakeAVSExt(aFiles[i]);
      If not FileExists(avs) then
      begin
        if errFile = '' then errFile:= 'Avs file not found:'#13#13;
        errFile:= errFile + avs+#13;
        Continue;
      end;

      If FileExists(aFiles[i]) then
      begin
        //- Add empty clip
        if AddNewClip and (GetCurrentClip.FrameList.Count > 0) then
          NewClip();

        if LoadBookmarksFromFile(aFiles[i], CurrentClip.FrameList, CurrentClip.FavorList) > 0 then
        begin
          CurrentClip.LastFile:= aFiles[i];
          GetBookmarksThumbs(avs);
          if not FStop and (CurrentClip.FrameList.Count > 0) then
            CurrentClip.NeedSave:= true;
          SetCaption();
        end
        else begin
          if errBook = '' then
            errBook:= 'No Bookmarks found:'#13;
          errBook:= errBook + aFiles[i]+#13
        end;
      end
      else begin
        //~FLastFile:= '';
      end;
    end;

    //- Remove last empty clip
    If (GetCurrentClip.FrameList.Count < 1) and (TabView.Tabs.Count > 1) then
      CloseTabs([TabView.TabIndex]);
  Finally
    aFiles:= [];
    If (errFile <> '') or (errBook <> '') then
      ShowMessage(errFile + errBook);
  End;
end;


procedure TForm1.popOpenLastSavedStreamClick(Sender: TObject);
var
  item: TMenuItem;
  i: Integer;
begin
  if (Sender <> popOpenLastSavedStream) and (Sender.ClassType = TMenuItem) then
  begin
    item:= TMenuItem(Sender);
    If FileExists(item.Hint) then
      LoadFromStream(item.Hint)
    else begin
      i:= FHistoryList.IndexOf(item.Hint);
      if i > -1 then
        FHistoryList.Delete(i);
      i:= popOpenLastSavedStream.IndexOf(item);
      if i > -1 then
        popOpenLastSavedStream.Delete(i);
      beep
    end;
  end;
end;

procedure TForm1.OpenGroup(Sender: TObject);
var
  item: TMenuItem;
  i,Error,TabIdx,LVidx: Integer;
  SL: TStringList;
  s: String;
  a,ap: TArray<String>;
begin
  SL:= TStringList.Create;
  Error:= 0;
  Try
    item:= TMenuItem(Sender);
    If FileExists(item.Hint) then
    begin
      SL.LoadFromFile(item.Hint);
      popCloseAllTabsClick(self);
      For i:= 0 to SL.Count -1 do
      begin
        SL[i]:= TrimLeft(SL[i]);

        //- Select TabSet and LV item eg. D:\MyFavorite.bk6|0,8 )
        TabIdx:= -1;
        LVidx:= -1;

        If SL[i].Contains('|') then
        begin
          a:= SL[i].Split(['|']);
          s:= Trim(a[0]);
          Try
            ap:= a[1].Split([',']);
            Tabidx:= StrToIntDef(ap[0], -1);
            LVidx:= StrToIntDef(ap[1], -1);
          except
            Tabidx:= -1;
            LVidx:= -1;
          end;
        end
        else s:= SL[i];

        If FileExists(s) then
        begin
          LoadFromStream(s);
          //- select now the items
          if (TabIdx > -1) and (Tabidx < TabSet.Tabs.Count) then
          begin
            TabSet.TabIndex:= TabIdx;
            If (LVidx > -1) and (LVidx < LV.Items.Count) then
              LV_MakeItemVisible(LVidx, True, True);
          end;
          //-
        end
        else begin
          inc(Error);
          If not SL[i].StartsWith('#') then
            SL[i]:= '###' + SL[i]; //- mark this line
        end;
      end;
    end
    else begin
      MessageDlg('File not found:'#13+item.Hint,mtError,[mbOk],0);
      exit;
    end;
    If Error > 0 then
    begin
      //- Save the changes and show the group file
      SL.SaveToFile(item.Hint);
      MessageDlg('Some Bookstreams not found in:'#13 + item.Caption + #13#13 +
                 'Errors market with ### at the first chars.'#13#13+
                 'After closing this Message the editor should open the file.'#13+
                 'Change or remove the line(s) and save it.',mtError,[mbOK],0);
      If ExecuteFile(item.Hint) < 33 then
        FileUtils.ExecuteExplorer(item.Hint);
    end;
  finally
    SL.Free;
  end;
end;


{
procedure TForm1.OpenGroup(Sender: TObject);
var
  item: TMenuItem;
  i,Error: Integer;
  SL: TStringList;
begin
  SL:= TStringList.Create;
  Error:= 0;
  Try
    item:= TMenuItem(Sender);
    If FileExists(item.Hint) then
    begin
      SL.LoadFromFile(item.Hint);
      popCloseAllTabsClick(self);
      For i:= 0 to SL.Count -1 do
      begin
        SL[i]:= TrimLeft(SL[i]);
        If FileExists(SL[i]) then
          LoadFromStream(SL[i])
        else begin
          inc(Error);
          If not SL[i].StartsWith('#') then
            SL[i]:= '###' + SL[i]; //- mark this line
        end;
      end;
    end
    else begin
      MessageDlg('File not found:'#13+item.Hint,mtError,[mbOk],0);
      exit;
    end;
    If Error > 0 then
    begin
      //- Save the changes and show the group file
      SL.SaveToFile(item.Hint);
      MessageDlg('Some Bookstreams not found in:'#13 + item.Caption + #13#13 +
                 'Errors market with ### at the first chars.'#13#13+
                 'After closing this Message the editor should open the file.'#13+
                 'Change or remove the line(s) and save it.',mtError,[mbOK],0);
      If ExecuteFile(item.Hint) < 33 then
        FileUtils.ExecuteExplorer(item.Hint);
    end;
  finally
    SL.Free;
  end;
end;
}

procedure TForm1.AddTabToGroup(Sender: TObject);
 var
  item: TMenuItem;
  SL: TStringList;
  idx: Integer;

  function SL_IndexOf(const s: String): boolean;
  var
    i: Integer;
  begin
    For i:= 0 to SL.Count -1 do
      if SameText(Copy(SL[i], 1, Length(s)), s) then
      begin
        Result:= True;
        exit;
      end;

    Result:= False;
  end;
begin
  If not Assigned(CurrentClip.FileStream) then
  begin
    MessageDlg('Clip not saved.'#13+
               'You must first save it as a stream.',mtError,[mbOK],0);
    exit;
  end;

  item:= TMenuItem(Sender);
  If not FileExists(item.Hint) then
  begin
    MessageDlg('Group file not found.',mtError,[mbOK],0);
    //- Read groups new
    AddGroups();
    exit;
  end;

  SL:= TStringList.Create;
  Try
    SL.LoadFromFile(item.Hint);
    If not SL_IndexOf(CurrentClip.LastOpen) then
    begin
      SL.Add(CurrentClip.LastOpen+'|'+IntToStr(TabSet.TabIndex)+','+IntToStr(LV.ItemIndex));
      SL.SaveToFile(item.Hint);
    end
    else
      MessageDlg('Clip already included in the group file.'#13+
                 'Nothing done.',mtInformation,[mbOK],0);
  finally
    SL.Free;
  end;
end;

procedure TForm1.popOpenClick(Sender: TObject);
begin
  OpenBookFile();
end;

procedure TForm1.popReOpen240Click(Sender: TObject);
var
  i, defW: Integer;
  s: String;
  favor: TStringList;
  P: PFrameRec;

  procedure AddFavorites(list: TStringList);
  var
    i,x,z: Integer;
  begin
    For i:= 0 to CurrentClip.FrameList.Count -1 do
    begin
      P:= PFrameRec(CurrentClip.FrameList[i]);
      z:= list.IndexOfName(IntToStr(P^.FrameNr));
      if z > -1 then
      begin
        x:= StrToIntDef(list.ValueFromIndex[z], 0);
        if GetBit(x, 1) then
          AddFavorList(CurrentClip.FrameList, CurrentClip.FavorList, i);
        if GetBit(x, 2) then
          AddFavorList(CurrentClip.FrameList, CurrentClip.Favor2List, i);
      end;
    end;
    CurrentClip.FavorList.Sort(@SortListFunc_FrameNr);
    CurrentClip.Favor2List.Sort(@SortListFunc_FrameNr);
  end;

begin
  If IsSplitClip(CurrentClip) then
    exit;
  defW:= DefaultThumbWidth;
  DefaultThumbWidth:= TMenuItem(sender).Tag;
  If Assigned(CurrentClip.FileStream) then
    s:= ChangeFileExt(CurrentClip.LastOpen, '.avs')
  else s:= CurrentClip.LastFile;

  If (CurrentClip.FavorList.Count > 0) or (CurrentClip.Favor2List.Count > 0) then
  begin
    favor:= TStringList.Create;
    For i := 0 to CurrentClip.FrameList.Count-1 do
    begin
      P:= PFrameRec(CurrentClip.FrameList[i]);
      If GetBit(P^.BitInt, 1) or GetBit(P^.BitInt, 2) then
        favor.Add(IntToStr(P^.FrameNr) + '=' + IntToStr(P^.BitInt));
    end;
  end
  else favor:= nil;

  Try
    If FileExists(s) then
    begin
      OpenBookFile(s, False);
      if Assigned(favor) then
        AddFavorites(favor);
    end
    else MessageDlg('File not found:'#13+s, mtError, [mbOK],0);
  Finally
    if Assigned(favor) then
      favor.Free;
    DefaultThumbWidth:= defW;
    LV.UpdateItems(0, LV.Items.Count-1);
  End;
end;

procedure TForm1.popReOpenCustomSizeClick(Sender: TObject);
var
  s: String;
  i: Integer;
  w: TWindowState;
begin
  w:= WindowState;
  WindowState:= wsMinimized;
  SetForegroundWindow(Handle);
  s:= IntToStr(popReOpenCustom.Tag);
  If not InputQuery('ReOpen Custom Size', '120 to 1280', s) then
  begin
    WindowState:= w;
    exit;
  end;
  i:= StrToIntDef(s, -1);
  If (i > 119) and (i < 1281) then
  begin
    If Sender = popReOpenSizeCustom then
    begin
      popReOpenSizeCustom.Tag:= i;
      WindowState:= wsNormal;
      popReOpen240Click(popReOpenSizeCustom);
      exit;
    end
    else begin
       popReOpenCustom.Tag:= i;
       popReOpenCustom.Caption:= IntTostr(i);
    end;
  end
  else ShowMessage('Invalid Input');
  WindowState:= w;
end;

procedure TForm1.popDefThumbWidthClick(Sender: TObject);
var
  s: String;
  i: Integer;
  w: TWindowState;
begin
  w:= WindowState;
  Try
    WindowState:= wsMinimized;
    SetForegroundWindow(Handle);
    s:= IntToStr(DefaultThumbWidth);
    If not InputQuery('Default Thumb Width', '120 to 1280', s) then
      exit;

    i:= StrToIntDef(s, -1);
    If (i > 119) and (i < 1281) then
      DefaultThumbWidth:= i
    else ShowMessage('Invalid Input');
  Finally
    WindowState:= w;
  End;
end;

procedure TForm1.ProzessParamStr(const fFile, fParam1 :  String);
var
  i: Integer;
begin
  If (fFile <> '') and FileExists(fFile) then
  begin
    //- add empty clip is the current not empty
    //- proccesed by the open func

    i:= DefaultThumbWidth;
    Try
      If fParam1 <> '' then
        DefaultThumbWidth:= StrToIntDef(fParam1, DefaultThumbWidth);

      If IsBookmarkExt(fFile) then
        OpenBookFile(fFile)   //- load from bookmark file (*.cr.txt)
      else if SameText(ExtractFileExt(fFile), fext) then
      begin
        LoadFromStream(fFile);  //- LoadFromBookstream (.bk3, .bk6)
      end
      else if SameText(ExtractFileExt(fFile), '.avs') then
      begin
        If FileExists(ChangeFileExt(fFile, '.cr.txt')) then  //- force bookmark file over avs..? mybe remove it
          OpenBookFile(ChangeFileExt(fFile, '.cr.txt'))
        else OpenBookFile(fFile) //- read bookmarks from avs
      end
      else //- if not found try do find the file from the media filename
{$IFDEF WIN64}
        If FileExists(fFile + '_x64.avs') then //- my own extension for avs 64bit scripts
          OpenBookFile(fFile + '_x64.avs')
        else if FileExists(ChangeFileExt(fFile,'_x64.avs')) then
          OpenBookFile(ChangeFileExt(fFile,'_x64.avs'))

        else {$endif} if FileExists(fFile + '.avs') then
          OpenBookFile(fFile + '.avs')
        else if FileExists(ChangeFileExt(fFile,'.avs')) then
          OpenBookFile(ChangeFileExt(fFile,'.avs'))
        else if FileExists(ChangeFileExt(fFile, '') + '.cr.txt') then
          OpenBookFile(ChangeFileExt(fFile, '') + '.cr.txt')
        else if FileExists(fFile + '.cr.txt') then
          OpenBookFile(fFile + '.cr.txt')
        else ShowMessage('Can not find a suitable file for:'#13+fFile);
    finally
      DefaultThumbWidth:= i;
    end;

    //- finds not the tab in AvsP, finds only the first instance of an AvsP Wnd.
    //- if the found Wnd not the right, LV.OnMouseDown does then search for the tab
    //FindAvsWnd();

    //- Get AvsP info if AvsP Wnd exists (bad idea on startup)
    {
    if (LV.Items.Count > 0) and (CurrentClip.AvsWnd = 0) and FindAvsWnd and
      (SendMessageTimeout(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_SIZE,
                         SMTO_ABORTIFHUNG or SMTO_BLOCK,250,nil) <> 0) then
      begin
        sleep(100);
        Application.ProcessMessages;
      end;
    }
  end;
end;

procedure TForm1.popZ100FitClick(Sender: TObject);
begin
  if WindowState <> wsNormal then
    WindowState:= wsNormal;
  UpdateWindow(Handle);
  popZ50Click(popZ100Fit);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
  s: String;
  Clip: TClip;
begin
  CanClose:= False;

  If FTaskCount > 0 then
  begin
    MessageDlg('External thread is loading or waiting for AvsPmod.'#13+
               'Program will wait max 30 seconds for AvsPmod.'#13+
               'Or stop loading or close AvsPmod, then try again.', mtInformation,[mbOK],0);
    exit;
  end;

  s:= '';
  For i:= 0 to TabView.Tabs.Count-1 do
  begin
    Clip:= GetClip(i);
    If Clip.NeedSave and (Clip.FrameList.Count > 0) then
      s:= s + 'Tab ' + IntToStr(i+1)+#13;
  end;

  If s <> '' then
  begin
    CanClose:= MessageDlg('Changes not saved. Exit program?'#13+ s,
                           mtConfirmation, mbYesNo,0,mbNo) <> mrNo;
  end
  else CanClose:= true;
end;

procedure TForm1.popStyle_0Click(Sender: TObject);
var
  s: String;
  Style : TStyleInfo;
  w: TWindowState;

  procedure UpdateStyle;
  begin
    w:= WindowState;
    WindowState:= wsMinimized;
    sleep(200);
    Application.ProcessMessages;
    WindowState:= w;
    Update;
    Repaint;
    If popZFit.Checked then
    begin
      popZFit.Tag:= 0;
      FZoom:= 100;
      SendMessage(Handle, WM_SIZE, SIZE_RESTORED, 0);
    end;
    SetForegroundWindow(Handle);
    If LV.Enabled then
      LV.SetFocus;
  end;

begin
  If TMenuItem(Sender).Hint = 'Windows' then
  begin
    If TStyleManager.ActiveStyle.Name <> 'Windows' then
    begin
      If TStyleManager.TrySetStyle('Windows', True) then
        FDefStyle:= TMenuItem(Sender).Caption;
      If LV.Items.Count > 0 then
        UpdateStyle
      else SetZoom;
    end;
  end
  else begin
    s:= ProgramPath+'Themes\' + TMenuItem(Sender).Caption + '.vsf';
    If FileExists(s) and TStyleManager.IsValidStyle(s, Style) then
    begin
      If TStyleManager.ActiveStyle.Name = Style.Name then
        exit;
      If not Assigned(TStyleManager.Style[Style.Name]) then
        TStyleManager.LoadFromFile(s);
      If TStyleManager.TrySetStyle(Style.Name, True) then
        FDefStyle:= TMenuItem(Sender).Caption;
      If LV.Items.Count > 0 then
        UpdateStyle
      else SetZoom;
    end;
  end;
end;

procedure OnProcessParamTimer;
var
  x: Integer;
  s,w: String;
begin with Form1 do
begin
  KillTimer(Handle, 1111);
  // TODO make it better
  x:= 1;
  While x <= ParamCount do
  begin
    w:= '';
    s:= ParamStr(x);
    If x < ParamCount then
    begin
      inc(x);
      w:= ParamStr(x);
    end;
    If (w <> '') then
    begin
      If not FileExists(w) then
         ProzessParamStr(s, w)
      else begin
        ProzessParamStr(s, '');
        ProzessParamStr(w, '');
      end;
    end
    else ProzessParamStr(s, '');
    inc(x);
  end;
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
 ini: TInifile;
 ZoomIdx,i,x: Integer;
 SL: TStringList;
 item: TMenuItem;

begin
  //- If we can not write to the program directory... Terminate
  ini:= nil;
  Try
    ini:= TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  except
    MessageDlg('Can not open the options file, no write access to:'#13+
                ExtractFilePath(Application.ExeName)+#13#13+
               'The program will now be closed.', mtError, [mbOK],0);
    Halt;
  End;

  //- For saving and reading groups
  If not DirectoryExists(ProgramPath + 'Groups') then
    CreateDir(ProgramPath + 'Groups');

  Caption:= myName;
  popLoadFromStream.Caption:= 'Load from Stream (' + fext + ')';
  popSaveToStream.Caption:= 'Save to Stream (' + fext + ')';

  FMaxHistoryCount:= 15;
  DefaultThumbWidth:= 360;
  popReOpenCustom.Tag:= 640;
  FZoom:= 100;
  ZoomIdx:= 2;
  FTaskCount:= 0;
  FJPEGQuality:= 85;
  FHide_SB_HORZ:= true;
  popSendCommand.Caption:= 'Send Command';
  FDefStyle:= 'Windows';
  FMaxBmCount:= 1000;
  AVSGrabber:= TAvisynthGrabber.Create;

  Fbmp:= TBitmap.Create;
  FHistoryList:= TStringList.Create;
  FHistoryList.Sorted:= False;

  //- Add empty clip
  TabView.Tabs.Clear;
  NewClip();

  If Assigned(ini) then
  begin
    Try
      FDefStyle:= ini.ReadString('Main', 'DefStyle', 'Windows');
      Left:= ini.ReadInteger('Main', 'Left', Screen.WorkAreaWidth - 290);
      Top:= ini.ReadInteger('Main', 'Top', 10);
      Width:= ini.ReadInteger('Main', 'Width', 280);
      Height:= ini.ReadInteger('Main', 'Height', Screen.WorkAreaHeight- 20);
      DefaultThumbWidth:= ini.ReadInteger('Main', 'DefThumbWidth', 360);
      popReOpenCustom.Tag:= ini.ReadInteger('Main', 'ReOpenCustomSize', 640);
      popFormAutoMove.Checked:= ini.ReadBool('Main', 'FormAutoMove', True);
      popSingleInstance.Checked:= ini.ReadBool('Main', 'SingleInstance', true);
      fRunProg:= ini.ReadString('Main', 'RunProg', '');
      popShowTitle.Checked:= ini.ReadBool('Main', 'ShowTitle', False);
      popTitleAutoAddFavor.Checked:= ini.ReadBool('Main', 'TitleAutoAddFavor', true);
      ZoomIdx:= iniReadRadioItem(ini, 'Main', 'Zoom', 2, popZoom);
      FJPEGQuality:= ini.ReadInteger('Main', 'JPEG_Q', 85);
      //popAfterSaveToStreamOpenStream.Checked:= ini.ReadBool('Main', 'AfterSaveOpen', True);
      //popAvsPTabsChange.Checked:= ini.ReadBool('Main', 'AvsPtabschange', true);
      popAvsPscrolldiv2.Checked:= ini.ReadBool('Main', 'AvsPscrolldiv2', True);
      popAvsPscrollreverse.Checked:= ini.ReadBool('Main', 'AvsPscrollreverse', false);
      FMaxHistoryCount:= ini.ReadInteger('Main', 'MaxHistoryCount', 20);
      popForceAvsPWnd.Checked:= ini.ReadBool('Main', 'TabForceAvsWnd', False);
      popShowPreview.Checked:= ini.ReadBool('Main', 'TabShowPreview', True);
      LV.Color:= ini.ReadInteger('Main', 'BackgroundColor', clBlack);
      popClipExtraMenu.Visible:= not ini.ReadBool('Main', 'HideClipMenu', False);

      //- Tweaks
      //-- hide the LV horizontal scroll bar
      FHide_SB_HORZ:= ini.ReadBool('Tweaks', 'Hide_SB_HORZ', true);
      //-- remove the Style from Dialogs
      If ini.ReadBool('Tweaks', 'StyleHook_shDialog', false) then
        with TStyleManager do SystemHooks:= SystemHooks - [shDialogs];
      FClipsToClipTweak:= ini.ReadBool('Tweaks', 'ClipsToClipTweak', False);
      FMaxBmCount:= ini.ReadInteger('Tweaks', 'MaxBmCount', 1000);
    Finally
      ini.Free;
    End;
  end;

  If FHide_SB_HORZ then
  begin
    FListViewWndProc := LV.WindowProc; //- save old window proc
    LV.WindowProc := ListViewWndProc;  //- subclass
  end;

  SL:= TStringList.Create;
  Try
    //- History bookstream
    Try
      SL.LoadFromFile(ChangeFileExt(Application.ExeName, '.dat'));
      if SL.Count > 0 then
        for i:= 0 to SL.Count-1 do
          AddLastSavedStream(SL[i]);
    except
    end;

    SL.Clear;
    //- Add groups to menu
    Try
      FileUtils.GetFileList(ProgramPath + 'Groups','*' + GroupExt,SL,True,False,False);
      if SL.Count > 0 then
        AddGroups(SL);
    except
    end;

    //- Send command to AvsP menu  (add submenus to 'Send command')
    SL.Clear;

    If FileExists(ProgramPath + 'AvsPCommand.txt') then
    begin
      Try
        SL.LoadFromFile(ProgramPath + 'AvsPCommand.txt');
        For i:= 0 to SL.Count-1 do if not TrimLeft(SL[i]).StartsWith('#') then
        begin
          item:= TMenuItem.Create(self);
          popSendCommand.Add(item);
          If SL[i].Contains('|') then
          begin
            x:= Pos('|', SL[i]);
            item.Caption:= Trim(Copy(SL[i],1,x-1));
            item.Hint:= Trim(Copy(SL[i], x+1, MaxInt));
          end
          else if TrimLeft(SL[i]).StartsWith('-') then
          begin
            item.Caption:= '-';    //- Add a item seperator
            Continue;
          end
          else begin
            item.Caption:= SL.Names[i];
            item.Hint:= SL[i];
          end;
          item.AutoHotkeys:= maManual;
          item.OnClick:= OnCommand;
        end;
      except
      end;
    end
    else begin
      SL.Add('#Copy image to clipboard=2');
      Try
        SL.SaveToFile(ProgramPath + 'AvsPCommand.txt');
      except
      end;
    end;

    //-Themes
    SL.Clear;
    Try
      FileUtils.GetFileList(ProgramPath+'Themes\','*.vsf',SL,False,False,True);
      x:= Min(SL.Count-1, 79) ;//- We don't need so many Themes
      For i:= 0 to x do
      begin
        item:= TMenuItem.Create(self);
        item.RadioItem:= True;
        item.AutoCheck:= True;
        item.Caption:= SL[i];
        item.OnClick:= popStyle_0Click;
        If (i mod 20 = 0) and (SL.Count > 24) then
          item.Break:= mbBarBreak;
        popThemes.Add(item);
        if SameText(SL[i], FDefStyle) then
        begin
          item.Checked:= True;
          popStyle_0Click(item);
        end;
      end;
    except
    end;
  Finally
    SL.Free;
  End;

  popReOpenCustom.Caption:= IntToStr(popReOpenCustom.Tag);
  CurrentClip.AR:= 16/9;
  CurrentClip.ThumbWidth:= DefaultThumbWidth;
  CurrentClip.ThumbHeight:= Round(CurrentClip.ThumbWidth/CurrentClip.AR);
  FDefLeft:= Left;
  FDefWidth:= Width;
  DummyImL:= ImageList_Create(CurrentClip.ThumbWidth-12,CurrentClip.ThumbHeight,ILC_COLOR24,1,0);
  ImageList_SetIconSize(DummyImL,Round((CurrentClip.ThumbWidth/100)*FZoom)-12,
                                 Round((CurrentClip.ThumbHeight/100)*FZoom));
  ListView_SetImageList(LV.Handle,DummyIML,LVSIL_NORMAL);
  ListView_SetIconSpacing(LV.Handle,Round((CurrentClip.ThumbWidth/100)*FZoom)+ 5,
                                       Round((CurrentClip.ThumbHeight/100)*FZoom)+ 25);
  Application.OnMessage:= AppOnMessages;
  //~Application.OnIdle:= AppOnIdle;


  Show;
  if popZoom.Items[ZoomIdx].Tag <> 100 then
    popZoom.Items[ZoomIdx].Click;

  If ParamCount > 0 then
  begin
    //- Delphi style bug!
    //- If the create routine is not finished
    //- there is an error if the window status is set to minimized.
    //- So we start the Param process over an timer.
    If SetTimer(Handle, 1111, 200, @OnProcessParamTimer) = 0 then
      MessageDlg('Error SetTimer: Cannot process the ParamStr',mtError,[mbOK],0);
  end;

  //- Enable AvsP custom handler and get info
  //~if (LV.Items.Count > 0) and FindAvsWnd then
    //~PostMessage(CurrentClip.AvsWnd, AVSP_INFORM, Handle, AVSP_VIDEO_SIZE);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  ini: TInifile;
  i: Integer;
  Clip: TClip;
  SL: TStringList;
begin
  //- disable AvsP custom handler..
  //-if not single instance, next Avs Thumb must get the handles again
  SL:= TStringList.Create;
  Try
    Try
      For i:= 0 to TabView.Tabs.Count -1 do
      begin
        Clip:= GetClip(i);
        If Clip.AvsWnd > 0 then
          PostMessage(Clip.AvsWnd, AVSP_INFORM, 0, 0);
        //- save last tabs as group
        if Assigned(Clip.FileStream) then
          SL.Add(Clip.LastOpen)
      end;
      If SL.Count > 0 then
        SL.SaveToFile(ProgramPath + 'Groups\' + 'Last' + GroupExt);
    except
    end;
  finally
    SL.Free;
  end;

  AVSGrabber.Free;
  For i:= 0 to TabView.Tabs.Count-1 do
    GetClip(i).Free;

  ImageList_Destroy(DummyImL);
  Fbmp.Free;

  If FHide_SB_HORZ then
  begin
    LV.WindowProc := FListViewWndProc; //- restore window proc
    FListViewWndProc := nil;
  end;

  Try
    ini:= TInifile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  except
    FHistoryList.Free;
    MessageDlg('Can not save the options file, no write access to:'#13+
                ProgramPath, mtError, [mbOK],0);
    exit;
  end;

  Try
    FHistoryList.SaveToFile(ChangeFileExt(Application.ExeName, '.dat'));
  except
  end;
  FHistoryList.Free;

  If Assigned(ini) then
  begin
    Try
      ini.WriteString('Main', 'DefStyle', FDefStyle);
      ini.WriteInteger('Main', 'DefThumbWidth',  DefaultThumbWidth);
      ini.WriteInteger('Main', 'ReOpenCustomSize', popReOpenCustom.Tag);
      ini.WriteBool('Main', 'FormAutoMove', popFormAutoMove.Checked);
      ini.WriteBool('Main', 'SingleInstance', popSingleInstance.Checked);
      ini.WriteBool('Main', 'ShowTitle', popShowTitle.Checked);
      ini.WriteBool('Main', 'TitleAutoAddFavor', popTitleAutoAddFavor.Checked);
      ini.WriteString('Main', 'RunProg', fRunProg);
      GPoUtils.iniWriteRadioItem(ini, 'Main', 'Zoom', popZoom);
      ini.WriteInteger('Main', 'JPEG_Q', FJPEGQuality);
      //ini.WriteBool('Main', 'AfterSaveOpen',  popAfterSaveToStreamOpenStream.Checked);
      //ini.WriteBool('Main', 'AvsPtabschange', popAvsPTabsChange.Checked);
      ini.WriteBool('Main', 'AvsPscrolldiv2', popAvsPscrolldiv2.Checked);
      ini.WriteBool('Main', 'AvsPscrollreverse', popAvsPscrollreverse.Checked);
      ini.WriteInteger('Main', 'MaxHistoryCount', FMaxHistoryCount);
      ini.WriteBool('Main', 'TabForceAvsWnd', popForceAvsPWnd.Checked);
      ini.WriteBool('Main', 'TabShowPreview', popShowPreview.Checked);
      ini.WriteInteger('Main', 'BackgroundColor', LV.Color);
      ini.WriteBool('Main', 'HideClipMenu', popHideClipMenu.Checked);
      //- Tweaks
      ini.WriteBool('Tweaks', 'Hide_SB_HORZ', FHide_SB_HORZ);
      ini.WriteBool('Tweaks', 'StyleHook_shDialog', not (shDialogs in TStyleManager.SystemHooks));
      ini.WriteBool('Tweaks', 'ClipsToClipTweak', FClipsToClipTweak);
      ini.WriteInteger('Tweaks', 'MaxBmCount', FMaxBmCount);
    Finally
      ini.Free;
    End;
  end;
end;

function TForm1.LoadBookmarksFromFile(const fileName: String; FrList,FavList: TList): Integer;
const
  digit: TSysCharSet = ['0'..'9'];
var
  SL: TStringList;
  i,x: Integer;
  pRec: PFrameRec;
  s: String;
begin
  Result:= -1;
  If FrList = CurrentClip.FrameList then
    Clear();

  If GetFileSize(fileName) > 102400 then //- larger 100 kb should not be an avs file
  begin
    MessageDlg('Error: File size to large.',mtError,[mbOK],0);
    exit;
  end;

  FInProgress:= True;
  SL:= TStringList.Create;
  Application.ProcessMessages;
  Try
    SL.LoadFromFile(fileName);
    //- read Bookmarks from avs
    if SameText(ExtractFileExt(fileName), '.avs') then
    begin

      For i:= 0 to SL.Count -1 do
      begin
        s:= TrimLeft(SL[i]);
        if s.StartsWith('#Bookmarks:') then  //- ignor all other e.g. ##Bookmarks:
        begin
          Delete(s, 1, Length('#Bookmarks:'));
          s:= trimLeft(s);
          SL.Clear;
          SL.Delimiter:= ',';
          SL.StrictDelimiter:= true; //- sonst title getrennt in anderem Index
          SL.DelimitedText:= s;
          break;
        end;
      end;
    end;

    for i:= 0 to SL.Count-1 do
    begin
      s:= Trim(SL[i]);
      If s = '' then
        Continue;
      x:= 1;
      while CharInSet(s[x], digit) do
        inc(x);

      If x > 1 then
      begin
         pRec:= New(pFrameRec);
         ZeroMemory(pRec, SizeOf(TFrameRec));
         pRec^.FrameNr:= StrToInt(Copy(s,1, x-1));
         //- Ignor spaces (Leerzeichen gleich ignorieren);
         If Length(s) > x then
         begin
            pRec^.Title:= Copy(s, x, 255);
            if popTitleAutoAddFavor.Checked and Assigned(FavList) then
            begin
              SetBit(pRec^.BitInt, 1, False);
              FavList.Add(pRec);
            end;
         end;
         pRec^.bmp:= TBitmap.Create;
         pRec^.bmp.SetSize(10,10);
         FrList.Add(pRec);
      end;
    end;
  Finally
    SL.Free;
    FInProgress:= False;
  End;
  If FrList = CurrentClip.FrameList then
    CurrentClip.LastOpen:= fileName;
  Result:= CurrentClip.FrameList.Count;
end;

procedure TForm1.GetBookmarksThumbs(const fileName: String);
var
  Error,re: Integer;
  pRec: pFrameRec;
  THR: TTHread;
  TH: THandle;
begin
  re:= 0;
{$IFDEF WIN32}
  Caption:= 'Avisynth_32 in progress...';
{$else}
  Caption:= 'Avisynth_64 in progress...';
{$endif}
  CurrentClip.LastOpen:= fileName;
  Error:= 0;
  FStop:= false;
  ProgressBar1.Max:= CurrentClip.FrameList.Count;
  ProgressBar1.Position:= 0;
  Panel1.Visible:= true;
  BlockInput;
  Application.ProcessMessages;

  Try

    THR:= TThread.CreateAnonymousThread(procedure
    var
      i: Integer;
      FFStop: boolean;
    begin
      If AvsGrabber.OpenAvs(fileName, nil) < 0 then
      begin
        TThread.Synchronize(nil, procedure
        begin
          Clear();
          MessageDlg(AvsGrabber.ClipError, mtError, [mbOK],0);
          exit;
        end);
      end;

      Fbmp.PixelFormat:= pf32bit;
      Fbmp.SetSize(AvsGrabber.DisplayInfo.width, AvsGrabber.DisplayInfo.height);
      CurrentClip.AR:= AvsGrabber.DisplayInfo.width/AvsGrabber.DisplayInfo.height;
      CurrentClip.ThumbHeight:= Round(CurrentClip.ThumbWidth/CurrentClip.AR);

      For i:= 0 to CurrentClip.FrameList.Count-1 do
      begin
        pRec:= PFrameRec(CurrentClip.FrameList[i]);

        If (pRec^.FrameNr < AVSGrabber.DisplayInfo.num_frames) and AvsGrabber.GrabbFrame(pRec^.FrameNr, Fbmp) then
        begin
          pRec^.bmp.Assign(Fbmp);
          Stretch(pRec^.bmp, CurrentClip.ThumbWidth,CurrentClip.ThumbHeight);
          inc(re);
        end
        else inc(Error);

        TThread.Synchronize(nil, procedure
        begin
          ProgressBar1.StepIt;
          Caption:= IntToStr(i+1) + '/' + IntToStr(CurrentClip.FrameList.Count);
          FFStop:= FStop;
        end);

        If FFStop then
          break;
      end;
    end);
    TH:= THR.Handle;
    THR.Priority:= tpHigher;
    inc(FTaskCount);
    THR.Start;
    Repeat
      Case MsgWaitForMultipleObjectsEx(1, TH, INFINITE, QS_ALLINPUT, 0) of
        WAIT_OBJECT_0+1: Application.ProcessMessages;
        else
          break;
      end;
    Until False;
    dec(FTaskCount);

  Finally
    Panel1.Visible:= False;
    AvsGrabber.Close;
    UnblockInput;
    If (re > 0) and  popZFit.Checked then
    begin
      FZoom:= 100;
      popZFit.Tag:= 0;
    end;
    SetZoom;
    ListView_SetWidth;
    LV_MakeItemVisible(0, False);
  End;

  If not FStop and (Error > 0) then
    MessageDlg(IntToStr(Error)+' Thumbnails not read.',mtInformation,[mbOK],0)
end;

procedure TForm1.JPEGQuality1Click(Sender: TObject);
var
  s: String;
  i: Integer;
  w: TWindowState;
begin
  w:= WindowState;
  Try
    WindowState:= wsMinimized;
    SetForegroundWindow(Handle);
    s:= InputBox('JPEG save quality', '30 to 100', IntToStr(FJPEGQuality));
    if s = '' then
      exit;
    i:= StrToIntDef(s, -1);
    If (i > 29) and (i < 101) then
      FJPEGQuality:= i
    else MessageDlg('Invalide input.',mtError,[mbOK],0);
  Finally
    WindowState:= w;
  End;
end;

procedure TForm1.popTitleAddFavorClick(Sender: TObject);
var
  i: Integer;
  P: PFrameRec;
begin
  LV.Items.BeginUpdate;
  Try
    For i:= 0 to CurrentClip.FrameList.Count -1 do
    begin
      P:= PFrameRec(CurrentClip.FrameList[i]);
      If (P^.Title <> '') and (CurrentClip.FavorList.IndexOf(P) < 0) then
      begin
        SetBit(P^.BitInt, 1, True);
        CurrentClip.FavorList.Add(P);
        CurrentClip.NeedSave:= true;
      end;
    end;
  Finally
    LV.Items.Count:= ActiveList.Count;
    LV.Items.EndUpdate;
    If TabSet.TabIndex = 1 then
      LV_StyleBugFix;
    LV.Invalidate;
  End;
end;

procedure TForm1.popUpdateBookmarksClick(Sender: TObject);
var
  avs,Last,s: String;
begin
  If IsSplitClip(CurrentClip) then
    exit;
  With OpenDlg do
  begin
    Filter:= 'Bookmarks (avs, cr.txt)|*.avs; *.cr.txt';
    FileName:= '';
    If Assigned(CurrentClip.FileStream) then
      Last:= CurrentClip.LastOpen
    else Last:= CurrentClip.LastFile;
    InitialDir:= ExtractFilePath(Last);
    avs:= ChangeFileExt(Last, '.cr.txt');
    If not FileExists(avs) then
      avs:= ChangeFileExt(Last, '.avs');
    If not FileExists(avs) and Assigned(CurrentClip.FileStream) then
    begin;
      s:= RemoveFileExt(Last);
      If (Length(s) > 2) and (StrGetDigit(s, Length(s)) <> '') and (s[Length(s)-1] = '_') then
        avs:= Copy(s, 1, Length(s)-2)+ '.avs';
    end;
    If FileExists(avs) then
      FileName:= ExtractFileName(avs);
    If not Execute then
      exit;
  end;

  avs:= MakeAVSExt(OpenDlg.FileName);
  if not FileExists(avs) then
  begin
    MessageDlg('Avisynth ".avs" file not found.',mtError,[mbOK],0);
    exit;
  end;

  UpdateBookmarks(OpenDlg.FileName, avs);
end;

function TForm1.SaveToStream(const fileName : String): boolean;
var
  fs: TFileStream;
  i,e,z: Integer;
  b: Byte;
  P: PFrameRec;
  mem: TMemoryStream;
  jpg: TJpegImage;
  splitsL: Integer;
begin
  jpg:= TJPEGImage.Create;
  jpg.CompressionQuality:= FJPEGQuality;
  mem:= TMemoryStream.Create;
  fs:= nil;
  z:= 0;

  If Assigned(CurrentClip.FileStream) then
  begin
    CurrentClip.FileStream.Free;
    CurrentClip.FileStream:= nil;
  end;

  FInProgress:= True;
  Try
    Try
      fs:= TFileStream.Create(filename, fmCreate);
      fs.Size:= 0;
      //~fs.Write(HeaderFlag, SizeOf(Integer));

      If CurrentClip.Splits <> '' then
        splitsL:= Length(CurrentClip.Splits)*2
      else splitsL:= 0;
      fs.Write(Header2Flag, SizeOf(Integer));
      fs.Write(splitsL, SizeOf(Integer));

      For i:= 0 to CurrentClip.FrameList.Count-1 do
      begin
        P:= CurrentClip.FrameList[i];
        fs.Write(P^.FrameNr, SizeOf(Integer));
        fs.Write(P^.BitInt, SizeOf(Integer));
        b:= 0;
        If P^.Title <> '' then
        begin
          b:= Byte(Length(P^.Title)*2);
          fs.Write(b, SizeOf(Byte));
          fs.Write(P^.Title[1], b);
        end
        else fs.Write(b, SizeOf(Byte));
        mem.SetSize(0);
        jpg.Assign(P^.bmp);
        jpg.Compress;
        jpg.SaveToStream(mem);
        e:= mem.Size;
        fs.Write(e, SizeOf(Integer));
        mem.Position:= 0;
        mem.SaveToStream(fs);
        fs.Position:= fs.Size;
        inc(z);
      end;
      If splitsL > 0 then
      begin
        fs.Position:= fs.Size;
        fs.Write(CurrentClip.Splits[1], splitsL);
      end;
    Except
      RaiseLastOSError;
      exit;
    End;
  Finally
    jpg.Free;
    mem.Free;
    If Assigned(fs) then
      fs.Free;
    Result:= z = CurrentClip.FrameList.Count;
    FInProgress:= false;
  End;

end;

function TForm1.LoadFromStream(const fileName : String; const AddNewClip: boolean=True): Integer;
var
  fs: TBookStream;
  i,e,w,h: Integer;
  b: Byte;
  err: Boolean;
  P: PFrameRec;
  mem: TMemoryStream;
  jpg: TJpegImage;
  TH: THandle;
  THR: TThread;
  Splits: String;
  splitsL: Integer;
begin
  Result:= 0;
  Try
    fs:= TBookStream.Create(filename);
  except
    If (GetCurrentClip.FrameList.Count < 1) and (TabView.Tabs.Count > 1) then
      CloseTabs([TabView.TabIndex]);
    MessageDlg('Can not open:'#13#13 + ExtractFileName(filename)+#13+#13+
               'File already opened?', mtError,[mbOK],0);
    exit;
  end;

  //- No need for set the TabSet index or set the ActiveList
  If AddNewClip and (CurrentClip.FrameList.Count > 0) then
    NewClip(fileName)
  else Clear();
  ActiveList:= CurrentClip.FrameList;

  //~ test, nach Update bookstream werden die thumbs hin und wieder nicht gleich angezeigt
  // Gefunden, bei Clear wurde die ActiveList nicht auf CurrentClip.FrameList gesetzt
  //GetCurrentClip;
  //ActiveList:= CurrentClip.FrameList;

  BlockInput;
  SetCaption('Load from Stream...');
  Application.ProcessMessages;
  mem:= TMemoryStream.Create;
  jpg:= TJPEGImage.Create;
  err:= False;
  w:= 0;
  Try
    CurrentClip.MultiThumbSize:= False;
    CurrentClip.LastOpen:= filename;
    CurrentClip.LastFile:= '';
    If Assigned(CurrentClip.FileStream) then
      CurrentClip.FileStream.Free;
    CurrentClip.FileStream:= fs;

    fs.Position:= 0;
    fs.Read(e, SizeOf(Integer));
    If e = Header2Flag then
      fs.Read(splitsL, SizeOf(Integer))
    else splitsL:= 0;

    If (e = Header2Flag) or (e = HeaderFlag) then
    begin
      THR:= TThread.CreateAnonymousThread(procedure
      begin
        Try
          While fs.Position < fs.Size-(50 + splitsL) do
          begin
            P:= New(PFrameRec);
            ZeroMemory(P, SizeOf(TFrameRec));
            fs.Read(P^.FrameNr, SizeOf(Integer));
            fs.Read(P^.BitInt, SizeOf(Integer));
            fs.Read(b, SizeOf(Byte));
            If b > 0 then
            begin
              SetLength(P^.Title, b div 2);
              fs.Read(P^.Title[1], b);
            end;

            fs.Read(i, SizeOf(Integer));
            e:= fs.Position;
            mem.SetSize(0);
            mem.CopyFrom(fs, i);
            mem.Position:= 0;
            jpg.LoadFromStream(mem);
            P^.bmp:= TBitmap.Create;
            P^.bmp.Assign(jpg);
            If w = 0 then
            begin
              w:= P^.bmp.Width;
              h:= P^.bmp.Height;
            end
            else if not CurrentClip.MultiThumbSize then
            begin
              If (w <> P^.bmp.Width) or (h <> P^.bmp.Height) then
                CurrentClip.MultiThumbSize:= True;
            end;
            fs.Position:= e + i;
            CurrentClip.FrameList.Add(P);
            If GetBit(P^.BitInt, 1) then
              CurrentClip.FavorList.Add(P);
            If GetBit(P^.BitInt, 2) then
              CurrentClip.Favor2List.Add(P);
          end;
          If splitsL > 0 then
          begin
            fs.Position:= fs.Size - splitsL;
            SetLength(Splits, splitsL div 2);
            fs.Read(splits[1], splitsL);
            CurrentClip.Splits:= splits;
          end;
        except
          err:= True;
          exit;
        end;
      end);
      TH:= THR.Handle;
      THR.Priority:= tpHigher;
      inc(FTaskCount);
      THR.Start;
      Repeat
        Case MsgWaitForMultipleObjectsEx(1, TH, 60000, QS_ALLINPUT, 0) of
          WAIT_OBJECT_0+1: Application.ProcessMessages;
          else
            break;
        end;
      Until False;
      dec(FTaskCount);
    end
    else
      MessageDlg('Bookstream header not found.',mtError,[mbOK],0);
  Finally
    mem.Free;
    jpg.Free;
    UnblockInput;
    If (CurrentClip.FrameList.Count > 0) and not err then
    begin
      CurrentClip.FrameList.Sort(@SortListFunc_FrameNr);
      CurrentClip.FavorList.Sort(@SortListFunc_FrameNr);
      CurrentClip.ThumbWidth:= PFrameRec(CurrentClip.FrameList[0])^.bmp.Width;
      CurrentClip.ThumbHeight:= PFrameRec(CurrentClip.FrameList[0])^.bmp.Height;
      CurrentClip.AR:= CurrentClip.ThumbWidth/CurrentClip.ThumbHeight;
      If popZFit.Checked then
      begin
        FZoom:= 100;
        popZFit.Tag:= 0;
      end;
      SetZoom;
      ListView_SetWidth;
      LV_MakeItemVisible(0, False);

      i:= TabSet.Tabs.IndexOf('Basket');
      If CurrentClip.Favor2List.Count > 0 then
      begin
        CurrentClip.Favor2List.Sort(@SortListFunc_FrameNr);
        If i < 0 then TabSet.Tabs.Add('Basket');
      end
      else if i > -1 then
        TabSet.Tabs.Delete(i);

      SetCaption();
    end
    else begin
      If Assigned(CurrentClip.FileStream) then
        CurrentClip.FileStream.Free;
      CurrentClip.FileStream:= nil;
      SetCaption(myName);
      If err then
      begin
        Clear();
        MessageDlg('Fatal Error while reading from stream.',mtWarning,[mbOK],0);
      end;
    end;
    Result:= CurrentClip.FrameList.Count;

    //- Remove last empty clip
    If (GetCurrentClip.FrameList.Count < 1) and (TabView.Tabs.Count > 1) then
      CloseTabs([TabView.TabIndex]);
  End;
end;

procedure TForm1.popLoadFromStreamClick(Sender: TObject);
var
  i: Integer;
begin
  With OpenDlg do
  begin
    Filter:= 'Bookstream (*' + fext + ')|*' + fext;
    FileName:= '';
    If CurrentClip.LastFile <> '' then
      InitialDir:= ExtractFilePath(CurrentClip.LastFile)
    else if CurrentClip.LastOpen <> '' then
    begin
      InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
      FileName:= ExtractFileName(CurrentClip.LastOpen);
    end;
    if not Execute then
      exit;
  end;

  For i:= 0 to OpenDlg.Files.Count-1 do
    LoadFromStream(OpenDlg.Files[i], True);

  {If (GetCurrentClip.FrameList.Count < 1) and (TabView.Tabs.Count > 1) then
    CloseTabs([TabView.TabIndex]);}
end;

function TForm1.IsSplitClip(Clip: TClip): boolean;
begin
  Result:= Assigned(Clip.PrevPart) or Assigned(Clip.NextPart);
end;

function TForm1.GetSplitFirstClip(Clip: TClip): TClip;
var
  Clip2: TClip;
begin
  Result:= nil;

  If not Assigned(Clip.PrevPart) then
  begin
    If not Assigned(Clip.NextPart) then
      exit;
    Result:= Clip;
  end
  else begin
    Clip2:= Clip.PrevPart;
    While Assigned(Clip2.PrevPart) do
     Clip2:= Clip2.PrevPart;
    Result:= Clip2;
  end;
end;

procedure TForm1.SplitUpdateWnd(Source: TClip);
var
  Clip: TClip;
begin
  Clip:= GetSplitFirstClip(Source);
  Try
    While Assigned(Clip) do
    begin
      Clip.AvsWnd:= Source.AvsWnd;
      Clip.AvsP_video_w:= Source.AvsP_video_w;
      Clip.AvsP_video_h:= Source.AvsP_video_h;
      TabView_SetTabText(TabView_IndexOfClip(Clip));
      Clip:= Clip.NextPart;
    end;
  except
    exit;
  end;
end;

procedure TForm1.popSortClipPartsClick(Sender: TObject);
begin
  TabView_SplitSort(CurrentClip)
end;

procedure TForm1.SplitsSetCaption(Source: TClip);
var
  i: Integer;
  Parent: TClip;
begin
  i:= 1;
  Parent:= GetSplitFirstClip(Source);
  While Assigned(Parent) do
  begin
    Parent.LastFile:= Format('(Part %d) %s', [i, ExtractFileNameNoExt(Parent.LastOpen)]);
    inc(i);
    Parent:= Parent.NextPart;
  end;
end;

  function C_Sort(List: TStringList; Idx1, Idx2: Integer): Integer;
  var
    Clip1,Clip2: TClip;
    s1,s2: String;
  begin
    Clip1:= TClip(Integer(List.Objects[idx1]));
    Clip2:= TClip(Integer(List.Objects[idx2]));

    //If Form1.IsSplitClip(Clip1) and Form1.IsSplitClip(Clip2) then
      Result:= CompareStr(Clip1.LastFile, Clip2.LastFile)
    //else Result:= CompareStr(Clip1.LastOpen, Clip2.LastOpen);
  end;

procedure TForm1.TabView_SplitSort(Source: TClip);
var
  Parent,Clip: TClip;
  idx,i,count: Integer;
  SL: TStringList;
  s: String;
begin
  Parent:= GetSplitFirstClip(Source);
  If not Assigned(Parent) then
    exit;
  BlockInput;
  Try
    count:= 0;
    Clip:= Parent;
    While Assigned(Clip) do
    begin
      inc(count);
      Clip:= Clip.NextPart;
    end;

    idx:= TabView_IndexOfClip(Parent);
    If idx + count > TabView.Tabs.Count then
      TabView.Tabs.Move(idx, TabView.Tabs.Count - count);


    {SL:= TStringList.Create;
    For i:= 0 to TabView.Tabs.Count-1 do
      SL.AddObject(TabView.Tabs[i], TabView.Tabs.Objects[i]);
    SL.CustomSort(@C_Sort);

    TabView.Tabs.Clear;
    For i:= 0 to SL.Count-1 do
      TabView.Tabs.AddObject(SL[i], SL.Objects[i]);
    SL.Free;}

    //idx:= TabView_IndexOfClip(Parent) + 1;
    count:= 1;
    Clip:= Parent.NextPart;
    While Assigned(Clip) do
    begin
      idx:= TabView_IndexOfClip(Parent);
      i:= TabView_IndexOfClip(Clip);
      TabView.Tabs.Move(i, idx + count);
      //idx:= TabView_IndexOfClip(Clip)+1;
      //s:= s + IntToStr(idx) + ',' + IntToStr(i) + ',' + IntToStr(count) + #13;
      inc(count);
      Clip:= Clip.NextPart;
    end;
  finally
    UnblockInput;
    TabView_SetTabIndex(TabView_IndexOfClip(Source));
    TabView_SetTabText();
    SetCaption();
  end;
  //ShowMessage(s);
end;

procedure TForm1.popSplitClipClick(Sender: TObject);
begin
  SplitClip([LV.Selected.Index]);
end;

procedure TForm1.popSplitMergeNextClick(Sender: TObject);
begin
  //- if first part then merge next part to first part, do not move the complete first part!
  If Assigned(CurrentClip.NextPart) and Assigned(CurrentClip.PrevPart) then
    SplitMove(CurrentClip, 0, False)
  else if Assigned(CurrentClip.NextPart) then
    SplitMove(CurrentClip.NextPart, CurrentClip.NextPart.FrameList.Count-1, True);
end;

procedure TForm1.popSplitMergePrevClick(Sender: TObject);
begin
  SplitMove(CurrentClip, CurrentClip.FrameList.Count-1, True);
end;

procedure TForm1.popAutoSplitClipClick(Sender: TObject);
var
  a,b: TArray<String>;
  ai: Array of Integer;
  splits, sidx: String;
  i,idx,frameCount,srcCount, splitErr: Integer;
  Clip,Clip2: TClip;
begin
  If CurrentClip.Splits = '' then
    exit;

  //- split in two parts (splits, LV selected indexes for each clip)
  splits:= CurrentClip.Splits;
  i:= Pos('|', splits);
  If i > 2 then
  begin
    sidx:= Copy(splits, i+1, MaxInt); //- copy first! else splits indexes empty
    b:= sidx.Split([';']);
    splits:= Copy(splits, 1, i-1);
  end;
  a:= splits.Split([',']);

  splitErr:= 0;
  frameCount:= 0;
  srcCount:= CurrentClip.FrameList.Count-2;

  For i:= 0 to High(a) do
  begin
    idx:= StrToIntDef(a[i], -1);
    If (idx > -1) and ((frameCount + idx) < srcCount) then
    begin
      inc(frameCount,idx);
      SetLength(ai, Length(ai)+1);
      ai[High(ai)]:= idx;
    end
    else if idx > -1 then //- do not add error if it's not an integer e.g ','
      inc(splitErr)
  end;

  If Length(ai) > 0 then
  begin
    SplitClip(ai,-1);

    //- Set the stored selected index for each clip
    If Length(b) > 0 then
    begin
      i:= 0;
      Clip2:= nil;
      Clip:= GetSplitFirstClip(CurrentClip);
      While Assigned(Clip) and (i < Length(b)) do
      begin
        Clip.LastIndexLV:= StrToIntDef(b[i], -1);
        If Clip.LastIndexLV > -1 then
          Clip.LastViewOriginLV:= Point(0, MaxInt); //- Make sure selected does show at top
        Clip2:= Clip;
        Clip:= Clip.NextPart;
        inc(i);
      end;
      If Assigned(Clip2) and (Clip2.LastIndexLV > -1) and (Clip2 = CurrentClip) then
      begin
        FindAvsWnd(0);
        SplitUpdateWnd(CurrentClip);
        LV_MakeItemVisible(Clip2.LastIndexLV, True, True);
        If (LV.ItemIndex > -1) and (LV.ItemIndex < Clip2.FrameList.Count) then
          PostMessage(Clip2.AvsWnd, AVSP_SET_FRAME_NR, 0, PFrameRec(Clip2.FrameList[LV.ItemIndex])^.FrameNr);
      end
      else LV_MakeItemVisible(0, False, True);
    end
    else LV_MakeItemVisible(0, False, True);
  end;

  If splitErr > 0 then
    MessageDlg('To many splits for the frames count.'#13+
               IntToStr(splitErr) + ' splits was canceled.',mtInformation,[mbOK],0)
end;

//- Must check the range for idx
procedure TForm1.SplitClip(idxList: Array of Integer; const MakeItemVisible: Integer);
var
  i,Loop,idx: Integer;
  P: pFrameRec;
  LastClip: TClip;
begin
  BlockInput;
  LV.Items.Count:= 0;
  Try
    For Loop:= 0 to High(idxList) do
    begin
      idx:= idxList[Loop];
      LastClip:= CurrentClip;

      //- Add the moment no support for Bookstreams
      If Assigned(LastClip.FileStream) then
      begin
        LastClip.StoredStream:= LastClip.FileStream;
        LastClip.FileStream:= nil;
      end;

      CurrentClip:= NewClip;

      If not Assigned(LastClip.PrevPart) and not Assigned(LastClip.NextPart) then  //- then clip first split
        CurrentClip.PrevPart:= LastClip
      else begin
        If Assigned(LastClip.NextPart) then
        begin
          CurrentClip.NextPart:= LastClip.NextPart;
          LastClip.NextPart.PrevPart:= CurrentClip;
        end;

        CurrentClip.PrevPart:= LastClip;
      end;

      LastClip.NextPart:= CurrentClip;

      //- Copy values
      With CurrentClip do
      begin
        ThumbWidth:= LastClip.ThumbWidth;
        ThumbHeight:= LastClip.ThumbHeight;
        MultiThumbSize:= LastClip.MultiThumbSize;
        AR:= LastClip.AR;
        LastOpen:= LastClip.LastOpen;
        AvsWnd:= LastClip.AvsWnd;
        AvsP_video_w:= LastClip.AvsP_video_w;
        AvsP_video_h:= LastClip.AvsP_video_h;
      end;

      //- Add split
      For i:= idx to LastClip.FrameList.Count -1 do
      begin
        P:= PFrameRec(LastClip.FrameList[i]);
        CurrentClip.FrameList.Add(P);
        If GetBit(P^.BitInt, 1) then
          CurrentClip.FavorList.Add(P);
        If GetBit(P^.BitInt, 2) then
          CurrentClip.Favor2List.Add(P);
      end;

      //- Del in prevPart
      For i:= LastClip.FrameList.Count - 1 downto idx do
        LastClip.FrameList.Delete(i);

      //- Add Favors to prevPart
      Clip_FillFavorLists(LastClip, False);

      LastClip.TabSet_LastIndex:= 0;
      If LastClip.LastIndexLV >= LastClip.FrameList.Count then
        LastClip.LastIndexLV:= -1;
      If LastClip.LastIndexFV >= LastClip.FavorList.Count then
        LastClip.LastIndexFV:= -1;
      If LastClip.LastIndexFV2 >= LastClip.Favor2List.Count then
        LastClip.LastIndexFV2:= -1;

      SplitsSetCaption(CurrentClip);
    End;
  finally
    UnblockInput;
    If CurrentClip.FrameList.Count > 0 then
    begin
      //- SplitSort also calls TabViewChange
      TabView_SplitSort(CurrentClip);
      If popZFit.Checked then
      begin
        FZoom:= 100;
        popZFit.Tag:= 0;
      end;
      SetZoom; //- Sets also LV item count
      ListView_SetWidth;
      If MakeItemVisible > -1 then
        LV_MakeItemVisible(MakeItemVisible, False, True);
    end
    else begin
      If (TabView.Tabs.Count > 1) then
        CloseTabs([TabView.TabIndex]);
      SetCaption()
    end;
  end;
end;

procedure TForm1.popJoinClipPartsClick(Sender: TObject);
var
  i: Integer;
  Clip,Clip2: TClip;
  a: Array of Integer;
begin
  If not IsSplitClip(CurrentClip) then
    exit;

  Clip:= GetSplitFirstClip(CurrentClip);
  If not Assigned(Clip) or not Assigned(Clip.NextPart) then
    exit;
  BlockInput;
  Try
    Clip2:= Clip.NextPart;

    While Assigned(Clip2) do
    begin
      For i:= 0 to Clip2.FrameList.Count-1 do
        Clip.FrameList.Add(Clip2.FrameList[i]);
      Clip2.FrameList.Clear;
      Clip2:= Clip2.NextPart;
    end;

    Clip.NextPart:= nil;
    Clip.PrevPart:= nil;
    Clip_FillFavorLists(Clip, False);
    Clip.LastFile:= Clip.LastOpen;

    If Assigned(Clip.StoredStream) then
    begin
      Clip.FileStream:= Clip.StoredStream;
      Clip.StoredStream:= nil;
    end;

    For i:= TabView.Tabs.Count -1 downto 0 do
      if GetClip(i).FrameList.Count < 1 then
      begin
        SetLength(a, Length(a)+ 1);
        a[High(a)]:= i;
      end;
    //- Leave it in the Block UnBlock part
    CloseTabs(a, True);
  finally
    UnblockInput;
    TabView_SetTabIndex(TabView_IndexOfClip(Clip));
    SetZoom;
    LV_MakeItemVisible(0, False);
  end;
end;

//- Valid idx only from FrameList, not from the Favor lists!
procedure TForm1.SplitMove(Source: TClip; idx: Integer; prev: boolean);
var
  i: Integer;
  Parent: TClip;
begin
  BlockInput;
  Parent:= Source; //- compiler still
  Try
    If prev then
    begin
      If not Assigned(Source.PrevPart) then
        exit;
      For i:= 0 to idx do
        Source.PrevPart.FrameList.Add(Source.FrameList[i]);
      For i:= idx downto 0 do
        Source.FrameList.Delete(i);
      Clip_FillFavorLists(Source.PrevPart, False);
      Parent:= Source.PrevPart;
    end
    else begin
      If not Assigned(Source.NextPart) or
         (not Assigned(Source.PrevPart) and (idx < 1)) then  //- Do not move the first part, it's Master part
           exit;
      For i:= Source.FrameList.Count -1 downto idx do
        Source.NextPart.FrameList.Insert(0, Source.FrameList[i]);
      For i:= Source.FrameList.Count -1 downto idx do
        Source.FrameList.Delete(i);
      Clip_FillFavorLists(Source.NextPart, False);
      Parent:= Source.NextPart;
    end;

    If Source.FrameList.Count > 0 then
      Clip_FillFavorLists(Source, False)//Source = CurrentClip)
    else begin
      If prev then
      begin
        If Assigned(Source.NextPart) then
        begin
          Parent.NextPart:= Source.NextPart;
          Parent.NextPart.PrevPart:= Parent
        end
        else Parent.NextPart:= nil;
      end
      else begin
         If Assigned(Source.PrevPart) then
         begin
           Parent.PrevPart:= Source.PrevPart;
           Parent.PrevPart.NextPart:= Parent;
         end
         else Parent.PrevPart:= nil;
      end;

      CloseTabs([TabView_IndexOfClip(Source)], True);

      If not IsSplitClip(Parent) then
      begin
        Parent.LastFile:= Parent.LastOpen;
        If Assigned(Parent.StoredStream) then
        begin
          Parent.FileStream:= Parent.StoredStream;
          Parent.StoredStream:= nil;
        end;
      end
      else
        SplitsSetCaption(Parent);
    end;

  finally
    UnblockInput;
    TabView_SetTabIndex(TabView_IndexOfClip(Parent));
    {LV.Items.Count:= ActiveList.Count;
    LV.Invalidate;
    If LV.Enabled then
      LV.SetFocus;
    SetCaption();}
  end;
end;

procedure TForm1.popSaveCurrentSplitsClick(Sender: TObject);
var
  Clip,Clip2: TClip;
  s,si: String;
  fs: TBookStream;
  e,splitL: Integer;
  ClearSplits: Boolean;
begin
  Clip:= GetSplitFirstClip(CurrentClip);
  ClearSplits:= False;
  If not Assigned(Clip) and (CurrentClip.Splits <> '') then
  begin
    If MessageDlg('This will delete the current stored splits'#13+
                  'Keep going?', mtConfirmation,[mbCancel, mbYes], 0, mbCancel)
                   <> mrYes then exit;
    CurrentClip.Splits:= '';
    Clip:= CurrentClip;
    ClearSplits:= True;
  end;

  If not Assigned(Clip) then
    exit;

  If Assigned(Clip.StoredStream) then
    fs:= Clip.StoredStream
  else if Assigned(Clip.FileStream) then
    fs:= Clip.FileStream
  else begin
    MessageDlg('Bookstream not found'#13+'Cannot save the splits',
               mtError,[mbOK],0);
    exit;
  end;

  If not ClearSplits then
  begin
    Clip2:= Clip;
    While Assigned(Clip2) do
    begin
      //- do not add the last split part
      If Assigned(Clip2.NextPart) then
        s:= s + IntToStr(Clip2.FrameList.Count) + ',';
      If Clip2 = CurrentClip then
      begin
        If Assigned(LV.Selected) then
          Clip2.LastIndexLV:= LV.Selected.Index
        else Clip2.LastIndexLV:= Clip2.FrameList.Count;
      end;
      If Clip2.LastIndexLV < Clip2.FrameList.Count then
        si:= si + IntToStr(Clip2.LastIndexLV) + ';'
      else si:= si + '-1;';

      Clip2:= Clip2.NextPart;
    end;

    Clip.Splits:= s + '|' + si;
  end;

  Try
    fs.Position:= 0;
    fs.Read(e, SizeOf(e));
    If e <> Header2Flag then
    begin
      MessageDlg('Old header Version'#13+'Cannot save the splits'#13#13+
                 'You must first Join, then save the stream.',mtError,[mbOK],0);
      exit;
    end;
    fs.Read(splitL, SizeOf(splitL));
    fs.Position:= fs.Size - splitL;
    fs.Size:= fs.Position;
    If ClearSplits then
      splitL:= 0
    else begin
      splitL:= Length(Clip.Splits)*2;
      fs.Write(Clip.Splits[1], splitL);
    end;
    fs.Position:= SizeOf(Integer);
    fs.Write(splitL, SizeOf(splitL));
  except
    RaiseLastOSError;
    exit;
  end;

  ShowMessage('Done');
end;

procedure TForm1.popSaveFavoritesClick(Sender: TObject);
begin
  SaveFavoritesToStream();
end;

procedure TForm1.popSaveToStreamClick(Sender: TObject);
var
  SaveName,s: String;
begin
  With SaveDlg do
  begin
    Filter:= 'Bookstream (*' + fext + ')|*' + fext;
    If CurrentClip.LastFile <> '' then
    begin
      InitialDir:= ForceBackslash(ExtractFilePath(CurrentClip.LastFile));
      If IsBookmarkExt(CurrentClip.LastFile) then
        FileName:= ExtractFileNameNoExt(ChangeFileExt(CurrentClip.LastFile, '')) + fext
      else FileName:= ExtractFileNameNoExt(CurrentClip.LastFile) + fext;
    end
    else if CurrentClip.LastOpen <> '' then
    begin
      InitialDir:= ForceBackslash(ExtractFilePath(CurrentClip.LastOpen));
      FileName:= ExtractFileName(CurrentClip.LastOpen);
    end;
    if not Execute then
      exit;
  end;
  Application.ProcessMessages;

  If not SameText(ExtractFileExt(SaveDlg.FileName), fext) then
     SaveName:= SaveDlg.FileName + fext
  else SaveName:= SaveDlg.FileName;

  //- SaveDialog override prompt muss wegen evtl. ext Änderung erweitert werden.
  If (SaveName <> SaveDlg.FileName) and FileExists(SaveName) then
  begin
    If MessageDlg('File name already exists.'#13+
                  'Should the existing file be overwritten?',
                   mtConfirmation,[mbYes,mbCancel],0,mbCancel) <> mrYes then
                     exit;
  end;

  If SaveToStream(SaveName) then
  begin
    CurrentClip.NeedSave:= false;
    AddLastSavedStream(SaveName);

    s := '';
    If CurrentClip.LastFile <> '' then
      s:= CurrentClip.LastFile
    else if CurrentClip.LastOpen <> '' then
      s:= CurrentClip.LastOpen;

    if s <> '' then
    begin
      if FileUtils.ChangeFileCreateTime(s, SaveName,'') < 1 then
        MessageDlg('Cannot change the file CreateTime.',mtError,[mbOK],0);
    end;
    if popAfterSaveToStreamOpenStream.Checked then
       LoadFromStream(SaveName, false);
  end;
  //- SaveToStream löst eine Fehler Message aus
  //~else ShowMessage('Error while writing stream');
end;

//- Only save favorites only if a bookstream has been opened.
//- No deterioration of thumbnail quality.
//- Nur Favoriten speichern, nur wenn ein Bookstream geöffnet wurde.
//- Keine Verschlechterung der Thumbnail Qualität.
procedure TForm1.SaveFavoritesToStream();
var
  e, splitsL: Integer;
  P: PFrameRec;
  b: Byte;
begin
  If not Assigned(CurrentClip.FileStream) then
    exit;

  LV.Items.BeginUpdate;
  FInProgress:= True;
  Try
    CurrentClip.FavorList.Sort(@SortListFunc_FrameNr);
    CurrentClip.Favor2List.Sort(@SortListFunc_FrameNr);
    With CurrentClip.FileStream do
    begin
      Try
        Position:= 0;
        Read(e, SizeOf(Integer));
        If e = Header2Flag then
          Read(splitsL, SizeOf(Integer))
        else splitsL:= 0;

        Repeat
          Read(e, SizeOf(Integer));   //- FrameNr
          //- FrameNr muss gesucht werden da Stream unsortiert geschrieben
          //- FrameNr must be searched because Stream written unsorted
          P:= CurrentClip.FrameList[List_IndexOfFrameNr(CurrentClip.FrameList, e)];
          Write(P^.BitInt, SizeOf(Integer)); //- FavorFlag
          b:= 0;
          Read(b, SizeOf(Byte));
          if b > 0 then
            Seek(b, soFromCurrent);  //- Length title
          Read(e, SizeOf(Integer));
          Seek(e, soFromCurrent); //- ImageSize
        Until Position >= Size - (50 + splitsL);
        CurrentClip.NeedSave:= false;
      Except
        Free;
        CurrentClip.FileStream:= nil;
        MessageDlg('Fatal Error while writting to stream.',mtWarning,[mbOK],0);
      End;
    end;
  Finally
    FInProgress:= false;
    LV.Items.EndUpdate;
    LV.Invalidate;
  End;
end;

procedure TForm1.popMoveFrameNrClick(Sender: TObject);
var
  s: String;
  sr: TArray<String>;
  i: Integer;
  w: TWindowState;
begin
  If CurrentClip.FrameList.Count < 1 then
    exit;
  w:= WindowState;
  Try
    WindowState:= wsMinimized;
    SetForegroundWindow(Handle);
    if Assigned(LV.Selected) then
      i:= LV.Selected.Index
    else i:= 0;
    s:= IntToStr(i) + ',' + IntToStr(CurrentClip.FrameList.Count-1) + ',0';
    If not InputQuery('Move frame numbers', 'start,end,amount', s) then
      exit;
    s:= s.Replace(' ','');
    sr:= s.Split([',']);
    if Length(sr) < 3 then
      exit;
    if StrToIntDef(sr[2], 0) = 0 then
      exit;
    For i:= 0 to 1 do
      if StrToIntDef(sr[i], -1) < 0 then
      begin
        MessageDlg('Invalid Input: number < 0',mtError,[mbOk],0);
        exit;
      end;

    If StrToInt(sr[0]) > StrToInt(sr[1]) then
    begin
      MessageDlg('Invalid Input: start > end',mtError,[mbOk],0);
      exit;
    end;

    sr[1]:= IntToStr(Min(StrToInt(sr[1]), CurrentClip.FrameList.Count-1));
    MoveFrameNr(StrToInt(sr[0]),StrToInt(sr[1]),StrToInt(sr[2]), true);
  Finally
    WindowState:= w;
  End;
end;

procedure TForm1.UpdateBookmarks(const BookFile, avsFile: String);
var
  i,Error,removed,added,idx: Integer;
  TempAR: Single;
  FrList: TList;
  P,PRec: PFrameRec;
  RunGrabber: Integer;
  TH: THandle;
  THR: TThread;

  procedure MyMessage();
  begin
    MessageDlg('Added: '+ IntToStr(added)+#13+
               'Removed: ' + IntToStr(removed)+#13+
               'Error: ' + IntToStr(Error), mtInformation,[mbOk],0);
  end;

begin
  removed:= 0;
  added:= 0;
  Error:= 0;
  RunGrabber:= 0;
  FrList:= TList.Create;

  Try
    //- Quick check if add or remove needed
    If LoadBookmarksFromFile(BookFile, FrList, nil) < 1 then
    begin
      MessageDlg('No Bookmarks found.'#13+BookFile,mtInformation,[mbOk],0);
      exit;
    end;

    For i:= 0 to CurrentClip.FrameList.Count-1 do
      If List_IndexOfFrameNr(FrList, PFrameRec(CurrentClip.FrameList[i])^.FrameNr) < 0 then
      begin
        RunGrabber:= -1;
        break;
      end;
    If RunGrabber <= 0 then
      for i:= 0 to FrList.Count-1 do
        If List_IndexOfFrameNr(CurrentClip.FrameList, PFrameRec(FrList[i])^.FrameNr) < 0 then
        begin
          RunGrabber:= 1;
          break;
        end;
    If RunGrabber = 0 then
    begin
      MyMessage();
      exit;
    end;
  finally
    if RunGrabber = 0 then
      FrList.Free;
  end;
  //- end quick check, if RunGrabber <> 0 we need add or remove bookmarks

  TabSet.TabIndex:= 0;
  LV.Items.BeginUpdate;
  BlockInput;

  Try
    If RunGrabber > 0 then  //- add bookmarks
    begin
{$IFDEF WIN32}
      Caption:= 'Avisynth_32 in progress...';
{$else}
      Caption:= 'Avisynth_64 in progress...';
{$endif}
      //Screen.Cursor:= crHourGlass;
      Application.ProcessMessages;
    end;

    THR:= TThread.CreateAnonymousThread(procedure
    var
      i: Integer;
      FFStop: Boolean;
    begin
      If RunGrabber > 0 then
      begin
        If AvsGrabber.OpenAvs(avsFile, nil) < 0 then
          TThread.Synchronize(nil, procedure
          begin
            MessageDlg(AvsGrabber.ClipError,mtError,[mbOk],0);
            exit;
          end);

        TempAR:= AvsGrabber.DisplayInfo.width/AvsGrabber.DisplayInfo.height;
        i:= Round(AvsGrabber.DisplayInfo.width/TempAR);
        TempAR:= AvsGrabber.DisplayInfo.width/i;

        TThread.Synchronize(nil, procedure
        begin
          If ABS((Round(TempAR*100)/100) - (Round(CurrentClip.AR*100)/100)) > 0.1 then
          begin
            MessageDlg('Aspect ratio is different. Cancellation.'#13+
                       'Old: ' + FloatToStr(Round(CurrentClip.AR*100)/100)+#13+
                       'New: ' + FloatToStr(Round(TempAR*100)/100),mtError,[mbOk],0);
            exit;
          end;
          FStop:= false;
          ProgressBar1.Max:= FrList.Count;
          ProgressBar1.Position:= 0;
          Caption:= '0/' + IntToStr(FrList.Count);
          Panel1.Visible:= true;
        end);

        Fbmp.PixelFormat:= pf32bit;
        Fbmp.SetSize(AvsGrabber.DisplayInfo.width, AvsGrabber.DisplayInfo.height);
      end;

      //- Nicht mehr vorandene Bookmarks löschen. (delete non-existent bookmarks)
      For i:= CurrentClip.FrameList.Count-1 downto 0 do
      begin
        P:= PFrameRec(CurrentClip.FrameList[i]);
        If List_IndexOfFrameNr(FrList, P^.FrameNr) < 0 then
        begin
          idx:= CurrentClip.FavorList.IndexOf(P);
          if idx > -1 then
            CurrentClip.FavorList.Delete(idx);
          idx:= CurrentClip.Favor2List.IndexOf(P);
          if idx > -1 then
            CurrentClip.Favor2List.Delete(idx);
          P^.bmp.Free;
          Dispose(P);
          CurrentClip.FrameList.Delete(i);
          inc(removed);
        end;
      end;

      //- Neue Bookmarks hinzufügen. (add new bookmarks)
      If RunGrabber > 0 then
      For i := 0 to FrList.Count-1 do
      begin
        P:= PFrameRec(FrList[i]);
        If List_IndexOfFrameNr(CurrentClip.FrameList, P^.FrameNr) < 0 then
        begin
          If(P^.FrameNr < AVSGrabber.DisplayInfo.num_frames) and AvsGrabber.GrabbFrame(P^.FrameNr, Fbmp) then
          begin
            inc(added);
            pRec:= New(PFrameRec);
            ZeroMemory(pRec, SizeOf(TFrameRec));
            pRec^.bmp:= TBitmap.Create;
            pRec^.FrameNr:= P^.FrameNr;
            pRec^.Title:= P^.Title;
            pRec^.bmp.Assign(Fbmp);
            Stretch(pRec^.bmp, CurrentClip.ThumbWidth,CurrentClip.ThumbHeight);
            If Assigned(CurrentClip.FileStream) then
              pRec^.tmp:= 1;
            CurrentClip.FrameList.Add(pRec);
          end
          else inc(Error);
        end;

        TThread.Synchronize(nil, procedure
        begin
          ProgressBar1.StepIt;
          Caption:= IntToStr(i+1) + '/' + IntToStr(FrList.Count);
          FFStop:= FStop;
        end);
        If FFStop then
          break;
      end;

      if RunGrabber > 0 then
        AvsGrabber.Close; //- close in thread
    end);

    TH:= THR.Handle;
    inc(FTaskCount);
    THR.Start;
    Repeat
      Case MsgWaitForMultipleObjectsEx(1, TH, INFINITE, QS_ALLINPUT, 0) of
        WAIT_OBJECT_0+1: Application.ProcessMessages;
        else
          break;
      end;
    Until False;
    dec(FTaskCount);
  Finally
    For i:= 0 to FrList.Count-1 do
    begin
      P:= FrList[i];
      P^.bmp.Free;
      Dispose(P);
    end;
    FrList.Free;
    CurrentClip.FrameList.Sort(@SortListFunc_FrameNr);
    AvsGrabber.Close;
    Panel1.Visible:= False;
    LV.Items.Count:= CurrentClip.FrameList.Count;
    LV.Items.EndUpdate;
    Application.ProcessMessages;
    UnBlockInput;
    LV_StyleBugFix;
    LV.Invalidate;
    if CurrentClip.Favor2List.Count < 1 then
    begin
      i:= TabSet.Tabs.IndexOf('Basket');
      if i > -1 then
        TabSet.Tabs.Delete(i);
    end;
    //Screen.Cursor:= crDefault;
    If CurrentClip.FrameList.Count > 0 then
      SetCaption()
    else Clear();
  End;

  If Assigned(CurrentClip.FileStream) and (Error < 1) and ((removed>0)or(added>0)) then
  if GetWinMajorVersion < 6 then
  begin
    idx:= MessageDlg('Added: '+ IntToStr(added)+#13+
                 'Removed: ' + IntToStr(removed)+#13#13+
                 'Yes: Save directly'#13+
                 ' OK: Open save dialog', mtConfirmation,
                 [mbYes,mbOK,mbCancel],0,mbYes);

    CurrentClip.NeedSave:= true;
    if idx in [mrYes, mrOK] then
      UpdateStream(idx=mrYes);
  end
  else with TaskDlg do  //- not WinXP compatible !?
  begin
    //- for both dialogs
    Caption:= 'AvsPThump';
    Title:= 'Save options';
    Text := 'Added: ' + IntToStr(added)+#13+
            'Removed: ' + IntToStr(removed);
    MainIcon := tdiNone;

    //- dialog
    CommonButtons := [tcbOk, tcbCancel];

    RadioButtons.Clear;
    with RadioButtons.Add do
    begin
      Caption := 'Save directly';
      Default:= True;
    end;

    with RadioButtons.Add do
      Caption := 'New file...';

    if Execute and (ModalResult = mrOK) then
    begin
      CurrentClip.NeedSave:= true;
      Case RadioButton.Index of
        0: idx:= mrYes;
        1: idx:= mrOK;
        else idx:= mrYes //- compiler quiet
      end;
      UpdateStream(idx=mrYes);
    end;

    //- alternative dialog without radio buttons
    {
    CommonButtons:= [];
    with TTaskDialogButtonItem(Buttons.Add) do
    begin
      Caption:= 'New file...';
      CommandLinkHint:= 'Open save dialog.';
      ModalResult := mrOK;
    end;
    with TTaskDialogButtonItem(Buttons.Add) do
    begin
      Caption:= 'Direct';
      CommandLinkHint := 'Save in the current file.';
      ModalResult:= mrYes;
      Default:= True;
    end;
    Flags:= [tfUseCommandLinks];
    if Execute then
    begin
      if ModalResult in [mrYes, mrOK] then
         UpdateStream(ModalResult=mrYes);
    end;
    }
  end
  else
    MyMessage();
end;

procedure TForm1.popMaxHistoryCountClick(Sender: TObject);
var
  s: String;
  i,x: Integer;
  w: TWindowState;
begin
  w:= WindowState;
  Try
    WindowState:= wsMinimized;
    SetForegroundWindow(Handle);
    s:= IntToStr(FMaxHistoryCount);
    If not InputQuery('Max File History', '0 to 100', s) then
      exit;

    i:= StrToIntDef(s, -1);
    If (i > -1) and (i < 101) then
    begin
      FMaxHistoryCount:= i;
      if i < popOpenLastSavedStream.Count-1 then
      begin
        x:= (popOpenLastSavedStream.Count - FMaxHistoryCount) -1;
        For i:= x downto 0 do
          popOpenLastSavedStream.Delete(i);
        FHistoryList.Clear;
        For i:= 0 to popOpenLastSavedStream.Count-1 do
          FHistoryList.Add(popOpenLastSavedStream.Items[i].Hint);
      end;
    end
    else MessageDlg('Invalide Input',mtError,[mbOk],0);
  Finally
    WindowState:= w;
  End;
end;

function TForm1.UpdateStream(const direct: boolean): Integer;
var
  mem: TMemoryStream;
  jpg: TJPEGImage;
  e,i,Nr: Integer;
  start,count,splitsL: Integer;
  b: Byte;
  P: PFrameRec;
begin
  Result:= 0;
  mem:= TMemoryStream.Create;
  mem.Write(Header2Flag, SizeOf(Integer));
  if CurrentClip.Splits <> '' then
    splitsL:= Length(CurrentClip.Splits)*2
  else splitsL:= 0;
  mem.Write(splitsL, SizeOf(Integer));
  jpg:= TJPEGImage.Create;
  jpg.CompressionQuality:= FJPEGQuality;
  Try
    Try
      With CurrentClip.FileStream do
      begin
        Position:= 0;
        Read(e, SizeOf(Integer));
        If e = Header2Flag then
          Read(splitsL, SizeOf(Integer))
        else splitsL:= 0;

        While Position < Size - (50 + splitsL) do
        begin
          start:= Integer(Position);
          Read(Nr, SizeOf(Integer));  //- FrameNr
          Seek(SizeOf(Integer), soFromCurrent); //- BitInt
          Read(b, SizeOf(Byte));
          if b > 0 then                        //- Title
            Seek(b, soFromCurrent);
          Read(e, SizeOf(Integer));     //- ImageSize
          count:= (Integer(Position) - start) + e;
          If List_IndexOfFrameNr(CurrentClip.FrameList, Nr) > -1 then
          begin
            Position:= start;
            mem.CopyFrom(CurrentClip.FileStream, count);
            inc(Result)
          end
          else Position:= start + count;
        end;
      end;

      For i:= 0 to CurrentClip.FrameList.Count-1 do
      begin
        P:= PFrameRec(CurrentClip.FrameList[i]);
        If P^.tmp = 1 then
        begin
          P^.tmp:= 0;
          mem.Position:= mem.Size;
          mem.Write(P^.FrameNr, SizeOf(Integer));
          mem.Write(P^.BitInt, SizeOf(Integer));
          b:= 0;
          If P^.Title <> '' then
          begin
            b:= Byte(Length(P^.Title)*2);
            mem.Write(b, SizeOf(Byte));
            mem.Write(P^.Title[1], b);
          end
          else mem.Write(b, SizeOf(Byte));
          start:= Integer(mem.Size);
          mem.Write(start, SizeOf(Integer));
          jpg.Assign(P^.bmp);
          jpg.Compress;
          jpg.SaveToStream(mem);
          count:= Integer(mem.Size)-start-SizeOf(Integer);
          mem.Position:= start;
          mem.Write(count, SizeOf(Integer));
          inc(Result)
        end;
      end;
    except
      RaiseLastOSError;
      exit;
    End;

    if direct then
    begin
      Try
        CurrentClip.FileStream.Size:= 0;
        mem.SaveToStream(CurrentClip.FileStream);
        CurrentClip.NeedSave:= false;
      except
        RaiseLastOSError;
      end;
    end
    else begin
      With SaveDlg do
      begin
        Filter:= 'Bookmarks|*'+fext;
        InitialDir:= ExtractFilePath(CurrentClip.LastOpen);
        FileName:= ExtractFileNameNoExt(CurrentClip.LastOpen) + fext;

        while Execute do  //- At Save Error do not lost the Data
          Try
            mem.SaveToFile(SaveDlg.FileName);
            CurrentClip.NeedSave:= false;
            exit;
          except
            ShowMessage(SysErrorMessage(GetLastError));
          end;
      end;
    end;
  Finally
    mem.Free;
    jpg.Free;
  end;

  If Result <> CurrentClip.FrameList.Count then
    MessageDlg(IntToStr(CurrentClip.FrameList.Count-Result)+ 'frames not saved.',mtInformation,[mbOk],0);
end;

procedure TForm1.MoveFrameNr(idxStart, idxEnd, Amount: Integer; direct: boolean);
var
  e,i,Nr: Integer;
  start,count, splitL: Integer;
  b: Byte;
begin
  //Result:= 0;
  If Assigned(CurrentClip.FileStream) and direct then
  Try
    With CurrentClip.FileStream do
    begin
      Position:= 0;
      Read(e, SizeOf(Integer));
      If e = Header2Flag then
        Read(splitL, SizeOf(Integer))
      else splitL:= 0;

      While Position < Size - (50 + splitL) do
      begin
        start:= Integer(Position);
        Read(Nr, SizeOf(Integer));  //- FrameNr
        Seek(SizeOf(Integer), soFromCurrent); //- BitInt
        Read(b, SizeOf(Byte));
        if b > 0 then                        //- Title
          Seek(b, soFromCurrent);
        Read(e, SizeOf(Integer));     //- ImageSize
        count:= (Integer(Position) - start) + e;
        i:= List_IndexOfFrameNr(CurrentClip.FrameList, Nr);
        If InRange(i, idxStart, idxEnd) then
        begin
          inc(Nr, Amount);
          Position:= start;
          Write(Nr, SizeOf(Integer));
          Position:= start + count;
          //~inc(Result)
        end
        else Position:= start + count;
      end;
    end;
  except
    RaiseLastOSError;
    exit;
  end;

  For i:= idxStart to idxEnd do
    inc(PFrameRec(CurrentClip.FrameList[i])^.FrameNr, Amount);
  CurrentClip.NeedSave:= not Assigned(CurrentClip.FileStream) or not direct;
end;

procedure TForm1.ClipsToClip(const SaveName: String);
var
  fs: TFileStream;
  SL,Bookmarks: TStringList;
  TH: THandle;
  THR: TThread;
  i,bmAll: Integer;

begin
  bmAll:= 0;
  For i:= 0 to TabView.Tabs.Count -1 do
   inc(bmAll, GetClip(i).FrameList.Count);
  If bmAll > FMaxBmCount then
  begin
    If MessageDlg('AvsPmod maximum bookmark count is ' + IntToStr(FMaxBmCount) + #13+
                  'The bookmark count of all clips is '+ IntToStr(bmAll)+#13+
                  'So not all clips can be added.'#13+
                  'Continue?', mtInformation, mbYesNo,0) <> mrYes then
                    exit;
  end;

  fs:= nil;
  SL:= TStringList.Create;
  Bookmarks:= TStringList.Create;
  BlockInput;
  ProgressBar1.Max:= TabView.Tabs.Count;
  ProgressBar1.Position:= 0;
  Panel1.Visible:= True;
  FStop:= False;
  Application.ProcessMessages;

  Try
    THR:= TThread.CreateAnonymousThread(procedure
    type
      TClipInfo = record
        w,h: Integer;
        fps: String;
      end;
    var
      i,e,c,sc,Nr,Count,bmCount,w,h,splitsL,Header: Integer;
      Clip: TClip;
      c_start: Int64;
      b: Byte;
      FFStop: boolean;
      fileName, title, script, s, hs, ws, splits: String;
      clipErr, fileErr: String;
      ClipsInfo: Array of TClipInfo;

      procedure AddToScript(const fname: String; idx: Integer);
      var
        i: Integer;
        s: String;
      begin
        SL.Clear;
        SL.LoadFromFile(fname);
        For i:= 0 to SL.Count-1 do  // disable prefetch and MCTD GPU
        begin
          s:= TrimLeft(SL[i]);
          if s.StartsWith('prefetch',True) or s.StartsWith('#Bookmarks:', True) or
             s.StartsWith('SetMemoryMax',True)then
               SL[i]:= '#~' + s
          else
            If s.TrimLeft.StartsWith('MCT', True) then
              SL[i]:= StringReplace(s,'GPU=True', 'GPU=False', [rfIgnoreCase]);
        end;
        script:= script + 'function script_' + IntTosTr(idx) + '(){'#13 +
                 Trim(SL.Text) + #13 + '}'#13#13;
      end;

    begin
      sc:= 0;
      FFStop:= false;
      bmCount:= 0;
      Count:= 0;
      splits:= '';

      Try
        fs:= TFileStream.Create(SaveName + fext, fmCreate);
        fs.Size:= 0;
        fs.Write(Header2Flag, SizeOf(Integer));
        splitsL:= 0;
        fs.Write(splitsL, SizeOf(Integer));
        SetLength(ClipsInfo, TabView.Tabs.Count);

        For i:= 0 to TabView.Tabs.Count -1 do
        begin
          TThread.Synchronize(nil, procedure
          begin
            If clipErr <> '' then
              ShowMessage(clipErr);
            ProgressBar1.StepIt;
            Caption:= Format('Clip: %d/%d - Bookmarks: %d/%d', [Count,TabView.Tabs.Count,bmCount,bmAll]);
            If not FFStop then
              FFStop:= FStop;
          end);
          If FFStop then
            break;
          clipErr:= '';

          Clip:= GetClip(i);

          if not Assigned(Clip.FileStream) then
          begin
            fileErr:= fileErr + ExtractFileName(Clip.LastOpen) + #13;
            Continue;
          end;

          fileName:= MakeAVSExt(Clip.LastOpen);
          If not FileExists(fileName) then
          begin
            fileErr:= fileErr + ExtractFileName(fileName) + #13;
            Continue;
          end;

          If bmCount + Clip.FrameList.Count > FMaxBmCount then
          begin
            clipErr:= 'Now ' + IntToStr(bmCount) + ' have been added.'#13+
                      'Can''t add the next clips. Sorry.';
            FFStop:= True;
            Continue;
          end;

          c:= AvsGrabber.OpenAvs(fileName);
          clipErr:= AvsGrabber.ClipError;
          if Assigned(AvsGrabber.VideoInfo) and (c > 0) then
          begin
            ClipsInfo[Count].fps:= FloatToStrF(AvsGrabber.VideoInfo.fps_numerator/AvsGrabber.VideoInfo.fps_denominator, ffGeneral, 8, 3);
            ClipsInfo[Count].w:= AvsGrabber.VideoInfo.width;
            ClipsInfo[Count].h:= AvsGrabber.VideoInfo.height;
            AvsGrabber.Close;
          end
          else begin
            AvsGrabber.Close;
            fileErr:= fileErr + ExtractFileName(fileName) + #13;
            Continue;
          end;

          inc(Count);
          AddToScript(fileName, Count);
          inc(bmCount, Clip.FrameList.Count);
          splits:= splits + IntToStr(Clip.FrameList.Count) + ',';

          With Clip.FileStream do
          begin
            Position:= 0;
            Read(Header, SizeOf(Integer));
            If Header = Header2Flag then
              Read(splitsL, SizeOf(Integer))
            else splitsL:= 0
          end;
          c_start:= fs.Size;
          fs.Position:= fs.Size;
          fs.CopyFrom(Clip.FileStream, Clip.FileStream.Size - (Clip.FileStream.Position + splitsL));

          fs.Position:= c_start;
          While fs.Position < fs.Size - 50 do  //- no + splitsL , it's new stream
          begin
            fs.Read(Nr, SizeOf(Integer));  //- FrameNr
            If sc > 0 then
            begin
              fs.Position:= fs.Position - SizeOf(Integer);
              inc(Nr, sc);
              fs.Write(Nr, SizeOf(Integer));
            end;
            fs.Seek(SizeOf(Integer), soFromCurrent); //- BitInt
            fs.Read(b, SizeOf(Byte));
            if b > 0 then                  //- Title
            begin
              SetLength(title, b div 2);
              fs.Read(title[1], b);
              Bookmarks.Add(IntToStr(Nr) + '= ' + title);
            end
            else Bookmarks.Add(IntToStr(Nr) + '= ');
            fs.Read(e, SizeOf(Integer));     //- ImageSize
            fs.Seek(e, soFromCurrent);
          end;
          sc:= sc + c;
        end;

        //- write splits, must remove the last split, there is nothing to split it's the last part
        If splits.EndsWith(',') then
          SetLength(splits, Length(splits)-1);
        splits:= Copy(splits, 1, splits.LastDelimiter(','));
        If Length(splits) > 3 then
        begin
          splitsL:= Length(splits)*2;
          fs.Position:= fs.Size;
          fs.Write(splits[1], splitsL);
        end
        else splitsL:= 0;
        fs.Position:= SizeOf(Integer);
        fs.Write(splitsL, SizeOf(Integer));

        s:= '#Clips bookmarks'#13 + '#Bookmarks: ';
        Bookmarks.CustomSort(SortListFunc_Bookmarks);
        For i:= 0 to Bookmarks.Count -1 do
          s:= s + Bookmarks.Names[i] + Bookmarks.ValueFromIndex[i] + ',';
        s:= s + #13#13 + script + #13#13;

        //-Force Full HD 16/9 on 4/3 clips and Assume same FPS and kill audio
        If FClipsToClipTweak then
        begin
          For i:= 0 to Count -1 do
          begin
            ws:= '0'; hs:= '0';
            If (ClipsInfo[i].w < 1920) or (ClipsInfo[i].h < 1080) then
            begin
              w:= 1920 - ClipsInfo[i].w;
              If (w > 3) and (w mod 4 = 0) then
                ws:= IntToStr(w div 2);
              h:= 1080 - ClipsInfo[i].h;
              If (h > 3) and (h mod 4 = 0) then
                hs:= IntToStr(h div 2);
            end;
            If (ws <> '0') or (hs <> '0') then
              s:= s + Format('script_%d=script_%d.AddBorders(%s,%s,%s,%s).AssumeFPS(%s).KillAudio()',
                             [i+1,i+1,ws,hs,ws,hs,ClipsInfo[0].fps])+#13
            else
              s:= s + Format('script_%d=script_%d.AssumeFPS(%s).KillAudio()',
                             [i+1,i+1,ClipsInfo[0].fps])+#13;
          end;
          s:= s + #13;
        end;

        For i:= 0 to Count -1 do
          s:= s + 'script_' + IntToStr(i+1) + '+';

        SetLength(s, Length(s)-1);
        SL.Clear;
        SL.Text:= s;
        SL.SaveToFile(SaveName + '.avs');

        If fileErr <> '' then
          TThread.Synchronize(nil, procedure
          begin
            MessageDlg('Clips not saved.'#13#13+ fileErr,mtInformation, [mbOK],0);
          end);
      except
        RaiseLastOSError;
        exit;
      end;

    end);

    TH:= THR.Handle;
    THR.Priority:= tpHigher;
    inc(FTaskCount);
    THR.Start;
    Repeat
      Case MsgWaitForMultipleObjectsEx(1, TH, INFINITE, QS_ALLINPUT, 0) of
        WAIT_OBJECT_0+1: Application.ProcessMessages;
        else
          break;
      end;
    Until False;
    dec(FTaskCount);

  finally
    If Assigned(fs) then
      fs.Free;
    SL.Free;
    Bookmarks.Free;
    Panel1.Visible:= false;
    SetCaption();
    UnblockInput;
  end;

end;

procedure TForm1.PopupMenuPopup(Sender: TObject);
var
  b: Boolean;
begin
  //-popMain
  b:= IsSplitClip(CurrentClip);
  popReOpenSize.Enabled:= (CurrentClip.FrameList.Count > 0) and not b;
  popClearFavorites.Enabled:= CurrentClip.FavorList.Count > 0;
  popClearBasket.Enabled:= CurrentClip.Favor2List.Count > 0;
  popSaveFavorites.Enabled:= Assigned(CurrentClip.FileStream);
  popUpdateBookmarks.Enabled:= (CurrentClip.FrameList.Count > 0) and not b;
  popRunAvsP.Enabled:= CurrentClip.FrameList.Count > 0;
  popOpenLastSavedStream.Enabled:= popOpenLastSavedStream.Count > 0;
  popSaveToStream.Enabled:= (CurrentClip.FrameList.Count > 0) and not b;
  popRunAvsPAllTabs.Visible:= (fRunProg <> '') and (TabView.Tabs.Count > 1);
end;

procedure TForm1.popExtraMenuClick(Sender: TObject);
begin
  //-popExtra
  popTitleAddFavor.Enabled:= CurrentClip.FrameList.Count > 0;
  popSaveImages.Enabled:= ActiveList.Count > 0;
  popBackupFavor.Enabled:= CurrentClip.FavorList.Count > 0;
  popRestoreFavor.Enabled:= CurrentClip.FrameList.Count > 0;
  popSortFavorites.Enabled:= CurrentClip.FavorList.Count > 1;
  popSaveBookmarks.Enabled:= CurrentClip.FrameList.Count > 0;
  popClipsToClip.Enabled:= TabView.Tabs.Count > 1;
  popSaveGroup.Enabled:= GetClip(0).FrameList.Count > 0;
  popMoveFrameNr.Enabled:= CurrentClip.FrameList.Count > 0;
end;

procedure TForm1.popHideClipMenuClick(Sender: TObject);
begin
  popClipExtraMenu.Visible:= not popHideClipMenu.Checked;
end;

procedure TForm1.SendClipToAvsWnd(Sender: TObject);
var
  s: String;
  THR: TThread;
  TH: THandle;
begin
  If FInProgress then
  begin
    beep;
    exit;
  end;

  s:= MakeAVSExt(CurrentClip.LastOpen);
  If FileExists(s) then
  begin
    FInProgress:= True;
    THR:= TThread.CreateAnonymousThread(procedure
    begin
      SendCopyData(GetClip(TMenuItem(Sender).Tag).AvsWnd,s,2,2000); //- Wait max 2 seconds
    end);
    Screen.Cursor:= crHourGlass;
    TH:= THR.Handle;
    THR.Start;
    Repeat
      Case MsgWaitForMultipleObjectsEx(1, TH, 4000, QS_ALLINPUT, 0) of
        WAIT_OBJECT_0+1: Application.ProcessMessages;
        else break;
      end;
    Until False;
    Screen.Cursor:= crDefault;
    FInProgress:= false;
  end
  else
    MessageDlg('Cannot find the avs file.'#13#13+
               ExtractFileName(s),mtInformation,[mbOk],0);
end;

procedure TForm1.PopUpTabPopup(Sender: TObject);
var
  i: Integer;
  item: TMenuItem;
  Clip: TClip;
begin
  popCloseOtherTabs.Enabled:= TabView.Tabs.Count > 1;
  popTabSaveGroup.Enabled:= GetClip(0).FrameList.Count > 0;
  popCloseAllTabs.Enabled:= popTabSaveGroup.Enabled;
  popCloseNextTabs.Enabled:= TabView.TabIndex < TabView.Tabs.Count-1;

  popSendTab.Clear;
  If TabView.Tabs.Count > 1 then
  begin
    For i:= 0 to TabView.Tabs.Count -1 do if (i <> TabView.TabIndex) then
    begin
      Clip:= GetClip(i);
      If (Clip.AvsWnd <> 0) and (Clip.AvsWnd <> CurrentClip.AvsWnd) and IsWindow(Clip.avsWnd) then
      begin
        item:= TMenuItem.Create(popSendTab);
        item.Caption:= 'Wnd tab ' + IntToStr(i+1);
        item.Tag:= i;
        item.OnClick:= SendClipToAvsWnd;
        popSendTab.Add(item);
      end;
    end;
  end;
  popSendTab.Enabled:= popSendTab.Count > 0;
end;

end.
