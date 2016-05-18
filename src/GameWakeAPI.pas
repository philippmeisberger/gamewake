{ *********************************************************************** }
{                                                                         }
{ Game Wake API Interface Unit                                            }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeAPI;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
{$IFNDEF MSWINDOWS}
  Process,
{$ELSE}
  Windows, MMSystem,
{$ENDIF}
  SysUtils, Classes, ExtCtrls, Graphics, PMCWIniFileParser;

type
  { TConfigFile }
  TConfigFile = class(TIniFile)
  public
    function ReadColor(const ASection, AKey: string): TColor;
    procedure ReadColors(var AArray: array of string);
    procedure WriteColor(const ASection, AKey: string; AColor: TColor);
    procedure WriteColors(const AArray: array of string);
  end;

  { TTime }
  TTime = class(TObject)
  protected
    FCombine: Boolean;
    FHour,
    FMin,
    FSec: Byte;
    procedure SetBasicTime(ANewMin, ANewSec: Byte);
  public
    constructor Create(AHour, AMin, ASec: Byte; ACombine: Boolean);
    function DecrementHours(): string; virtual; abstract;
    function DecrementMinutes(): string; virtual;
    function Equals(const ATime: TTime): Boolean; reintroduce;
    function GetDateTime(): TDateTime;
    function GetHour(): string;
    function GetMin(): string;
    function GetTime(ALongFormat: Boolean = True): string; overload;
    procedure GetTime(var AHour, AMin: string); overload;
    function IncrementHours(): string; virtual; abstract;
    function IncrementMinutes(): string;
    procedure IncrementSeconds();
    procedure SetHour(ANewHour: Byte); virtual; abstract;
    procedure SetMin(ANewMin: Byte); virtual;
    procedure SetSystemTime();
    procedure SetTime(ANewHours, ANewMin: Byte); overload; virtual; abstract;
    procedure SetTime(ANewHours, ANewMin, ANewSec: Byte); overload; virtual; abstract;
    procedure Reset(); virtual; abstract;
    { external }
    property Hour: Byte read FHour write SetHour;
    property Min: Byte read FMin write SetMin;
    property Sec: Byte read FSec;
    property Combine: Boolean read FCombine write FCombine;
  end;

  { TTimerMode }
  TTimerMode = class(TTime)
  public
    constructor Create(ACombine: Boolean = True); overload;
    function DecrementHours(): string; override;
    function IncrementHours(): string; override;
    procedure Reset(); override;
    procedure SetHour(ANewHour: Byte); override;
    procedure SetTime(ANewHour, ANewMin: Byte); override;
    procedure SetTime(ANewHour, ANewMin, ANewSec: Byte); override;
  end;

  { TCounterMode }
  TCounterMode = class(TTime)
  public
    constructor Create(ACombine: Boolean = True); overload;
    function DecrementHours(): string; override;
    function DecrementMinutes(): string; override;
    function IncrementHours(): string; override;
    procedure Reset(); override;
    procedure SetHour(ANewHour: Byte); override;
    procedure SetMin(ANewMin: Byte); override;
    procedure SetTime(ANewHour, ANewMin: Byte); override;
    procedure SetTime(ANewHour, ANewMin, ANewSec: Byte); override;
  end;

  { Exception class }
  EInvalidTimeException = class(Exception);

  { TAlertType }
  TAlertType = (atClock, atHorn, atBing, atBeep, atShutdown, atNone);

  { TClock }
  TClock = class(TObject)
  private
    FTimer: TTimer;
    FAlertType: TAlertType;
    FAlertThread: TThread;
    FAlertEnabled,
    FTimerMode: Boolean;
    FTime: TTimerMode;
    FTimeAlert: TTime;
    FOnCounting,
    FOnAlertBegin,
    FOnAlert,
    FOnAlertEnd: TNotifyEvent;
    FSoundPath: string;
    procedure Count(Sender: TObject);
    procedure SetAlertEnabled(const AAlertEnabled: Boolean);
    procedure SetTimerMode(const ATimerMode: Boolean);
    procedure DoNotifyOnCounting();
  public
    constructor Create(AOwner: TComponent; ATimerMode: Boolean;
      ACombine: Boolean = False);
    destructor Destroy; override;
    procedure GetTimeRemaining(var AHour, AMin, ASec: string);
    function PlaySound(const ASound: string; ASynchronized: Boolean = False{$IFDEF MSWINDOWS};
      AResource: Boolean = False{$ENDIF}): Boolean; overload;
    function PlaySound(ASound: TAlertType; ASynchronized: Boolean = False{$IFDEF MSWINDOWS};
      AResource: Boolean = False{$ENDIF}): Boolean; overload;
    { external }
    property Alert: TTime read FTimeAlert write FTimeAlert;
    property AlertEnabled: Boolean read FAlertEnabled write SetAlertEnabled;
    property AlertType: TAlertType read FAlertType write FAlertType;
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
    property OnAlertBegin: TNotifyEvent read FOnAlertBegin write FOnAlertBegin;
    property OnAlertEnd: TNotifyEvent read FOnAlertEnd write FOnAlertEnd;
    property OnCounting: TNotifyEvent read FOnCounting write FOnCounting;
    property SoundPath: string read FSoundPath write FSoundPath;
    property Time: TTimerMode read FTime write FTime;
    property TimerMode: Boolean read FTimerMode write SetTimerMode;
  end;

  { TAlertThread }
  TAlertThread = class(TThread)
  private
    FClock: TClock;
    FAlertType: TAlertType;
    FOnAlert: TNotifyEvent;
    procedure DoNotifyOnAlert();
  protected
    procedure Execute(); override;
  public
    constructor Create(AClock: TClock; AAlertType: TAlertType);
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
  end;

