{ *********************************************************************** }
{                                                                         }
{ Game Wake Main Unit                                                     }
{                                                                         }
{ Copyright (c) 2011-2018 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeMain;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Menus,
  Dialogs, DateUtils, GameWakeAPI, PMCW.LanguageFile, PMCW.SysUtils, PMCW.Dialogs,
  PMCW.Application,
{$IFDEF MSWINDOWS}
  Winapi.Windows, System.UITypes, Winapi.ShlObj, Winapi.KnownFolders,
  Winapi.Messages;
{$ELSE}
  LCLType;
{$ENDIF}

type
  { TMain }
  TMain = class(TMainForm)
    eHour: TEdit;
    eMin: TEdit;
    bAlert: TButton;
    bStop: TButton;
    lDp: TLabel;
    pmClose: TMenuItem;
    pmOpen: TMenuItem;
    mmCounter: TMenuItem;
    mmTimer: TMenuItem;
    pmMenu: TPopupMenu;
    rgSounds: TRadioGroup;
    lHour: TLabel;
    lCopy: TLabel;
    bPlayClock: TButton;
    bPlayBing: TButton;
    bPlayBeep: TButton;
    gpOther: TGroupBox;
    cbBlink: TCheckBox;
    cbText: TCheckBox;
    bChange: TButton;
    MainMenu: TMainMenu;
    mmFile: TMenuItem;
    mmSave: TMenuItem;
    mmHelp: TMenuItem;
    bColor: TButton;
    mmEdit: TMenuItem;
    mmOptions: TMenuItem;
    bPlayHorn: TButton;
    pText: TPanel;
    bIncHour: TButton;
    bDecHour: TButton;
    bDecMin: TButton;
    bIncMin: TButton;
    N4: TMenuItem;
    mmView: TMenuItem;
    mmLang: TMenuItem;
    TrayIcon: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pmCloseClick(Sender: TObject);
    procedure pmOpenClick(Sender: TObject);
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lCopyClick(Sender: TObject);
    procedure lCopyMouseEnter(Sender: TObject);
    procedure lCopyMouseLeave(Sender: TObject);
    procedure Blink(Sender: TObject);
    procedure mmLangClick(Sender: TObject);
  private
    FClock: TClock;
    FAlertThread: TAlertThread;
    FColor: TColor;
    FConfigPath: string;
    procedure Alert(Sender: TObject);
    procedure BlinkEnd(Sender: TObject);
    procedure Counting(Sender: TObject);
    procedure LoadFromIni();
  {$IFDEF MSWINDOWS}
    procedure PowerBroadcast(var AMsg: TMessage); message WM_POWERBROADCAST;
  {$ENDIF}
    procedure SaveToIni();
    procedure ShowAlertTime();
    function ShowOptionsDialog(): Boolean;
  protected
    procedure LanguageChanged(); override;
  end;

var
  Main: TMain;

implementation

uses GameWakeOps;

{$I LanguageIDs.inc}
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TMain }

{ TMain.FormCreate

  VCL event that is called when form is being created. }

procedure TMain.FormCreate(Sender: TObject);
{$IFNDEF MSWINDOWS}
var
  i: Integer;
  LanguageFileName: TFileName;
{$ENDIF}

begin
  FColor := clRed;
{$IFNDEF MSWINDOWS}
  LanguageFileName := ExtractFilePath(Application.ExeName) +'languages';
  FConfigPath := GetUserDir() +'.gamewake';

  // Parse arguments
  for i := 1 to Paramcount() do
  begin
    // Load other language file?
    if ((ParamStr(i) = '--lang') and (ParamStr(i + 1) <> '')) then
      LanguageFileName := ParamStr(i + 1)
    else
      Continue;

    // Load other configuration?
    if ((ParamStr(i) = '--config') and (ParamStr(i + 1) <> '')) then
      FConfigPath := ParamStr(i + 1)
    else
      Continue;
  end;  //of for

  // Setup language
  try
    FLang := TLanguageFile.Create(LanguageFileName);

  except
    // File could not be found or file contains no languages -> Terminate anyway!
    on E: Exception do
    begin
      MessageDlg(E.Message, mtError, [mbOK], 0);
      Application.Terminate;
    end;
  end;  //of try

  // Do not continue if language file could not be loaded
  if not Assigned(FLang) then
    Exit;
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

  // Setup language
  FLang := TLanguageFile.Create(100);
{$ENDIF}
  FLang.AddListener(Self);

  // Build menus
  BuildLanguageMenu(mmLang);
  BuildHelpMenu(mmHelp);

  // Init Clock
  FClock := TClock.Create(mmTimer.Checked);

  with FClock do
  begin
    OnAlert := Self.Alert;
    OnCounting := Self.Counting;
  end;  //of with

  // Load configuration
  LoadFromIni();
