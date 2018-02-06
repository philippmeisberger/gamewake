object Options: TOptions
  Left = 230
  Top = 188
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 210
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    426
    210)
  PixelsPerInch = 96
  TextHeight = 14
  object gbSave: TGroupBox
    Left = 16
    Top = 8
    Width = 396
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Storage settings'
    TabOrder = 3
    DesignSize = (
      396
      97)
    object cbSaveClock: TCheckBox
      Left = 16
      Top = 20
      Width = 110
      Height = 22
      Caption = 'Save time'
      TabOrder = 0
    end
    object cbSaveSound: TCheckBox
      Left = 208
      Top = 20
      Width = 179
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Save sound selection'
      TabOrder = 1
      ExplicitWidth = 177
    end
    object cbSaveColor: TCheckBox
      Left = 208
      Top = 44
      Width = 179
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Save color'
      TabOrder = 3
      ExplicitWidth = 177
    end
    object cbSaveText: TCheckBox
      Left = 16
      Top = 44
      Width = 96
      Height = 22
      Caption = 'Save text'
      TabOrder = 2
    end
    object cbSavePos: TCheckBox
      Left = 16
      Top = 68
      Width = 113
      Height = 22
      Caption = 'Save position'
      TabOrder = 4
    end
  end
  object bOk: TButton
    Left = 337
    Top = 176
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = bOkClick
    ExplicitTop = 191
  end
  object bCancel: TButton
    Left = 249
    Top = 176
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'cancel'
    TabOrder = 1
    OnClick = bCancelClick
    ExplicitTop = 191
  end
  object bReset: TButton
    Left = 16
    Top = 176
    Width = 97
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Default'
    TabOrder = 2
    OnClick = bResetClick
    ExplicitTop = 191
  end
  object gbGeneral: TGroupBox
    Left = 16
    Top = 113
    Width = 396
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = 'General'
    TabOrder = 4
    object cbUpdate: TCheckBox
      Left = 16
      Top = 24
      Width = 187
      Height = 22
      Caption = 'Automatically check for update'
      TabOrder = 0
    end
  end
end