implementation

{ TConfigFile }

{ public TConfigFile.ReadColor

  Reads a TColor value from config . }

function TConfigFile.ReadColor(const ASection, AKey: string): TColor;
begin
  Result := StringToColor(ReadString(ASection, AKey));
end;

{ public TConfigFile.ReadColors

  Returns an array containing all saved custom colors from config file. }

procedure TConfigFile.ReadColors(var AArray: array of string);
var
  i: Byte;

begin
  for i := Low(AArray) to High(AArray) do
    AArray[i] := ReadString('CustomColors', 'Color'+ IntToStr(i));
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
    WriteString('CustomColors', 'Color'+ IntToStr(i), AArray[i]);
end;


{ TTime }

{ public TTime.Create

  General constructor for creating a TTime instance. }

constructor TTime.Create(AHour, AMin, ASec: Byte; ACombine: Boolean);
begin
  inherited Create;
  FHour := AHour;
  FMin := AMin;
  FSec := ASec;
  FCombine := ACombine;
end;

{ private TTime.SetTime

  Sets the current minutes and seconds. }

procedure TTime.SetBasicTime(ANewMin, ANewSec: Byte);
begin
  SetMin(ANewMin);

  if (ANewSec > 59) then
    FMin := 59
  else
    FSec := ANewSec;
end;

{ public TTime.DecrementMinutes

  Decrements minutes by 1 and returns them as formatted string. }

function TTime.DecrementMinutes(): string;
begin
  if (FMin = 0) then
  begin
    FMin := 59;

    if FCombine then
      DecrementHours();
  end  //of begin
  else
    Dec(FMin);

  Result := GetMin();
end;

{ public TTime.Equals

  Checks if time matches another time. }

function TTime.Equals(const ATime: TTime): Boolean;
begin
  Assert(Assigned(ATime), 'Argument ''ATime'' not assigned!');
  Result := (Hour = ATime.Hour) and (Min = ATime.Min) and (Sec = ATime.Sec);
end;

{ public TTime.GetDateTime

  Returns the current time as TDateTime. }

function TTime.GetDateTime(): TDateTime;
begin
  Result := EncodeTime(FHour, FMin, FSec, 0);
end;

{ public TTime.GetHour

  Returns the current hour as 2 digit formatted string. }

function TTime.GetHour(): string;
begin
  Result := Format('%.*d', [2, FHour]);
end;

{ public TTime.GetMin

  Returns the current minute as 2 digit formatted string. }

function TTime.GetMin(): string;
begin
  Result := Format('%.*d', [2, FMin]);
