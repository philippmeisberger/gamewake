object Info: TInfo
  Left = 248
  Height = 257
  Top = 197
  Width = 464
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Über '
  ClientHeight = 257
  ClientWidth = 464
  Color = clBtnFace
  Font.CharSet = 4
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  OnCreate = FormCreate
  Position = poScreenCenter
  LCLVersion = '1.2.4.0'
  object PageControl: TPageControl
    Left = 0
    Height = 259
    Top = -2
    Width = 468
    ActivePage = tsDescription
    Anchors = [akTop, akLeft, akRight, akBottom]
    MultiLine = True
    TabIndex = 0
    TabOrder = 0
    Options = [nboMultiLine]
    object tsDescription: TTabSheet
      Caption = 'Infos'
      ClientHeight = 229
      ClientWidth = 462
      object Image: TImage
        Left = 16
        Height = 48
        Top = 16
        Width = 48
      end
      object lVersion: TLabel
        Left = 29
        Height = 12
        Top = 68
        Width = 21
        Caption = 'v1.0'
        ParentColor = False
      end
      object lBuild: TLabel
        Left = 14
        Height = 12
        Top = 83
        Width = 37
        Caption = '(Build: )'
        ParentColor = False
      end
      object bOk: TButton
        Left = 368
        Height = 25
        Top = 200
        Width = 75
        Anchors = [akBottom]
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object mCopying: TMemo
        Left = 82
        Height = 180
        Top = 16
        Width = 361
        Anchors = [akTop, akLeft, akRight, akBottom]
        Lines.Strings = (
          'Copyright (C) 2011 Philipp Meisberger <team@pm-codeworks.de> '
          ''
          'This Program may be used by anyone in accordance with the terms of the German Free Software License.'
          ''
          'The License may be obtained under <http://www.d-fsl.org>.'
        )
        ReadOnly = True
        TabOrder = 1
      end
    end
    object tsChangelog: TTabSheet
      Caption = 'Changelog'
      ClientHeight = 229
      ClientWidth = 462
      ImageIndex = 1
      object bOk2: TButton
        Left = 368
        Height = 25
        Top = 200
        Width = 75
        Anchors = [akBottom]
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 0
      end
      object mChangelog: TMemo
        Left = 15
        Height = 180
        Top = 16
        Width = 428
        Anchors = [akTop, akLeft, akRight, akBottom]
        Lines.Strings = (
          'Changelog'
        )
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
end