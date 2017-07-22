{ *********************************************************************** }
{                                                                         }
{ Game Wake API Interface Unit                                            }
{                                                                         }
{ Copyright (c) 2011-2017 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeAPI;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
{$IFNDEF MSWINDOWS}
  Process,
{$ELSE}
  Windows, MMSystem,
{$ENDIF}
  DateUtils, SysUtils, Classes, ExtCtrls, Graphics, IniFiles;

const
  SOUND_PATH = {$IFDEF MSWINDOWS}''{$ELSE}'/usr/lib/gamewake/'{$ENDIF};

type
  /// <summary>
  ///   Manages the configuration file.
  /// </summary>
  TConfigFile = class(TIniFile)
  public
    const
      SectionGlobal = 'Global';
      SectionAlert  = 'Alert';
      SectionColors = 'CustomColors';
      IdSave        = 'Save';
      IdSaveClock   = 'SaveClock';
      IdHour        = 'Hour';
      IdMinute      = 'Min';
      IdSaveText    = 'SaveText';
      IdText        = 'Text';
      IdShowText    = 'ShowText';
      IdSaveSound   = 'SaveSound';
      IdSound       = 'Sound';
      IdSaveColor   = 'SaveColor';
      IdColor       = 'Color';
      IdSavePos     = 'SavePos';
      IdTop         = 'Top';
      IdLeft        = 'Left';
      IdBlink       = 'Blink';
      IdLocale      = 'Locale';
      IdTimerMode   = 'TimerMode';
    {$IFDEF MSWINDOWS}
      IdAutoUpdate  = 'AutoUpdate';
    {$ENDIF}
    /// <summary>
    ///   Reads a color from the configuration file.
    /// </summary>
    /// <param name="ASection">
    ///   The section to load the color from.
    /// </param>
    /// <param name="AKey">
    ///   The key to load the color from.
    /// </param>
    /// <param name="ADefault">
    ///   The color to use if reading failed.
    /// </param>
    /// <returns>
    ///   The color.
    /// </returns>
    function ReadColor(const ASection, AKey: string; ADefault: TColor): TColor;

    /// <summary>
    ///   Reads an array of custom colors from the configuration file.
    /// </summary>
    /// <param name="AArray">
    ///   The array containing the colors.
    /// </param>
    procedure ReadColors(var AArray: array of string);

    /// <summary>
    ///   Writes a color to the configuration file.
    /// </summary>
    /// <param name="ASection">
    ///   The section to store the value.
    /// </param>
    /// <param name="AKey">
    ///   The key to store the value.
    /// </param>
    /// <param name="AColor">
    ///   The color.
    /// </param>
    procedure WriteColor(const ASection, AKey: string; AColor: TColor);

    /// <summary>
    ///   Writes an array of custom colors to the configuration file.
    /// </summary>
    /// <param name="AArray">
    ///   The array containing the colors.
    /// </param>
    procedure WriteColors(const AArray: array of string);
  end;

  TTimeHelper = record helper for TTime
    const
      /// <summary>
      ///   Two digit format to add a leading zero to values between 0 and 9.
      /// </summary>
      TwoDigitFormat = '%.2d';

    /// <summary>
    ///   Checks if a given time is equal to current time ignoring milliseconds.
    /// </summary>
    /// <param name="ATime">
    ///   The time to check.
    /// </param>
    /// <returns>
    ///   <c>True</c> if both times are equal except milliseconds or <c>False</c>
    ///   otherwise.
    /// </returns>
    function EqualsInSeconds(const ATime: TTime): Boolean;

    /// <summary>
    ///   Decodes the hour.
    /// </summary>
    /// <returns>
    ///   The hour.
    /// </returns>
    function Hour(): Word; inline;

    /// <summary>
    ///   Decodes the hour and converts it to a string.
    /// </summary>
    /// <returns>
    ///   The hour as string.
    /// </returns>
    function HourToString(): string; inline;

    /// <summary>
    ///   Decodes the minute.
    /// </summary>
    /// <returns>
    ///   The minute.
    /// </returns>
    function Minute(): Word; inline;

    /// <summary>
    ///   Decodes the minute and converts it to a string.
    /// </summary>
    /// <returns>
    ///   The minute as string.
    /// </returns>
    function MinuteToString(): string; inline;

    /// <summary>
    ///   Decodes the second.
    /// </summary>
    /// <returns>
    ///   The second.
    /// </returns>
    function Second(): Word; inline;

    /// <summary>
    ///   Decodes the second and converts it to a string.
    /// </summary>
    /// <returns>
    ///   The second as string.
    /// </returns>
    function SecondToString(): string; inline;

    /// <summary>
    ///   Changes the time.
    /// </summary>
    /// <param name="AHour">
    ///   The hour.
    /// </param>
    /// <param name="AMinute">
    ///   The minute.
    /// </param>
    /// <param name="ASecond">
    ///   Optional: The second.
    /// </param>
    procedure SetTime(const AHour, AMinute: Word; const ASecond: Word = 0); inline;

    /// <summary>
    ///   Changes the hour.
    /// </summary>
    /// <param name="AHour">
    ///   The hour.
    /// </param>
    procedure SetHour(const AHour: Word); inline;

    /// <summary>
    ///   Changes the minute.
    /// </summary>
    /// <param name="AMinute">
    ///   The minute.
    /// </param>
    procedure SetMinute(const AMinute: Word); inline;

    /// <summary>
    ///   Changes the second.
    /// </summary>
    /// <param name="ASecond">
    ///   The second.
    /// </param>
    procedure SetSecond(const ASecond: Word); inline;

    /// <summary>
    ///   Converts the time to a string.
    /// </summary>
    /// <param name="ALongFormat">
    ///   Optional: Set to <c>True</c> to use a HH:MM:SS format or set to
    ///   <c>False</c> to use a HH:MM format.
    /// </param>
    /// <returns>
    ///   The time as string.
    /// </returns>
    function ToString(const ALongFormat: Boolean = True): string; inline;
  end;

  /// <summary>
  ///   An alarm clock which supports a timer and counter mode.
  /// </summary>
  TClock = class(TObject)
  private
    FTimer: TTimer;
    FAlertEnabled,
    FTimerMode: Boolean;
    FTime,
    FAlertTime: TTime;
    FOnCounting,
    FOnAlert: TNotifyEvent;
    procedure Count(Sender: TObject);
    procedure SetAlertEnabled(const AAlertEnabled: Boolean);
    procedure SetTimerMode(const ATimerMode: Boolean);
    procedure SetAlertTime(const AAlertTime: TTime);
    procedure SetTime(const ATime: TTime);
  public
    /// <summary>
    ///   Constructor for creating a <c>TClock</c> instance.
    /// </summary>
    /// <param name="ATimerMode">
    ///   Set to <c>True</c> to use a default clock or set to <c>False</c> to
    ///   use a counter.
    /// </param>
    constructor Create(ATimerMode: Boolean);

    /// <summary>
    ///   Destructor for destroying a <c>TClock</c> instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Gets or sets the alarm time.
    /// </summary>
    property Alert: TTime read FAlertTime write SetAlertTime;

    /// <summary>
    ///   Enables or disables the alarm clock.
    /// </summary>
    property AlertEnabled: Boolean read FAlertEnabled write SetAlertEnabled;

    /// <summary>
    ///   Occurs when <see cref="Time"/> equals <see cref="Alert"/>.
    /// </summary>
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;

    /// <summary>
    ///   Occurs when current time is incremented.
    /// </summary>
    property OnCounting: TNotifyEvent read FOnCounting write FOnCounting;

    /// <summary>
    ///   Gets or sets the current time.
    /// </summary>
    property Time: TTime read FTime write SetTime;

    /// <summary>
    ///   Use a timer or a counter.
    /// </summary>
    /// <remarks>
    ///   Set to <c>True</c> to use a default clock or set to <c>False</c> to
    ///   use a counter.
    /// </remarks>
    property TimerMode: Boolean read FTimerMode write SetTimerMode;
  end;

  /// <summary>
  ///   Possible alert sounds.
  /// </summary>
  TAlertSound = (atClock, atHorn, atBing, atBeep);

  TAlertSoundHelper = record helper for TAlertSound
    /// <summary>
    ///   Plays the alarm sound.
    /// </summary>
    /// <param name="ASynchronized">
    ///   Optional: Set to <c>True</c> to wait until the sound is finished or
    ///   <c>False</c> to immediately return.
    /// </param>
    /// <returns>
    ///   <c>True</c> if sound was successfully played or <c>False</c> otherwise.
    /// </returns>
    function PlayAlarmSound(ASynchronized: Boolean = False): Boolean;
  end;

  /// <summary>
  ///   Plays an alarm sound in a loop.
  /// </summary>
  /// <remarks>
  ///   Sound automatically stops playing after 1 minute.
  /// </remarks>
  TAlertThread = class(TThread)
  private
    FAlertSound: TAlertSound;
    FOnAlert: TNotifyEvent;
    procedure DoNotifyOnAlert();
  protected
    procedure Execute(); override;
  public
    /// <summary>
    ///   Constructor for creating a <c>TAlertThread</c> instance.
    /// </summary>
    /// <param name="AAlertSound">
    ///   The alarm sound to play.
    /// </param>
    constructor Create(AAlertSound: TAlertSound);

    /// <summary>
    ///   Occurs while sound is playing.
    /// </summary>
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
  end;

/// <summary>
///   Plays a .wav file.
/// </summary>
/// <param name="AFileName">
///   The .wav file to play.
/// </param>
/// <param name="ASynchronized">
///   Set to <c>True</c> to wait until the sound is finished or <c>False</c>
///   to immediately return.
/// </param>
/// <returns>
///   <c>True</c> if sound was successfully played or <c>False</c> otherwise.
/// </returns>
function PlaySound(const AFileName: string; ASynchronized: Boolean = False): Boolean;

/// <summary>
///   Shutdown PC.
/// </summary>
procedure Shutdown();

implementation

function PlaySound(const AFileName: string; ASynchronized: Boolean = False): Boolean;
var
{$IFNDEF MSWINDOWS}
  Process: TProcess;
{$ELSE}
  Flags: DWORD;
{$ENDIF}

begin
  if (AFileName = '') then
    Exit(False);

{$IFDEF MSWINDOWS}
  if ASynchronized then
    Flags := SND_SYNC
  else
    Flags := SND_ASYNC;

  // Add volume slider in system tray
  if CheckWin32Version(6) then
    Inc(Flags, SND_SENTRY);

  Result := MMSystem.PlaySound(PChar(AFileName), 0, Flags or SND_FILENAME);
{$ELSE}
  Process := TProcess.Create(nil);

  try
    Process.Executable := '/usr/bin/aplay';
    Process.Parameters.Append(AFileName);

    if ASynchronized then
      Process.Options := Process.Options + [poWaitOnExit];

   Process.Execute();
   Result := True;

  finally
    Process.Free;
  end;  //of try
{$ENDIF}
end;

procedure Shutdown();
{$IFNDEF MSWINDOWS}
const
  SHUTDOWN_INITD_BIN   = '/usr/bin/dbus-send';
  SHUTDOWN_SYSTEMD_BIN = '/bin/systemctl';

var
  Process: TProcess;

begin
  Process := TProcess.Create(nil);

  try
    // systemd Linux?
    if FileExists(SHUTDOWN_SYSTEMD_BIN) then
    begin
      Process.Executable := SHUTDOWN_SYSTEMD_BIN;
      Process.Parameters.Append('poweroff');
    end  //of begin
    else
      if FileExists(SHUTDOWN_INITD_BIN) then
      begin
        Process.Executable := SHUTDOWN_INITD_BIN;

        with Process.Parameters do
        begin
          Append('--system');
          Append('--print-reply');
          Append('--dest=org.freedesktop.ConsoleKit');
          Append('/org/freedesktop/ConsoleKit/Manager');
          Append('org.freedesktop.ConsoleKit.Manager.Stop');
        end;  //of with
      end  //of begin
      else
        raise EOSError.Create('No program found to shutdown');

    Process.Execute();

  finally
    Process.Free;
  end;  //of try
end;
{$ELSE}
const
  SE_SHUTDOWN_NAME               = 'SeShutdownPrivilege';
  SHTDN_REASON_MAJOR_APPLICATION = $00040000;
  SHTDN_REASON_MINOR_MAINTENANCE = 1;

var
  TokenHandle: THandle;
  NewState: TTokenPrivileges;
  ReturnLength: DWORD;
  Luid: TLargeInteger;

begin
  if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, TokenHandle) then
    raise EOSError.Create(SysErrorMessage(GetLastError()));

  try
    // Get LUID of shutdown privilege
    if not LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, Luid) then
      raise EOSError.Create(SysErrorMessage(GetLastError()));

    // Enable shutdown privilege
    with NewState do
    begin
      PrivilegeCount := 1;
      Privileges[0].Luid := Luid;
      Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    end;  //of with

    if not AdjustTokenPrivileges(TokenHandle, False, NewState, 0, nil, ReturnLength) then
      raise EOSError.Create(SysErrorMessage(GetLastError()));

    // Shutdown
    if not ExitWindowsEx(EWX_SHUTDOWN or EWX_FORCE, SHTDN_REASON_MAJOR_APPLICATION or
      SHTDN_REASON_MINOR_MAINTENANCE) then
      raise EOSError.Create(SysErrorMessage(GetLastError()));

  finally
    CloseHandle(TokenHandle);
  end;  //of try