end;

{ public TTime.GetTime

  Returns hours and minutes of current time as string. }

procedure TTime.GetTime(var AHour, AMin: string);
begin
  AHour := GetHour();
  AMin := GetMin();
end;

{ public TTime.GetTime

  Returns the current time as formatted string. }

function TTime.GetTime(ALongFormat: Boolean = True): string;
begin
  if ALongFormat then
    Result := FormatDateTime('tt', GetDateTime())
  else
    Result := FormatDateTime('t', GetDateTime());
end;

{ public TTime.IncrementMinutes

  Increments minutes by 1 and returns them as formatted string. }

function TTime.IncrementMinutes(): string;
begin
  if (FMin = 59) then
  begin
    FMin := 0;

    if FCombine then
      IncrementHours();
  end  //of begin
  else
    Inc(FMin);

  Result := GetMin();
end;

{ public TTime.IncrementSeconds

  Increments seconds by 1. }

procedure TTime.IncrementSeconds();
begin
  if (FSec = 59) then
  begin
    FSec := 0;

    if FCombine then
      IncrementMinutes();
  end  //of begin
  else
    Inc(FSec);
end;

{ public TTime.SetMin

  Sets minutes to an valid value. }

procedure TTime.SetMin(ANewMin: Byte);
begin
  if (ANewMin > 59) then
    FMin := 59
  else
    FMin := ANewMin;
end;

{ public TTime.SetSystemTime

  Gets current system time and stores them in current time object. }

procedure TTime.SetSystemTime();
var
  currentHour, currentMin, currentSec, ms: Word;

begin
  DecodeTime(Now(), currentHour, currentMin, currentSec, ms);
  SetTime(currentHour, currentMin, currentSec);
end;


{ TTimerMode }

{ public TTimerMode.Create

  Standard constructor for creating a TTimerMode instance. }

constructor TTimerMode.Create(ACombine: Boolean = True);
begin
  inherited Create(0, 0, 0, ACombine);
end;

{ public TTimerMode.DecrementHours

  Decrements hours by 1 and returns them as formatted string. }

function TTimerMode.DecrementHours(): string;
begin
  if (FHour = 0) then
    FHour := 23
  else
    Dec(FHour);

  Result := GetHour();
end;

{ public TTimerMode.IncrementHours

  Increments hours by 1 and returns them as formatted string. }

function TTimerMode.IncrementHours(): string;
begin
  if (FHour = 23) then
    FHour := 0
  else
    Inc(FHour);

  Result := GetHour();
end;

{ public TTimerMode.Reset

  Resets hours and minutes to minimal values. }

procedure TTimerMode.Reset();
begin
  SetTime(0, 0);
end;

{ public TTimerMode.SetHour

  Sets hour to an valid value. }

procedure TTimerMode.SetHour(ANewHour: Byte);
begin
  if (ANewHour > 23) then
    FHour := 23
  else
    FHour := ANewHour;
end;

{ public TTimerMode.SetTime

  Sets current hours and minutes. }

procedure TTimerMode.SetTime(ANewHour, ANewMin: Byte);
begin
  SetTime(ANewHour, ANewMin, 0);
end;

{ public TTimerMode.SetTime

  Sets current hours, minutes and seconds. }

procedure TTimerMode.SetTime(ANewHour, ANewMin, ANewSec: Byte);
begin
  SetHour(ANewHour);
  SetBasicTime(ANewMin, ANewSec);
end;


{ TCounterMode }

{ public TCounterMode.Create

  Standard constructor for creating a TCounterMode instance. }

constructor TCounterMode.Create(ACombine: Boolean = True);
begin
  inherited Create(0, 1, 0, ACombine);
end;

{ public TCounterMode.DecrementHours

  Decrements hours by 1 and returns them as formatted string. }

function TCounterMode.DecrementHours(): string;
begin
  if (FHour = 0) then
    FHour := 99
  else
    if not ((FHour = 1) and (FMin = 0)) then
      Dec(FHour);

  Result := GetHour();
end;

{ public TCounterMode.DecrementMinutes

  Decrements minutes by 1 and returns them as formatted string. }

