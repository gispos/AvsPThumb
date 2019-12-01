unit GPoUtils;   //GPo 2001

interface
uses IniFiles,Menus,CheckLst,Math,Forms,SysUtils,Graphics, System.UITypes;

procedure iniWriteFormRect(IniFile: TIniFile; aForm: TForm; const AutoWriteStayOnTop: Boolean= True; StayOnTop: Boolean= False);
procedure iniWriteCheckListBox(IniFile: TIniFile; Sektion: String; aCheckListBox: TCheckListBox);
procedure iniWriteRadioItem(IniFile: TIniFile; Sektion,Value: String; aMenuItem: TMenuItem);
procedure iniWriteRadioItemGroup(IniFile: TIniFile; Sektion, Value: String; aMenuItem: TMenuItem; GroupIndex: Byte);
function iniReadFormRect(IniFile: TIniFile; DfWidth,DfHeight: Integer;
 aForm: TForm; DefaultStayOnTop: Boolean= False; Center: Boolean=True; DfLeft: Integer=0; DfTop: Integer=0): Boolean;
procedure iniReadRadioItemCheck(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem);
procedure iniReadRadioItemClick(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem);
function iniReadRadioItem(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem): Integer;
procedure iniReadRadioItemGroupCheck(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem; GroupIndex: Byte);
function iniReadCheckListBox(IniFile: TIniFile; Sektion: String; aCheckListBox: TCheckListBox; DefaultChecked: Boolean): Boolean;
procedure iniWriteFont(ini: TIniFile; Name: String; Font: TFont);
procedure iniReadFont(ini: TIniFile; Name: String; Font: TFont);
procedure FormToMainFormCenter(MainForm,ClientForm: TForm);
procedure FormToScreenCenter(aForm: TForm);
function  ExtractFileNameNoExt(FileName: String): String;
function GetRadioItemIndex(aMenuItem: TMenuItem; GetTag: Boolean= False): Integer;
// Ver. u. Endschlüßeln
function XORString(const aText,Schluessel: String): String;
function GetWinMajorVersion: Integer;

implementation

uses StrUtils, WinApi.windows;

procedure iniWriteFormRect(IniFile: TIniFile; aForm: TForm; const AutoWriteStayOnTop: Boolean= True; StayOnTop: Boolean= False);
begin
  If not Assigned(aForm) then exit;
  If aForm.WindowState<>wsMaximized then
  begin
    IniFile.WriteInteger(aForm.Name,'Left',aForm.Left);
    IniFile.WriteInteger(aForm.Name,'Top',aForm.Top);
    IniFile.WriteInteger(aForm.Name,'Width',aForm.Width);
    IniFile.WriteInteger(aForm.Name,'Height',aForm.Height);
    IniFile.WriteBool(aForm.Name,'Maximized',False);
  end
  else IniFile.WriteBool(aForm.Name,'Maximized',True);
  If AutoWriteStayOnTop then
  begin
    If aForm.FormStyle= fsNormal then IniFile.WriteBool(aForm.Name,'StayOnTop',False)
    else IniFile.WriteBool(aForm.Name,'StayOnTop',True);
  end
  else begin
    If StayOnTop then IniFile.WriteBool(aForm.Name,'StayOnTop',True)
    else IniFile.WriteBool(aForm.Name,'StayOnTop',False);
  end;
end;

// Ist Center= False dann wird DfLeft und DfTop bei Defaultweten ausgegeben.
function iniReadFormRect(IniFile: TIniFile; DfWidth,DfHeight: Integer;
   aForm: TForm; DefaultStayOnTop: Boolean= False; Center: Boolean=True; DfLeft: Integer=0; DfTop: Integer=0): Boolean;