end;
{$ENDIF}

{ TConfigFile }

function TConfigFile.ReadColor(const ASection, AKey: string; ADefault: TColor): TColor;
begin
  Result := StringToColor(ReadString(ASection, AKey, ColorToString(ADefault)));
end;

procedure TConfigFile.ReadColors(var AArray: array of string);
var
  i: Byte;

begin
  for i := Low(AArray) to High(AArray) do
    AArray[i] := ReadString(SectionColors, IdColor + IntToStr(i), '');
end;

procedure TConfigFile.WriteColor(const ASection, AKey: string; AColor: TColor);
begin
  WriteString(ASection, AKey, ColorToString(AColor));
end;

procedure TConfigFile.WriteColors(const AArray: array of string);
var
  i: Byte;

begin
  for i := Low(AArray) to High(AArray) do
    WriteString(SectionColors, IdColor + IntToStr(i), AArray[i]);
end;


{ TTimeHelper }

function TTimeHelper.EqualsInSeconds(const ATime: TTime): Boolean;
var
  Hour1, Hour2, Min1, Min2, Sec1, Sec2, Msec: Word;

begin
  DecodeTime(Self, Hour1, Min1, Sec1, Msec);
  DecodeTime(ATime, Hour2, Min2, Sec2, Msec);
  Result := ((Hour1 = Hour2) and (Min1 = Min2) and (Sec1 = Sec2));
