{ *********************************************************************** }
{                                                                         }
{ Game Wake Main Unit                                                     }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeMain;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Menus,
  Dialogs, GameWakeAPI, PMCWLanguageFile, PMCWUpdater, PMCWOSUtils, PMCWAbout,

{$IFDEF PORTABLE}
  MMSystem,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Windows, System.UITypes, ShlObj, KnownFolders, Messages;
{$ELSE}
  LCLType, Process;
{$ENDIF}

type
  { TMain }
  TMain = class(TForm, IChangeLanguageListener, IUpdateListener)
    eHour: TEdit;
    eMin: TEdit;
    bAlert: TButton;
    bStop: TButton;
    lDp: TLabel;
    mmInstallCertificate: TMenuItem;
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
    mmAbout: TMenuItem;
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
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mmInstallCertificateClick(Sender: TObject);
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
    procedure mmReportClick(Sender: TObject);
    procedure mmAboutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lCopyClick(Sender: TObject);
    procedure lCopyMouseEnter(Sender: TObject);
    procedure lCopyMouseLeave(Sender: TObject);
    procedure Blink(Sender: TObject);
  private
    FClock: TClock;
    FLang: TLanguageFile;
    FTrayIcon: TTrayIcon;
    FColor: TColor;
    FConfigPath, FLangPath, FPath: string;
    FUpdateCheck: TUpdateCheck;
    procedure Alert(Sender: TObject);
    procedure OnUpdate(Sender: TObject; const ANewBuild: Cardinal);
    procedure BlinkEnd(Sender: TObject);
    procedure Count(Sender: TObject; ATime: string);
    procedure LoadColor();
    procedure LoadFromIni();
  {$IFDEF MSWINDOWS}
    procedure PowerBroadcast(var AMsg: TMessage); message WM_POWERBROADCAST;
  {$ENDIF}
    procedure SaveToIni();
    procedure SetLanguage(Sender: TObject);
    function Shutdown(): Boolean;
    procedure TrayMouseUp(Sender: TObject; AButton: TMouseButton;
      AShiftState: TShiftState; X, Y: Integer);
  end;

var
  Main: TMain;

implementation

{$IFDEF MSWINDOWS}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

{$IFDEF PORTABLE}
{$R 'sounds.res' 'sounds.res'}
{$ENDIF}

uses GameWakeOps;

{ TMain }

{ TMain.FormCreate

  VCL event that is called when form is being created. }

procedure TMain.FormCreate(Sender: TObject);
var
  Config: TConfigFile;
  Combine, AutoUpdate: Boolean;

begin
  FLangPath := '';
{$IFNDEF MSWINDOWS}
  FPath := '/usr/lib/gamewake/';

  // Load other language file?
  if ((ParamStr(1) = '--lang') and (ParamStr(2) <> '')) then
    FLangPath := ParamStr(2)
  else
    if ((ParamStr(3) = '--lang') and (ParamStr(4) <> '')) then
      FLangPath := ParamStr(4);

  // Load other configuration?
  if ((ParamStr(1) = '--config') and (ParamStr(2) <> '')) then
    FConfigPath := ParamStr(2)
  else
    if ((ParamStr(3) = '--config') and (ParamStr(4) <> '')) then
      FConfigPath := ParamStr(4)
    else
      FConfigPath := GetUserDir() +'.gamewake';

  // Setup language
  FLang := TLanguageFile.Create(Self, FLangPath);
{$ELSE}
  if CheckWin32Version(6) then
    FConfigPath := GetKnownFolderPath(FOLDERID_RoamingAppData)
  else
  {$WARN SYMBOL_DEPRECATED OFF}
    FConfigPath := GetFolderPath(CSIDL_APPDATA);
  {$WARN SYMBOL_DEPRECATED ON}

  FConfigPath := FConfigPath + IncludeTrailingPathDelimiter(Application.Title);

  if not DirectoryExists(FConfigPath) then
    CreateDir(FConfigPath);

  FConfigPath := FConfigPath +'gamewake.ini';
  FPath := '';

  // Setup language
  FLang := TLanguageFile.Create(Self);
  FLang.Interval := 100;
{$ENDIF}
  FLang.BuildLanguageMenu(MainMenu, mmLang);

  // Init config file access
  Config := TConfigFile.Create(FConfigPath);

  try
    // Check if anything shall be loaded from config
    if Config.ReadBoolean('Global', 'Save') then
    begin
      LoadFromIni();
      mmOptions.Enabled := True;
    end  //of begin
    // Do not load anything except language
    else
    begin
      mmSave.Checked := False;
      mmOptions.Enabled := False;
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
    mmInstallCertificate.Visible := False;
    Icon.LoadFromFile('/usr/share/pixmaps/gamewake.ico');
  {$ENDIF}

  // Init Clock
  FClock := TClock.Create(Self, mmTimer.Checked, Combine);

  with FClock do
  begin
    Alert.SetTime(StrToInt(eHour.Text), StrToInt(eMin.Text));
    OnAlert := Self.Alert;
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
  FClock.Free;
  FUpdateCheck.Free;

  // Delete icon from tray
  if Assigned(FTrayIcon) then
    FTrayIcon.Free;
