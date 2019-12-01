unit Optionen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Themes;

type
  TFormOptions = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    Tab1: TTabSheet;
    TabSheet1: TTabSheet;
    cbTheme: TComboBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FormOptions: TFormOptions;

implementation
uses Main, FileUtils;

{$R *.dfm}

procedure TFormOptions.btnCancelClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure TFormOptions.btnOKClick(Sender: TObject);
var
  s: String;
  Style: TStyleManager.TStyleServicesHandle;
begin
  if Assigned(TStyleManager.ActiveStyle) and
    (TStyleManager.ActiveStyle.Name <> cbTheme.Items[cbTheme.ItemIndex]) then
    begin
      s:= ProgramPath+'Themes\'+ cbTheme.Items[cbTheme.ItemIndex] + '.vsf';
      if FileExists(s) then
      begin
        Style:= TStyleManager.LoadFromFile(s);
        If Assigned(Style) then
           TStyleManager.SetStyle(Style)
        else cbTheme.ItemIndex:= 0;
      end
      else cbTheme.ItemIndex:= 0;
    end;

   ModalResult:= mrOk;
end;

end.
