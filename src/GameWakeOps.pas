{ *********************************************************************** }
{                                                                         }
{ Game Wake Options Unit                                                  }
{                                                                         }
{ Copyright (c) 2011-2018 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeOps;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  Forms, StdCtrls, Classes, Controls, SysUtils, PMCW.LanguageFile, GameWakeAPI,
  PMCW.Dialogs;

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
      const AConfigPath: string = ''); reintroduce;
  end;

implementation

{$I LanguageIDs.inc}
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TOptions }

{ public TOptions.Create

  Constructor for creating a TOptions instance. }

constructor TOptions.Create(AOwner: TComponent; AClock: TClock;
  ALang: TLanguageFile; const AConfigPath: string = '');
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
      cbSaveClock.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSaveClock, True);
      cbSaveText.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSaveText, True);
      cbSaveSound.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSaveSound, True);
      cbSaveColor.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSaveColor, True);
      cbSavePos.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSavePos, False);
    {$IFDEF MSWINDOWS}
      cbUpdate.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdAutoUpdate, True);
    {$ELSE}
      cbUpdate.Enabled := False;
    {$ENDIF}

    finally
      Config.Free;
    end;  //of finally

  except
    on E: Exception do
      ExceptionDlg(FLang, FLang.Format(LID_STORING_FAILED, [FConfigPath]), E.Message);
  end;  //of try
end;

{ private TOptions.SetLanguage

  Updates all component captions with new language text. }

procedure TOptions.SetLanguage();
begin
  with FLang do
  begin
    Caption := GetString(LID_SETTINGS);
    gbSave.Caption := GetString(LID_SETTINGS_STORAGE);
    cbSaveClock.Caption := GetString(LID_STORE_TIME);
    cbSaveText.Caption := GetString(LID_STORE_TEXT);
    cbSavePos.Caption := GetString(LID_STORE_POSITION);
    cbSaveSound.Caption := GetString(LID_STORE_SOUND);
    cbSaveColor.Caption := GetString(LID_STORE_COLOR);
    gbGeneral.Caption := GetString(LID_GENERAL);
    cbUpdate.Caption := GetString(LID_AUTO_UPDATE);
    bReset.Caption := GetString(LID_DEFAULT_VALUES);
    bCancel.Caption := GetString(LID_CANCEL);
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
{$IFDEF MSWINDOWS}
  cbUpdate.Checked := True;
{$ENDIF}
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
      Config.WriteBool(Config.SectionGlobal, Config.IdSaveClock, cbSaveClock.Checked);
      Config.WriteBool(Config.SectionGlobal, Config.IdSaveText, cbSaveText.Checked);
      Config.WriteBool(Config.SectionGlobal, Config.IdSaveSound, cbSaveSound.Checked);
      Config.WriteBool(Config.SectionGlobal, Config.IdSaveColor, cbSaveColor.Checked);
      Config.WriteBool(Config.SectionGlobal, Config.IdSavePos, cbSavePos.Checked);
    {$IFDEF MSWINDOWS}
      Config.WriteBool(Config.SectionGlobal, Config.IdAutoUpdate, cbUpdate.Checked);
    {$ENDIF}

    finally
      Config.Free;
    end;  //of finally

    ModalResult := mrOk;

  except
    on E: Exception do
    begin
      ExceptionDlg(FLang, FLang.Format(LID_STORING_CONFIG_FAILED, [FConfigPath]), E.Message);
      ModalResult := mrAbort;
    end;  //of begin
  end;  //of try
end;

end.
