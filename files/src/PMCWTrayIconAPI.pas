{ *********************************************************************** }
{                                                                         }
{ Tray Icon Windows API v2.1                                              }
{                                                                         }
{ Copyright (c) 2011-2015 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

unit PMCWTrayIconAPI;

interface

uses
  Windows, SysUtils, Messages, ShellAPI, Classes, Forms;

const
  { uFlags possible values }
  // Indicates that the uCallbackMessage member is valid
  NIF_MESSAGE = $00000001;

  // Indicates that the hIcon member is valid
  NIF_ICON = $00000002;

  // Indicates that the szTip member is valid
  NIF_TIP = $00000004;

  // Indicates that the dwState and dwStateMask members are valid
  NIF_STATE = $00000008;

  // Display a balloon notification. The szInfo, szInfoTitle, dwInfoFlags, and
  // uTimeout members are valid. Note: uTimeout is valid only in Windows 2000
  // and Windows XP.
  NIF_INFO = $00000010;

  // Indicates that the guidItem is valid. Note: Should only be used in Windows 7 and later.
  NIF_GUID = $00000020;

  // Use the standard tooltip. Normally, when uVersion is set to
  // NOTIFYICON_VERSION_4, the standard tooltip is suppressed and can be
  // replaced by the application-drawn, pop-up UI.
  NIF_SHOWTIP = $00000080;

  { dwState possible values }
  // Indicates that the icon is hidden.
  NIS_HIDDEN = $00000001;

  // Indicates that the icon resource is shared between multiple icons.
  NIS_SHAREDICON = $00000002;

  { uVersion possible values }
  // Indicates to use the Windows 2000 behavior.
  NOTIFYICON_VERSION = $00000003;

  // Indicates to use the behavior for Windows Vista and later.
  NOTIFYICON_VERSION_4 = $00000004;

  { dwInfoFlags possible values }
  // Indicates that no icon shall be displayed.
  NIIF_NONE =$00000000;

  // Indicates that an information icon shall be used.
  NIIF_INFO = $00000001;

  // Indicates that a warning icon shall be used.
  NIIF_WARNING = $00000002;

  // Indicates that an error icon shall be used.
  NIIF_ERROR = $00000003;

  // Windows XP: Indicates that the hIcon should be used as message icon.
  // Since Windows Vista: Indicates that the hBalloonIcon should be used as message icon.
  NIIF_USER = $00000004;

  // Since Windows XP: Do not play the associated sound. Applies only to notifications.
  NIIF_NOSOUND = $00000010;

  // Windows Vista and later: The large version of the icon should be used as the notification icon.
  NIIF_LARGE_ICON = $00000020;

  // Do not display the balloon notification if the current user is in
  // "quiet time", which is the first hour after a new user logs into his or
  // her account for the first time.
  NIIF_RESPECT_QUIET_TIME = $00000080;

  { Event callback values }
  NIN_BALLOONSHOW = WM_USER + 2;
  NIN_BALLOONHIDE = WM_USER + 3;
  NIN_BALLOONTIMEOUT = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  NIN_SELECT = WM_USER + 0;
  NINF_KEY = $1;
  NIN_KEYSELECT = NIN_SELECT or NINF_KEY;

  TRAY_CALLBACK = WM_USER + $7258;
  WM_TASKABAREVENT = WM_USER + 1;

  { Additional Shell_NotifyIcon dwMessages }
  NIM_SETFOCUS    = $00000003;
  NIM_SETVERSION  = $00000004;

type
  { union class definition }
  TNotifyIconDataUnion = record
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT);
  end;

  { Pointer definition }
  PNewNotifyIconData = ^TNewNotifyIconData;

  { TNewNotifyIconData }
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
    uNotifyIconDataUnion: TNotifyIconDataUnion;
    szInfoTitle: array [0..63] of Char;
    dwInfoFlags: DWORD;
  end;

  { Mousebuttons from Control.pas }
  TMouseButton = (mbLeft, mbRight, mbMiddle);

  { Events }
  TOnMouseUpEvent = procedure(Sender: TObject; AButton: TMouseButton; X, Y: Integer) of object;
  TOnMouseDblClickEvent = procedure(Sender: TObject; X, Y: Integer) of object;

  { TTrayIcon }
  TTrayIcon = class(TObject)
  private
    FTrayIconName: string;                //Name shown on mouseover-event
    FIconHandle: HICON;                   //Application.Icon.Handle
    FTimeOutInterval: Cardinal;           //Interval in milliseconds
    FIconData: TNewNotifyIconData;
    FOnMouseUp: TOnMouseUpEvent;
    FOnDblClick: TOnMouseDblClickEvent;
    FOnClick, FOnShow, FOnHide, FOnTimeOut: TNotifyEvent;
    procedure DoNotifyOnClick;
    procedure DoNotifyOnDblClick(X, Y: Integer);
    procedure DoNotifyOnHide;
    procedure DoNotifyOnMouseUp(AButton: TMouseButton; X, Y: Integer);
    procedure DoNotifyOnShow;
    procedure DoNotifyOnTimeOut;
    procedure SetTrayIconName(ANewName: string);
    procedure TrayIconMsgHandler(var Msg: TMessage); message TRAY_CALLBACK;
  public
    constructor Create(AOwner: TApplication; ATimeOutInterval: Cardinal = 3000); overload;
    constructor Create(ATrayIconName: string; AIconHandle: HIcon;
      ATimeOutInterval: Cardinal = 3000); overload;
    destructor Destroy; override;
    procedure BalloonTip(AText: string; AIconID: Cardinal = NIIF_INFO); overload;
    procedure BalloonTip(AText: string; ACaption: string;
      AIconID: Cardinal = NIIF_INFO); overload;
    { external }
    property Name: string read FTrayIconName write SetTrayIconName;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TOnMouseDblClickEvent read FOnDblClick write FOnDblClick;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnMouseUp: TOnMouseUpEvent read FOnMouseUp write FOnMouseUp;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnTimeOut: TNotifyEvent read FOnTimeOut write FOnTimeOut;
    property TimeOut: Cardinal read FTimeOutInterval write FTimeOutInterval;
  end;