end;

{ TMain.FormDestroy

  VCL event that is called when form has been closed. }

procedure TMain.FormDestroy(Sender: TObject);
begin
  // Save configuration
  SaveToIni();

  FreeAndNil(FClock);
end;

{ private TMain.Alert

  Event that is called when alert was started. }

procedure TMain.Alert(Sender: TObject);
begin
  bAlert.Default := False;
  bStop.Default := True;
  // TODO: In Lazarus disabling the complete group box will not change the color when blinking
  rgSounds.Enabled := False;
  bPlayBeep.Enabled := False;
  bPlayBing.Enabled := False;
  bPlayClock.Enabled := False;
  bPlayHorn.Enabled := False;
  bChange.Enabled := False;
  bColor.Enabled := False;
  cbBlink.Enabled := False;
  cbText.Enabled := False;

  // Show text?
  if cbText.Checked then
  begin
    pText.Visible := True;
    pText.BringToFront;
  end;   //of begin

  cbText.Enabled := False;

  // Remove tray icon and show form
  pmOpen.Click;

  // Shutdown selected?
  if (rgSounds.ItemIndex = 4) then
  begin
    try
      Shutdown();
      FClock.AlertEnabled := False;
      Close();

    except
      on E: EOSError do
      begin
        ExceptionDlg(FLang, FLang.GetString([LID_SHUTDOWN, LID_IMPOSSIBLE]), E.Message);
        bStop.Click;
      end;
    end;  //of try
  end  //of begin
  else
  begin
    // Start playing sound
    FAlertThread := TAlertThread.Create(TAlertSound(rgSounds.ItemIndex));

    with FAlertThread do
    begin
      OnAlert := Blink;
      OnTerminate := BlinkEnd;
      Start();
    end;  //of begin
  end;  //of begin
end;

{ private TMain.BlinkEnd

  Event that is called by TAlertThread when alert was stopped. }

procedure TMain.BlinkEnd(Sender: TObject);
begin
  Color := clBtnFace;

  // Thread is terminated after 1 minute and variable holds address of a freed object
  FAlertThread := nil;
end;

{ private TMain.Counting

  Event that is called by TClock when current time is incremented. }

procedure TMain.Counting(Sender: TObject);
var
  TimeRemaining: TTime;

begin
  lHour.Caption := FClock.Time.ToString();

  if (TrayIcon.Visible and not FClock.TimerMode) then
  begin
    TimeRemaining := FClock.Alert - FClock.Time;
    TrayIcon.Hint := Application.Title +' - '+ FLang.Format(LID_ALERT_REMAINING, [TimeRemaining.ToString()]);
  end;  //of begin
end;

{ private TMain.LoadFromIni

  Loads user specific configuration from file. }

procedure TMain.LoadFromIni();
var
  Config: TConfigFile;
  Locale: TLocale;
  AlertType: Integer;
  AlarmHour, AlarmMinute: string;
  ParsedAlarmTime: TDateTime;
{$IFDEF MSWINDOWS}
  SearchForUpdate: Boolean;
{$ENDIF}

