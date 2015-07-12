program GameWake;

uses
  Vcl.Forms,
  GameWakeMain in 'GameWakeMain.pas' {Main},
  GameWakeAPI in 'GameWakeAPI.pas',
  GameWakeInfo in 'GameWakeInfo.pas' {Info},
  GameWakeOps in 'GameWakeOps.pas' {Options},
  GameWakeAlertThread in 'GameWakeAlertThread.pas';

{$R *.res}

begin          
  Application.Initialize;
  Application.Title := 'Game Wake';
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
