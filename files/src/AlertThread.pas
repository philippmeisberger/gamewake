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
  Windows,
{$ENDIF}
  PMCW.OSUtils, Classes;

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
      atClock: PlaySound(Path +'bell.wav', True);
      atHorn:  PlaySound(Path +'horn.wav', True);
    {$IFDEF MSWINDOWS}
      atBing:
        begin
          MessageBeep(0);
          Sleep(1000);
        end;  //of begin
    {$ELSE}
      atBing:  PlaySound(Path +'bing.wav', True);
    {$ENDIF}
      atBeep:  PlaySound(Path +'beep.wav', True);
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