begin
{$IFDEF MSWINDOWS}
  SearchForUpdate := True;
{$ENDIF}

  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Check if anything shall be loaded from config
      mmSave.Checked := Config.ReadBool(Config.SectionGlobal, Config.IdSave, False);

      if not mmSave.Checked then
      begin
        mmOptions.Enabled := False;
        Exit;
      end  //of begin
      else
        mmOptions.Enabled := True;

      // Load language from config
    {$IFDEF MSWINDOWS}
      Locale := Config.ReadInteger(Config.SectionGlobal, Config.IdLocale, 0);
      SearchForUpdate := Config.ReadBool(Config.SectionGlobal, Config.IdAutoUpdate, True);
    {$ELSE}
      Locale := Config.ReadString(Config.SectionGlobal, Config.IdLocale, '');
    {$ENDIF}

      // Load prefered language
      FLang.Locale := Locale;

      // Load last mode
      FClock.TimerMode := Config.ReadBool(Config.SectionGlobal, Config.IdTimerMode, True);
      mmTimer.Checked := FClock.TimerMode;
      mmCounter.Checked := not mmTimer.Checked;

      // Load last time?
      if Config.ReadBool(Config.SectionGlobal, Config.IdSaveClock, False) then
      begin
        AlarmHour := Config.ReadString(Config.SectionAlert, Config.IdHour, '00');
        AlarmMinute := Config.ReadString(Config.SectionAlert, Config.IdMinute, '00');

        if TryStrToTime(AlarmHour + FormatSettings.TimeSeparator + AlarmMinute, ParsedAlarmTime) then
          FClock.Alert := ParsedAlarmTime;

        eHour.Text := FClock.Alert.HourToString();
        eMin.Text := FClock.Alert.MinuteToString();
      end;  //of begin

      // Load last sound?
      if Config.ReadBool(Config.SectionGlobal, Config.IdSaveSound, False) then
      begin
        AlertType := Config.ReadInteger(Config.SectionAlert, Config.IdSound, 0);

        if (AlertType in [0..4]) then
          rgSounds.ItemIndex := AlertType
        else
          rgSounds.ItemIndex := 0;
      end;  //of begin

      // Load last set alert text?
      if Config.ReadBool(Config.SectionGlobal, Config.IdSaveText, False) then
        pText.Caption := Config.ReadString(Config.SectionAlert, Config.IdText, 'Game Wake');

      // Load last position?
      if Config.ReadBool(Config.SectionGlobal, Config.IdSavePos, False) then
      begin
        Position := poDefault;
        Left := Config.ReadInteger(Config.SectionGlobal, Config.IdLeft, 0);
        Top := Config.ReadInteger(Config.SectionGlobal, Config.IdTop, 0);
      end;  //of begin

      // Load last "show text" state?
      if Config.ReadBool(Config.SectionAlert, Config.IdShowText, False) then
      begin
        cbText.Checked := True;
        bChange.Enabled := True;
      end;  //of begin

      // Load last flash state
      cbBlink.Checked := Config.ReadBool(Config.SectionAlert, Config.IdBlink, False);

      // Load flash color
      if Config.ReadBool(Config.SectionGlobal, Config.IdSaveColor, False) then
        FColor := Config.ReadColor(Config.SectionAlert, Config.IdColor, clRed)
      else
        FColor := clRed;

    finally
      Config.Free;

    {$IFNDEF FPC}
      // Search for update?
      if SearchForUpdate then
      {$IFDEF PORTABLE}
        CheckForUpdate('GameWake', 'gamewake.exe', 'gamewake64.exe', 'Game Wake.exe');
      {$ELSE}
        CheckForUpdate('GameWake', 'game_wake_setup.exe', '', 'Game Wake Setup.exe');
      {$ENDIF}
    {$ENDIF}
    end;  //of try

  except
    on E: Exception do
    begin
      ExceptionDlg(FLang, FLang.Format(LID_LOADING_CONFIG_FAILED, [FConfigPath]),
        E.Message);
    end;
  end;  //of try
end;

{$IFDEF MSWINDOWS}
{ private TMain.PowerBroadcast

  Event that is called after wakeup (after suspending). }

procedure TMain.PowerBroadcast(var AMsg: TMessage);
begin
  if (AMsg.WParam = PBT_APMRESUMESUSPEND) then
    FClock.Time := Time();
end;
{$ENDIF}

{ private TMain.SaveToIni

  Stores current configuration to config file. }

procedure TMain.SaveToIni();
var
  Config: TConfigFile;