function TCounterMode.DecrementMinutes(): string;
begin
  if ((FMin = 1) and (FHour = 0)) then
  begin
    Result := GetMin();
    Exit;
  end  //of begin
  else
    Result := inherited DecrementMinutes();
end;

{ public TCounterMode.IncrementHours

  Increments hours by 1 and returns them as formatted string. }

function TCounterMode.IncrementHours(): string;
begin
  if (FHour = 99) then
  begin
    if (FMin <> 0) then
      FHour := 0;
  end  //of begin
  else
    Inc(FHour);

  Result := GetHour();
end;

{ public TCounterMode.Reset

  Resets hours and minutes to minimal values. }

procedure TCounterMode.Reset();
begin
  SetTime(0, 1);
end;

{ public TCounterMode.SetHour

  Sets hour to an valid value. }

procedure TCounterMode.SetHour(ANewHour: Byte);
begin
  if not ((ANewHour = 0) and (FMin = 0)) then
    FHour := ANewHour;
end;

{ public TCounterMode.SetMin

  Sets minutes to an valid value. }

procedure TCounterMode.SetMin(ANewMin: Byte);
begin
  if not ((ANewMin = 0) and (FHour = 0)) then
    inherited SetMin(ANewMin);
end;

{ public TCounterMode.SetTime

  Sets current hours and minutes. }

procedure TCounterMode.SetTime(ANewHour, ANewMin: Byte);
begin
  SetTime(ANewHour, ANewMin, 0);
end;

{ public TCounterMode.SetTime

  Sets current hours, minutes and seconds. }

procedure TCounterMode.SetTime(ANewHour, ANewMin, ANewSec: Byte);
begin
  if ((ANewHour = 0) and (ANewMin = 0)) then
    raise EInvalidTimeException.Create('Hours and Minutes must not be 0!');

  SetHour(ANewHour);
  SetBasicTime(ANewMin, ANewSec);
end;


{ TClock }

{ public TClock.Create

  Constructor for creating a TClock instance. }

constructor TClock.Create(AOwner: TComponent; ATimerMode: Boolean;
  ACombine: Boolean = False);
begin
  inherited Create;
  FTimerMode := ATimerMode;
  FAlertEnabled := False;
  FAlertType := atClock;
  FAlertThread := nil;
  FTime := TTimerMode.Create(True);

  // TTimerMode as initial mode?
  if ATimerMode then
  begin
    FTime.SetSystemTime();
    FTimeAlert := TTimerMode.Create(ACombine);
  end  //of begin
  else
    FTimeAlert := TCounterMode.Create(ACombine);

  // Init TTimer
  FTimer := TTimer.Create(AOwner);

  with FTimer do
  begin
    OnTimer := Count;
    Interval := 1000;
    Enabled := ATimerMode;
  end;  //of with
end;

{ public TClock.Destroy

  Destructor for destroying a TClock instance. }

destructor TClock.Destroy;
begin
  FreeAndNil(FTimeAlert);
  FreeAndNil(FTime);
  FreeAndNil(FTimer);
  inherited Destroy;
end;

{ public TClock.Count

  Increments time a calls alert. }

procedure TClock.Count(Sender: TObject);
begin
  FTime.IncrementSeconds();
  DoNotifyOnCounting();

  if FAlertEnabled then
  begin
    // Current time matches alert time: Call alert!
    if FTime.Equals(FTimeAlert) then
    begin
      // Stop TTimer in counter mode
      if not FTimerMode then
        FTimer.Enabled := False;

      if (FAlertType = atShutdown) then
        Exit;

      if Assigned(FOnAlertBegin) then
        FOnAlertBegin(Self);

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
     if ((FTimeAlert.Hour = FTime.Hour) and (FTime.Min = FTimeAlert.Min + 1) and (FTime.Sec = 0)) then
       SetAlertEnabled(False);
  end; //of begin
end;

{ public TClock.GetTimeRemaining

  Returns remaining hours and minutes until alert will be called. }

procedure TClock.GetTimeRemaining(var AHour, AMin, ASec: string);
var
  CurrentHour, CurrentMin, CurrentSec, Ms: Word;
  TimeRemain: TDateTime;

