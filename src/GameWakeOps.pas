{ *********************************************************************** }
{                                                                         }
{ Game Wake Options Unit                                                  }
{                                                                         }
{ Copyright (c) 2011-2014 Philipp Meisberger (PM Code Works)              }
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
    Config := TConfigFile.Create('Global', FConfigPath);
            
    try
      cbSaveClock.Checked := Config.GetSaveValue('SaveClock');
      cbSaveText.Checked := Config.GetSaveValue('SaveText');
      cbSaveSound.Checked := Config.GetSaveValue('SaveSound');
      cbSaveColor.Checked := Config.GetSaveValue('SaveColor');
      cbSavePos.Checked := Config.GetSaveValue('SavePos');
      cbCombine.Checked := Config.GetSaveValue('Combine');
      cbUpdate.Checked := Config.GetSaveValue('AutoUpdate');

    finally
      Config.Free;
    end;  //of finally

  except
    FLang.MessageBox(Format(FLang.GetString(74), [FConfigPath]), mtError);
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
  Close;
end;

{ TOptions.bOkClick

  Stores current configuration to config file. }

procedure TOptions.bOkClick(Sender: TObject);
var
  Config: TConfigFile;

begin
  try
    Config := TConfigFile.Create('Global', FConfigPath);

    try
      Config.SetIniValue('SaveClock', cbSaveClock.Checked);
      Config.SetIniValue('SaveText', cbSaveText.Checked);
      Config.SetIniValue('SaveSound', cbSaveSound.Checked);
      Config.SetIniValue('SaveColor', cbSaveColor.Checked);
      Config.SetIniValue('SavePos', cbSavePos.Checked);
      Config.SetIniValue('Combine', cbCombine.Checked);
      Config.SetIniValue('AutoUpdate', cbUpdate.Checked);
      FClock.Alert.Combine := cbCombine.Checked;

    finally
      Config.Free;
    end;  //of finally

  except
    FLang.MessageBox(76, mtError);
  end;  //of try

  Close;
end;

end.