begin
  // Language file could not be found?
  if not Assigned(FLang) then
    Exit;

  try
    Config := TConfigFile.Create(FConfigPath);

    try
      // Save anything?
      if mmSave.Checked then
      begin
      {$IFDEF MSWINDOWS}
        Config.WriteInteger(Config.SectionGlobal, Config.IdLocale, FLang.Locale);
      {$ELSE}
        Config.WriteString(Config.SectionGlobal, Config.IdLocale, FLang.Locale);
      {$ENDIF}
        Config.WriteBool(Config.SectionGlobal, Config.IdSave, True);
        Config.WriteBool(Config.SectionGlobal, Config.IdTimerMode, mmTimer.Checked);

        // Save position?
        if Config.ReadBool(Config.SectionGlobal, Config.IdSavePos, False) then
        begin
          Config.WriteInteger(Config.SectionGlobal, Config.IdLeft, Left);
          Config.WriteInteger(Config.SectionGlobal, Config.IdTop, Top);
        end;  //of begin

        // Save time input?
        if Config.ReadBool(Config.SectionGlobal, Config.IdSaveClock, True) then
        begin
          if (eHour.Text <> '') then
            Config.WriteString(Config.SectionAlert, Config.IdHour, eHour.Text);

          if (eMin.Text <> '') then
            Config.WriteString(Config.SectionAlert, Config.IdMinute, eMin.Text);
        end;  //of if

        // Save current text input
        if Config.ReadBool(Config.SectionGlobal, Config.IdSaveText, True) then
          Config.WriteString(Config.SectionAlert, Config.IdText, pText.Caption);

        // Save current selected sound?
        if Config.ReadBool(Config.SectionGlobal, Config.IdSaveSound, True) then
          Config.WriteInteger(Config.SectionAlert, Config.IdSound, rgSounds.ItemIndex);

        // Save current selected color
        if Config.ReadBool(Config.SectionGlobal, Config.IdSaveColor, True) then
          Config.WriteColor(Config.SectionAlert, Config.IdColor, FColor);

        // Save current checks
        Config.WriteBool(Config.SectionAlert, Config.IdBlink, cbBlink.Checked);
        Config.WriteBool(Config.SectionAlert, Config.IdShowText, cbText.Checked);
      end  //of begin
      else
        // Do not save anything
        Config.WriteBool(Config.SectionGlobal, Config.IdSave, False);

    finally
      Config.Free;
    end;  //of try

  except
    on E: Exception do
    begin
      ExceptionDlg(FLang, FLang.Format(LID_STORING_CONFIG_FAILED, [FConfigPath]),
        E.Message);
    end;
  end;  //of try
end;

{ private TMain.SetLanguage

  Updates all component captions with new language text. }

procedure TMain.LanguageChanged();
var
  i: Byte;

begin
  inherited LanguageChanged();

  with FLang do
  begin
    // Set captions for TMenuItems
    mmFile.Caption := GetString(LID_FILE);
    mmSave.Caption := GetString(LID_SETTINGS_STORE);
    mmEdit.Caption := GetString(LID_EDIT);
    mmOptions.Caption := GetString(LID_SETTINGS);
    mmTimer.Caption := GetString(LID_MODE_TIMER);
    mmCounter.Caption := GetString(LID_MODE_COUNTER);
    mmView.Caption := GetString(LID_VIEW);
    lCopy.Hint := GetString(LID_TO_WEBSITE);

    // Set captions for "alert type" TRadioGroup
    rgSounds.Caption := GetString(LID_ALERT_SELECTION);

    for i := 0 to rgSounds.Items.Count - 1 do
      rgSounds.Items[i] := GetString(i + LID_SOUND_CLOCK);

    // Set captions for "at alert" TGroupBox
    gpOther.Caption := GetString(LID_ALERT_EVENT);
    cbBlink.Caption := GetString(LID_BLINK);
    bColor.Caption := GetString(LID_COLOR);
    cbText.Caption := GetString(LID_SHOW_TEXT);
    bChange.Caption := GetString(LID_CHANGE_TEXT);

    // Set captions for buttons
    bAlert.Caption := GetString(LID_ALERT_ON);
    bStop.Caption := GetString(LID_ALERT_OFF);

    // Set captions for TPopupMenu items
    pmOpen.Caption := GetString(LID_OPEN);
    pmClose.Caption := GetString(LID_CLOSE);
  end;  //of with
end;

procedure TMain.ShowAlertTime();
begin
  eHour.Text := FClock.Alert.HourToString();
  eMin.Text := FClock.Alert.MinuteToString();
end;

function TMain.ShowOptionsDialog(): Boolean;
var
  Options: TOptions;

begin
  Options := TOptions.Create(Self, FClock, FLang, FConfigPath);

  try
    Result := (Options.ShowModal() = mrOk);

  finally
    FreeAndNil(Options);
  end;  //of try
end;

{ TMain.Blink

  Event that is called by Timer while alert is in progress. }

procedure TMain.Blink(Sender: TObject);
begin
  if not cbBlink.Checked then
    Exit;

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
  if (MessageDlg(FLang.GetString([LID_CLOSE_CONFIRM1, LID_CLOSE_CONFIRM2]),
    mtConfirmation, mbYesNo, 0) = IDYES) then
  begin
    bStop.Click;
    Close;
  end;  //of begin
end;

{ TMain.pmOpenClick

  PopMenu entry that opens Game Wake. }

