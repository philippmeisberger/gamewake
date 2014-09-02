{ *********************************************************************** }
{                                                                         }
{ Game Wake Alert Thread                                                  }
{                                                                         }
{ Copyright (c) 2011-2014 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit AlertThread;

{$IFDEF LINUX} {$mode delphi}{$H+} {$ENDIF}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  OSUtils, Classes;

type
  { TAlertType }
  TAlertType = (atClock, atHorn, atBing, atBeep, atShutdown, atNone);

  { Events }
  TOnAlertEvent = procedure(Sender: TThread) of object;
  TOnAlertEndEvent = procedure(Sender: TThread) of object;

  { TAlertThread }
  TAlertThread = class(TThread)
  private
    FAlertType: TAlertType;
    FOnAlert: TOnAlertEvent;
    FOnAlertEnd: TOnAlertEndEvent;
    procedure DoNotifyOnAlert;
    procedure DoNotifyOnAlertEnd;
  protected
    procedure Execute; override;
  public
    constructor Create(AAlertType: TAlertType);
    { external }
    procedure OnStop(Sender: TObject);
    property OnAlert: TOnAlertEvent read FOnAlert write FOnAlert;
    property OnAlertEnd: TOnAlertEndEvent read FOnAlertEnd write FOnAlertEnd;
  end;

implementation

uses GameWakeAPI;

{ TAlertThread }

{ TAlertThread.Create

  Constructor for creating a TAlertThread instance. }

constructor TAlertThread.Create(AAlertType: TAlertType);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FAlertType := AAlertType;
end;

{ TAlertThread.OnStop

  Event that is called when user stops alert. }

procedure TAlertThread.OnStop(Sender: TObject);
begin
  Terminate;
  FAlertType := atNone;
end;

{ TAlertThread.Execute

  Thread main method that plays a *.wav file. }

procedure TAlertThread.Execute;
begin
  while not Terminated do
  begin
    Synchronize(DoNotifyOnAlert);
  
    // Play *.wav file
    case FAlertType of
      atClock: TOSUtils.PlaySound('bell.wav', True);
      atHorn:  TOSUtils.PlaySound('horn.wav', True);
    {$IFDEF MSWINDOWS}
      atBing:
        begin
          MessageBeep(0);
          Sleep(1000);
        end;  //of begin
    {$ELSE}
      atBing:  TOSUtils.PlaySound('bing.wav', True);
    {$ENDIF}
      atBeep:  TOSUtils.PlaySound('beep.wav', True);
      else
        Break;
    end;  //of case
  end;  //of while

  Synchronize(DoNotifyOnAlertEnd);
end;

{ TAlertThread.DoNotifyOnAlert

  Synchronizable event that is called while alert is in progress. }

procedure TAlertThread.DoNotifyOnAlert;
begin
  if Assigned(FOnAlert) then
    OnAlert(Self);
end;

{ TAlertThread.DoNotifyOnAlert

  Synchronizable event that is called while alert ends. }

procedure TAlertThread.DoNotifyOnAlertEnd;
begin
  if Assigned(FOnAlertEnd) then
    OnAlertEnd(Self);
end;

end.