begin
  aForm.Width:= IniFile.ReadInteger(aForm.Name,'Width',DfWidth);
  aForm.Height:= IniFile.ReadInteger(aForm.Name,'Height',DfHeight);
  If Center and((not IniFile.ValueExists(aForm.Name,'Left'))or(not IniFile.ValueExists(aForm.Name,'Top')))then
  begin
    aForm.Left:= Max((Screen.DesktopWidth-aForm.Width)div 2,0);
    aForm.Top:= Max((Screen.DesktopHeight-aForm.Height)div 2,0);
  end
  else begin
    aForm.Left:= Max(IniFile.ReadInteger(aForm.Name,'Left',DfLeft),0);
    aForm.Top:= Max(IniFile.ReadInteger(aForm.Name,'Top',DfTop),0);
  end;

  If IniFile.ReadBool(aForm.Name,'Maximized',False) then aForm.WindowState:= wsMaximized;
  If IniFile.ReadBool(aForm.Name,'StayOnTop',DefaultStayOnTop) then
  begin
    aForm.FormStyle:= fsStayOnTop;
    Result:= True;
  end
  else begin
    aForm.FormStyle:= fsNormal;
    Result:= False;
  end;
end;

procedure iniWriteRadioItem(IniFile: TIniFile; Sektion,Value: String; aMenuItem: TMenuItem);
var i: Integer;
begin
  For i:= 0 to aMenuItem.Count-1 do if (aMenuItem.Items[i].RadioItem) and (aMenuItem.Items[i].Checked) then
  begin
    IniFile.WriteInteger(Sektion,Value,aMenuItem.Items[i].MenuIndex);
    exit;
  end;
end;

procedure iniReadRadioItemCheck(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem);
var i: Integer;
begin
  i:= IniFile.ReadInteger(Sektion, Value, Default);
  If (i < aMenuItem.Count) and (i> -1) then
    aMenuItem.Items[i].Checked:= True
  else if (Default > -1) and (aMenuItem.Count> 0) then aMenuItem.Items[0].Checked:= True;
end;

procedure iniReadRadioItemClick(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem);
var i: Integer;
begin
  i:= IniFile.ReadInteger(Sektion, Value, Default);
  If (i < aMenuItem.Count) and (i> -1) then
    aMenuItem.Items[i].Click
  else if aMenuItem.Count> 0 then aMenuItem.Items[0].Click;
end;

function iniReadRadioItem(IniFile: TIniFile; Sektion,Value: String; Default: Integer; aMenuItem: TMenuItem): Integer;
var i: Integer;
begin
  i:= IniFile.ReadInteger(Sektion, Value, Default);
  If (i < aMenuItem.Count) and (i> -1) then
    Result:= i
  else Result:= 0;
end;

procedure iniWriteRadioItemGroup(IniFile: TIniFile; Sektion,Value: String; aMenuItem: TMenuItem; GroupIndex: Byte);
var i,z: Integer;
begin
  z:= 0;
  For i:= 0 to aMenuItem.Count-1 do if (aMenuItem.Items[i].RadioItem)and (aMenuItem[i].GroupIndex= GroupIndex) then
  begin
    If aMenuItem.Items[i].Checked then
    begin
      IniFile.WriteInteger(Sektion, Value, z);
      exit;
    end
    else inc(z);
  end;
end;

procedure iniReadRadioItemGroupCheck(IniFile: TIniFile; Sektion, Value: String; Default: Integer; aMenuItem: TMenuItem; GroupIndex: Byte);
var i,z: Integer;
begin
  z:= IniFile.ReadInteger(Sektion, Value, Default);
  For i:= 0 to aMenuItem.Count-1 do if (aMenuItem.Items[i].RadioItem)and (aMenuItem[i].GroupIndex= GroupIndex) then
  begin
    If (i + z < aMenuItem.Count) and (aMenuItem.Items[i + z]).RadioItem and (aMenuItem.Items[i + z].GroupIndex = GroupIndex) then
      aMenuItem.Items[i + z].Checked:= true;
    exit;
  end;
end;

procedure iniWriteCheckListBox(IniFile: TIniFile; Sektion: String; aCheckListBox: TCheckListBox);
var i: Integer;
begin
  For i:= 0 to aCheckListBox.Count-1 do
   IniFile.WriteBool(Sektion,aCheckListBox.Items.Strings[i],aCheckListBox.Checked[i]);
end;