end;

{ private TMain.Alert

  Event that is called when alert was started. }

procedure TMain.Alert(Sender: TObject);
begin
  Application.Restore;
  Show;
  Application.BringToFront;

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
  FClock.AlertType := TAlertType(rgSounds.ItemIndex);

  // Check for shutdown
  if (FClock.AlertType = atShutdown) then
  begin
    if Shutdown() then
    begin
      bAlert.Enabled := True;
      Close;
    end;  //of begin
  end  //of begin
  else
  begin
    // Enable blinking?
    Timer.Enabled := cbBlink.Checked;

    // Show text?
    if cbText.Checked then
    begin
      pText.Visible := True;
      pText.BringToFront;
    end;   //of begin

    cbText.Enabled := False;
    pmOpen.Click;
  end;  //of if
end;

{ private TMain.OnUpdate

  Event that is called by TUpdateCheck when TUpdateCheckThread finds an update. }

procedure TMain.OnUpdate(Sender: TObject; const ANewBuild: Cardinal);
{$IFDEF MSWINDOWS}
var
  Updater: TUpdate;

begin
  // Ask user to permit download
  if (FLang.ShowMessage(FLang.Format(LID_UPDATE_AVAILABLE, [ANewBuild]),
    FLang.GetString(LID_UPDATE_CONFIRM_DOWNLOAD), mtConfirmation) = IDYES) then
  begin
    // init TUpdate instance
    Updater := TUpdate.Create(Self, FLang);

    try
      // Set updater options
      with Updater do
      begin
        Title := FLang.GetString(LID_UPDATE_DOWNLOAD);
        FileNameLocal := 'Game Wake Setup.exe';
        FileNameRemote := 'game_wake_setup.exe';
      end;  //of begin

      // Successfully downloaded update?
      if Updater.Execute() then
      begin
        // Caption "Search for update"
        mmUpdate.Caption := FLang.GetString(LID_UPDATE_SEARCH);
        mmUpdate.Enabled := False;

        // Start with new version installing
        Updater.LaunchSetup();
      end;  //of begin

    finally
      Updater.Free;
    end;  //of try
  end  //of begin
  else
    mmUpdate.Caption := FLang.GetString(LID_UPDATE_DOWNLOAD);
{$ELSE}
begin
  FLang.ShowMessage(FLang.Format([LID_UPDATE_AVAILABLE], [ANewBuild]),
    FLang.GetString(LID_UPDATE_CONFIRM_DOWNLOAD), mtInformation);
{$ENDIF}
end;

{ private TMain.BlinkEnd

  Event that is called by TAlertThread when alert was stopped. }

procedure TMain.BlinkEnd(Sender: TObject);
begin
  Timer.Enabled := False;
  Color := clBtnFace;
end;

{ private TMain.Count

  Event that is called by TClock when current time is incremented. }

procedure TMain.Count(Sender: TObject; ATime: string);
begin
  lHour.Caption := ATime;
end;

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
    FLang.ShowMessage(FLang.GetString(73), mtError);
  end;  //of try
end;

{ private TMain.LoadFromIni

  Loads user specific configuration from file. }

procedure TMain.LoadFromIni();
var
  Config: TConfigFile;
  Locale: TLanguageId;
  AlertType: Integer;

begin
  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Load language from config
    {$IFDEF MSWINDOWS}
      Locale := Config.ReadInteger('Global', 'Locale', 0);
    {$ELSE}
      Locale := Config.ReadString('Global', 'Locale');
    {$ENDIF}

      // Load prefered language
      FLang.Locale := Locale;

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
    FLang.ShowMessage(FLang.Format(75, [FConfigPath]), mtError);
  end;  //of try