procedure TMain.pmOpenClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  BringToFront();
end;

{ TMain.bIncHourClick

  Increments hours by 1. }

procedure TMain.bIncHourClick(Sender: TObject);
begin
  FClock.Alert := IncHour(FClock.Alert);
  ShowAlertTime();
end;

{ TMain.bDecHourClick

  Decrements hours by 1. }

procedure TMain.bDecHourClick(Sender: TObject);
begin
  FClock.Alert := IncHour(FClock.Alert, -1);
  ShowAlertTime();
end;

{ TMain.bIncMinClick

  Increments minutes by 1. }

procedure TMain.bIncMinClick(Sender: TObject);
begin
  FClock.Alert := IncMinute(FClock.Alert);
  ShowAlertTime();
end;

{ TMain.bDecMinClick

  Decrements minutes by 1. }

procedure TMain.bDecMinClick(Sender: TObject);
begin
  FClock.Alert := IncMinute(FClock.Alert, -1);
  ShowAlertTime();
end;

{ TMain.bPlayClockClick

  Plays a the bell sound as preview. }

procedure TMain.bPlayClockClick(Sender: TObject);
begin
  atClock.PlayAlarmSound();
end;

{ TMain.bPlayHornClick

  Plays a the horn sound as preview. }

procedure TMain.bPlayHornClick(Sender: TObject);
begin
  atSiren.PlayAlarmSound();
end;

{ TMain.bPlayBingClick

  Plays a the bing sound as preview. }

procedure TMain.bPlayBingClick(Sender: TObject);
begin
  atBing.PlayAlarmSound();
end;

{ TMain.bPlayBeepClick

  Plays a the beep sound as preview. }

procedure TMain.bPlayBeepClick(Sender: TObject);
begin
  atBeep.PlayAlarmSound();
end;

{ TMain.eHourKeyPress

  Event that is called when user edits time and presses a key. }

procedure TMain.eHourKeyPress(Sender: TObject; var Key: Char);
begin
  // Only allow digits and backspace
  if not CharInSet(Key, ['0'..'9', Char(VK_BACK)]) then
  begin
    SysUtils.Beep();
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
      eHour.Text := FClock.Alert.HourToString();
      eMin.SetFocus;
    end;  //of begin

  except
    on E: EConvertError do
      eHour.Text := FClock.Alert.HourToString();
  end;  //of try
end;

{ TMain.eMinKeyUp

  Event that is called when user edits minutes and a key is released. }

procedure TMain.eMinKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  try
    if ((Length(eMin.Text) = 2) and not (Key in [VK_RIGHT, VK_LEFT])) then
    begin
      FClock.Alert.SetMinute(StrToInt(eMin.Text));
      eMin.Text := FClock.Alert.MinuteToString();
    end;  //of begin

  except
    on E: EConvertError do
      eMin.Text := FClock.Alert.MinuteToString();
  end;  //of try
end;

{ TMain.bAlertClick

  Event that is called when user sets alert. }

procedure TMain.bAlertClick(Sender: TObject);
begin
  // Try to set alert time
  try
    FClock.Alert.SetTime(StrToInt(eHour.Text), StrToInt(eMin.Text));
    ShowAlertTime();

    // Start alert
    FClock.AlertEnabled := True;

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

    MessageDlg(FLang.Format(LID_ALERT_CONFIRM, [FClock.Alert.ToString(False)]),
      mtInformation, [mbOK], 0);

  except
    on E: EConvertError do
      MessageDlg(FLang.GetString(LID_ALERT_INVALID), mtWarning, [mbOK], 0);

    on E: EAssertionFailed do
      // TODO: Improve message
      MessageDlg(FLang.GetString(LID_ALERT_INVALID), mtWarning, [mbOK], 0);
  end;  //of try
end;

{ TMain.bStopClick

  Event that is called when user stops alert. }

procedure TMain.bStopClick(Sender: TObject);
begin
  // Stop playing sound
  if Assigned(FAlertThread) then
  begin
    FAlertThread.Terminate();
    FAlertThread := nil;
  end;  //of begin

  // Disable alert
  FClock.AlertEnabled := False;

  if mmCounter.Checked then
  begin
    FClock.Time := 0;
    lHour.Caption := FClock.Time.ToString();
  end;  //of begin

  // Reset GUI
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

  MessageDlg(FLang.GetString(LID_ALERT_CANCELED), mtInformation, [mbOK], 0);
