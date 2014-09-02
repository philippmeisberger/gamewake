{ *********************************************************************** }
{                                                                         }
{ Tray Icon API v2.0                                                      }
{                                                                         }
{ Copyright (c) 2011-2014 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit TrayIconAPI;

interface

uses
  Windows, SysUtils, Messages, ShellAPI, Classes;

const
  { Function const }
  NIF_INFO = $10;
  NIF_MESSAGE = 1;
  NIF_ICON = 2;
  NOTIFYICON_VERSION = 3;
  NIF_TIP = 4;
  NIM_SETVERSION = $00000004;
  NIM_SETFOCUS = $00000003;

  { Icon const }
  NIIF_INFO = $00000001;
  NIIF_WARNING = $00000002;
  NIIF_ERROR = $00000003;

  NIN_BALLOONSHOW = WM_USER + 2;
  NIN_BALLOONHIDE = WM_USER + 3;
  NIN_BALLOONTIMEOUT = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  NIN_SELECT = WM_USER + 0;
  NINF_KEY = $1;
  NIN_KEYSELECT = NIN_SELECT or NINF_KEY;

  { Callback-Message }
  TRAY_CALLBACK = WM_USER + $7258;
  WM_TASKABAREVENT = WM_USER + 1;

type
  { new NotifyIconData structure definition }
  PNewNotifyIconData = ^TNewNotifyIconData;
  TDUMMYUNIONNAME    = record
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;

  TNewNotifyIconData = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of Char;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of Char;
    DUMMYUNIONNAME: TDUMMYUNIONNAME;
    szInfoTitle: array [0..63] of Char;
    dwInfoFlags: DWORD;
  end;

  { Mousebuttons from Control.pas }
  TMouseButton = (mbLeft, mbRight, mbMiddle);

  { Events }
  TOnMouseUpEvent = procedure(Sender: TObject; AButton: TMouseButton; X, Y: Integer) of object;
  TOnMouseDblClickEvent = procedure(Sender: TObject; X, Y: Integer) of object;
  TOnBalloonClickEvent = procedure(Sender: TObject) of object;
  TOnBalloonShowEvent = procedure(Sender: TObject) of object;
  TOnBalloonHideEvent = procedure(Sender: TObject) of object;
  TOnBalloonTimeOutEvent = procedure(Sender: TObject) of object;

  { TTrayIcon }
  TTrayIcon = class
  private
    FTrayIconName: string;                //Name shown on mouseover-event
    FIconHandle: HICON;                   //Application.Icon.Handle
    FTimeOutInterval: Cardinal;           //Interval in milliseconds
    FIconData: TNewNotifyIconData;
    FOnMouseUp: TOnMouseUpEvent;
    FOnDblClick: TOnMouseDblClickEvent;
    FOnClick: TOnBalloonClickEvent;
    FOnShow: TOnBalloonShowEvent;
    FOnHide: TOnBalloonHideEvent;
    FOnTimeOut: TOnBalloonTimeOutEvent;
    procedure DoNotifyOnClick;
    procedure OnNotifyOnDblClick(X, Y: Integer);
    procedure DoNotifyOnHide;
    procedure DoNotifyOnMouseUp(AButton: TMouseButton; X, Y: Integer);
    procedure DoNotifyOnShow;
    procedure DoNotifyOnTimeOut;
    procedure SetTrayIconName(ANewName: string);
    procedure TrayIconMsgHandler(var Msg: TMessage); message TRAY_CALLBACK;
  public
    constructor Create(ATrayIconName: string; AIconHandle: HIcon;
      ATimeOutInterval: Cardinal = 3000);
    destructor Destroy; override;
    procedure BalloonTip(AText: string; AIconID: Cardinal = NIIF_INFO); overload;
    procedure BalloonTip(AText: string; ACaption: string;
      AIconID: Cardinal = NIIF_INFO); overload;
    { external }
    property Name: string read FTrayIconName write SetTrayIconName;
    property OnClick: TOnBalloonClickEvent read FOnClick write FOnClick;
    property OnDblClick: TOnMouseDblClickEvent read FOnDblClick write FOnDblClick;
    property OnHide: TOnBalloonHideEvent read FOnHide write FOnHide;
    property OnMouseUp: TOnMouseUpEvent read FOnMouseUp write FOnMouseUp;
    property OnShow: TOnBalloonShowEvent read FOnShow write FOnShow;
    property OnTimeOut: TOnBalloonTimeOutEvent read FOnTimeOut write FOnTimeOut;
    property TimeOut: Cardinal read FTimeOutInterval write FTimeOutInterval;
  end;
  
implementation

{ TTrayIcon }

constructor TTrayIcon.Create(ATrayIconName: string; AIconHandle: HIcon;
  ATimeOutInterval: Cardinal = 3000);
begin
  FTrayIconName := ATrayIconName;
  FIconHandle := AIconHandle;
  FTimeOutInterval := ATimeOutInterval;

  with FIconData do
  begin
    cbSize := SizeOf(FIconData);
    Wnd := AllocateHWnd(TrayIconMsgHandler);       //Form Handle
    uID := 0;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallbackMessage := TRAY_CALLBACK;             //Callback-Message
    hIcon := AIconHandle;                          //Icon Handle
    StrPLCopy(szTip, FTrayIconName, SizeOf(szTip) - 1);  //Name of Tray Icon
  end;  //of with

  //Shell_NotifyIcon(NIM_ADD, @FIconData);           //Add Tray-Icon
end;


destructor TTrayIcon.Destroy;
begin
  //Shell_NotifyIcon(NIM_DELETE, @FIconData);        //Remove Tray-Icon
  DeallocateHWnd(FIconData.Wnd);
end;

{ private }
procedure TTrayIcon.DoNotifyOnClick;
begin
  if Assigned(FOnClick) then
     FOnClick(Self);
end;


procedure TTrayIcon.OnNotifyOnDblClick(X, Y: Integer);
begin
  if Assigned(FOnDblClick) then
     FOnDblClick(Self, X, Y);
end;


procedure TTrayIcon.DoNotifyOnHide;
begin
  if Assigned(FOnHide) then
     FOnHide(Self);
end;


procedure TTrayIcon.DoNotifyOnMouseUp(AButton: TMouseButton; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
     FOnMouseUp(Self, AButton, X, Y);
end;


procedure TTrayIcon.DoNotifyOnShow;
begin
  if Assigned(FOnShow) then
     FOnShow(Self);
end;


procedure TTrayIcon.DoNotifyOnTimeOut;
begin
  if Assigned(FOnTimeOut) then
     FOnTimeOut(Self);
end;


procedure TTrayIcon.SetTrayIconName(ANewName: string);   //Change name Tray Icon
begin
  FTrayIconName := ANewName;
  StrPLCopy(FIconData.szTip, ANewName, SizeOf(FIconData.szTip) - 1);  
end;


procedure TTrayIcon.TrayIconMsgHandler(var Msg: TMessage);
var
  X, Y: Integer;

  procedure GetCoordinates(var X, Y: Integer);
  var
    Point: TPoint;

  begin
    GetCursorPos(Point);                  //get cursor position
    X := Point.X;                         //X-coordinate
    Y := Point.Y;                         //Y-coordinate
  end;

begin
  case Msg.LParam of
    WM_LBUTTONUP:
      begin
      GetCoordinates(X, Y);
      DoNotifyOnMouseUp(mbLeft, X, Y);
      end;  //of begin

    WM_RBUTTONUP:
      begin
      GetCoordinates(X, Y);
      DoNotifyOnMouseUp(mbRight, X, Y);
      end;  //of begin

    WM_LBUTTONDBLCLK:
      begin
      GetCoordinates(X, Y);
      OnNotifyOnDblClick(X, Y);
      end;  //of begin

    NIN_BALLOONSHOW:
      DoNotifyOnShow;
      //Sent when the balloon is shown

    NIN_BALLOONHIDE:
      DoNotifyOnHide;
      //Sent when the balloon disappears?Rwhen the icon is deleted,
      //for example. This message is not sent if the balloon is dismissed because of
      //a timeout or mouse click by the user.

    NIN_BALLOONTIMEOUT:
      DoNotifyOnTimeOut;
      //Sent when the balloon is dismissed because of a timeout.

    NIN_BALLOONUSERCLICK:
      DoNotifyOnClick;
      //Sent when the balloon is dismissed because the user clicked the mouse.
      //Note: in XP there's Close button on he balloon tips, when click the button,
      //send NIN_BALLOONTIMEOUT message actually.
  end;  //of case
end;

{ public }
procedure TTrayIcon.BalloonTip(AText: string; AIconID: Cardinal = NIIF_INFO);
begin
  BalloonTip(AText, FTrayIconName, AIconID);
end;


procedure TTrayIcon.BalloonTip(AText: string; ACaption: string;
  AIconID: Cardinal = NIIF_INFO);                              //Show Ballon Tip
begin
  with FIconData do
  begin
    cbSize := SizeOf(FIconData);
    uFlags := NIF_INFO;
    StrPLCopy(szInfo, AText, SizeOf(szInfo) - 1);
    DUMMYUNIONNAME.uTimeout := FTimeOutInterval;
    StrPLCopy(szInfoTitle, ACaption, SizeOf(szInfoTitle) - 1);
    dwInfoFlags := AIconID;    //NIIF_INFO, NIIF_ERROR, NIIF_WARNING
  end;  //of with

  //Shell_NotifyIcon(NIM_MODIFY, @FIconData);
end;

end.