implementation

{ TTrayIcon }

{ public TTrayIcon.Create

  Constructor for creating a TTrayIcon instance. }

constructor TTrayIcon.Create(AOwner: TApplication; ATimeOutInterval: Cardinal = 3000);
begin
  Create(AOwner.Title, AOwner.Icon.Handle, ATimeOutInterval);
end;

{ public TTrayIcon.Create

  Constructor for creating a TTrayIcon instance. }

constructor TTrayIcon.Create(ATrayIconName: string; AIconHandle: HIcon;
  ATimeOutInterval: Cardinal = 3000);
begin
  inherited Create;
  FTrayIconName := ATrayIconName;
  FIconHandle := AIconHandle;
  FTimeOutInterval := ATimeOutInterval;

  with FIconData do
  begin
    cbSize := SizeOf(FIconData);
    Wnd := Classes.AllocateHWnd(TrayIconMsgHandler);      //Form Handle
    uID := 0;
    hIcon := AIconHandle;                                 //Icon Handle
    uCallbackMessage := TRAY_CALLBACK;                    //Callback-Message
    StrPLCopy(szTip, FTrayIconName, SizeOf(szTip) - 1);   //Name of Tray Icon
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uNotifyIconDataUnion.uTimeout := FTimeOutInterval;
  end;  //of with

  Shell_NotifyIcon(NIM_ADD, @FIconData);                  //Add Tray-Icon
end;

{ public TTrayIcon.Destroy

  Destructor for destroying a TTrayIcon instance. }

destructor TTrayIcon.Destroy;
begin
  Shell_NotifyIcon(NIM_DELETE, @FIconData);               //Remove Tray-Icon
  Classes.DeallocateHWnd(FIconData.Wnd);
  inherited Destroy;
