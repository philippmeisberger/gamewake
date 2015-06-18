program GameWake;

uses
  Forms,
  GameWakeMain in 'GameWakeMain.pas' {Main},
  GameWakeAPI in 'GameWakeAPI.pas',
  GameWakeInfo in 'GameWakeInfo.pas' {Info},
  GameWakeOps in 'GameWakeOps.pas' {Options},
  AlertThread in 'AlertThread.pas';

{$R *.res}

begin          
  Application.Initialize;
  Application.Title := 'Game Wake';
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