end;

{$IFDEF MSWINDOWS}
{ private TMain.PowerBroadcast

  Event that is called after wakeup (after suspending). }

procedure TMain.PowerBroadcast(var AMsg: TMessage);
begin
  if (AMsg.WParam = PBT_APMRESUMESUSPEND) then
    FClock.Time.SetSystemTime();
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
        Config.WriteInteger('Global', 'Locale', FLang.Locale);
      {$ELSE}
        Config.WriteString('Global', 'Locale', FLang.Locale);
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
    on E: Exception do
      FLang.ShowException(FLang.Format(76, [FConfigPath]), E.Message);
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
    mmFile.Caption := GetString(33);
    mmSave.Caption := GetString(42);
    mmEdit.Caption := GetString(43);
    mmOptions.Caption := GetString(44);
    mmTimer.Caption := GetString(45);
    mmCounter.Caption := GetString(46);
    mmView.Caption := GetString(10);
    mmLang.Caption := GetString(25);
    mmHelp.Caption := GetString(14);
    mmUpdate.Caption:= GetString(15);
    mmInstallCertificate.Caption := GetString(16);
    mmReport.Caption := GetString(26);
    mmWebsite.Caption := GetString(29);
    lCopy.Hint := mmWebsite.Caption;
    mmAbout.Caption := Format(17, [Application.Title]);

    // Set captions for "alert type" TRadioGroup
    rgSounds.Caption := GetString(47);

    for i := 0 to 4 do
      rgSounds.Items[i] := GetString(i + 48);

    // Set captions for "at alert" TGroupBox
    gpOther.Caption := GetString(53);
    cbBlink.Caption := GetString(54);
    bColor.Caption := GetString(55);
    cbText.Caption := GetString(56);
    bChange.Caption := GetString(57);

    // Set captions for buttons
    bAlert.Caption := GetString(58);
    bStop.Caption := GetString(59);

    // Set captions for TPopupMenu items
    pmOpen.Caption := GetString(87);
    pmClose.Caption := GetString(88);
  end;  //of with
end;

{ private TMain.Shutdown

  Tells the OS to shutdown the computer. }

function TMain.Shutdown(): Boolean;
{$IFNDEF MSWINDOWS}
var
  Process: TProcess;

begin
  if FileExists('/usr/bin/dbus-send') then
    try
      Process := TProcess.Create(nil);

      try
        Process.Executable := '/usr/bin/dbus-send';

        with Process.Parameters do
        begin
          Append('--system');
          Append('--print-reply');
          Append('--dest=org.freedesktop.ConsoleKit');
          Append('/org/freedesktop/ConsoleKit/Manager');
          Append('org.freedesktop.ConsoleKit.Manager.Stop');
        end;  //of with

        Process.Execute;
        Result := True;

      finally
        Process.Free;
      end;  //of try

    except
      Result := False;
    end  //of try
  else
    Result := False;
end;
{$ELSE}
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SHTDN_REASON_MAJOR_APPLICATION = $00040000;
  SHTDN_REASON_MINOR_MAINTENANCE = 1;

var
  TokenHandle: THandle;
  NewState, PreviousState: TTokenPrivileges;
  BufferLength, ReturnLength: Cardinal;
  Luid: Int64;

begin
  if ((Win32Platform = VER_PLATFORM_WIN32_NT)) then
  try
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
      TOKEN_QUERY, TokenHandle) then
      raise Exception.Create(SysErrorMessage(GetLastError()));

    // Get LUID of shutdown privilege
    if not LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, Luid) then
      raise Exception.Create(SysErrorMessage(GetLastError()));

    // Create new shutdown privilege
    NewState.PrivilegeCount := 1;
    NewState.Privileges[0].Luid := Luid;
    NewState.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    BufferLength := SizeOf(PreviousState);
    ReturnLength := 0;

    // Set the shutdown privilege
    if not AdjustTokenPrivileges(TokenHandle, False, NewState, BufferLength,
      PreviousState, ReturnLength) then
      raise Exception.Create(SysErrorMessage(GetLastError()));

  finally
    CloseHandle(TokenHandle);
  end;  //of try

  Result := ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE, SHTDN_REASON_MAJOR_APPLICATION or
    SHTDN_REASON_MINOR_MAINTENANCE);
