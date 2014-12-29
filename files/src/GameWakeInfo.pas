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
  Graphics, Controls, Forms, StdCtrls, ExtCtrls, ComCtrls, SysUtils, OSUtils,
  Classes;

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
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;


implementation

{$IFDEF MSWINDOWS}
{$R *.dfm}
{$ELSE}
{$R *.lfm}
{$ENDIF}

procedure TInfo.bOkClick(Sender: TObject);
begin
  Close;
end;


procedure TInfo.FormCreate(Sender: TObject);
begin
  lBuild.Caption := 'Build: '+ IntToStr(TOSUtils.GetBuildNumber());
end;

end.