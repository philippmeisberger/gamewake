#define MyAppName "Game Wake"
#define MyAppURL "http://www.pm-codeworks.de"
#define MyAppExeName "GameWake.exe"
#define MyAppExePath32 "..\bin\Win32\Release\"
#define MyAppExePath64 "..\bin\Win64\Release\"
#define FileVersion GetFileVersion(MyAppExePath32 + MyAppExeName)
#define ProductVersion GetFileProductVersion(MyAppExePath32 + MyAppExeName)

[Setup]
AppId={{36300BAF-CB39-4551-A54E-53F263EB0595}
AppName={#MyAppName}
AppVersion={#FileVersion}
AppVerName={#MyAppName} {#ProductVersion}
AppCopyright=Philipp Meisberger
AppPublisher=PM Code Works
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/gamewake.html
CreateAppDir=yes
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=auto
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE.txt
OutputDir=.
OutputBaseFilename=game_wake_setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
VersionInfoVersion={#FileVersion}
SignTool=MySignTool sign /v /n "PM Code Works" /tr http://timestamp.globalsign.com/scripts/timstamp.dll /td SHA256 /fd SHA256 $f

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "DesktopIcon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#MyAppExePath32}{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Check: not Is64BitInstallMode
Source: "{#MyAppExePath64}{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode
Source: "..\bin\bell.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\beep.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\horn.wav"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{userappdata}\{#MyAppName}"; Flags: uninsalwaysuninstall

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: DesktopIcon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram, {#MyAppName}}"; Flags: postinstall shellexec skipifsilent

[Registry]
; Delete obsolete registry key
Root: HKCU; Subkey: "SOFTWARE\PM Code Works\{#MyAppName}"; Flags: deletekey
Root: HKCU; Subkey: "SOFTWARE\PM Code Works"; Flags: uninsdeletekeyifempty

[InstallDelete]
; Replace "Game Wake.exe" by "GameWake.exe"
Type: files; Name: "{app}\Game Wake.exe"
; Delete old start menu group
Type: filesandordirs; Name: "{group}"

[UninstallDelete]
Type: files; Name: "{userappdata}\{#MyAppName}\gamewake.ini"

[Messages]
BeveledLabel=Inno Setup

[Code]
procedure UrlLabelClick(Sender: TObject);
var
  ErrorCode : Integer;

begin
  ShellExec('open', ExpandConstant('{#MyAppURL}'), '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;


procedure InitializeWizard;
var
  UrlLabel: TNewStaticText;
  CancelBtn: TButton;

begin
  CancelBtn := WizardForm.CancelButton;
  UrlLabel := TNewStaticText.Create(WizardForm);
  UrlLabel.Top := CancelBtn.Top + (CancelBtn.Height div 2) -(UrlLabel.Height div 2);
  UrlLabel.Left := WizardForm.ClientWidth - CancelBtn.Left - CancelBtn.Width;
  UrlLabel.Caption := 'www.pm-codeworks.de';
  UrlLabel.Font.Style := UrlLabel.Font.Style + [fsUnderline];
  UrlLabel.Cursor := crHand;
  UrlLabel.Font.Color := clHighlight;
  UrlLabel.OnClick := @UrlLabelClick;
  UrlLabel.Parent := WizardForm;
end;
