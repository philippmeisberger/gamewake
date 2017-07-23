unit GameWakeAPITests;

interface

uses
  TestFramework, Windows, Classes, Forms, SysUtils, DateUtils, GameWakeAPI;

type
  TClockTest = class(TTestCase)
  strict private
    FClock: TClock;
    FAlertCalled: Boolean;
    procedure Alert(Sender: TObject);
    procedure AssignTimeToAlert();
    procedure EnableAlert();
    procedure WaitForAlert();
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCounterMode;
    procedure TestTimerMode;
  end;

implementation

type
  // Helper class needed becaue UpdateActions() is protected
  TMyCustomForm = class(TCustomForm);

function GetTickCount64(): UInt64; stdcall; external kernel32 name 'GetTickCount64';

procedure Delay(AMilliseconds: Cardinal);
var
  FirstTickCount: UInt64;

begin
  FirstTickCount := GetTickCount64();

  while (GetTickCount64() < FirstTickCount + AMilliseconds) do
  begin
    Sleep(5);

    if ((GetCurrentThreadId() = MainThreadID) and Assigned(Application)) then
    begin
      Application.ProcessMessages();

      // Also process update actions
      if Assigned(Screen.ActiveCustomForm) then
        TMyCustomForm(Screen.ActiveCustomForm).UpdateActions();

      CheckSynchronize();
    end;  //of if
  end;  //of while
end;

procedure TClockTest.SetUp;
begin
  FClock := TClock.Create(True);
  FClock.OnAlert := Alert;
  FAlertCalled := False;
end;

procedure TClockTest.TearDown;
begin
  FreeAndNil(FClock);
end;

procedure TClockTest.Alert(Sender: TObject);
begin
  FAlertCalled := True;
end;

procedure TClockTest.EnableAlert();
begin
  FClock.AlertEnabled := True;
end;

procedure TClockTest.AssignTimeToAlert();
begin
  FClock.Alert := FClock.Time;
end;

procedure TClockTest.WaitForAlert;
begin
  Delay(1200);
  Check(FAlertCalled, 'OnAlert was not called');
  Check(FClock.AlertEnabled, 'Alert should stay enabled after alert occured');
end;

procedure TClockTest.TestCounterMode;
begin
  // Use counter mode
  FClock.TimerMode := False;
  Check(FClock.Time = 0, 'Time should be 0 initially');

  // Alert and Time must not be equal in counter mode
  FClock.Alert := FClock.Time;
  CheckException(EnableAlert, EAssertionFailed, 'Alert and Time must not be equal in counter mode');
  CheckFalse(FClock.AlertEnabled, 'Alert should stay disabled when alert time was invalid');

  // Enable alert
  FClock.Alert := IncSecond(FClock.Alert);
  FClock.AlertEnabled := True;
  Check(FClock.AlertEnabled, 'Alert was not enabled');

  // Alert and Time must not be equal in counter mode when alert is enabled
  CheckException(AssignTimeToAlert, EAssertionFailed, 'Alert and Time must not be equal in counter mode when alert is enabled');
  Check(FClock.AlertEnabled, 'Alert should stay enabled when alert time was invalid');
  Check(FClock.Alert <> 0, 'Alert time should have been changed');
  WaitForAlert();
end;

procedure TClockTest.TestTimerMode;
begin
  Check(FClock.TimerMode, 'Timer mode should be used initially');
  Check(FClock.Time <> 0, 'Time should not be 0 initially');

  // Alert and Time can be equal in timer mode
  FClock.Alert := FClock.Time;

  // Enable alert
  FClock.AlertEnabled := True;
  Check(FClock.AlertEnabled, 'Alert was not enabled');
  FClock.Alert := IncSecond(FClock.Alert);

  // Check EAssertionFailed does not occur
  FClock.Alert := IncSecond(FClock.Alert, -1);
  FClock.Alert := IncSecond(FClock.Alert);
  WaitForAlert();
end;

initialization
  RegisterTest(TClockTest.Suite);
end.