end;

function TTimeHelper.Hour(): Word;
var
  Min, Sec, Msec: Word;

begin
  DecodeTime(Self, Result, Min, Sec, Msec);
end;

function TTimeHelper.HourToString(): string;
begin
  Result := Format(TwoDigitFormat, [Hour()]);
end;

function TTimeHelper.Minute(): Word;
var
  Hour, Sec, Msec: Word;

begin
  DecodeTime(Self, Hour, Result, Sec, Msec);
end;

function TTimeHelper.MinuteToString(): string;
begin
  Result := Format(TwoDigitFormat, [Minute()]);
end;

function TTimeHelper.Second(): Word;
var
  Hour, Min, Msec: Word;

begin
  DecodeTime(Self, Hour, Min, Result, Msec);
end;

function TTimeHelper.SecondToString(): string;
begin
  Result := Format(TwoDigitFormat, [Second()]);
end;

procedure TTimeHelper.SetHour(const AHour: Word);
begin
  Self := EncodeTime(AHour, Minute(), 0 , 0);
end;

procedure TTimeHelper.SetMinute(const AMinute: Word);
begin
  Self := EncodeTime(Hour(), AMinute, 0 , 0);
end;

procedure TTimeHelper.SetSecond(const ASecond: Word);
begin
  Self := EncodeTime(Hour(), Minute(), ASecond , 0);
