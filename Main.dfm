object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'AvsPThumb'
  ClientHeight = 436
  ClientWidth = 233
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesigned
  Visible = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LV: TListViewEx
    Left = 0
    Top = 20
    Width = 233
    Height = 395
    Align = alClient
    Color = clBlack
    Columns = <>
    ColumnClick = False
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    HideSelection = False
    StyleElements = [seBorder]
    OwnerData = True
    ReadOnly = True
    ParentDoubleBuffered = False
    ParentFont = False
    ShowColumnHeaders = False
    TabOrder = 0
    Touch.InteractiveGestureOptions = []
    Touch.ParentTabletOptions = False
    Touch.TabletOptions = []
    OnChange = LVChange
    OnCustomDrawItem = LVCustomDrawItem
    OnData = LVData
    OnDataStateChange = LVDataStateChange
    OnDblClick = LVDblClick
    OnEndDrag = LVEndDrag
    OnDragDrop = LVDragDrop
    OnDragOver = LVDragOver
    OnMouseDown = LVMouseDown
    OnMouseMove = LVMouseMove
    OnResize = LVResize
    OnSelectItem = LVSelectItem
    OnStartDrag = LVStartDrag
  end
  object TabSet: TTabSet
    Left = 0
    Top = 415
    Width = 233
    Height = 21
    Align = alBottom
    AutoScroll = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    SelectedColor = clActiveCaption
    SoftTop = True
    Style = tsSoftTabs
    Tabs.Strings = (
      'Norm'
      'Favor')
    TabIndex = 0
    OnChange = TabSetChange
  end
  object TabView: TTabSet
    Left = 0
    Top = 0
    Width = 233
    Height = 20
    Align = alTop
    DoubleBuffered = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    SelectedColor = clActiveCaption
    SoftTop = True
    Style = tsModernTabs
    Tabs.Strings = (
      ' 1 '
      ' 2 ')
    TabIndex = 0
    TabPosition = tpTop
    OnChange = TabViewChange
    OnDrawTab = TabViewDrawTab
    OnMouseDown = TabViewMouseDown
    OnMouseMove = TabViewMouseMove
  end
  object Panel1: TPanel
    Left = 1
    Top = 20
    Width = 109
    Height = 42
    BevelOuter = bvNone
    Color = clActiveCaption
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    ShowCaption = False
    TabOrder = 1
    Visible = False
    object ProgressBar1: TProgressBar
      Left = 0
      Top = 0
      Width = 109
      Height = 17
      Align = alTop
      Smooth = True
      Step = 1
      TabOrder = 0
    end
    object btnStop: TButton
      Left = 0
      Top = 17
      Width = 109
      Height = 25
      Align = alClient
      BiDiMode = bdLeftToRight
      Caption = 'Stop'
      ImageAlignment = iaCenter
      ParentBiDiMode = False
      TabOrder = 1
      TabStop = False
      OnClick = btnStopClick
    end
  end
  object OpenDlg: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofShareAware, ofEnableSizing]
    Left = 36
    Top = 92
  end
  object PopupMenu: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PopupMenuPopup
    Left = 28
    Top = 176
    object popOpen: TMenuItem
      Caption = 'Open...'
      OnClick = popOpenClick
    end
    object popReOpenSize: TMenuItem
      AutoHotkeys = maManual
      Caption = 'ReOpen Size'
      object popReOpen240: TMenuItem
        Tag = 240
        Caption = '240'
        OnClick = popReOpen240Click
      end
      object popReOpen360: TMenuItem
        Tag = 360
        Caption = '360'
        OnClick = popReOpen240Click
      end
      object popReOpen480: TMenuItem
        Tag = 480
        Caption = '480'
        OnClick = popReOpen240Click
      end
      object popReOpen640: TMenuItem
        Tag = 640
        Caption = '640'
        OnClick = popReOpen240Click
      end
      object popReOpen720: TMenuItem
        Tag = 720
        Caption = '720'
        OnClick = popReOpen240Click
      end
      object popReOpenSizeCustom: TMenuItem
        Caption = 'Custom...'
        OnClick = popReOpenCustomSizeClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object popReOpenCustom: TMenuItem
        Tag = 800
        Caption = '800'
        OnClick = popReOpen240Click
      end
    end
    object popOpenLastSavedStream: TMenuItem
      Caption = 'Open last saved stream'
      OnClick = popOpenLastSavedStreamClick
    end
    object popUpdateBookmarks: TMenuItem
      Caption = 'Update Bookmarks...'
      OnClick = popUpdateBookmarksClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object popZoom: TMenuItem
      AutoHotkeys = maManual
      Caption = 'Zoom'
      object N251: TMenuItem
        Tag = 25
        Caption = '25'
        RadioItem = True
        OnClick = popZ50Click
      end
      object popZ50: TMenuItem
        Tag = 50
        Caption = '50'
        RadioItem = True
        OnClick = popZ50Click
      end
      object popZ100: TMenuItem
        Tag = 100
        Caption = '100'
        RadioItem = True
        OnClick = popZ50Click
      end
      object popZ150: TMenuItem
        Tag = 150
        Caption = '150'
        RadioItem = True
        OnClick = popZ50Click
      end
      object popZ200: TMenuItem
        Tag = 200
        Caption = '200'
        RadioItem = True
        OnClick = popZ50Click
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object popZFit: TMenuItem
        Tag = -1
        Caption = 'Fit'
        Checked = True
        RadioItem = True
        OnClick = popZ50Click
      end
      object popZ100Fit: TMenuItem
        Caption = '100 Fit   (F1)'
        OnClick = popZ100FitClick
      end
    end
    object Option1: TMenuItem
      AutoHotkeys = maManual
      Caption = 'Options'
      object popDefThumbWidth: TMenuItem
        Caption = 'Default image width...'
        OnClick = popDefThumbWidthClick
      end
      object popReOpenCustomSize: TMenuItem
        Caption = 'ReOpen custom size...'
        OnClick = popReOpenCustomSizeClick
      end
      object JPEGQuality1: TMenuItem
        Caption = 'JPEG quality...'
        OnClick = JPEGQuality1Click
      end
      object popBackgroundColor: TMenuItem
        Caption = 'Background color...'
        OnClick = popBackgroundColorClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object popMaxHistoryCount: TMenuItem
        Caption = 'Max file history count...'
        OnClick = popMaxHistoryCountClick
      end
      object popClearFileHistory: TMenuItem
        Caption = 'Clear file history'
        OnClick = popClearFileHistoryClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object popFormAutoMove: TMenuItem
        AutoCheck = True
        Caption = 'Form auto move'
        Checked = True
      end
      object popTitleAutoAddFavor: TMenuItem
        AutoCheck = True
        Caption = 'Title automatic to favorites'
        Checked = True
      end
      object popShowTitle: TMenuItem
        AutoCheck = True
        Caption = 'Show Title'
      end
      object popSingleInstance: TMenuItem
        AutoCheck = True
        Caption = 'Single Instance'
        Checked = True
      end
      object popAfterSaveToStreamOpenStream: TMenuItem
        AutoCheck = True
        Caption = 'After save stream open Stream'
        Checked = True
        Visible = False
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object popAvsPTabsChange: TMenuItem
        AutoCheck = True
        Caption = 'Enable AvsP Tabs change'
        Checked = True
        Visible = False
      end
      object popAvsPscrolldiv2: TMenuItem
        AutoCheck = True
        Caption = 'AvsP scroll div 2'
        Checked = True
      end
      object popAvsPscrollreverse: TMenuItem
        AutoCheck = True
        Caption = 'AvsP scroll reverse'
      end
    end
    object E1: TMenuItem
      AutoHotkeys = maManual
      Caption = 'Extras'
      object SaveDefaultPos1: TMenuItem
        Caption = 'Save default Pos'
        OnClick = SaveDefaultPos1Click
      end
      object popResetDefaultPos: TMenuItem
        Caption = 'Reset to default Pos   (F2)'
        OnClick = popResetDefaultPosClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object popThemes: TMenuItem
        AutoHotkeys = maManual
        Caption = 'Themes'
        object popStyle_0: TMenuItem
          AutoCheck = True
          AutoHotkeys = maManual
          Caption = 'Windows'
          Checked = True
          Hint = 'Windows'
          RadioItem = True
          OnClick = popStyle_0Click
        end
        object N15: TMenuItem
          Caption = '-'
        end
      end
      object N14: TMenuItem
        Caption = '-'
      end
      object popSortFavorites: TMenuItem
        Caption = 'Sort Favorites'
        OnClick = popSortFavoritesClick
      end
      object popBackupFavor: TMenuItem
        Caption = 'Backup Favorites...'
        OnClick = popBackupFavorClick
      end
      object popRestoreFavor: TMenuItem
        Caption = 'Restore Favorites...'
        OnClick = popRestoreFavorClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object popTitleAddFavor: TMenuItem
        Caption = 'Title add Favorites'
        OnClick = popTitleAddFavorClick
      end
      object popSaveImages: TMenuItem
        Caption = 'Save all Images (bmp)...'
        OnClick = popSaveImagesClick
      end
      object popSaveBookmarks: TMenuItem
        Caption = 'Save Bookmarks (*.cr)'
        OnClick = popSaveBookmarksClick
      end
      object popClipsToClip: TMenuItem
        Caption = 'Clips to clip...'
        OnClick = popClipsToClipClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object M1: TMenuItem
        Caption = 'Move frame nr...'
        OnClick = M1Click
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object popSaveToStream: TMenuItem
      Caption = 'Save to Stream (bok)...'
      OnClick = popSaveToStreamClick
    end
    object popLoadFromStream: TMenuItem
      Caption = 'Load from Stream (bok)...'
      OnClick = popLoadFromStreamClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object popSaveFavorites: TMenuItem
      Caption = 'Save Favorites'
      OnClick = popSaveFavoritesClick
    end
    object popClearFavorites: TMenuItem
      Caption = 'Clear Favorites'
      OnClick = popClearFavoritesClick
    end
    object popClearBasket: TMenuItem
      Caption = 'Clear Basket'
      OnClick = popClearBasketClick
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object popRunAvsP: TMenuItem
      Caption = 'Run AvsPmod'
      OnClick = popRunAvsPClick
    end
    object popRunAvsPAllTabs: TMenuItem
      Caption = 'Run AvsPmod all tabs'
      OnClick = popRunAvsPAllTabsClick
    end
    object popSendCommand: TMenuItem
      AutoHotkeys = maManual
      Caption = 'Send Command'
    end
  end
  object SaveDlg: TSaveDialog
    Options = [ofOverwritePrompt, ofEnableSizing, ofForceShowHidden]
    Left = 104
    Top = 92
  end
  object PopUpTab: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PopUpTabPopup
    Left = 152
    Top = 28
    object popCloseTab: TMenuItem
      Caption = 'Close tab'
      OnClick = popCloseTabClick
    end
    object popCloseAllTabs: TMenuItem
      Caption = 'Close all tabs'
      OnClick = popCloseAllTabsClick
    end
    object popCloseOtherTabs: TMenuItem
      Caption = 'Close all other tabs'
      OnClick = popCloseOtherTabsClick
    end
    object N16: TMenuItem
      Caption = '-'
    end
    object popSendTab: TMenuItem
      Caption = 'Send tab to'
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object popShowPreview: TMenuItem
      AutoCheck = True
      Caption = 'Show preview'
      Checked = True
    end
    object popForceAvsPWnd: TMenuItem
      AutoCheck = True
      Caption = 'Force AvsP Wnd'
    end
  end
  object TaskDlg: TTaskDialog
    Buttons = <>
    CommonButtons = [tcbOk]
    MainIcon = 0
    RadioButtons = <>
    Left = 156
    Top = 172
  end
  object ColorDialog: TColorDialog
    Options = [cdFullOpen, cdAnyColor]
    Left = 80
    Top = 268
  end
end