end;

{ TMain.bColorClick

  Shows a TColorDialog for choosing a blink color. }

procedure TMain.bColorClick(Sender: TObject);
var
  ColorDialog: TColorDialog;
  Config: TConfigFile;
  SaveColor: Boolean;
  Colors: array[0..15] of string;
  i: Byte;

begin
  Config := TConfigFile.Create(FConfigPath);

  try
    try
      SaveColor := Config.ReadBool(Config.SectionGlobal, Config.IdSaveColor, True);
      Config.ReadColors(Colors);

      // Init TColorDialog
      ColorDialog := TColorDialog.Create(Self);

      try
        // Select current color
        ColorDialog.Color := FColor;

        // Load stored custom colors?
        if (mmSave.Checked and SaveColor) then
          for i := Low(Colors) to High(Colors) do
            ColorDialog.CustomColors.Insert(i, Config.IdColor + Chr(Ord('A') + i) +'='+ Colors[i]);

        // Action "Ok" was called
        if ColorDialog.Execute then
        begin
          FColor := ColorDialog.Color;

          if (mmSave.Checked and SaveColor) then
          begin
            for i := Low(Colors) to High(Colors) do
              Colors[i] := ColorDialog.CustomColors.Values[Config.IdColor + Chr(Ord('A') + i)];

            // Write custom colors to config file
            Config.WriteColors(Colors);
          end;  //of begin
        end;  //of begin

      finally
        ColorDialog.Free;
      end;  //of try

    finally
      Config.Free;
    end;  //of try

  except
    on E: Exception do
      ExceptionDlg(FLang, FLang.GetString(LID_COLORS_INVALID), E.Message);
  end;  //of try
end;

{ TMain.bChangeClick

  Shows a InputBox for setting up the text message. }

procedure TMain.bChangeClick(Sender: TObject);
var
  UserInput: string;

begin
  UserInput := InputBox(FLang.GetString(LID_TEXT_CAPTION),
    FLang.Strings[LID_TEXT_PROMPT], pText.Caption);

  // Text length maximum 16 characters
  if (Length(UserInput) > 16) then
  begin
    MessageDlg(FLang.GetString([LID_TEXT_TOO_LONG1, LID_TEXT_TOO_LONG2]),
      mtWarning, [mbOK], 0);
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
  // Show options dialog after checking
  if not mmSave.Checked then
    mmSave.Checked := ShowOptionsDialog()
  else
    mmSave.Checked := False;

  // Options only available if settings should be saved
  mmOptions.Enabled := mmSave.Checked;
end;

{ TMain.mmOptionsClick

  MainMenu entry that allows to edit the configuration. }

procedure TMain.mmOptionsClick(Sender: TObject);
begin
  ShowOptionsDialog();
end;

{ TMain.mmTimerClick

  MainMenu entry that allows to change the current mode to Timer. }

procedure TMain.mmTimerClick(Sender: TObject);
begin
  if not mmTimer.Checked then
  begin
    mmCounter.Checked := False;
    mmTimer.Checked := True;
    FClock.TimerMode := True;
    ShowAlertTime();
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
    FClock.TimerMode := False;
    lHour.Caption := FClock.Time.ToString();
    ShowAlertTime();
    eHour.SetFocus;
  end;  //of begin
end;

procedure TMain.mmLangClick(Sender: TObject);
var
  i: Integer;

begin
  for i := 0 to mmLang.Count - 1 do
  {$IFDEF MSWINDOWS}
    mmLang.Items[i].Checked := (mmLang.Items[i].Tag = FLang.Locale);
  {$ELSE}
    mmLang.Items[i].Checked := (mmLang.Items[i].Hint = FLang.Locale);
  {$ENDIF}
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

  try
    // Show tray icon
    with TrayIcon do
    begin
      Hint := Application.Title +' - '+ FLang.Format(LID_ALERT_AT, [FClock.Alert.ToString(False)]);
    {$IFDEF MSWINDOWS}
      Icon.Handle := Application.Icon.Handle;
    {$ELSE}
      Icon.LoadFromResourceName(HINSTANCE, 'MAINICON');
    {$ENDIF}
      Visible := True;
    end;  //of with

    // Hide form
    Hide();

  except
    on E: Exception do
    begin
      Show();
      ExceptionDlg(FLang, FLang.GetString(LID_TRAY_CREATION_FAILED), E.Message);
    end;
  end;  //of try

  CanClose := False;
end;

end.