end;

procedure TTimeHelper.SetTime(const AHour, AMinute: Word; const ASecond: Word = 0);
begin
  Self := EncodeTime(AHour, AMinute, ASecond, 0);
end;

function TTimeHelper.ToString(const ALongFormat: Boolean = True): string;
begin
  if ALongFormat then
    Result := FormatDateTime('tt', Self)
  else
    Result := FormatDateTime('t', Self);
end;


{ TClock }

constructor TClock.Create(ATimerMode: Boolean);
begin
  inherited Create;
  FAlertEnabled := False;

  // Init TTimer
  FTimer := TTimer.Create(nil);

  with FTimer do
  begin
    OnTimer := Count;
    Interval := 1000;
    Enabled := ATimerMode;
  end;  //of with

  SetTimerMode(ATimerMode);
end;

destructor TClock.Destroy;
begin
  FreeAndNil(FTimer);
  inherited Destroy;
end;

procedure TClock.Count(Sender: TObject);
begin
  FTime := IncSecond(FTime);

  if Assigned(FOnCounting) then
    FOnCounting(Self);

  if FAlertEnabled then
  begin
    // Current time matches alert time: Call alert!
    if FTime.EqualsInSeconds(FAlertTime) then
    begin
      // Stop TTimer in counter mode
      if not FTimerMode then
        FTimer.Enabled := False;

      if Assigned(FOnAlert) then
        FOnAlert(Self);
    end;  //of begin
  end; //of begin
