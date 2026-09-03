[Setup]
AppId={{D1E5F8A2-304B-4E02-8901-20268E7A0001}}
AppName=TejaBeats
AppVersion=3.0.4
AppPublisher=TejaBeats
DefaultDirName={autopf}\TejaBeats
DefaultGroupName=TejaBeats
UninstallDisplayIcon={app}\TejaBeats.exe
Compression=lzma2/ultra64
SolidCompression=yes
OutputDir=c:\tejamusic\BloomeeTunes-3.0.4-202\BloomeeTunes-3.0.4-202
OutputBaseFilename=TejaBeats-Windows
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "c:\tejamusic\BloomeeTunes-3.0.4-202\BloomeeTunes-3.0.4-202\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\TejaBeats"; Filename: "{app}\TejaBeats.exe"
Name: "{autodesktop}\TejaBeats"; Filename: "{app}\TejaBeats.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\TejaBeats.exe"; Description: "{cm:LaunchProgram,TejaBeats}"; Flags: nowait postinstall skipifsilent
