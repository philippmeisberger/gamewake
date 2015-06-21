#define MyAppName "Game Wake"
#define MyAppURL "http://www.pm-codeworks.de"
#define MyAppExeName "Game Wake.exe"
#define FileVersion GetFileVersion(MyAppExeName)
#define ProductVersion GetFileProductVersion(MyAppExeName)

#define VersionFile FileOpen("..\Windows\version.txt")
#define Build FileRead(VersionFile)
#expr FileClose(VersionFile)
#undef VersionFile

[Setup]
AppId={{36300BAF-CB39-4551-A54E-53F263EB0595}
AppName={#MyAppName}
AppVersion={#FileVersion}
AppVerName={#MyAppName} {#ProductVersion}
AppCopyright=Philipp Meisberger
AppPublisher=PM Code Works
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/gamewake.html
ArchitecturesInstallIn64BitMode=x64 ia64
CreateAppDir=yes
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableDirPage=auto
DisableProgramGroupPage=yes
LicenseFile=..\Windows\eula.txt
OutputDir=.
OutputBaseFilename=game_wake_setup64
Compression=lzma
SolidCompression=yes
UninstallDisplayIcon={app}\{#MyAppExeName}
VersionInfoVersion=2.3
SignTool=Sign {srcexe}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Windows\ReadMe.pdf"; DestDir: "{app}"; Flags: isreadme
Source: "..\bell.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\beep.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\horn.wav"; DestDir: "{app}"; Flags: ignoreversion
Source: "ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Windows\Updater.exe"; DestDir: "{tmp}"; Flags: dontcopy
Source: "..\Windows\version.txt"; DestDir: "{tmp}"; Flags: dontcopy

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Game Wake ausführen"; Flags: postinstall shellexec

[Messages]
BeveledLabel=Inno Setup

[Code]
const 
  WM_Close = $0010;

procedure CloseWindow(AAppName: string);
var
  WinID: Integer;

begin                                                              
  WinID := FindWindowByWindowName(AAppName);
  
  if (WinID <> 0) then
    SendMessage(WinID, WM_CLOSE, 0, 0);
end;


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


function InitializeSetup(): Boolean;
var 
  CurBuild, ErrorCode: Integer;
  Build, TempDir: string;

begin
  Result := True;
  CloseWindow('{#MyAppName}');                                                                // Terminate Game Wake first  
    
  if RegValueExists(HKCU, 'SOFTWARE\PM Code Works\{#MyAppName}', 'Build') then                // Upgrade installation?
  begin    
    if RegQueryStringValue(HKCU, 'SOFTWARE\PM Code Works\{#MyAppName}', 'Build', Build) then  // Read build number from Registry
    try  
      CurBuild := StrToInt(Build)
    
    except
      CurBuild := 0;
    end  //of except
    else
      CurBuild := 0;

    if ({#Build} < CurBuild) then                                         // Newer build already installed?
    begin
      MsgBox('Es ist bereits eine neuere Version installiert!' +#13+ 'Das Setup wird beendet!', mbINFORMATION, MB_OK);
      Result := False;                                                    // Terminate setup!                                                            
    end  //of begin
    else
    begin
      // Copy Updater and version file to tmp directory
      ExtractTemporaryFile('Updater.exe');                                
      ExtractTemporaryFile('version.txt');
      ExtractTemporaryFile('libeay32.dll');
      ExtractTemporaryFile('ssleay32.dll');

      // Get user temp dir
      TempDir := ExpandConstant('{localappdata}\Temp\');

      // Launch Updater
      ShellExec('open', ExpandConstant('{tmp}\Updater.exe'), '-d GameWake -s '+ TempDir +' -i game_wake_setup.exe -o "Game Wake Setup.exe"', '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);  
    
      // Update successful?
      if (ErrorCode = 0) then
      begin
        // Launch downloaded setup
        ShellExec('open', '"'+ TempDir +'Game Wake Setup.exe"', '', TempDir, SW_SHOW, ewNoWait, ErrorCode);
        
        // Terminate current setup
        Result := False
      end;  //of begin
    end;  //of if
  end;  //of if         
end; 

[Registry]
Root: HKCU; Subkey: "SOFTWARE\PM Code Works\{#MyAppName}"; ValueType: string; ValueName: "Build"; ValueData: "{#Build}"
Root: HKCU; Subkey: "SOFTWARE\PM Code Works\{#MyAppName}"; ValueType: string; ValueName: "InstallDir"; ValueData: "{app}"; Flags: uninsdeletekey  
Root: HKCU; Subkey: "SOFTWARE\PM Code Works"; Flags: uninsdeletekeyifempty   

[UninstallDelete]     
Type: filesandordirs; Name: "{reg:HKCU\SOFTWARE\PM Code Works\Game Wake, 'InstallDir'}"
Type: filesandordirs; Name: "{userappdata}\Game Wake"
