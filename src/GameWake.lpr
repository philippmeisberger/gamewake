program GameWake;

{$define UseCThreads}

{$R 'changelog.res' 'changelog.rc'}
{$R 'description.res' 'description.rc'}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, GameWakeMain;

{$R *.res}

begin
  Application.Title := 'Game Wake';
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