function iniReadCheckListBox(IniFile: TIniFile; Sektion: String;
  aCheckListBox: TCheckListBox; DefaultChecked: Boolean): Boolean;
var i: Integer;
begin
  Result:= IniFile.SectionExists(Sektion);
  For i:= 0 to aCheckListBox.Count-1 do
   aCheckListBox.Checked[i]:= IniFile.ReadBool(Sektion,aCheckListBox.Items.Strings[i],DefaultChecked);
end;

procedure iniWriteFont(ini: TIniFile; Name: String; Font: TFont);
begin
  ini.WriteString(Name, 'Name', Font.Name);
  ini.WriteInteger(Name, 'Size', Font.Size);
  ini.WriteInteger(Name, 'Color', Font.Color);
  ini.WriteBool(Name, 'Bold', fsBold in Font.Style);
  ini.WriteBool(Name, 'Italic', fsItalic in Font.Style);
  ini.WriteBool(Name, 'UnderL', fsUnderline in Font.Style);
  ini.WriteBool(Name, 'StrOut', fsStrikeOut in Font.Style);
end;

procedure iniReadFont(ini: TIniFile; Name: String; Font: TFont);
var
  fs: TFontStyles;
begin
  Font.Name:= ini.ReadString(Name, 'Name', 'Tahoma');
  Font.Size:= ini.ReadInteger(Name, 'Size', 8);
  Font.Color:= ini.ReadInteger(Name, 'Color', clBlack);
  fs:= [];
  If ini.ReadBool(Name, 'Bold', false) then
    Include(fs, fsBold);
  If ini.ReadBool(Name, 'Italic', false) then
    Include(fs, fsItalic);
  If ini.ReadBool(Name, 'UnderL', false) then
    Include(fs, fsUnderline);
  If ini.ReadBool(Name, 'StrOut', false) then
    Include(fs, fsStrikeOut);
  Font.Style:= fs;
end;

procedure FormToMainFormCenter(MainForm,ClientForm: TForm);
begin
  ClientForm.Left:= Min(Max(MainForm.Left+((MainForm.Width-ClientForm.Width)div 2),0),Screen.WorkAreaWidth-ClientForm.Width);
  ClientForm.Top:=  Min(Max(MainForm.Top+((MainForm.Height-ClientForm.Height)div 2),0),Screen.WorkAreaHeight-ClientForm.Height);
end;

procedure FormToScreenCenter(aForm: TForm);
begin
  aForm.SetBounds((Screen.WorkAreaWidth-aForm.Width)div 2,(Screen.WorkAreaHeight-aForm.Height)div 2,aForm.Width,aForm.Height);
end;

function  ExtractFileNameNoExt(FileName: String): String;
begin
  Result:= ChangeFileExt(ExtractFileName(FileName),'');
end;

function GetRadioItemIndex(aMenuItem: TMenuItem; GetTag: Boolean= False): Integer;
var i: Integer;
begin
  For i:= 0 to aMenuItem.Count-1 do if (aMenuItem.Items[i].RadioItem)and(aMenuItem.Items[i].Checked) then
  begin
    If GetTag then Result:= aMenuItem.Items[i].Tag
    else Result:= i;
    exit;
  end;
  Result:= 0;
end;

function XORString(const aText,Schluessel: String): String;
var i,q: integer;
    sc: String;
begin
  q:= 1;
  if Trim(Schluessel)= '' then
    sc:= 'gisbertpospischil'
  else sc:= Schluessel;
  Result:= aText;
  If Result<> '' then
  for i:= 1 to Length(Result) do
  begin
    Result[i]:= Chr(Ord(aText[i]) XOR Ord(sc[q]));
    inc(q);
    if q> length(sc) then q:= 1;
  end;
end;

function GetWinMajorVersion: Integer;
var
  OSVersionInfo: TOSVersionInfo;
begin
  OSVersionInfo.dwOSVersionInfoSize := sizeof(OSVersionInfo);
  GetVersionEx(OSVersionInfo);
  Result:= OSVersionInfo.dwMajorVersion; // < 6 WinXP
end;

end.
