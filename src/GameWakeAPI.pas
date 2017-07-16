{ *********************************************************************** }
{                                                                         }
{ Game Wake API Interface Unit                                            }
{                                                                         }
{ Copyright (c) 2011-2017 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeAPI;

{$IFDEF FPC}{$mode delphi}{$ENDIF}

interface

uses
{$IFNDEF MSWINDOWS}
  Process,
{$ELSE}
  Windows, MMSystem,
{$ENDIF}
  DateUtils, SysUtils, Classes, ExtCtrls, Graphics, IniFiles;

type
  { TConfigFile }
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
    function ReadColor(const ASection, AKey: string; ADefault: TColor): TColor;
    procedure ReadColors(var AArray: array of string);
    procedure WriteColor(const ASection, AKey: string; AColor: TColor);
    procedure WriteColors(const AArray: array of string);
  end;

  { TTimeHelper }
  TTimeHelper = record helper for TTime
    const
      TwoDigitFormat = '%.2d';

    function Hour(): Word; inline;
    function HourToString(): string; inline;
    function Minute(): Word; inline;
    function MinuteToString(): string; inline;
    function Second(): Word; inline;
    function SecondToString(): string; inline;
    procedure SetTime(const AHour, AMinute: Word; const ASecond: Word = 0); inline;
    procedure SetHour(const AHour: Word); inline;
    procedure SetMinute(const AMinute: Word); inline;
    procedure SetSecond(const ASecond: Word); inline;
    function ToString(const ALongFormat: Boolean = True): string; inline;
  end;

  { TAlertType }
  TAlertType = (atClock, atHorn, atBing, atBeep, atShutdown, atNone);

  TAlertSound = atClock..atBeep;

  { TClock }
  TClock = class(TObject)
  private
    FTimer: TTimer;
    FAlertType: TAlertType;
    FAlertThread: TThread;
    FAlertEnabled,
    FTimerMode: Boolean;
    FTime,
    FAlertTime: TTime;
    FOnCounting,
    FOnAlertBegin,
    FOnAlert,
    FOnAlertEnd: TNotifyEvent;
    FSoundPath: string;
    procedure Count(Sender: TObject);
    function IsSameTime(const ATime1, ATime2: TTime): Boolean; inline;
    procedure SetAlertEnabled(const AAlertEnabled: Boolean);
    procedure SetTimerMode(const ATimerMode: Boolean);
    procedure SetAlertTime(const AAlertTime: TTime);
    procedure SetTime(const ATime: TTime);
  public
    constructor Create(ATimerMode: Boolean);
    destructor Destroy; override;
    function PlaySound(const AFileName: string; ASynchronized: Boolean = False): Boolean; overload;
    function PlaySound(AAlertSound: TAlertSound; ASynchronized: Boolean = False): Boolean; overload;
    { external }
    property Alert: TTime read FAlertTime write SetAlertTime;
    property AlertEnabled: Boolean read FAlertEnabled write SetAlertEnabled;
    property AlertType: TAlertType read FAlertType write FAlertType;
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
    property OnAlertBegin: TNotifyEvent read FOnAlertBegin write FOnAlertBegin;
    property OnAlertEnd: TNotifyEvent read FOnAlertEnd write FOnAlertEnd;
    property OnCounting: TNotifyEvent read FOnCounting write FOnCounting;
    property SoundPath: string read FSoundPath write FSoundPath;
    property Time: TTime read FTime write SetTime;
    property TimerMode: Boolean read FTimerMode write SetTimerMode;
  end;

  { TAlertThread }
  TAlertThread = class(TThread)
  private
    FClock: TClock;
    FAlertSound: TAlertSound;
    FOnAlert: TNotifyEvent;
    procedure DoNotifyOnAlert();
  protected
    procedure Execute(); override;
  public
    constructor Create(AClock: TClock; AAlertSound: TAlertSound);
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
  end;

implementation

{ TConfigFile }

{ public TConfigFile.ReadColor

  Reads a TColor value from config . }

function TConfigFile.ReadColor(const ASection, AKey: string; ADefault: TColor): TColor;
begin
  Result := StringToColor(ReadString(ASection, AKey, ColorToString(ADefault)));
end;

{ public TConfigFile.ReadColors

  Returns an array containing all saved custom colors from config file. }

procedure TConfigFile.ReadColors(var AArray: array of string);
var
  i: Byte;

begin
  for i := Low(AArray) to High(AArray) do
    AArray[i] := ReadString(SectionColors, IdColor + IntToStr(i), '');
end;

{ public TConfigFile.WriteColor

  Writes a TColor value into config file. }

procedure TConfigFile.WriteColor(const ASection, AKey: string; AColor: TColor);
begin
  WriteString(ASection, AKey, ColorToString(AColor));
end;

{ public TConfigFile.WriteColors

  Writes an array containing all saved custom colors into config file. }

procedure TConfigFile.WriteColors(const AArray: array of string);
var
  i: Byte;

begin
  for i := Low(AArray) to High(AArray) do
    WriteString(SectionColors, IdColor + IntToStr(i), AArray[i]);
end;


{ TTimeHelper }

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

{ public TClock.Create

  Constructor for creating a TClock instance. }

constructor TClock.Create(ATimerMode: Boolean);
begin
  inherited Create;
  FAlertEnabled := False;
  FAlertType := atClock;
  FAlertThread := nil;

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

{ public TClock.Destroy

  Destructor for destroying a TClock instance. }

destructor TClock.Destroy;
begin
  FreeAndNil(FTimer);
  inherited Destroy;
end;

{ public TClock.Count

  Increments time a calls alert. }

procedure TClock.Count(Sender: TObject);
begin
  FTime := IncSecond(FTime);

  if Assigned(FOnCounting) then
    FOnCounting(Self);

  if FAlertEnabled then
  begin
    // Current time matches alert time: Call alert!
    if IsSameTime(FTime, FAlertTime) then
    begin
      // Stop TTimer in counter mode
      if not FTimerMode then
        FTimer.Enabled := False;

      if Assigned(FOnAlertBegin) then
        FOnAlertBegin(Self);

      // Shutdown does not need a thread
      if (FAlertType = atShutdown) then
        Exit;

      // Start playing sound
      FAlertThread := TAlertThread.Create(Self, FAlertType);

      with (FAlertThread as TAlertThread) do
      begin
        OnAlert := Self.OnAlert;
        OnTerminate := FOnAlertEnd;
        Start();
      end;  //of begin
    end;  //of begin

    // Automatically abort alert after 1 minute
    if IsSameTime(IncMinute(FAlertTime), FTime) then
      SetAlertEnabled(False);
  end; //of begin
end;

{ private TClock.IsSameTime

  Checks if two times are the same except milliseconds. }

function TClock.IsSameTime(const ATime1, ATime2: TTime): Boolean;
var
  Hour1, Hour2, Min1, Min2, Sec1, Sec2, Msec: Word;

begin
  DecodeTime(ATime1, Hour1, Min1, Sec1, Msec);
  DecodeTime(ATime2, Hour2, Min2, Sec2, Msec);
  Result := ((Hour1 = Hour2) and (Min1 = Min2) and (Sec1 = Sec2));
end;

function TClock.PlaySound(const AFileName: string; ASynchronized: Boolean = False): Boolean;
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

function TClock.PlaySound(AAlertSound: TAlertSound; ASynchronized: Boolean = False): Boolean;
{$IFDEF MSWINDOWS}
const
  Synchronous: array[Boolean] of DWORD = (SND_ASYNC, SND_SYNC);
{$ENDIF}

var
  Sound: string;

begin
{$IFDEF MSWINDOWS}
  if (AAlertSound = atBing) then
  begin
    // Play default Windows sound
    Exit(MMSystem.PlaySound(PChar(SND_ALIAS_SYSTEMDEFAULT), 0,
      Synchronous[ASynchronized] or SND_ALIAS_ID or SND_SENTRY));
  end;  //of begin
{$ENDIF}

  case AAlertSound of
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
  if (FSoundPath <> '') then
    Sound := IncludeTrailingPathDelimiter(FSoundPath) + Sound;

  Result := PlaySound(ChangeFileExt(Sound, '.wav'), ASynchronized);
{$ENDIF}
end;

{ private TClock.SetAlertEnabled

  Enables or disables the current alert. }

procedure TClock.SetAlertEnabled(const AAlertEnabled: Boolean);
begin
  if (AAlertEnabled and not FTimerMode and IsSameTime(FTime, FAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FAlertEnabled := AAlertEnabled;

  // Start/Stop TTimer in counter mode
  if not FTimerMode then
    FTimer.Enabled := AAlertEnabled;

  if (not AAlertEnabled and Assigned(FAlertThread)) then
  begin
    FAlertThread.Terminate();
    FAlertThread := nil;
  end;  //of begin
end;

procedure TClock.SetAlertTime(const AAlertTime: TTime);
begin
  if (FAlertEnabled and not FTimerMode and IsSameTime(FTime, AAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FAlertTime := AAlertTime;
end;

procedure TClock.SetTime(const ATime: TTime);
begin
  if (FAlertEnabled and not FTimerMode and IsSameTime(ATime, FAlertTime)) then
    raise EAssertionFailed.Create('Alert time and current time cannot be equal!');

  FTime := ATime;
end;

{ private TClock.SetTimerMode

  Changes between the modes. }

procedure TClock.SetTimerMode(const ATimerMode: Boolean);
begin
  FTimerMode := ATimerMode;
  FTimer.Enabled := ATimerMode;

  if ATimerMode then
    FTime := SysUtils.Time()
  else
    FTime := 0;
end;


{ TAlertThread }

{ public TAlertThread.Create

  Constructor for creating a TAlertThread instance. }

constructor TAlertThread.Create(AClock: TClock; AAlertSound: TAlertSound);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FClock := AClock;
  FAlertSound := AAlertSound;
end;

{ private TAlertThread.DoNotifyOnAlert

  Notifies the alert. }

procedure TAlertThread.DoNotifyOnAlert;
begin
  if Assigned(FOnAlert) then
    FOnAlert(Self);
end;

{ protected TAlertThread.Execute

  Thread main method that plays a *.wav file. }

procedure TAlertThread.Execute();
begin
  while not Terminated do
  begin
    Synchronize(DoNotifyOnAlert);
    FClock.PlaySound(FAlertSound, True);
  end;  //of begin
end;

end.

