{ *********************************************************************** }
{                                                                         }
{ Game Wake API Interface Unit                                            }
{                                                                         }
{ Copyright (c) 2011-2015 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeAPI;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
{$IFNDEF MSWINDOWS}
  Process,
{$ELSE}
  MMSystem,
{$ENDIF}
  SysUtils, Classes, ExtCtrls, Graphics, PMCWIniFileParser;

type
  { TAlertType }
  TAlertType = (atClock, atHorn, atBing, atBeep, atShutdown, atNone);

  { TConfigFile }
  TConfigFile = class(TIniFile)
  public
    function ReadColor(ASection, AKey: string): TColor;
    procedure ReadColors(var AArray: array of string);
    procedure WriteColor(ASection, AKey: string; AColor: TColor);
    procedure WriteColors(AArray: array of string);
  end;

  { TTime }
  TTime = class(TObject)
  protected
    FCombine: Boolean;
    FHour, FMin, FSec: Byte;
    procedure SetBasicTime(ANewMin, ANewSec: Byte);
  public
    constructor Create(AHour, AMin, ASec: Byte; ACombine: Boolean);
    function ChangeMode(): TTime; virtual; abstract;
    function DecrementHours(): string; virtual; abstract;
    function DecrementMinutes(): string; virtual;
    function GetDateTime: TDateTime;
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
    function ChangeMode(): TTime; override;
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
    function ChangeMode(): TTime; override;
    function DecrementHours(): string; override;
    function DecrementMinutes(): string; override;
    function IncrementHours(): string; override;
    procedure Reset(); override;
    procedure SetHour(ANewHour: Byte); override;
    procedure SetMin(ANewMin: Byte); override;
    procedure SetTime(ANewHour, ANewMin: Byte); override;
    procedure SetTime(ANewHour, ANewMin, ANewSec: Byte); override;
  end;

  { Alert events }
  TOnCountEvent = procedure(Sender: TObject; ATime: string) of object;

  { Exception class }
  EInvalidTimeException = class(Exception);

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
    FOnCount: TOnCountEvent;
    FOnAlert,
    FOnAlertEnd,
    FOnAlertStop: TNotifyEvent;
  public
    constructor Create(AOwner: TComponent; ATimerMode: Boolean;
      ACombine: Boolean = False);
    destructor Destroy; override;
    procedure ChangeMode(ATimerMode: Boolean);
    procedure Count(Sender: TObject);
    procedure GetTimeRemaining(var AHour, AMin, ASec: string);
    function PlaySound(AFileName: string; ASynchronized: Boolean = False): Boolean;
    procedure StartAlert();
    procedure StopAlert();
    { external }
    property Alert: TTime read FTimeAlert write FTimeAlert;
    property AlertEnabled: Boolean read FAlertEnabled;
    property AlertType: TAlertType read FAlertType write FAlertType;
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
    property OnAlertEnd: TNotifyEvent read FOnAlertEnd write FOnAlertEnd;
    property OnAlertStop: TNotifyEvent read FOnAlertStop write FOnAlertStop;
    property OnCount: TOnCountEvent read FOnCount write FOnCount;
    property Time: TTimerMode read FTime write FTime;
    property Timer: TTimer read FTimer;
    property TimerMode: Boolean read FTimerMode;
  end;

implementation

uses GameWakeAlertThread;

{ TConfigFile }

{ public TConfigFile.ReadColor

  Reads a TColor value from config . }

function TConfigFile.ReadColor(ASection, AKey: string): TColor;
begin
  Result := StringToColor(ReadString(ASection, AKey));
end;

{ public TConfigFile.ReadColors

  Returns an array containing all saved custom colors from config file. }

procedure TConfigFile.ReadColors(var AArray: array of string);
var
  i: Byte;

begin
  for i := 0 to Length(AArray) -1 do
    AArray[i] := ReadString('CustomColors', 'Color'+ IntToStr(i));
end;

{ public TConfigFile.WriteColor

  Writes a TColor value into config file. }

procedure TConfigFile.WriteColor(ASection, AKey: string; AColor: TColor);
begin
  WriteString(ASection, AKey, ColorToString(AColor));
end;

{ public TConfigFile.WriteColors

  Writes an array containing all saved custom colors into config file. }

procedure TConfigFile.WriteColors(AArray: array of string);
var
  i: Byte;

begin
  for i := 0 to Length(AArray) -1 do
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

  result := GetMin();
end;

{ public TTime.GetDateTime

  Returns the current time as TDateTime. }

function TTime.GetDateTime: TDateTime;
begin
  result := EncodeTime(FHour, FMin, FSec, 0);
end;

{ public TTime.GetHour

  Returns the current hour as 2 digit formatted string. }

function TTime.GetHour(): string;
begin
  result := Format('%.*d', [2, FHour]);
end;

{ public TTime.GetMin

  Returns the current minute as 2 digit formatted string. }

function TTime.GetMin(): string;
begin
  result := Format('%.*d', [2, FMin]);
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
    result := FormatDateTime('tt', GetDateTime())
  else
    result := FormatDateTime('t', GetDateTime());
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

  result := GetMin();
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

{ public TTimerMode.ChangeMode

  Changes current used mode to TCounterMode. }

function TTimerMode.ChangeMode(): TTime;
begin
  result := TCounterMode.Create(FCombine);
end;

{ public TTimerMode.DecrementHours

  Decrements hours by 1 and returns them as formatted string. }

function TTimerMode.DecrementHours(): string;
begin
  if (FHour = 0) then
    FHour := 23
  else
    Dec(FHour);

  result := GetHour();
end;

{ public TTimerMode.IncrementHours

  Increments hours by 1 and returns them as formatted string. }

function TTimerMode.IncrementHours(): string;
begin
  if (FHour = 23) then
    FHour := 0
  else
    Inc(FHour);

  result := GetHour();
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

{ public TCounterMode.ChangeMode

  Changes current used mode to TTimerMode. }

function TCounterMode.ChangeMode(): TTime;
begin
  result := TTimerMode.Create(FCombine);
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

  result := GetHour();
end;

{ public TCounterMode.DecrementMinutes

  Decrements minutes by 1 and returns them as formatted string. }

function TCounterMode.DecrementMinutes(): string;
begin
  if ((FMin = 1) and (FHour = 0)) then
  begin
    result := GetMin();
    Exit;
  end  //of begin
  else
    result := inherited DecrementMinutes();
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

  result := GetHour();
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
  FAlertThread := nil;
  FTimeAlert.Free;
  FTime.Free;
  FTimer.Free;
  inherited Destroy;
end;

{ public TClock.ChangeMode

  Changes between the modes. }

procedure TClock.ChangeMode(ATimerMode: Boolean);
begin
  FTimerMode := ATimerMode;
  FTimer.Enabled := ATimerMode;
  FTimeAlert := FTimeAlert.ChangeMode();

  if ATimerMode then
     FTime.SetSystemTime()
  else
  begin
    FTime.Reset();
    FOnCount(Self, FTime.GetTime());
  end;  //of begin
end;

{ public TClock.Count

  Increments time a calls alert. }

procedure TClock.Count(Sender: TObject);
begin
  FTime.IncrementSeconds();
  FOnCount(Self, FTime.GetTime());

  if FAlertEnabled then
  begin
    // Current time matches alert time: Call alert!
    if ((FTimeAlert.Hour = FTime.Hour) and (FTimeAlert.Min = FTime.Min) and (FTime.Sec = 0)) then
    begin
      // Stop TTimer in counter mode
      if (FTimerMode = False) then
        FTimer.Enabled := False;

      if (FAlertType = atShutdown) then
         Exit;

      // Notify start of alert
      OnAlert(Self);

      // Start playing sound
      FAlertThread := TAlertThread.Create(Self, FAlertType);

      with (FAlertThread as TAlertThread) do
      begin
        OnAlertEnd := FOnAlertEnd;
        OnAlertStop := OnStop;
        Start;
      end;  //of with
    end;  //of begin

    // Automatically abort alert after 1 minute
     if ((FTimeAlert.Hour = FTime.Hour) and (FTime.Min = FTimeAlert.Min + 1) and (FTime.Sec = 0)) then
       StopAlert();
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

{ public TClock.PlaySound

  Plays a *.wav file. }

function TClock.PlaySound(AFileName: string; ASynchronized: Boolean = False): Boolean;
{$IFNDEF MSWINDOWS}
var
  Process : TProcess;
{$ENDIF}
begin
  //AFileName := ExtractFilePath(ParamStr(0)) + AFileName;

  if ((ExtractFileExt(AFileName) <> '.wav') or (not FileExists(AFileName))) then
  begin
    Result := False;
    SysUtils.Beep;
    Exit;
  end;  //of begin

{$IFDEF MSWINDOWS}
  if ASynchronized then
    SndPlaySound(PChar(AFileName), SND_SYNC)
  else
    SndPlaySound(PChar(AFileName), SND_ASYNC);

  Result := True;
{$ELSE}
  Process := TProcess.Create(nil);

  try
    Process.Executable := '/usr/bin/aplay';
    Process.Parameters.Append(AFileName);

    if ASynchronized then
      Process.Options := Process.Options + [poWaitOnExit];

   Process.Execute;
   Result := True;

  finally
    Process.Free;
  end;  //of try
{$ENDIF}
end;

{ public TClock.StartAlert

  Starts current alert. }

procedure TClock.StartAlert();
begin
  FAlertEnabled := True;

  // Start TTimer in counter mode
  if (FTimerMode = False) then
    FTimer.Enabled := True;
end;

{ public TClock.StopAlert

  Stops current alert. }

procedure TClock.StopAlert();
begin
  FAlertEnabled := False;

  if Assigned(FAlertThread) then
  begin
    FOnAlertStop(Self);
    FAlertThread := nil;
  end;  //of begin

  // Stop TTimer in counter mode
  if (FTimerMode = False) then
    FTimer.Enabled := False;
end;

end.