end;
{$ENDIF}

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
          FTrayIcon.BalloonHint := Format(FLang.GetString(73), [FClock.Alert.GetTime(False)])
        else
        begin
          FClock.GetTimeRemaining(Hour, Min, Sec);
          FTrayIcon.BalloonHint := Format(FLang.GetString(82), [Hour, Min, Sec]);
        end;  //of if

        FTrayIcon.ShowBalloonHint;
      end;  //of begin
  end;  //of case
end;

{ TMain.Blink

  Event that is called by Timer while alert is in progress. }

procedure TMain.Blink(Sender: TObject);
begin
  if (Color = clBtnFace) then
    Color := FColor
  else
    Color := clBtnFace;
end;

{ TMain.pmCloseClick

  PopMenu entry that terminates Game Wake. }

procedure TMain.pmCloseClick(Sender: TObject);
begin
  // Show confirmation
  if (FLang.ShowMessage(79, 80, mtConfirmation) = IDYES) then
  begin
    bStop.Click;
    Close;
  end;  //of begin
end;

{ TMain.pmOpenClick

  PopMenu entry that opens Game Wake. }

procedure TMain.pmOpenClick(Sender: TObject);
begin
  if Assigned(FTrayIcon) then
    FTrayIcon.Visible := False;

  Show;
  BringToFront;
end;

{ TMain.bIncHourClick

  Increments hours by 1. }

procedure TMain.bIncHourClick(Sender: TObject);
begin
  eHour.Text := FClock.Alert.IncrementHours();

  if FClock.Alert.Combine then
    eMin.Text := FClock.Alert.GetMin();
end;

{ TMain.bDecHourClick

  Decrements hours by 1. }

procedure TMain.bDecHourClick(Sender: TObject);
begin
  eHour.Text := FClock.Alert.DecrementHours();

  if FClock.Alert.Combine then
    eMin.Text := FClock.Alert.GetMin();
end;

{ TMain.bIncMinClick

  Increments minutes by 1. }

procedure TMain.bIncMinClick(Sender: TObject);
begin
  eMin.Text := FClock.Alert.IncrementMinutes();

  if FClock.Alert.Combine then
    eHour.Text := FClock.Alert.GetHour();
end;

{ TMain.bDecMinClick

  Decrements minutes by 1. }

procedure TMain.bDecMinClick(Sender: TObject);
begin
  eMin.Text := FClock.Alert.DecrementMinutes();

  if FClock.Alert.Combine then
    eHour.Text := FClock.Alert.GetHour();
end;

{ TMain.bPlayClockClick

  Plays a the bell sound as preview. }

procedure TMain.bPlayClockClick(Sender: TObject);
begin
{$IFDEF PORTABLE}
  PlaySound(PChar('BELL'), HInstance, SND_ASYNC or SND_MEMORY or SND_RESOURCE);
{$ELSE}
  FClock.PlaySound(FPath +'bell.wav');
{$ENDIF}
end;

{ TMain.bPlayHornClick

  Plays a the horn sound as preview. }

procedure TMain.bPlayHornClick(Sender: TObject);
begin
{$IFDEF PORTABLE}
  PlaySound(PChar('HORN'), HInstance, SND_ASYNC or SND_MEMORY or SND_RESOURCE);
{$ELSE}
  FClock.PlaySound(FPath +'horn.wav');
{$ENDIF}
end;

{ TMain.bPlayBingClick

  Plays a the bing sound as preview. }

procedure TMain.bPlayBingClick(Sender: TObject);
begin
{$IFDEF PORTABLE}
  SysUtils.Beep();
{$ELSE}
  FClock.PlaySound(FPath +'bing.wav');
{$ENDIF}
end;

{ TMain.bPlayBeepClick

  Plays a the beep sound as preview. }

procedure TMain.bPlayBeepClick(Sender: TObject);
begin
{$IFDEF PORTABLE}
  PlaySound(PChar('BEEP'), HInstance, SND_ASYNC or SND_MEMORY or SND_RESOURCE);
{$ELSE}
  FClock.PlaySound(FPath +'beep.wav');
{$ENDIF}
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
      FClock.Alert.SetHour(StrToInt(eHour.Text));
      eHour.Text := FClock.Alert.GetHour();
      eMin.SetFocus;
    end;  //of begin

  except
    eHour.Text := FClock.Alert.GetHour();
  end;  //of try
end;

{ TMain.eMinKeyUp

  Event that is called when user edits minutes and a key is released. }

