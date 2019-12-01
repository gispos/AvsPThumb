object FormOptions: TFormOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Optionen'
  ClientHeight = 263
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    480
    263)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 390
    Top = 230
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 309
    Top = 230
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 480
    Height = 224
    ActivePage = Tab1
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object Tab1: TTabSheet
      Caption = 'Default'#13#10
    end
    object TabSheet1: TTabSheet
      Caption = 'Theme'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 470
      ExplicitHeight = 186
    end
  end
  object cbTheme: TComboBox
    Left = 16
    Top = 180
    Width = 145
    Height = 21
    TabOrder = 3
    Text = 'Windows'
    Items.Strings = (
      'Windows'
      'Amakrits'
      'Charcoal Dark Slate'
      'Glossy'
      'Glow'
      'Onyx Blue'
      'Ruby Graphite')
  end
end
