program GameWake;

{$R 'changelog.res' 'changelog.rc'}
{$R 'description.res' 'description.rc'}

{$IFDEF PORTABLE}
{$R 'sounds.res' 'sounds.rc'}
{$ENDIF}

uses
  Vcl.Forms,
  GameWakeMain in 'GameWakeMain.pas' {Main},
  GameWakeAPI in 'GameWakeAPI.pas',
  GameWakeOps in 'GameWakeOps.pas' {Options};

{$R *.res}

begin          
  Application.Initialize;
  Application.Title := 'Game Wake';
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