begin
  if (FTimeAlert.GetDateTime > FTime.GetDateTime) then
    TimeRemain := FTimeAlert.GetDateTime - FTime.GetDateTime
  else
    TimeRemain := FTime.GetDateTime - FTimeAlert.GetDateTime;

  DecodeTime(TimeRemain, CurrentHour, CurrentMin, CurrentSec, Ms);

  AHour := Format('%.*d', [2, CurrentHour]);
  AMin := Format('%.*d', [2, CurrentMin]);
  ASec := Format('%.*d', [2, CurrentSec]);
end;

{ private TClock.DoNotifyOnCounting

  Notifies about counting. }

procedure TClock.DoNotifyOnCounting();
begin
  if Assigned(FOnCounting) then
    FOnCounting(Self);
end;

{ public TClock.PlaySound

  Plays a predefined sound. }

function TClock.PlaySound(ASound: TAlertType; ASynchronized: Boolean = False
  {$IFDEF MSWINDOWS}; AResource: Boolean = False{$ENDIF}): Boolean;
var
  Sound: string;

begin
  case ASound of
    atClock: Sound := 'bell';
    atHorn:  Sound := 'horn';
    atBing:  Sound := 'bing';
    atBeep:  Sound := 'beep';
    else     Sound := '';
  end;  //of case

  if ((Sound <> ''){$IFDEF MSWINDOWS}and not AResource{$ENDIF}) then
    Sound := Sound +'.wav';

  Result := PlaySound(Sound, ASynchronized{$IFDEF MSWINDOWS}, AResource{$ENDIF});
end;

{ private TClock.SetAlertEnabled

  Enables or disables the current alert. }

procedure TClock.SetAlertEnabled(const AAlertEnabled: Boolean);
begin
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

{ private TClock.SetTimerMode

  Changes between the modes. }

procedure TClock.SetTimerMode(const ATimerMode: Boolean);
var
  Combine: Boolean;

begin
  FTimerMode := ATimerMode;
  FTimer.Enabled := ATimerMode;
  Combine := FTimeAlert.Combine;
  FTimeAlert.Free;

  if ATimerMode then
  begin
    FTimeAlert := TTimerMode.Create(Combine);
    FTime.SetSystemTime();
  end  //of begin
  else
  begin
    FTimeAlert := TCounterMode.Create(Combine);
    FTime.Reset();
  end;  //of if
end;

{ public TClock.PlaySound

  Plays a *.wav file. }

function TClock.PlaySound(const ASound: string; ASynchronized: Boolean = False
  {$IFDEF MSWINDOWS}; AResource: Boolean = False{$ENDIF}): Boolean;
var
{$IFNDEF MSWINDOWS}
  Process: TProcess;
{$ELSE}
  Flags: DWORD;
{$ENDIF}

begin
{$IFDEF MSWINDOWS}
  if ASynchronized then
    Flags := SND_SYNC
  else
    Flags := SND_ASYNC;

  if AResource then
    Inc(Flags, SND_MEMORY or SND_RESOURCE)
  else
    Inc(Flags, SND_FILENAME);

  // Add volume slider in system tray
  if CheckWin32Version(6) then
    Inc(Flags, SND_SENTRY);

  Result := MMSystem.PlaySound(PChar(FSoundPath + ASound), HInstance, Flags);
{$ELSE}
  Process := TProcess.Create(nil);

  try
    Process.Executable := '/usr/bin/aplay';
    Process.Parameters.Append(FSoundPath + ASound);

    if ASynchronized then
      Process.Options := Process.Options + [poWaitOnExit];

   Process.Execute();
   Result := True;

  finally
    Process.Free;
  end;  //of try
{$ENDIF}
end;


{ TAlertThread }

{ public TAlertThread.Create

  Constructor for creating a TAlertThread instance. }

constructor TAlertThread.Create(AClock: TClock; AAlertType: TAlertType);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FClock := AClock;
  FAlertType := AAlertType;
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
    FClock.PlaySound(FAlertType, True{$IFDEF PORTABLE}, True{$ENDIF});
  end;  //of begin
end;

end.
