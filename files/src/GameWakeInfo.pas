{ *********************************************************************** }
{                                                                         }
{ Game Wake Info Unit                                                     }
{                                                                         }
{ Copyright (c) 2011-2015 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit GameWakeInfo;

{$IFDEF LINUX} {$mode objfpc}{$H+} {$ENDIF}

interface

uses
  Graphics, Controls, Forms, StdCtrls, ExtCtrls, ComCtrls, SysUtils, Classes,
  PMCWUpdater;

type
  { TInfo }
  TInfo = class(TForm)
    PageControl: TPageControl;
    tsInfo: TTabSheet;
    tsHistory: TTabSheet;
    mInfo: TMemo;
    mHistroy: TMemo;
    bOk: TButton;
    lCopy2: TLabel;
    bOk2: TButton;
    lVersion: TLabel;
    Image: TImage;
    l_copy: TLabel;
    lBuild: TLabel;
    procedure FormCreate(Sender: TObject);
  end;


implementation

{$IFDEF MSWINDOWS}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

procedure TInfo.FormCreate(Sender: TObject);
begin
{$IFDEF PORTABLE}
  lBuild.WordWrap := True;
  lBuild.Caption := 'Build: '+ IntToStr(TUpdateCheck.GetBuildNumber()) +' Portable';
{$ELSE}
  lBuild.Caption := 'Build: '+ IntToStr(TUpdateCheck.GetBuildNumber());
{$ENDIF}
end;

end.