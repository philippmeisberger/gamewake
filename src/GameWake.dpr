program GameWake;

{$IFDEF PORTABLE}
{$R 'sounds.res' 'sounds.rc'}
{$ENDIF}

{$IFNDEF FPC}
{$R *.dres}
{$ENDIF}

uses
{$IFDEF UNIX}
  cthreads,
{$ENDIF}
{$IFDEF FPC}
  Interfaces, // this includes the LCL widgetset
{$ENDIF}
  Forms,
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
{$IFDEF MSWINDOWS}
  Application.MainFormOnTaskbar := True;
{$ENDIF}
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
