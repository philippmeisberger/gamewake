{ *********************************************************************** }
{                                                                         }
{ Game Wake Main Unit                                                     }
{                                                                         }
{ Copyright (c) 2011-2014 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeMain;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Menus,
  Dialogs, GameWakeAPI, LanguageFile, AlertThread, Updater, OSUtils,

{$IFDEF MSWINDOWS}
  Windows, Messages, XPMan, TrayIconAPI;
{$ELSE}
  LCLType;
{$ENDIF}

const
  LANG_GERMAN = '&Deutsch';
  LANG_ENGLISH = '&English';
  LANG_FRENCH = '&Francais';

type
  { TMain }
  TMain = class(TForm, IChangeLanguageListener, IUpdateListener)
    eHour: TEdit;
    eMin: TEdit;
    bAlert: TButton;
    bStop: TButton;
    lDp: TLabel;
    mmDownloadCert: TMenuItem;
    pmClose: TMenuItem;
    pmOpen: TMenuItem;
    mmWebsite: TMenuItem;
    mmCounter: TMenuItem;
    mmTimer: TMenuItem;
    mmUpdate: TMenuItem;
    N2: TMenuItem;
    pmMenu: TPopupMenu;
    rgSounds: TRadioGroup;
    lHour: TLabel;
    lCopy: TLabel;
    bPlayClock: TButton;
    bPlayBing: TButton;
    bPlayBeep: TButton;
    lVersion: TLabel;
    gpOther: TGroupBox;
    cbBlink: TCheckBox;
    cbText: TCheckBox;
    bChange: TButton;
    MainMenu: TMainMenu;
    mmFile: TMenuItem;
    mmSave: TMenuItem;
    mmHelp: TMenuItem;
    mmInfo: TMenuItem;
    bColor: TButton;
    mmEdit: TMenuItem;
    mmOptions: TMenuItem;
    bPlayHorn: TButton;
    pText: TPanel;
    N3: TMenuItem;
    bIncHour: TButton;
    bDecHour: TButton;
    bDecMin: TButton;
    bIncMin: TButton;
    N4: TMenuItem;
    mmView: TMenuItem;
    mmLang: TMenuItem;
    mmReport: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mmDownloadCertClick(Sender: TObject);
    procedure pmCloseClick(Sender: TObject);
    procedure pmOpenClick(Sender: TObject);
    procedure mmUpdateClick(Sender: TObject);
    procedure mmWebsiteClick(Sender: TObject);
    procedure bIncHourClick(Sender: TObject);
    procedure bDecHourClick(Sender: TObject);
    procedure bIncMinClick(Sender: TObject);
    procedure bDecMinClick(Sender: TObject);
    procedure bPlayClockClick(Sender: TObject);
    procedure bPlayHornClick(Sender: TObject);
    procedure bPlayBingClick(Sender: TObject);
    procedure bPlayBeepClick(Sender: TObject);
    procedure eHourKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eMinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eHourKeyPress(Sender: TObject; var Key: Char);
    procedure bAlertClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure bColorClick(Sender: TObject);
    procedure bChangeClick(Sender: TObject);
    procedure cbBlinkClick(Sender: TObject);
    procedure cbTextClick(Sender: TObject);
    procedure mmSaveClick(Sender: TObject);
    procedure mmOptionsClick(Sender: TObject);
    procedure mmTimerClick(Sender: TObject);
    procedure mmCounterClick(Sender: TObject);
    procedure mmLangClick(Sender: TObject);
    procedure mmReportClick(Sender: TObject);
    procedure mmInfoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lCopyClick(Sender: TObject);
    procedure lCopyMouseEnter(Sender: TObject);
    procedure lCopyMouseLeave(Sender: TObject);
  private
    Clock: TClock;
    FLang: TLanguageFile;
    FTrayIcon: TTrayIcon;
    FColor: TColor;
    FConfigPath, FLangPath, FPath: string;
    FUpdateCheck: TUpdateCheck;
    procedure AfterUpdate(Sender: TObject; ADownloadedFileName: string);
    procedure Alert(Sender: TObject);
    procedure BeforeUpdate(Sender: TObject; const ANewBuild: Cardinal);
    procedure Blink(Sender: TThread);
    procedure BlinkEnd(Sender: TThread);
    procedure Count(Sender: TObject; ATime: string);
  {$IFDEF MSWINDOWS}
    function GetLangId(ALang: string): Word;
  {$ENDIF}
    procedure LoadColor();
    procedure LoadFromIni();
    procedure LoadLanguageFile(var APrefLang: string);
  {$IFDEF MSWINDOWS}
    procedure PowerBroadcast(var AMsg: TMessage); message WM_POWERBROADCAST;
  {$ENDIF}
    procedure SaveToIni();
    procedure SetLanguage(Sender: TObject);
  {$IFDEF MSWINDOWS}
    procedure TrayIconMouseUp(Sender: TObject; AButton: TMouseButton; X, Y: Integer);
  {$ELSE}
    procedure TrayMouseUp(Sender: TObject; AButton: TMouseButton;
      AShiftState: TShiftState; X, Y: Integer);
  {$ENDIF}
  end;

var
  Main: TMain;

implementation

{$IFDEF MSWINDOWS}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

uses GameWakeInfo, GameWakeOps;

{ TMain }

{ TMain.FormCreate

  VCL event that is called when form is being created. }

procedure TMain.FormCreate(Sender: TObject);
var
  Config: TConfigFile;
  Combine, AutoUpdate: Boolean;
  Language: string;

begin
{$IFNDEF MSWINDOWS}
  // Load other configuration?
  if ((ParamStr(1) = '--config') and (ParamStr(2) <> '')) then
    FConfigPath := ParamStr(2)
  else
    if ((ParamStr(3) = '--config') and (ParamStr(4) <> '')) then
      FConfigPath := ParamStr(4)
    else
      FConfigPath := '/etc/gamewake/gamewake.conf';

  // Load other language file?
  if ((ParamStr(1) = '--lang') and (ParamStr(2) <> '')) then
    FLangPath := ParamStr(2)
  else
    if ((ParamStr(3) = '--lang') and (ParamStr(4) <> '')) then
      FLangPath := ParamStr(4)
    else
      FLangPath := '/etc/gamewake/lang';

  FPath := '/usr/lib/gamewake/';
{$ELSE}
  FConfigPath := ExtractFilePath(ParamStr(0)) + 'gamewake.ini';
  FLangPath := '';
  FPath := '';
{$ENDIF}

  // Init config file access
  Config := TConfigFile.Create(FConfigPath);

  try
    // Check if anything shall be loaded from config
    if Config.ReadBoolean('Global', 'Save') then
    begin
      LoadFromIni();
      mmOptions.Enabled := True;
    end  //of begin
    // Do not load anything instead of language
    else
    begin
      mmSave.Checked := False;
      mmOptions.Enabled := False;
      LoadLanguageFile(Language);
    end;  //of if

    // Load last position?
    if not Config.ReadBoolean('Global', 'SavePos') then
      Position := poScreenCenter;

    // Check for Updates?
    if Config.KeyExists('Global', 'AutoUpdate') then
      AutoUpdate := Config.ReadBoolean('Global', 'AutoUpdate')
    else
      AutoUpdate := True;

    // Load hours minutes combining
    Combine := Config.ReadBoolean('Global', 'Combine');

  finally
    Config.Free;
  end;  //of finally

  // Load last blink color
  LoadColor();

  // Init update notificator
  FUpdateCheck := TUpdateCheck.Create(Self, 'GameWake', FLang);

  // Search for updates on startup?
  if AutoUpdate then
    FUpdateCheck.CheckForUpdate(False);

  {$IFDEF MSWINDOWS}
    mmWebsite.Visible := False;
  {$ELSE}
    mmDownloadCert.Visible := False;
  {$ENDIF}

  // Init Clock
  Clock := TClock.Create(Self, mmTimer.Checked, Combine);

  with Clock do
  begin
    Alert.SetTime(StrToInt(eHour.Text), StrToInt(eMin.Text));
    OnAlertStart := Self.Alert;
    OnAlert := Blink;
    OnAlertEnd := BlinkEnd;
    OnCount := Self.Count;
  end;  //of with
end;

{ TMain.FormDestroy

  VCL event that is called when form has been closed. }

procedure TMain.FormDestroy(Sender: TObject);
begin
  // Save configuration
  SaveToIni();

  FLang.Free;
  Clock.Free;
  FUpdateCheck.Free;

{$IFNDEF MSWINDOWS}
  // Delete icon from tray
  if Assigned(FTrayIcon) then
    FTrayIcon.Free;
{$ENDIF}
end;

{ private TMain.AfterUpdate

  Event method that is called by TUpdate when download is finished. }

procedure TMain.AfterUpdate(Sender: TObject; ADownloadedFileName: string);
begin
{$IFDEF MSWINDOWS}
  if (ExtractFileExt(ADownloadedFileName) <> '.reg') then
  begin
    // Install update?
    if (FLang.MessageBox(11, mtQuestion, True) = ID_YES) then
    begin
      TOSUtils.ExecuteFile(ADownloadedFileName);
      Close;
      Abort;
    end;  //of if

    // Caption "Search for update"
    mmUpdate.Caption := FLang.GetString(15);
    mmUpdate.Enabled := False;
  end  //of begin
  else
    mmDownloadCert.Enabled := False;
{$ENDIF}
end;

{ private TMain.Alert

  Event that is called when alert was started. }

procedure TMain.Alert(Sender: TObject);
begin
  Application.Restore;
  Show;

  bStop.Caption := FLang.GetString(50);
  bAlert.Default := False;
  bStop.Default := True;
  rgSounds.Enabled := False;

  // Disable components in "at alert" TGroupBox
  bPlayBeep.Enabled := False;
  bPlayBing.Enabled := False;
  bPlayClock.Enabled := False;
  bPlayHorn.Enabled := False;
  bChange.Enabled := False;
  bColor.Enabled := False;
  cbBlink.Enabled := False;
  cbText.Enabled := False;

  // Get alert type
  Clock.AlertType := TAlertType(rgSounds.ItemIndex);

  // Check for shutdown
  if (Clock.AlertType = atShutdown) then
  begin
    if TOSUtils.Shutdown() then
    begin
      bAlert.Enabled := True;
      Close;
    end;  //of begin
  end  //of begin
  else
  begin
    if cbText.Checked then
    begin
      pText.Visible := True;
      pText.BringToFront;
    end;   //of begin

    cbText.Enabled := False;
    pmOpen.Click;
  end;  //of if
end;

{ private TMain.BeforeUpdate

  Event that is called by TUpdateCheck when TUpdateCheckThread finds an update. }

procedure TMain.BeforeUpdate(Sender: TObject; const ANewBuild: Cardinal);
{$IFDEF MSWINDOWS}
var
  Updater: TUpdate;

begin
  // Show dialog: Ask for permitting download
  if (FLang.MessageBox([21, NEW_LINE, 22], [ANewBuild], mtQuestion, True) = IDYES) then
  begin
    // init TUpdate instance
    Updater := TUpdate.Create(Self, FLang);

    try
      with Updater do
      begin
        Title := FLang.GetString(24);
        Download('game_wake_setup.exe', 'Game Wake Setup.exe')
      end;  //of begin

    finally
      Updater.Free;
    end;  //of try
  end  //of begin
  else
    mmUpdate.Caption := FLang.GetString(24);
{$ELSE}
begin
  with FLang do
    MessageBox([21, NEW_LINE, 22], [ANewBuild], mtInfo, True);
{$ENDIF}
end;

{ private TMain.Blink

  Event that is called by TAlertThread while alert is in progress. }

procedure TMain.Blink(Sender: TThread);
begin
  if (cbBlink.Checked and (Color = clBtnFace)) then
    Color := FColor
  else
    Color := clBtnFace;
end;

{ private TMain.BlinkEnd

  Event that is called by TAlertThread when alert was stopped. }

procedure TMain.BlinkEnd(Sender: TThread);
begin
  Color := clBtnFace;
end;

{ private TMain.Count

  Event that is called by TClock when current time is incremented. }

procedure TMain.Count(Sender: TObject; ATime: string);
begin
  lHour.Caption := ATime;
end;

{$IFDEF MSWINDOWS}

{ private TMain.GetLangId

  Returns the offset index of a language. }

function TMain.GetLangId(ALang: string): Word;
begin
  if (ALang = LANG_ENGLISH) then
    result := 200
  else
    if (ALang = LANG_FRENCH) then
      result := 300
    else
      result := 100;
end;
{$ENDIF}

{ private TMain.LoadColor

  Loads current blink color from config file and sets it. }

procedure TMain.LoadColor();
var
  Config: TConfigFile;
  BlinkColor: string;

begin
  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Color "red" for default
      FColor := clRed;

      if Config.ReadBoolean('Global', 'SaveColor') then
      begin
        // Load color from config file
        BlinkColor := Config.ReadString('Alert', 'Color');

        if (BlinkColor <> '') then
          FColor := StringToColor(BlinkColor);
      end;  //of begin

    finally
      Config.Free;
    end;  //of try

  except
    FLang.MessageBox(73, mtError);
  end;  //of try
end;

{ private TMain.LoadFromIni

  Loads user specific configuration from file. }

procedure TMain.LoadFromIni();
var
  Config: TConfigFile;
  Language: string;
  LangID, AlertType: Integer;

begin
  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Compability to old version
      LangID := Config.ReadInteger('Global', 'LangID');

      if (LangID <> -1) then
      begin
        case LangID of
          200: Language := LANG_ENGLISH;
          300: Language := LANG_FRENCH;
          else
               Language := LANG_GERMAN;
        end;  //of case

      {$IFNDEF MSWINDOWS}
        Config.Remove('Global', 'LangID');
      {$ENDIF}
      end  //of begin
      else
        // Load language from config
        Language := Config.ReadString('Global', 'Lang');

      // Load language file
      LoadLanguageFile(Language);

      // Load last mode
      mmTimer.Checked := Config.ReadBoolean('Global', 'TimerMode');
      mmCounter.Checked := not mmTimer.Checked;

      // Load last time?
      if Config.ReadBoolean('Global', 'SaveClock') then
      begin
        eHour.Text := Config.ReadString('Alert', 'Hour');
        eMin.Text := Config.ReadString('Alert', 'Min');
      end  //of if
      else
        // Counter can run at least 1 minute
        if mmCounter.Checked then
          eMin.Text := '01';

      // Load last sound?
      if Config.ReadBoolean('Global', 'SaveSound') then
      begin
        AlertType := Config.ReadInteger('Alert', 'Sound');

        if (AlertType in [0..4]) then
          rgSounds.ItemIndex := AlertType
        else
          rgSounds.ItemIndex := 0;
      end;  //of if

      // Load last set alert text?
      if Config.ReadBoolean('Global', 'SaveText') then
        pText.Caption := Config.ReadString('Alert', 'Text');

      // Load last position?
      if Config.ReadBoolean('Global', 'SavePos') then
      begin
        Left := Config.ReadInteger('Global', 'Left');
        Top := Config.ReadInteger('Global', 'Top');
      end  //of begin
      else
        Position := poScreenCenter;

      // Load last "show text" state?
      if Config.ReadBoolean('Alert', 'ShowText') then
      begin
        cbText.Checked := True;
        bChange.Enabled := True;
      end;  //of begin

      // Load last blink state
      cbBlink.Checked := Config.ReadBoolean('Alert', 'Blink');

      // Missing "AutoUpdate"?
      if not Config.KeyExists('Global', 'AutoUpdate') then
      begin
        Config.WriteBoolean('Global', 'AutoUpdate', True);
        Config.Save();
      end;  //of begin

    finally
      Config.Free;
    end;  //of try

  except
    FLang.MessageBox(FLang.Format(75, [FConfigPath]), mtError);
  end;  //of try
end;

{ private TMain.LoadLanguageFile

  Loads language file and returns current used language. }

procedure TMain.LoadLanguageFile(var APrefLang: string);
var
  Langs: TStringList;
  i: Word;
  Item: TMenuItem;
  LangInList: Boolean;
{$IFDEF MSWINDOWS}
  LangID: Word;
{$ENDIF}

begin
  // "German" for default
  if (APrefLang = '') then
    APrefLang := LANG_GERMAN;

  LangInList := False;
  Langs := TStringList.Create();

  try
  {$IFDEF MSWINDOWS}
    Langs.Append(LANG_GERMAN);
    Langs.Append(LANG_ENGLISH);
    Langs.Append(LANG_FRENCH);

    LangID := GetLangId(APrefLang);
    FLang := TLanguageFile.Create(LangID, Application);
  {$ELSE}
    // Open language file
    FLang := TLanguageFile.Create('', FLangPath);

    // Load all available languages
    FLang.GetLanguages(Langs);
  {$ENDIF}

    FLang.AddListener(Self);

    try
      // Add a menu entry for every found language
      for i := 0 to Langs.Count -1 do
      begin
        Item := TMenuItem.Create(Self);
        Item.Caption := Langs[i];
        Item.RadioItem := True;
        Item.AutoCheck := True;

        // Select current used language menu entry
        if (Langs[i] = APrefLang) then
        begin
        {$IFDEF MSWINDOWS}
          FLang.Lang := LangID;
        {$ELSE}
          FLang.Lang := APrefLang;
        {$ENDIF}
          LangInList := True;
          Item.Checked := True;
          Item.AutoCheck := True;
        end;  //of begin

        Item.OnClick := mmLangClick;
        mmLang.Add(Item);
      end;  //of for

      // Set loaded language as global
      SetLanguage(Self);

    finally
      Langs.Free;

      if not LangInList then
      begin
        FLang.MessageBox('Language file does not contain language "'+ APrefLang
                     +'"! Default language has been loaded!', mtWarning);
      {$IFDEF MSWINDOWS}
        FLang.Lang := 100;
      {$ELSE}
        FLang.Lang := LANG_GERMAN;
      {$ENDIF}
      end;  //of begin
    end;  //of try

  except
    Application.MessageBox(PChar('Language file could not be found!'), PChar('Error'), MB_ICONERROR);
  end;  //of try
end;

{$IFDEF MSWINDOWS}

{ private TMain.PowerBroadcast

  Event that is called after wakeup (after suspending). }

procedure TMain.PowerBroadcast(var AMsg: TMessage);
const
  PBT_APMRESUMESUSPEND = $0007;

begin
  if (AMsg.WParam = PBT_APMRESUMESUSPEND) then
    Clock.Time.SetSystemTime();
end;
{$ENDIF}

{ private TMain.SaveToIni

  Stores current configuration to config file. }

procedure TMain.SaveToIni();
var
  Config: TConfigFile;

begin
  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Save anything?
      if mmSave.Checked then
      begin
      {$IFDEF MSWINDOWS}
        Config.WriteInteger('Global', 'LangID', FLang.Lang);
      {$ELSE}
        Config.WriteString('Global', 'Lang', FLang.Lang);
      {$ENDIF}
        Config.WriteBoolean('Global', 'Save', True);
        Config.WriteBoolean('Global', 'TimerMode', mmTimer.Checked);

        // Save position?
        if Config.ReadBoolean('Global', 'SavePos') then
        begin
          Config.WriteInteger('Global', 'Left', Left);
          Config.WriteInteger('Global', 'Top', Top);
        end;  //of begin

        // Save time input?
        if Config.ReadBoolean('Global', 'SaveClock') then
        begin
          if (eHour.Text <> '') then
            Config.WriteString('Alert', 'Hour', eHour.Text);

          if (eMin.Text <> '') then
            Config.WriteString('Alert', 'Min', eMin.Text);
        end;  //of if

        // Save current text input
        if Config.ReadBoolean('Global', 'SaveText') then
          Config.WriteString('Alert', 'Text', pText.Caption);

        // Save current selected sound?
        if Config.ReadBoolean('Global', 'SaveSound') then
          Config.WriteInteger('Alert', 'Sound', rgSounds.ItemIndex);

        // Save current selected color
        if Config.ReadBoolean('Global', 'SaveColor') then
          Config.WriteColor('Alert', 'Color', FColor);

        // Save current checks
        Config.WriteBoolean('Alert', 'Blink', cbBlink.Checked);
        Config.WriteBoolean('Alert', 'ShowText', cbText.Checked);
      end  //of begin
      else
        // Do not save anything
        Config.WriteBoolean('Global', 'Save', False);

      // Save changes to config file
      Config.Save();

    finally
      Config.Free;
    end;  //of try

  except
    FLang.MessageBox(FLang.Format(76, [FConfigPath]), mtError);
  end;  //of try
end;

{ private TMain.SetLanguage

  Updates all component captions with new language text. }

procedure TMain.SetLanguage(Sender: TObject);
var
  i: Byte;

begin
  with FLang do
  begin
    // Set captions for TMenuItems
    mmFile.Caption := GetString(31);
    mmSave.Caption := GetString(32);
    mmEdit.Caption := GetString(33);
    mmOptions.Caption := GetString(34);
    mmTimer.Caption := GetString(35);
    mmCounter.Caption := GetString(36);
    mmView.Caption := GetString(20);
    mmLang.Caption := GetString(25);
    mmHelp.Caption := GetString(14);
    mmUpdate.Caption:= GetString(15);
    mmDownloadCert.Caption := GetString(16);
    mmReport.Caption := GetString(26);
    mmWebsite.Caption := GetString(29);
    lCopy.Hint := mmWebsite.Caption;
    mmInfo.Caption := GetString(17);

    // Set captions for "alert type" TRadioGroup
    rgSounds.Caption := GetString(37);

    for i := 0 to 4 do
      rgSounds.Items[i] := GetString(i + 38);

    // Set captions for "at alert" TGroupBox
    gpOther.Caption := GetString(43);
    cbBlink.Caption := GetString(44);
    bColor.Caption := GetString(45);
    cbText.Caption := GetString(46);
    bChange.Caption := GetString(47);

    // Set captions for buttons
    bAlert.Caption := GetString(48);
    bStop.Caption := GetString(49);

    // Set captions for TPopupMenu items
    pmOpen.Caption := GetString(77);
    pmClose.Caption := GetString(78);
  end;  //of with
end;

{$IFDEF MSWINDOWS}

{ private TMain.TrayIconMouseUp

  Event that is called when detecting mouse activity. }

procedure TMain.TrayIconMouseUp(Sender: TObject; AButton: TMouseButton;
  X, Y: Integer);
var
  Hour, Min, Sec: string;

begin
  case AButton of
    // Show Balloon hint on left click
    mbLeft:
      if mmTimer.Checked then
        FTrayIcon.BalloonTip(Format(FLang.GetString(63), [Clock.Alert.GetTime(False)]))
      else
      begin
        Clock.GetTimeRemaining(Hour, Min, Sec);
        FTrayIcon.BalloonTip(Format(FLang.GetString(72), [Hour, Min, Sec]));
      end;  //of if

    // Show PopupMenu on right click
    mbRight:
      pmMenu.Popup(X, Y);
  end;  //of case
end;

{$ELSE}

{ private TMain.TrayMouseUp

  Event that is called when detecting mouse activity. }

procedure TMain.TrayMouseUp(Sender: TObject; AButton: TMouseButton;
  AShiftState: TShiftState; X, Y: Integer);
var
  Hour, Min, Sec: string;

begin
  case AButton of
    // Show Balloon hint on left click
    mbLeft:
      begin
        if mmTimer.Checked then
          FTrayIcon.BalloonHint := Format(FLang.GetString(63), [Clock.Alert.GetTime(False)])
        else
        begin
          Clock.GetTimeRemaining(Hour, Min, Sec);
          FTrayIcon.BalloonHint := Format(FLang.GetString(72), [Hour, Min, Sec]);
        end;  //of if

        FTrayIcon.ShowBalloonHint;
      end;  //of begin

    // Show PopupMenu on right click
    mbRight:
      FTrayIcon.PopUpMenu.Popup(X, Y);
  end;  //of case
end;
{$ENDIF}

{ TMain.pmCloseClick

  PopMenu entry that terminates Game Wake. }

procedure TMain.pmCloseClick(Sender: TObject);
begin
  // Show confirmation
  with FLang do
    if (MessageBox([69, NEW_LINE, 70], mtQuestion) = IDYes) then
    begin
      bStop.Click;
      Close;
    end;  //of begin
end;

{ TMain.pmOpenClick

  PopMenu entry that opens Game Wake. }

procedure TMain.pmOpenClick(Sender: TObject);
begin
  Show;
  BringToFront;

  if Assigned(FTrayIcon) then
  {$IFDEF MSWINDOWS}
    FTrayIcon.Free;
  {$ELSE}
    FTrayIcon.Hide;
  {$ENDIF}
end;

{ TMain.bIncHourClick

  Increments hours by 1. }

procedure TMain.bIncHourClick(Sender: TObject);
begin
  eHour.Text := Clock.Alert.IncrementHours();

  if Clock.Alert.Combine then
    eMin.Text := Clock.Alert.GetMin();
end;

{ TMain.bDecHourClick

  Decrements hours by 1. }

procedure TMain.bDecHourClick(Sender: TObject);
begin
  eHour.Text := Clock.Alert.DecrementHours();

  if Clock.Alert.Combine then
    eMin.Text := Clock.Alert.GetMin();
end;

{ TMain.bIncMinClick

  Increments minutes by 1. }

procedure TMain.bIncMinClick(Sender: TObject);
begin
  eMin.Text := Clock.Alert.IncrementMinutes();

  if Clock.Alert.Combine then
    eHour.Text := Clock.Alert.GetHour();
end;

{ TMain.bDecMinClick

  Decrements minutes by 1. }

procedure TMain.bDecMinClick(Sender: TObject);
begin
  eMin.Text := Clock.Alert.DecrementMinutes();

  if Clock.Alert.Combine then
    eHour.Text := Clock.Alert.GetHour();
end;

{ TMain.bPlayClockClick

  Plays a the bell sound as preview. }

procedure TMain.bPlayClockClick(Sender: TObject);
begin
  TOSUtils.PlaySound(FPath +'bell.wav');
end;

{ TMain.bPlayHornClick

  Plays a the horn sound as preview. }

procedure TMain.bPlayHornClick(Sender: TObject);
begin
  TOSUtils.PlaySound(FPath +'horn.wav');
end;

{ TMain.bPlayBingClick

  Plays a the bing sound as preview. }

procedure TMain.bPlayBingClick(Sender: TObject);
begin
  TOSUtils.PlaySound(FPath +'bing.wav');
end;

{ TMain.bPlayBeepClick

  Plays a the beep sound as preview. }

procedure TMain.bPlayBeepClick(Sender: TObject);
begin
  TOSUtils.PlaySound(FPath +'beep.wav');
end;

{ TMain.eHourKeyPress

  Event that is called when user edits time and presses a key. }

procedure TMain.eHourKeyPress(Sender: TObject; var Key: Char);
begin
  // Only allow digits, arrow-left and arrow-right key and delete key
  if not (Key in [#25, #27, #08, '0'..'9']) then
  begin
    SysUtils.Beep;
    Key := #0;
  end;  //of begin
end;

{ TMain.eHourKeyUp

  Event that is called when user edits hours and a key is released. }

procedure TMain.eHourKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  try
    if ((Length(eHour.Text) = 2) and not (Key in [VK_RIGHT, VK_LEFT])) then
    begin
      Clock.Alert.SetHour(StrToInt(eHour.Text));
      eHour.Text := Clock.Alert.GetHour();
      eMin.SetFocus;
    end;  //of begin

  except
    eHour.Text := Clock.Alert.GetHour();
  end;  //of try
end;

{ TMain.eMinKeyUp

  Event that is called when user edits minutes and a key is released. }

procedure TMain.eMinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  try
    if ((Length(eMin.Text) = 2) and not (Key in [VK_RIGHT, VK_LEFT])) then
    begin
      Clock.Alert.SetMin(StrToInt(eMin.Text));
      eMin.Text := Clock.Alert.GetMin();
    end;  //of begin

  except
    eMin.Text := Clock.Alert.GetMin();
  end;  //of try
end;

{ TMain.bAlertClick

  Event that is called when user sets alert. }

procedure TMain.bAlertClick(Sender: TObject);
begin
  // Try to set alert time
  try
    // Check for invalid input
    if ((Trim(eHour.Text) = '') or (Trim(eMin.Text) = ''))  then
      raise EInvalidTimeException.Create('Hours and minutes must not be empty!');

    Clock.Alert.SetTime(StrToInt(eHour.Text), StrToInt(eMin.Text));
    eHour.Text := Clock.Alert.GetHour();
    eMin.Text := Clock.Alert.GetMin();
    Caption := Caption +' - '+ Clock.Alert.GetTime(False);

    // Start alert
    Clock.StartAlert();

    // Disable GUI components
    eHour.Enabled := False;
    bIncHour.Enabled := False;
    bDecHour.Enabled := False;
    eMin.Enabled := False;
    bIncMin.Enabled := False;
    bDecMin.Enabled := False;
    bAlert.Default := False;
    bAlert.Enabled := False;
    bStop.Enabled := True;
    bStop.Default := True;
    mmTimer.Enabled := False;
    mmCounter.Enabled := False;

    FLang.MessageBox(FLang.Format(62, [Clock.Alert.GetTime(False)]));

  except
    FLang.MessageBox(71, mtWarning);
  end;  //of try
end;

{ TMain.bStopClick

  Event that is called when user stops alert. }

procedure TMain.bStopClick(Sender: TObject);
begin
  // Stop alert
  Clock.StopAlert();

  if mmCounter.Checked then
  begin
    Clock.Time.Reset();
    lHour.Caption := Clock.Time.GetTime();
  end;  //of begin

  // Reset GUI
  Caption := Application.Title;
  bStop.Caption := FLang.GetString(49);
  bStop.Default := False;
  bStop.Enabled := False;
  bAlert.Enabled := True;
  bAlert.Default := True;
  eHour.Enabled := True;
  bIncHour.Enabled := True;
  bDecHour.Enabled := True;
  eMin.Enabled := True;
  bIncMin.Enabled := True;
  bDecMin.Enabled := True;
  rgSounds.Enabled := True;
  bPlayBeep.Enabled := True;
  bPlayBing.Enabled := True;
  bPlayClock.Enabled := True;
  bPlayHorn.Enabled := True;
  cbBlink.Enabled := True;
  cbText.Enabled := True;
  bColor.Enabled := cbBlink.Checked;
  mmTimer.Enabled := True;
  mmCounter.Enabled := True;

  if cbText.Checked then
  begin
    pText.SendToBack;
    pText.Visible := False;
    bChange.Enabled := True;
  end  //of begin
  else
    bChange.Enabled := False;

  FLang.MessageBox(64, mtInfo);
end;

{ TMain.bColorClick

  Shows a TColorDialog for choosing a blink color. }

procedure TMain.bColorClick(Sender: TObject);
var
  ColorDialog: TColorDialog;
  Config: TConfigFile;
  ChosenColor: TColor;
  Save, SaveColor: Boolean;
  Colors: array[0..15] of string;
  i: Byte;

begin
  Config := TConfigFile.Create(FConfigPath);

  try
    Save := Config.ReadBoolean('Global', 'Save');
    SaveColor := Config.ReadBoolean('Global', 'SaveColor');
    Config.ReadColors(Colors);

  except
    Config.Free;
    FLang.MessageBox(71, mtError);
    Exit;
  end;  //of try

  // Init TColorDialog
  ColorDialog := TColorDialog.Create(Self);

  try
    if (Save and SaveColor) then
      for i := 0 to Length(Colors) -1 do
        ColorDialog.CustomColors.Insert(i, 'Color'+ Chr(Ord('A') + i) +'='+ Colors[i]);

    // Action "Ok" was called
    if ColorDialog.Execute then
    begin
      ChosenColor := ColorDialog.Color;

      if (Save and SaveColor) then
      begin
        FColor := ChosenColor;

        for i := 0 to Length(Colors) -1 do
          Colors[i] := ColorDialog.CustomColors.Values['Color'+ Chr(Ord('A') + i)];

        // Write custom colors to config file
        Config.WriteColors(Colors);

        // Save changes to config file
        Config.Save();
      end;  //of begin
    end;  //of begin

  finally
    Config.Free;
    ColorDialog.Free;
  end;  //of try
end;

{ TMain.bChangeClick

  Shows a InputBox for setting up the text message. }

procedure TMain.bChangeClick(Sender: TObject);
var
  UserInput: string;

begin
  UserInput := InputBox(FLang.GetString(65), FLang.GetString(66), pText.Caption);

  // Text length maximum 16 characters
  if (Length(UserInput) > 16) then
  begin
    FLang.MessageBox([67, NEW_LINE, 68], mtWarning);
    bChange.Click;
  end  //of begin
  else
    pText.Caption := UserInput;
end;

{ TMain.cbBlinkClick

  Event that is called when user clicks the blink CheckBox. }

procedure TMain.cbBlinkClick(Sender: TObject);
begin
  bColor.Enabled := cbBlink.Checked;
end;

{ TMain.cbTextClick

  Event that is called when user clicks the show text CheckBox. }

procedure TMain.cbTextClick(Sender: TObject);
begin
  bChange.Enabled := cbText.Checked;
end;

{ TMain.mmSaveClick

  MainMenu entry that allows to enable or disable saving and loading the
  configuration file. }

procedure TMain.mmSaveClick(Sender: TObject);
begin
  mmOptions.Enabled := mmSave.Checked;

  if mmSave.Checked then
    mmOptions.Click;
end;

{ TMain.mmOptionsClick

  MainMenu entry that allows to edit the configuration. }

procedure TMain.mmOptionsClick(Sender: TObject);
var
  Options: TOptions;

begin
  Options := TOptions.Create(Self, Clock, FLang, FConfigPath);
  Options.ShowModal;
  Options.Free;
end;

{ TMain.mmTimerClick

  MainMenu entry that allows to change the current mode to Timer. }

procedure TMain.mmTimerClick(Sender: TObject);
begin
  if not mmTimer.Checked then
  begin
    mmCounter.Checked := False;
    mmTimer.Checked := True;
    Clock.ChangeMode(True);
    eHour.Text := Clock.Alert.GetHour();
    eMin.Text := Clock.Alert.GetMin();
    eHour.SetFocus;
  end;  //of begin
end;

{ TMain.mmCounterClick

  MainMenu entry that allows to change the current mode to Counter. }

procedure TMain.mmCounterClick(Sender: TObject);
begin
  if not mmCounter.Checked then
  begin
    mmTimer.Checked := False;
    mmCounter.Checked := True;
    Clock.ChangeMode(False);
    lHour.Caption := Clock.Time.GetTime();
    eHour.Text := Clock.Alert.GetHour();
    eMin.Text := Clock.Alert.GetMin();
    eHour.SetFocus;
  end;  //of begin
end;

{ TMain.mmLangClick

  MainMenu entry that allows to change the current language. }

procedure TMain.mmLangClick(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  FLang.ChangeLanguage(Sender, GetLangId((Sender as TMenuItem).Caption));
{$ELSE}
  FLang.ChangeLanguage(Sender, (Sender as TMenuItem).Caption);
{$ENDIF}
end;

{ TMain.mmDwnldCertClick

  MainMenu entry that allows to download the PM Code Works certificate. }

procedure TMain.mmDownloadCertClick(Sender: TObject);
{$IFDEF MSWINDOWS}
var
  Updater: TUpdate;

begin
  // Certificate already installed?
  if (TOSUtils.PMCertExists() and (FLang.MessageBox([27, NEW_LINE, 28],
    mtQuestion) = IDYES)) then
  begin
    // Init downloader
    Updater := TUpdate.Create(Self, FLang);

    // Download certificate
    try
      with Updater do
      begin
        Title := FLang.GetString(16);
        DownloadCertificate();
      end;  //of begin

    finally
      Updater.Free;
    end;  //of try
  end;  //of begin
{$ELSE}
begin
{$ENDIF}
end;

{ TMain.mmUpdateClick

  MainMenu entry that allows users to manually search for updates. }

procedure TMain.mmUpdateClick(Sender: TObject);
begin
  FUpdateCheck.CheckForUpdate(True);
end;

{ TMain.mmWebsiteClick

  Opens the homepage of Game Wake in a web browser. }

procedure TMain.mmWebsiteClick(Sender: TObject);
begin
  TOSUtils.OpenUrl(URL_BASE +'gamewake.html');
end;

{ TMain.mmReportClick

  MainMenu entry that allows users to easily report a bug by opening the web
  browser and using the "report bug" formular. }

procedure TMain.mmReportClick(Sender: TObject);
begin
  TOSUtils.OpenUrl(URL_CONTACT);
end;

{ TMain.mmInfoClick

  MainMenu entry that shows a info page with build number and version history. }

procedure TMain.mmInfoClick(Sender: TObject);
var
  Info: TInfo;

begin
  Application.CreateForm(TInfo, Info);
  Info.ShowModal;
  Info.Free;
end;

{ TMain.lCopyClick

  Opens the homepage of PM Code Works in a web browser. }

procedure TMain.lCopyClick(Sender: TObject);
begin
  TOSUtils.OpenUrl(URL_BASE);
end;

{ TMain.lCopyMouseEnter

  Allows a label to have the look like a hyperlink.  }

procedure TMain.lCopyMouseEnter(Sender: TObject);
begin
  with (Sender as TLabel) do
  begin
    Font.Style := Font.Style + [fsUnderline];
    Font.Color := clBlue;
    Cursor := crHandPoint;
  end;  //of with
end;

{ TMain.lCopyMouseLeave

  Allows a label to have the look of a normal label again. }

procedure TMain.lCopyMouseLeave(Sender: TObject);
begin
  with (Sender as TLabel) do
  begin
    Font.Style := Font.Style - [fsUnderline];
    Font.Color := clBlack;
    Cursor := crDefault;
  end;  //of with
end;

{ TMain.FormCloseQuery

  Event that is called during termination of Game Wake. }

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  TrayIcon: TIcon;

begin
  // Alert is not set?
  if (Clock.AlertEnabled = False) then
    CanClose := True
  else
    if rgSounds.Enabled then
    begin
      Hide;

      // Create TrayIcon
    {$IFDEF MSWINDOWS}
      FTrayIcon := TTrayIcon.Create(Application.Title, Self.Icon.Handle);
      FTrayIcon.OnMouseUp := TrayIconMouseUp;
    {$ELSE}
      FTrayIcon := TTrayIcon.Create(Self);

      try
        FTrayIcon.BalloonTitle := Application.Title;
        FTrayIcon.BalloonFlags := bfInfo;
        FTrayIcon.OnMouseUp := TrayMouseUp;
        FTrayIcon.Icon.LoadFromFile('/usr/share/pixmaps/gamewake.ico');
        FTrayIcon.PopUpMenu := pmMenu;
        FTrayIcon.Hint := Application.Title;
        FTrayIcon.Show;

      except
        FTrayIcon.Free;
        FTrayIcon := nil;
        FLang.MessageBox(79, mtError);
        Show;
      end;  //of try
    {$ENDIF}
      CanClose := False;
    end  //of begin
    else
      CanClose := True;
end;

end.