end;

procedure TClock.SetAlertEnabled(const AAlertEnabled: Boolean);
begin
  if (AAlertEnabled and not FTimerMode and FTime.EqualsInSeconds(FAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FAlertEnabled := AAlertEnabled;

  // Start/Stop TTimer in counter mode
  if not FTimerMode then
    FTimer.Enabled := AAlertEnabled;
end;

procedure TClock.SetAlertTime(const AAlertTime: TTime);
begin
  if (FAlertEnabled and not FTimerMode and FTime.EqualsInSeconds(AAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FAlertTime := AAlertTime;
end;

procedure TClock.SetTime(const ATime: TTime);
begin
  if (FAlertEnabled and not FTimerMode and ATime.EqualsInSeconds(FAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FTime := ATime;
end;

procedure TClock.SetTimerMode(const ATimerMode: Boolean);
begin
  FTimerMode := ATimerMode;
  FTimer.Enabled := ATimerMode;

  if ATimerMode then
    FTime := SysUtils.Time()
  else
    FTime := 0;
end;


{ TAlertSoundHelper }

function TAlertSoundHelper.PlayAlarmSound(ASynchronized: Boolean = False): Boolean;
{$IFDEF MSWINDOWS}
const
  Synchronous: array[Boolean] of DWORD = (SND_ASYNC, SND_SYNC);
{$ENDIF}

var
  Sound: string;

begin
{$IFDEF MSWINDOWS}
  if (Self = atBing) then
  begin
    // Play default Windows sound
    Exit(MMSystem.PlaySound(PChar(SND_ALIAS_SYSTEMDEFAULT), 0,
      Synchronous[ASynchronized] or SND_ALIAS_ID or SND_SENTRY));
  end;  //of begin
{$ENDIF}

  case Self of
    atClock: Sound := 'bell';
    atHorn:  Sound := 'horn';
    atBing:  Sound := 'bing';
    atBeep:  Sound := 'beep';
    else     Exit(False);
  end;  //of case

{$IFDEF PORTABLE}
  Result := MMSystem.PlaySound(PChar(Sound), HInstance, Synchronous[ASynchronized] or
    SND_RESOURCE or SND_SENTRY);
{$ELSE}
  if (SOUND_PATH <> '') then
    Sound := IncludeTrailingPathDelimiter(SOUND_PATH) + Sound;

  Result := PlaySound(ChangeFileExt(Sound, '.wav'), ASynchronized);
{$ENDIF}
end;


{ TAlertThread }

constructor TAlertThread.Create(AAlertSound: TAlertSound);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FAlertSound := AAlertSound;
end;

procedure TAlertThread.DoNotifyOnAlert();
begin
  if Assigned(FOnAlert) then
    FOnAlert(Self);
end;

procedure TAlertThread.Execute();
var
  AlertEndTime: TTime;

begin
  // Stop alarm after 1 minute
  AlertEndTime := IncMinute(Time());

  while not Terminated do
  begin
    Synchronize(DoNotifyOnAlert);
    FAlertSound.PlayAlarmSound(True);

    if (Time() >= AlertEndTime) then
      Break;
  end;  //of begin
end;

end.

