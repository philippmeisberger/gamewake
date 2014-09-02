object Main: TMain
  Left = 237
  Top = 160
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Game Wake'
  ClientHeight = 270
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Icon.Data = {
    0000010001002020100001000400E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000007777777770000000000000000
    000007777777777777000000000000000007777FFFF9FFFFFF77000000000000
    00777FFFFFFFFFFFFFF7700000000000077FF9FFFFFFFFFFF9FF770000000000
    77F9FFFFFFFFFFFFFFFFF7700000000077FF9FFFFFFFFFFFFFFFFF7000000007
    7FFFF9FFFFFFFFFFFFFFFF77000000077F9FFF9FFFFFFFFFFFFF9FF700000077
    FFFFFFF9FFFFFFFFFFFFFFF770000077FFFFFFFF9FFFFFFFFFFFFFF770000077
    FFFFFFFFF9FFFFFFFFFFFFFF70000077FFFFFFFFFF000FFFFFFFFFFF70000077
    9FFFFFFFFF000FFFFFFFFF9F70000077FFFFFFFFFF000FFFFFFFFFFF70000077
    FFFFFFFFF0F0FFFFFFFFFFF770000077FFFFFFFF0FF0FFFFFFFFFFF770000007
    7FFFFFF0FFF0FFFFFFFFFFF7000000077FFFFF0FFFF0FFFFFFFF9F7700000000
    779FF0FFFFF0FFFFFFFFFF700000000077FF0FFFFFFFFFFFFFFFF77000000000
    077FFFFFFFFFFFFFFFFF7700000000007077FF9FFFFFFFFF9FF7707000000077
    070777FFFFFFFFFFF7770707700000F77000077FFFF9FFFF770000777000000F
    7000000777777777000000F70000000000000000000000000000000000000000
    00000000007770000000000000000000000000000F0707000000000000000000
    000000000F07070000000000000000000000000000000000000000000000FFE0
    0FFFFF8003FFFE0000FFFC00007FF800003FF000001FE000000FE000000FC000
    0007C00000078000000380000003800000038000000380000003800000038000
    000380000003C0000007C0000007E000000FE000000FF000001FC00000078000
    000382000083C3800387E7E00FCFFFF83FFFFFF01FFFFFF01FFFFFF83FFF}
  Menu = MainMenu
  OldCreateOrder = True
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    298
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
    Left = 92
    Top = 253
    Width = 112
    Height = 14
    Anchors = [akBottom]
    Caption = #169' P.Meisberger 2014'
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
  object lVersion: TLabel
    Left = 264
    Top = 8
    Width = 24
    Height = 14
    Anchors = [akTop, akRight]
    Caption = 'v 3.0'
    Color = clBtnFace
    ParentColor = False
  end
  object bAlert: TButton
    Left = 8
    Top = 214
    Width = 136
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Alarm !'
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
    Caption = 'Bei Alarm'
    TabOrder = 10
    object cbBlink: TCheckBox
      Left = 12
      Top = 18
      Width = 53
      Height = 19
      Caption = 'blinken'
      TabOrder = 0
      OnClick = cbBlinkClick
    end
    object cbText: TCheckBox
      Left = 12
      Top = 38
      Width = 87
      Height = 19
      Caption = 'Schrift zeigen'
      TabOrder = 2
      OnClick = cbTextClick
    end
    object bChange: TButton
      Left = 12
      Top = 64
      Width = 109
      Height = 33
      Caption = 'Beschriftug '#228'ndern'
      Enabled = False
      TabOrder = 3
      OnClick = bChangeClick
    end
    object bColor: TButton
      Left = 80
      Top = 18
      Width = 40
      Height = 18
      Caption = 'Farbe'
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
    Caption = 'Alarmauswahl'
    ItemIndex = 0
    Items.Strings = (
      'Wecker'
      'Horn'
      'Beep'
      'Bing'
      'Herunterfahren')
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
    Left = 152
    Top = 214
    Width = 137
    Height = 33
    Anchors = [akBottom]
    Caption = 'aus'
    Enabled = False
    TabOrder = 11
    TabStop = False
    OnClick = bStopClick
  end
  object bPlayClock: TButton
    Left = 120
    Top = 96
    Width = 17
    Height = 17
    Caption = '>'
    TabOrder = 6
    OnClick = bPlayClockClick
  end
  object bPlayBing: TButton
    Left = 120
    Top = 136
    Width = 17
    Height = 17
    Caption = '>'
    TabOrder = 8
    OnClick = bPlayBingClick
  end
  object bPlayBeep: TButton
    Left = 120
    Top = 156
    Width = 17
    Height = 17
    Caption = '>'
    TabOrder = 13
    OnClick = bPlayBeepClick
  end
  object bPlayHorn: TButton
    Left = 120
    Top = 116
    Width = 17
    Height = 17
    Caption = '>'
    TabOrder = 7
    OnClick = bPlayHornClick
  end
  object pText: TPanel
    Left = 8
    Top = 81
    Width = 281
    Height = 124
    Caption = 'TEXT'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -37
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 14
    Visible = False
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
      Caption = 'Datei'
      object mmSave: TMenuItem
        AutoCheck = True
        Caption = 'Einstellungen speichern'
        Checked = True
        OnClick = mmSaveClick
      end
    end
    object mmEdit: TMenuItem
      Caption = 'Bearbeiten'
      object mmOptions: TMenuItem
        Caption = 'Optionen'
        OnClick = mmOptionsClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mmTimer: TMenuItem
        Caption = 'Timer Modus'
        Checked = True
        RadioItem = True
        OnClick = mmTimerClick
      end
      object mmCounter: TMenuItem
        Caption = 'Counter Modus'
        RadioItem = True
        OnClick = mmCounterClick
      end
    end
    object mmView: TMenuItem
      Caption = 'Ansicht'
      object mmLang: TMenuItem
        Caption = 'Sprache w'#228'hlen'
      end
    end
    object mmHelp: TMenuItem
      Caption = 'Hilfe'
      object mmUpdate: TMenuItem
        Caption = 'nach Update suchen'
        OnClick = mmUpdateClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mmWebsite: TMenuItem
        Caption = 'Zur Website'
        OnClick = mmWebsiteClick
      end
      object mmDownloadCert: TMenuItem
        Caption = 'Zertifikat herunterladen'
        OnClick = mmDownloadCertClick
      end
      object mmReport: TMenuItem
        Caption = 'Fehler melden'
        OnClick = mmReportClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mmInfo: TMenuItem
        Caption = #220'ber'
        OnClick = mmInfoClick
      end
    end
  end
  object pmMenu: TPopupMenu
    Left = 16
    Top = 24
    object pmOpen: TMenuItem
      Caption = 'offnen'
      Default = True
      OnClick = pmOpenClick
    end
    object pmClose: TMenuItem
      Caption = 'Beenden'
      OnClick = pmCloseClick
    end
  end
end
