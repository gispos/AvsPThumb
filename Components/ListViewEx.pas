unit ListViewEx;

interface

uses
  Windows, Classes, Controls, ComCtrls, CommCtrl, Messages;

type
  TOnBeforEditing= procedure(item: TListItem; var S: String) of Object;
  TListViewEx = class(TListView)
  private
    //procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    FOnBeforEditing: TOnBeforEditing;
    procedure WMKEYDOWN(var Msg: TMessage); message WM_KEYDOWN;
    procedure CNNOTIFY(var Msg:TWMNotify); message CN_NOTIFY;
  public
    constructor Create(Owner: TComponent); override;
    procedure ClearSelection; override;
    // this functions a little faster as ListView.NextItem
    function GetNextSelectedIndex(StartIndex: Integer): Integer;
    function GetNextSelectedItem(StartItem: TListItem): TListItem;
  published
    property OnBeforEditing: TOnBeforEditing read FOnBeforEditing write FOnBeforEditing;
    { Published-Deklarationen }
  end;

procedure Register;

implementation
const
  SelectedFlag = LVNI_ALL or LVNI_SELECTED;

procedure Register;
begin
  RegisterComponents('GPoExtra', [TListViewEx]);
end;

constructor TListViewEx.Create(Owner: TComponent);
begin
  inherited;
end;

{procedure TListViewEx.WMVScroll(var Message: TWMVScroll);
begin
  Message.Result:= 1;
  inherited;
end;}

procedure TListViewEx.CNNOTIFY(var Msg:TWMNotify);
var
    S: String;
    LVEditHandle: THandle;
begin
  //this is bug in TCustomListView in OwnerDraw mode
  {Case Msg.NMHdr.code of
    LVN_ITEMCHANGED:
      with PNMListView(Msg.NMHdr)^ do
       ListView_RedrawItems(Handle, iItem, iItem);
    LVN_ODSTATECHANGED :
      with PNMLVODStateChange(Msg.NMHdr)^ do
        ListView_RedrawItems(Handle, iFrom, iTo);
  end;
  }

  Case Msg.NMHdr.code of
    LVN_BEGINLABELEDIT:
      If Assigned(FOnBeforEditing)and(Msg.Result = 0) then
      begin
        LVEditHandle := ListView_GetEditControl(Handle);
        if LVEditHandle <> 0 then
        begin
          //GPo: Change the Caption befor Edit the item if you want (FOnBeforEditing)
          FOnBeforEditing(items[PLVDispInfo(Msg.NMHdr)^.item.iItem], S);
          SetWindowPos(LVEditHandle, 0, 0, 0, 500, 200, SWP_SHOWWINDOW + SWP_NOMOVE);
          SendMessage(LVEditHandle, WM_SETTEXT, 0, Longint(PAnsiChar(AnsiString(S))));
        end;
      end;
  end;
  inherited;
end;

// GPo: Performance bug in TListview on ClearSelection
procedure TListViewEx.ClearSelection;
var
  i: Integer;
begin
                  // This clear fast all selections (show in TListview proc)
  If SendMessage(Handle, LVM_GETSELECTEDCOUNT, 0, 0) > 1 then Selected:= nil
  else begin
    // this get fast first selected Index
    i:= ListView_GetNextItem(Handle, -1, SelectedFlag);
    If i> -1 then items[i].Selected:= false;
  end;
end;

// this is a TListView bug in OwnerData Mode
procedure TListViewEx.WMKEYDOWN(var Msg: TMessage);
var
  i,z: Integer;
  b,Handled: boolean;
  oEvent: TLVOwnerDataEvent;
begin
If (ViewStyle= vsIcon) and OwnerData then
begin
  Handled:= false;
  Case Msg.WParam of
    VK_LEFT,VK_RIGHT:
      begin
        If Selected<> nil then
        begin
          Handled:= true;
          b:= DoubleBuffered;
          DoubleBuffered:= true;
          Invalidate;
          oEvent:= OnData;
          OnData:= nil;
          Items.BeginUpdate;
          Try
            If Msg.WParam= VK_RIGHT then
            begin
              i:= Selected.Index+1;
              If i>= items.Count then i:= items.Count-1;
            end
            else begin
              i:= Selected.Index-1;
              If i< 0 then i:= 0;
            end;

            If ListView_GetSelectedCount(Handle)> 1 then Selected:= nil
            else Selected.Selected:= false;
            
            items[i].Selected:= true;
            items[i].Focused:= true;
            items[i].MakeVisible(false);
          finally
            OnData:= oEvent;
            Items.EndUpdate;
            Update;
            DoubleBuffered:= b;
          end;
        end
        else begin
          Handled:= true;
          b:= DoubleBuffered;
          DoubleBuffered:= true;
          Invalidate;
          inherited;
          DoubleBuffered:= b;
        end;
      end;

    VK_DOWN,VK_UP:
      begin
        If items.Count= 0 then exit;
        Handled:= true;
        b:= DoubleBuffered;
        DoubleBuffered:= true;
        Invalidate;
        oEvent:= OnData;
        OnData:= nil;
        If Selected<> nil then i:= Selected.Index
        else i:= 0;
        If items[i].GetPosition.X> 60 then z:= 1 // Wieder so'ne Kake
        else z:= 0;
        If Msg.WParam= VK_DOWN then
        begin
          z:= TListItem(GetNextItem(items[i],sdBelow,[isNone])).Index+z;
          If (z>= items.Count-1)or(z= i) then z:= items.Count-1;
        end
        else z:= TListItem(GetNextItem(items[i],sdAbove,[isNone])).Index+z;
        If z= -1 then exit;
        items.BeginUpdate;

        If ListView_GetSelectedCount(handle)> 1 then Selected:= nil
        else items[i].Selected:= false;

        items[z].Selected:= true;
        items[z].Focused:= true;
        items[z].MakeVisible(false);
        OnData:= oEvent;
        items.EndUpdate;
        Update;
        DoubleBuffered:= b;
      end;
    33..36:   // Pos1, Ende, Bild
      begin
        Handled:= true;
        b:= DoubleBuffered;
        DoubleBuffered:= true;
        Invalidate;
        inherited;
        DoubleBuffered:= b;
      end;
  end;
  If not Handled then inherited;
end
else Inherited;
end;

// call -1 for first selected
function TListViewEx.GetNextSelectedIndex(StartIndex: Integer): Integer;
begin
  If Handle <> 0 then
    Result:= ListView_GetNextItem(Handle, StartIndex, SelectedFlag)
  else Result:= -1;
end;

function TListViewEx.GetNextSelectedItem(StartItem: TListItem): TListItem;
var
  Index: Integer;
begin
  If Handle <> 0 then
  begin
    If Assigned(StartItem) then
      Index:= ListView_GetNextItem(Handle, StartItem.Index, SelectedFlag)
    else Index:= ListView_GetNextItem(Handle, -1, SelectedFlag);
    If Index > -1 then Result:= items[Index]
    else Result:= nil;
  end
  else Result:= nil;
end;

end.