procedure TMain.eMinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  try
    if ((Length(eMin.Text) = 2) and not (Key in [VK_RIGHT, VK_LEFT])) then
    begin
      FClock.Alert.SetMin(StrToInt(eMin.Text));
      eMin.Text := FClock.Alert.GetMin();
    end;  //of begin

  except
    eMin.Text := FClock.Alert.GetMin();
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

    FClock.Alert.SetTime(StrToInt(eHour.Text), StrToInt(eMin.Text));
    eHour.Text := FClock.Alert.GetHour();
    eMin.Text := FClock.Alert.GetMin();
    Caption := Caption +' - '+ FClock.Alert.GetTime(False);

    // Start alert
    FClock.StartAlert();

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

    FLang.ShowMessage(FLang.Format(72, [FClock.Alert.GetTime(False)]));

  except
    FLang.ShowMessage(FLang.GetString(81), mtWarning);
  end;  //of try
end;

{ TMain.bStopClick

  Event that is called when user stops alert. }

procedure TMain.bStopClick(Sender: TObject);
begin
  // Stop alert
  FClock.StopAlert();

  if mmCounter.Checked then
  begin
    FClock.Time.Reset();
    lHour.Caption := FClock.Time.GetTime();
  end;  //of begin

  // Reset GUI
  Caption := Application.Title;
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

  FLang.ShowMessage(FLang.GetString(74));
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
    FLang.ShowMessage(FLang.GetString(71), mtError);
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
  UserInput := InputBox(FLang.GetString(75), FLang.GetString(76), pText.Caption);

  // Text length maximum 16 characters
  if (Length(UserInput) > 16) then
  begin
    FLang.ShowMessage(77, 78, mtWarning);
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
  Options := TOptions.Create(Self, FClock, FLang, FConfigPath);
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
    FClock.ChangeMode(True);
    eHour.Text := FClock.Alert.GetHour();
    eMin.Text := FClock.Alert.GetMin();
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
    FClock.ChangeMode(False);
    lHour.Caption := FClock.Time.GetTime();
    eHour.Text := FClock.Alert.GetHour();
    eMin.Text := FClock.Alert.GetMin();
    eHour.SetFocus;
  end;  //of begin
end;

{ TMain.mmInstallCertificateClick

  MainMenu entry that allows to install the PM Code Works certificate. }

procedure TMain.mmInstallCertificateClick(Sender: TObject);
{$IFDEF MSWINDOWS}
var
  Updater: TUpdate;

begin
  Updater := TUpdate.Create(Self, FLang);

  try
    // Certificate already installed?
    if not Updater.CertificateExists() then
      Updater.InstallCertificate()
    else
      FLang.ShowMessage(FLang.GetString(LID_CERTIFICATE_ALREADY_INSTALLED), mtInformation);

  finally
    Updater.Free;
  end;  //of try
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
  OpenUrl(URL_BASE +'gamewake.html');
end;

{ TMain.mmReportClick

  MainMenu entry that allows users to easily report a bug by opening the web
  browser and using the "report bug" formular. }

procedure TMain.mmReportClick(Sender: TObject);
begin
  OpenUrl(URL_CONTACT);
end;

{ TMain.mmInfoClick

  MainMenu entry that shows a info page with build number and version history. }

procedure TMain.mmAboutClick(Sender: TObject);
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
  OpenUrl(URL_BASE);
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
begin
  // Alert is not set?
  if (not FClock.AlertEnabled) then
  begin
    CanClose := True;
    Exit;
  end;  //of begin

  // Create tray icon
  if not Assigned(FTrayIcon) then
    FTrayIcon := TTrayIcon.Create(Self);

  // Set tray icon options
  try
    FTrayIcon.BalloonTitle := Application.Title;
    FTrayIcon.BalloonFlags := bfInfo;
    FTrayIcon.OnMouseUp := TrayMouseUp;
    FTrayIcon.PopUpMenu := pmMenu;
    FTrayIcon.Hint := Application.Title;
  {$IFDEF MSWINDOWS}
    FTrayIcon.Icon.Handle := Application.Icon.Handle;
  {$ELSE}
    FTrayIcon.Icon.LoadFromFile('/usr/share/pixmaps/gamewake.ico');
  {$ENDIF}
    FTrayIcon.Visible := True;

    // Hide form
    Hide;

  except
    on E: Exception do
    begin
      FLang.ShowException(FLang.GetString(89), E.Message);
      FreeAndNil(FTrayIcon);
    end;
  end;  //of try

  CanClose := False;
end;

end.
