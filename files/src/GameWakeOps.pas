{ *********************************************************************** }
{                                                                         }
{ Game Wake Options Unit                                                  }
{                                                                         }
{ Copyright (c) 2011-2015 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeOps;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
  Forms, StdCtrls, GameWakeAPI, Classes, LanguageFile, Controls, SysUtils;

type
  { TOptions }
  TOptions = class(TForm)
    cbUpdate: TCheckBox;
    gbSave: TGroupBox;
    cbSaveClock: TCheckBox;
    cbSaveSound: TCheckBox;
    cbSaveColor: TCheckBox;
    cbSaveText: TCheckBox;
    bOk: TButton;
    bCancel: TButton;
    cbSavePos: TCheckBox;
    bReset: TButton;
    gbGeneral: TGroupBox;
    cbCombine: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure bResetClick(Sender: TObject);
  private
    FConfigPath: string;
    FLang: TLanguageFile;
    FClock: TClock;
    procedure LoadConfig();
    procedure SetLanguage();
  public
    constructor Create(AOwner: TComponent; AClock: TClock; ALang: TLanguageFile;
      AConfigPath: string = '');
  end;

implementation

{$IFDEF MSWINDOWS}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

{ TOptions }

{ public TOptions.Create

  Constructor for creating a TOptions instance. }

constructor TOptions.Create(AOwner: TComponent; AClock: TClock;
  ALang: TLanguageFile; AConfigPath: string = '');
begin
  inherited Create(AOwner);
  FClock := AClock;
  FLang := ALang;
  FConfigPath := AConfigPath;
end;

{ private TOptions.LoadConfig

  Loads user specific configuration from file. }

procedure TOptions.LoadConfig();
var
  Config: TConfigFile;

begin
  try
    Config := TConfigFile.Create(FConfigPath);
            
    try
      cbSaveClock.Checked := Config.ReadBoolean('Global', 'SaveClock');
      cbSaveText.Checked := Config.ReadBoolean('Global', 'SaveText');
      cbSaveSound.Checked := Config.ReadBoolean('Global', 'SaveSound');
      cbSaveColor.Checked := Config.ReadBoolean('Global', 'SaveColor');
      cbSavePos.Checked := Config.ReadBoolean('Global', 'SavePos');
      cbCombine.Checked := Config.ReadBoolean('Global', 'Combine');
      cbUpdate.Checked := Config.ReadBoolean('Global', 'AutoUpdate');

    finally
      Config.Free;
    end;  //of finally

  except
    FLang.MessageBox(FLang.Format(74, [FConfigPath]), mtError);
  end;  //of try
end;

{ private TOptions.SetLanguage

  Updates all component captions with new language text. }

procedure TOptions.SetLanguage();
begin
  with FLang do
  begin
    Caption := GetString(34);
    gbSave.Caption := GetString(51);
    cbSaveClock.Caption := GetString(52);
    cbSaveText.Caption := GetString(53);
    cbSavePos.Caption := GetString(54);
    cbSaveSound.Caption := GetString(55);
    cbSaveColor.Caption := GetString(56);
    gbGeneral.Caption := GetString(57);
    cbCombine.Caption := GetString(58);
    cbUpdate.Caption := GetString(59);
    bReset.Caption := GetString(61);
    bCancel.Caption := GetString(6);
  end;  //of with
end;

{ TOptions.FormCreate

  VCL event that is called when form is being created. }

procedure TOptions.FormShow(Sender: TObject);
begin
  LoadConfig();
  SetLanguage();
end;

{ TOptions.bResetClick

  Resets configuration settings to default. }

procedure TOptions.bResetClick(Sender: TObject);
begin
  cbSaveClock.Checked := True;
  cbSaveText.Checked := True;
  cbSaveSound.Checked := True;
  cbSaveColor.Checked := True;
  cbSavePos.Checked := False;
  cbCombine.Checked := False;
  cbUpdate.Checked := True;
end;

{ TOptions.bCancelClick

  Cancels configuration saving. }

procedure TOptions.bCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{ TOptions.bOkClick

  Stores current configuration to config file. }

procedure TOptions.bOkClick(Sender: TObject);
var
  Config: TConfigFile;

begin
  try
    Config := TConfigFile.Create(FConfigPath);

    try
      Config.WriteBoolean('Global', 'SaveClock', cbSaveClock.Checked);
      Config.WriteBoolean('Global', 'SaveText', cbSaveText.Checked);
      Config.WriteBoolean('Global', 'SaveSound', cbSaveSound.Checked);
      Config.WriteBoolean('Global', 'SaveColor', cbSaveColor.Checked);
      Config.WriteBoolean('Global', 'SavePos', cbSavePos.Checked);
      Config.WriteBoolean('Global', 'Combine', cbCombine.Checked);
      Config.WriteBoolean('Global', 'AutoUpdate', cbUpdate.Checked);
      FClock.Alert.Combine := cbCombine.Checked;

      // Save changes to config file
      Config.Save();

    finally
      Config.Free;
    end;  //of finally

    ModalResult := mrOk;

  except
    FLang.MessageBox(FLang.Format(76, [FConfigPath]), mtError);
    ModalResult := mrAbort;
  end;  //of try
end;

end.