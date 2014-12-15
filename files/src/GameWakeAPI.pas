{ *********************************************************************** }
{                                                                         }
{ Game Wake Cross API Interface Unit v3.1                                 }
{                                                                         }
{ Copyright (c) 2011-2014 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeAPI;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
  SysUtils, Classes, IniFiles, ExtCtrls, AlertThread, OSUtils;

const
  URL_BASE = 'http://www.pm-codeworks.de/';
  URL_CONTACT = URL_BASE +'kontakt.html';

type
  { TConfigFile }
  TConfigFile = class(TObject)
  private
    FSection: string;
    FIni: TIniFile;
  public
    constructor Create(AInitialSection: string; AConfig: string = '');
    destructor Destroy; override;
    procedure ChangeSection(ANewSection: string);
    procedure DeleteValue(const AValueName: string);
    function GetIniValue(AValueName: string): string; overload;
    function GetIniValue(ASection, AValueName: string): string; overload;
    function GetSaveValue(AValueName: string): Boolean; overload;
    function GetSaveValue(ASection, AValueName: string): Boolean; overload;
    procedure LoadColor(var AArray: array of string);
    procedure SaveColor(AArray: array of string);
    procedure SetIniValue(AValueName, AValue: string); overload;
    procedure SetIniValue(AValueName: string; AValue: Boolean); overload;
    procedure SetIniValue(ASection, AValueName, AValue: string); overload;
    procedure SetIniValue(ASection, AValueName: string; AValue: Boolean); overload;
    function ValueExists(AValueName: string): Boolean;
  end;

  { TTime }
  TTime = class(TObject)    
  protected
    FCombine: Boolean;
    FHour, FMin, FSec: Word;
    procedure SetBasicTime(ANewMin, ANewSec: Word);
  public
    constructor Create(AHour, AMin, ASec: Word; ACombine: Boolean);
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
    procedure SetHour(ANewHour: Word); virtual; abstract;
    procedure SetMin(ANewMin: Word); virtual;
    procedure SetSystemTime();
    procedure SetTime(ANewHours, ANewMin: Word); overload; virtual; abstract;
    procedure SetTime(ANewHours, ANewMin, ANewSec: Word); overload; virtual; abstract;
    procedure Reset(); virtual; abstract;
    { external }
    property Hour: Word read FHour write SetHour;
    property Min: Word read FMin write SetMin;
    property Sec: Word read FSec;
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
    procedure SetHour(ANewHour: Word); override;
    procedure SetTime(ANewHour, ANewMin: Word); override;
    procedure SetTime(ANewHour, ANewMin, ANewSec: Word); override;
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
    procedure SetHour(ANewHour: Word); override;
    procedure SetMin(ANewMin: Word); override;
    procedure SetTime(ANewHour, ANewMin: Word); override;
    procedure SetTime(ANewHour, ANewMin, ANewSec: Word); override;
  end;

  { Alert events }
  TOnAlertStartEvent = procedure(Sender: TObject) of object;
  TOnCountEvent = procedure(Sender: TObject; ATime: string) of object;
  TOnAlertStopEvent = procedure(Sender: TObject) of object;

  { Exception class }
  EInvalidTimeException = class(Exception);
  
  { TClock }
  TClock = class(TObject)
  private
    FTimer: TTimer;
    FAlertType: TAlertType;
    FAlertEnabled, FTimerMode: Boolean;
    FTime: TTimerMode;
    FTimeAlert: TTime;
    FAlertThread: TAlertThread;
    FOnAlert: TOnAlertEvent;
    FOnAlertStop: TOnAlertStopEvent;
    FOnCount: TOnCountEvent;
    FOnAlertEnd: TOnAlertEndEvent;
    FOnAlertStart: TOnAlertStartEvent;
  public
    constructor Create(AOwner: TComponent; ATimerMode: Boolean;
      ACombine: Boolean = False);
    destructor Destroy; override;
    procedure ChangeMode(ATimerMode: Boolean);
    procedure Count(Sender: TObject);
    procedure GetTimeRemaining(var AHour, AMin, ASec: string);
    procedure StartAlert();
    procedure StopAlert();
    { external }
    property Alert: TTime read FTimeAlert write FTimeAlert;
    property AlertEnabled: Boolean read FAlertEnabled;
    property AlertType: TAlertType read FAlertType write FAlertType;
    property OnAlert: TOnAlertEvent read FOnAlert write FOnAlert;
    property OnAlertEnd: TOnAlertEndEvent read FOnAlertEnd write FOnAlertEnd;
    property OnAlertStart: TOnAlertStartEvent read FOnAlertStart write FOnAlertStart;
    property OnAlertStop: TOnAlertStopEvent read FOnAlertStop write FOnAlertStop;
    property OnCount: TOnCountEvent read FOnCount write FOnCount;
    property Time: TTimerMode read FTime write FTime;
    property Timer: TTimer read FTimer;
    property TimerMode: Boolean read FTimerMode;
  end;

implementation

{ TConfigFile }

{ public TConfigFile.Create

  Constructor for creating a TConfigFile instance. }

constructor TConfigFile.Create(AInitialSection: string; AConfig: string = '');
begin
  inherited Create;
  FSection := AInitialSection;

{$IFDEF MSWINDOWS}
  if (AConfig = '') then
    AConfig := ExtractFilePath(ParamStr(0)) +'gamewake.ini'
  else
    if (ExtractFileExt(AConfig) <> '.ini') then
      raise Exception.Create('Invalid configuration file extension!');
{$ELSE}
  if (AConfig = '') then
    AConfig := ExtractFilePath(ParamStr(0)) +'gamewake.conf';
{$ENDIF}

  FIni := TIniFile.Create(AConfig);
end;

{ public TConfigFile.Destroy

  Destructor for destroying a TConfigFile instance. }

destructor TConfigFile.Destroy;
begin
  FIni.Free;
  inherited Destroy;
end;

{ public TConfigFile.DeleteValue

  Removes a value from config file. }

procedure TConfigFile.DeleteValue(const AValueName: string);
begin
  FIni.DeleteKey(FSection, AValueName);
end;

{ public TConfigFile.ChangeSection

  Changes the current section. }

procedure TConfigFile.ChangeSection(ANewSection: string);
begin
  FSection := ANewSection;
end;

{ public TConfigFile.DeleteValue

  Removes a value from config file. }

function TConfigFile.GetIniValue(AValueName: string): string;
begin
  result := GetIniValue(FSection, AValueName);
end;

{ public TConfigFile.GetIniValue

  Returns a string value from config file. }

function TConfigFile.GetIniValue(ASection, AValueName: string): string;
begin
  result := FIni.ReadString(ASection, AValueName, '');
end;

{ public TConfigFile.GetSaveValue

  Returns a boolean value from config file in current section. }

function TConfigFile.GetSaveValue(AValueName: string): Boolean;
begin
  result := GetSaveValue(FSection, AValueName);
end;

{ public TConfigFile.GetSaveValue

  Returns a boolean value from config file in a given section. }

function TConfigFile.GetSaveValue(ASection, AValueName: string): Boolean;
begin
  result := FIni.ReadBool(ASection, AValueName, False);
end;

{ public TConfigFile.LoadColor

  Returns an array containing all saved custom colors from config file. }

procedure TConfigFile.LoadColor(var AArray: array of string);
var
  i: Byte;

begin
  for i := 0 to Length(AArray) -1 do
    AArray[i] := GetIniValue('Color'+ IntToStr(i));
end;

{ public TConfigFile.SaveColor

  Saves an array containing all saved custom colors into config file. }

procedure TConfigFile.SaveColor(AArray: array of string);
var
  i: Byte;

begin
  for i := 0 to Length(AArray) -1 do
    SetIniValue('Color'+ IntToStr(i), AArray[i]);
end;

{ public TConfigFile.SetIniValue

  Stores a string value into config file in current section. }

procedure TConfigFile.SetIniValue(AValueName, AValue: string);
begin
  SetIniValue(FSection, AValueName, AValue);
end;

{ public TConfigFile.SetIniValue

  Stores a boolean value into config file in current section. }

procedure TConfigFile.SetIniValue(AValueName: string; AValue: Boolean);
begin
  SetIniValue(FSection, AValueName, AValue);
end;

{ public TConfigFile.SetIniValue

  Stores a string value into config file for a given section. }

procedure TConfigFile.SetIniValue(ASection, AValueName, AValue: string);
begin
  FIni.WriteString(ASection, AValueName, AValue);
end;

{ public TConfigFile.SetIniValue

  Stores a boolean value into config file for a given section. }

procedure TConfigFile.SetIniValue(ASection, AValueName: string; AValue: Boolean);
begin
  FIni.WriteBool(ASection, AValueName, AValue);
end;

{ public TConfigFile.SetIniValue

  Returns if a given value name exists. }

function TConfigFile.ValueExists(AValueName: string): Boolean;
begin
  result := FIni.ValueExists(FSection, AValueName);
end;


{ TTime }

{ public TTime.Create

  General constructor for creating a TTime instance. }

constructor TTime.Create(AHour, AMin, ASec: Word; ACombine: Boolean);
begin
  inherited Create;
  FHour := AHour;
  FMin := AMin;
  FSec := ASec;
  FCombine := ACombine;
end;

{ private TTime.SetTime

  Sets the current minutes and seconds. }

procedure TTime.SetBasicTime(ANewMin, ANewSec: Word);
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

procedure TTime.SetMin(ANewMin: Word);
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

procedure TTimerMode.SetHour(ANewHour: Word);
begin
  if (ANewHour > 23) then
    FHour := 23
  else
    FHour := ANewHour;
end;

{ public TTimerMode.SetTime

  Sets current hours and minutes. }

procedure TTimerMode.SetTime(ANewHour, ANewMin: Word);
begin
  SetTime(ANewHour, ANewMin, 0);
end;

{ public TTimerMode.SetTime

  Sets current hours, minutes and seconds. }

procedure TTimerMode.SetTime(ANewHour, ANewMin, ANewSec: Word);
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

procedure TCounterMode.SetHour(ANewHour: Word);
begin
  if not ((ANewHour = 0) and (FMin = 0)) then
    FHour := ANewHour;
end;

{ public TCounterMode.SetMin

  Sets minutes to an valid value. }

procedure TCounterMode.SetMin(ANewMin: Word);
begin
  if not ((ANewMin = 0) and (FHour = 0)) then
    inherited SetMin(ANewMin);
end;

{ public TCounterMode.SetTime

  Sets current hours and minutes. }

procedure TCounterMode.SetTime(ANewHour, ANewMin: Word);
begin
  SetTime(ANewHour, ANewMin, 0);
end;

{ public TCounterMode.SetTime

  Sets current hours, minutes and seconds. }

procedure TCounterMode.SetTime(ANewHour, ANewMin, ANewSec: Word);
begin
  if ((ANewHour = 0) and (ANewMin = 0)) then
    raise EInvalidTimeException.Create('Hours and Minutes must not be 0!');

  SetHour(ANewHour);
  SetBasicTime(ANewMin, ANewSec);
end;


{ TClock }

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

      FOnAlertStart(Self);

      if (FAlertType = atShutdown) then
         Exit;

      // Start playing sound
      FAlertThread := TAlertThread.Create(FAlertType);

      with FAlertThread do
      begin
        OnAlertEnd := FOnAlertEnd;
        OnAlert := FOnAlert;
        OnAlertStart := FOnAlertStart;
        OnAlertStop := OnStop;
      {$IFNDEF MSWINDOWS}
        Start;
      {$ELSE}
        Resume;
      {$ENDIF}
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
  currentHour, currentMin, currentSec, ms: Word;
  TimeRemain: TDateTime;

begin
  if (FTimeAlert.GetDateTime > FTime.GetDateTime) then
    TimeRemain := FTimeAlert.GetDateTime - FTime.GetDateTime
  else
    TimeRemain := FTime.GetDateTime - FTimeAlert.GetDateTime;

  DecodeTime(TimeRemain, currentHour, currentMin, currentSec, ms);
  AHour := Format('%.*d', [2, currentHour]);
  AMin := Format('%.*d', [2, currentMin]);
  ASec := Format('%.*d', [2, currentSec]);
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