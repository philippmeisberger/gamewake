object Main: TMain
  Left = 360
  Top = 201
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Game Wake'
  ClientHeight = 270
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    297
    270)
  PixelsPerInch = 96
  TextHeight = 14
  object lDp: TLabel
    Left = 144
    Top = 26
    Width = 7
    Height = 29
    Caption = ':'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -24
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object lHour: TLabel
    Left = 8
    Top = 8
    Width = 42
    Height = 14
    Caption = '00:00:00'
    Color = clBtnFace
    ParentColor = False
  end
  object lCopy: TLabel
    Left = 105
    Top = 253
    Width = 88
    Height = 14
    Anchors = [akBottom]
    Caption = 'PM Code Works'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = lCopyClick
    OnMouseEnter = lCopyMouseEnter
    OnMouseLeave = lCopyMouseLeave
  end
  object pText: TPanel
    Left = 8
    Top = 81
    Width = 282
    Height = 126
    Caption = 'Game Wake'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -37
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 14
    Visible = False
  end
  object bAlert: TButton
    Left = 8
    Top = 214
    Width = 136
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Alert'
    Default = True
    TabOrder = 12
    OnClick = bAlertClick
  end
  object gpOther: TGroupBox
    Left = 152
    Top = 80
    Width = 137
    Height = 127
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'At alert'
    TabOrder = 10
    object cbBlink: TCheckBox
      Left = 12
      Top = 18
      Width = 53
      Height = 19
      Caption = 'Flash'
      TabOrder = 0
      OnClick = cbBlinkClick
    end
    object cbText: TCheckBox
      Left = 12
      Top = 38
      Width = 87
      Height = 19
      Caption = 'Show text'
      TabOrder = 2
      OnClick = cbTextClick
    end
    object bChange: TButton
      Left = 12
      Top = 64
      Width = 109
      Height = 33
      Caption = 'Change text'
      Enabled = False
      TabOrder = 3
      OnClick = bChangeClick
    end
    object bColor: TButton
      Left = 80
      Top = 18
      Width = 40
      Height = 18
      Caption = 'Color'
      Enabled = False
      TabOrder = 1
      OnClick = bColorClick
    end
  end
  object rgSounds: TRadioGroup
    Left = 8
    Top = 80
    Width = 137
    Height = 127
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Alert selection'
    ItemIndex = 0
    Items.Strings = (
      'Bell'
      'Horn'
      'Beep'
      'Bing'
      'Shut down')
    TabOrder = 9
  end
  object eHour: TEdit
    Left = 111
    Top = 24
    Width = 33
    Height = 37
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -24
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    MaxLength = 2
    ParentFont = False
    TabOrder = 0
    Text = '00'
    OnKeyPress = eHourKeyPress
    OnKeyUp = eHourKeyUp
  end
  object eMin: TEdit
    Left = 152
    Top = 24
    Width = 33
    Height = 37
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -24
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    MaxLength = 2
    ParentFont = False
    TabOrder = 1
    Text = '00'
    OnKeyPress = eHourKeyPress
    OnKeyUp = eMinKeyUp
  end
  object bStop: TButton
    Left = 153
    Top = 214
    Width = 136
    Height = 33
    Anchors = [akBottom]
    Cancel = True
    Caption = 'off'
    Enabled = False
    TabOrder = 11
    OnClick = bStopClick
  end
  object bPlayClock: TButton
    Left = 120
    Top = 96
    Width = 17
    Height = 17
    Caption = #9654
    TabOrder = 6
    OnClick = bPlayClockClick
  end
  object bPlayBing: TButton
    Left = 120
    Top = 136
    Width = 17
    Height = 17
    Caption = #9654
    TabOrder = 8
    OnClick = bPlayBingClick
  end
  object bPlayBeep: TButton
    Left = 120
    Top = 156
    Width = 17
    Height = 17
    Caption = #9654
    TabOrder = 13
    OnClick = bPlayBeepClick
  end
  object bPlayHorn: TButton
    Left = 120
    Top = 116
    Width = 17
    Height = 17
    Caption = #9654
    TabOrder = 7
    OnClick = bPlayHornClick
  end
  object bIncHour: TButton
    Left = 111
    Top = 7
    Width = 33
    Height = 17
    Caption = '+'
    TabOrder = 3
    OnClick = bIncHourClick
  end
  object bDecHour: TButton
    Left = 111
    Top = 60
    Width = 33
    Height = 17
    Caption = '-'
    TabOrder = 2
    OnClick = bDecHourClick
  end
  object bDecMin: TButton
    Left = 152
    Top = 60
    Width = 33
    Height = 17
    Caption = '-'
    TabOrder = 4
    OnClick = bDecMinClick
  end
  object bIncMin: TButton
    Left = 152
    Top = 8
    Width = 33
    Height = 16
    Caption = '+'
    TabOrder = 5
    OnClick = bIncMinClick
  end
  object MainMenu: TMainMenu
    Left = 64
    Top = 24
    object mmFile: TMenuItem
      Caption = 'File'
      object mmSave: TMenuItem
        Caption = 'Store settings'
        OnClick = mmSaveClick
      end
    end
    object mmEdit: TMenuItem
      Caption = 'Edit'
      object mmOptions: TMenuItem
        Caption = 'Options'
        OnClick = mmOptionsClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mmTimer: TMenuItem
        Caption = 'Timer mode'
        Checked = True
        RadioItem = True
        OnClick = mmTimerClick
      end
      object mmCounter: TMenuItem
        Caption = 'Counter mode'
        RadioItem = True
        OnClick = mmCounterClick
      end
    end
    object mmView: TMenuItem
      Caption = 'View'
      object mmLang: TMenuItem
        Caption = 'Choose language'
        OnClick = mmLangClick
      end
    end
    object mmHelp: TMenuItem
      Caption = 'Help'
    end
  end
  object pmMenu: TPopupMenu
    Left = 16
    Top = 24
    object pmOpen: TMenuItem
      Caption = 'Open'
      Default = True
      OnClick = pmOpenClick
    end
    object pmClose: TMenuItem
      Caption = 'Close'
      OnClick = pmCloseClick
    end
  end
  object TrayIcon: TTrayIcon
    PopupMenu = pmMenu
    OnClick = pmOpenClick
    Left = 216
    Top = 24
  end
end
