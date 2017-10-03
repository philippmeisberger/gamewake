program GameWake;



{$IFDEF PORTABLE}
{$R 'sounds.res' 'sounds.rc'}
{$ENDIF}

{$R *.dres}

uses
  Vcl.Forms,
  GameWakeMain in 'GameWakeMain.pas' {Main},
  GameWakeAPI in 'GameWakeAPI.pas',
  GameWakeOps in 'GameWakeOps.pas' {Options};

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  Application.Initialize;
  Application.Title := 'Game Wake';
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
