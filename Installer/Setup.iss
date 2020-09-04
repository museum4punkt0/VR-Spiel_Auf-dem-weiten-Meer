#define AppDate GetDateTimeString('yyyy/mm/dd', '', '')

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl";

[Messages]
[CustomMessages]
english.AdditionalOptions=Additional options:
english.AutoBootMsg=Run this application when the computer starts up
english.InstallTeamviewer=Install Teamviewer 10 host
english.LaunchProgram=Start application after installing

[Setup]
SetupLogging=yes
VersionInfoDescription={#AppName}
VersionInfoProductName={#AppName}
VersionInfoCopyright=(c) IJsfontein BV, Amsterdam
VersionInfoProductTextVersion=version {#AppVersion}(build {#AppBuild}).({#AppDate})
VersionInfoVersion={#AppVersion}
VersionInfoCompany=IJsfontein BV, Amsterdam
AppName={#AppName}
AppVersion={#AppVersion} build {#AppBuild}
AppVerName={#AppName}
AppPublisher=IJsfontein
AppPublisherURL=http://www.ijsfontein.nl
AppSupportURL=http://www.ijsfontein.nl
AppUpdatesURL=https://updates.ijsfontein.nl/...
DefaultDirName={pf32}\{#AppName}
DefaultGroupName={#AppName}
OutputBaseFilename={#SetupName}
OutputDir=../
Compression=lzma/normal
SolidCompression=no
ShowLanguageDialog=auto
UsePreviousLanguage=no

;make compatible with 64-bit systems
ArchitecturesInstallIn64BitMode=x64 ia64

;always restart
AlwaysRestart=no

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "autoboot"; Description: "{cm:AutoBootMsg}";
Name: "launch"; Description: "{cm:LaunchProgram}";

[Files]
;Source: "icon.ico"; DestDir: "{app}";

; Main application
Source: "{#SourceDir}\*"; DestDir: "{app}\"; Flags: recursesubdirs ignoreversion;

; read me
Source: "..\README.pdf"; DestDir: "{app}\"; Flags: isreadme;

; Stream Deck Profile
Source: ".\VR.streamDeckProfile"; DestDir: "{commondesktop}\";
; Batch files for Stream Deck
Source: ".\Restart.bat"; DestDir: "{commondesktop}\";
Source: ".\Shutdown.bat"; DestDir: "{commondesktop}\";

[InstallDelete]

[UninstallDelete]
Type: filesandordirs; Name: "{app}\*";

[Icons]
;icons for all components:
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"; WorkingDir: "{app}"

Tasks: autoboot; Name: "{userstartup}\{#AppName}"; Filename:"{app}\run.bat";

;Link to executable
Name: "{group}\{#AppName}"; Filename: "{app}\run.bat"; WorkingDir: "{app}"

;Create desktop icon
Tasks: desktopicon; Name: "{commondesktop}\{#AppName}"; Filename: "{app}\run.bat"; WorkingDir: "{app}";


[Run]

Filename: {app}\run.bat; Description: {cm:LaunchProgram}; Flags: nowait postinstall; Tasks: launch;
