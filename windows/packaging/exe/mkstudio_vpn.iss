; MK Studio VPN — Inno Setup installer
; Compile on Windows after: flutter build windows --release --target=lib/main_prod.dart
;   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\packaging\exe\mkstudio_vpn.iss

#define MyAppName "MK Studio VPN"
#define MyAppVersion "4.1.7"
#define MyAppPublisher "MK Studio"
#define MyAppURL "https://myominnoo.org"
#define MyAppExeName "MKStudioVPN.exe"
#define MyAppId "8F2A91C4-6B3E-4D17-9A08-E5C7D4B2F1A0"

[Setup]
AppId={{#MyAppId}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL=https://t.me/mkstudio3
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\..\out
OutputBaseFilename=MK-Studio-VPN-Windows-Setup-x64
SetupIconFile=..\..\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
CloseApplications=force

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Flutter release output (relative to this .iss under windows/packaging/exe/)
Source: "..\..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
