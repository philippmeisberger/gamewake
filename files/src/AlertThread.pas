{ *********************************************************************** }
{                                                                         }
{ Game Wake Alert Thread                                                  }
{                                                                         }
{ Copyright (c) 2011-2015 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit AlertThread;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
{$IFDEF MSWINDOWS}
  SysUtils,
{$ENDIF}
  Classes, GameWakeAPI;

type
  { TAlertThread }
  TAlertThread = class(TThread)
  private
    FClock: TClock;
    FAlertType: TAlertType;
    FOnAlert,
    FOnAlertEnd: TNotifyEvent;
    procedure DoNotifyOnAlert;
    procedure DoNotifyOnAlertEnd;
  protected
    procedure Execute; override;
  public
    constructor Create(AClock: TClock; AAlertType: TAlertType);
    procedure OnStop(Sender: TObject);
    { external }
    property OnAlert: TNotifyEvent read FOnAlert write FOnAlert;
    property OnAlertEnd: TNotifyEvent read FOnAlertEnd write FOnAlertEnd;
  end;

implementation

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

{ public TAlertThread.OnStop

  Event that is called when user stops alert. }

procedure TAlertThread.OnStop(Sender: TObject);
begin
  Terminate;
  FAlertType := atNone;
end;

{ protected TAlertThread.Execute

  Thread main method that plays a *.wav file. }

procedure TAlertThread.Execute;
var
  Path: string;

begin
{$IFDEF MSWINDOWS}
  Path := '';
{$ELSE}
  Path := '/usr/lib/gamewake/';
{$ENDIF}

  while not Terminated do
  begin
    Synchronize(DoNotifyOnAlert);

    // Play *.wav file
    case FAlertType of
      atClock: FClock.PlaySound(Path +'bell.wav', True);
      atHorn:  FClock.PlaySound(Path +'horn.wav', True);
    {$IFDEF MSWINDOWS}
      atBing:
        begin
          Beep();
          Sleep(1000);
        end;  //of begin
    {$ELSE}
      atBing:  FClock.PlaySound(Path +'bing.wav', True);
    {$ENDIF}
      atBeep:  FClock.PlaySound(Path +'beep.wav', True);
      else
        Break;
    end;  //of case
  end;  //of while

  Synchronize(DoNotifyOnAlertEnd);
end;

{ private TAlertThread.DoNotifyOnAlert

  Synchronizable event that is called while alert is in progress. }

procedure TAlertThread.DoNotifyOnAlert;
begin
  if Assigned(FOnAlert) then
    OnAlert(Self);
end;

{ private TAlertThread.DoNotifyOnAlert

  Synchronizable event that is called while alert ends. }

procedure TAlertThread.DoNotifyOnAlertEnd;
begin
  if Assigned(FOnAlertEnd) then
    OnAlertEnd(Self);
end;

end.