end;

{ private TTrayIcon.DoNotifyOnClick

  Event method that is called when balloon tip is clicked. }

procedure TTrayIcon.DoNotifyOnClick;
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

{ private TTrayIcon.DoNotifyOnDblClick

  Event method that is called when balloon tip is double clicked. }

procedure TTrayIcon.DoNotifyOnDblClick(X, Y: Integer);
begin
  if Assigned(FOnDblClick) then
    FOnDblClick(Self, X, Y);
end;

{ private TTrayIcon.DoNotifyOnHide

  Event method that is called when balloon tip is hidden. }

procedure TTrayIcon.DoNotifyOnHide;
begin
  if Assigned(FOnHide) then
    FOnHide(Self);
end;

{ private TTrayIcon.DoNotifyOnMouseUp

  Event method that is called when balloon tip was clicked and mouse button
  was released. }

procedure TTrayIcon.DoNotifyOnMouseUp(AButton: TMouseButton; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, AButton, X, Y);
end;

{ private TTrayIcon.DoNotifyOnShow

  Event method that is called when balloon tip is shown. }

procedure TTrayIcon.DoNotifyOnShow;
begin
  if Assigned(FOnShow) then
    FOnShow(Self);
end;

{ private TTrayIcon.DoNotifyOnTimeOut

  Event method that is called when balloon tip is dismissed because of a timeout. }

procedure TTrayIcon.DoNotifyOnTimeOut;
begin
  if Assigned(FOnTimeOut) then
    FOnTimeOut(Self);
end;

{ private TTrayIcon.SetTrayIconName

  Changes the name of tray icon. }

procedure TTrayIcon.SetTrayIconName(ANewName: string);
begin
  FTrayIconName := ANewName;
  StrPLCopy(FIconData.szTip, ANewName, SizeOf(FIconData.szTip) - 1);
end;

{ private TTrayIcon.TrayIconMsgHandler

  Manages events invoked by balloon tip. }

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
        DoNotifyOnDblClick(X, Y);
      end;  //of begin

    NIN_BALLOONSHOW:
      // Sent when the balloon is shown
      DoNotifyOnShow;

    NIN_BALLOONHIDE:
      // Sent when the balloon disappears or when the icon is deleted,
      // for example. This message is not sent if the balloon is dismissed
      // because of a timeout or mouse click by the user.
      DoNotifyOnHide;

    NIN_BALLOONTIMEOUT:
      // Sent when the balloon is dismissed because of a timeout.
      DoNotifyOnTimeOut;

    NIN_BALLOONUSERCLICK:
      // Sent when the balloon is dismissed because the user clicked the mouse.
      // Note: in XP there's Close button on he balloon tips, when click the
      // button, send NIN_BALLOONTIMEOUT message actually.
      DoNotifyOnClick;
  end;  //of case
end;

{ public TTrayIcon.BalloonTip

  Shows a balloon tip with text and per default with info icon. }

procedure TTrayIcon.BalloonTip(AText: string; AIconID: Cardinal = NIIF_INFO);
begin
  BalloonTip(AText, FTrayIconName, AIconID);
end;

{ public TTrayIcon.BalloonTip

  Shows a balloon tip with text, caption and per default with info icon. }

procedure TTrayIcon.BalloonTip(AText: string; ACaption: string;
  AIconID: Cardinal = NIIF_INFO);
begin
  with FIconData do
  begin
    cbSize := SizeOf(FIconData);
    uFlags := NIF_INFO;
    StrPLCopy(szInfo, AText, SizeOf(szInfo) - 1);
    StrPLCopy(szInfoTitle, ACaption, SizeOf(szInfoTitle) - 1);
    dwInfoFlags := AIconID;    //NIIF_INFO, NIIF_ERROR, NIIF_WARNING
  end;  //of with

  Shell_NotifyIcon(NIM_MODIFY, @FIconData);
end;

end.
