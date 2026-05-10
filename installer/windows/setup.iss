; ─────────────────────────────────────────────────────────────────────────────
; Inno Setup 6 — NervScansFusion
; Appelé : iscc.exe /DMyAppVersion="..." /DSourceDir="C:\...\deploy" setup.iss
; ─────────────────────────────────────────────────────────────────────────────

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\..\deploy"
#endif

#define MyAppName      "NervScansFusion"
#define MyAppPublisher "NervScans"
#define MyAppURL       "https://example.com"
#define MyAppExeName   "NervScansFusion.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes

; Sortie dans installer/windows/dist/
OutputDir=dist
OutputBaseFilename={#MyAppName}-Setup

Compression=lzma2/ultra64
SolidCompression=yes

ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

WizardStyle=modern
WizardResizable=no

PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

Uninstallable=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}

CloseApplications=no
RestartApplications=no

[Languages]
Name: "french";  MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ── Exécutable ────────────────────────────────────────────────────────────────
Source: "{#SourceDir}\{#MyAppExeName}";         DestDir: "{app}"; Flags: ignoreversion

; ── DLL Qt ────────────────────────────────────────────────────────────────────
Source: "{#SourceDir}\Qt6Core.dll";             DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Qt6Gui.dll";              DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Qt6Widgets.dll";          DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Qt6Network.dll";          DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\Qt6Svg.dll";              DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

; ── VC++ Runtime — redistribuable officiel Microsoft ─────────────────────────
; windeployqt copie vc_redist.x64.exe automatiquement dans le dossier deploy.
; On l'exécute silencieusement : installe vcruntime140.dll, msvcp140.dll,
; msvcp140_1.dll et toutes les variantes d'un seul coup.
Source: "{#SourceDir}\vc_redist.x64.exe";       DestDir: "{tmp}"; Flags: deleteafterinstall

; ── Plugin platform OBLIGATOIRE ───────────────────────────────────────────────
Source: "{#SourceDir}\platforms\qwindows.dll";  DestDir: "{app}\platforms"; Flags: ignoreversion

; ── Plugins Qt ────────────────────────────────────────────────────────────────
Source: "{#SourceDir}\imageformats\*";  DestDir: "{app}\imageformats";  Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\iconengines\*";   DestDir: "{app}\iconengines";   Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceDir}\styles\*";        DestDir: "{app}\styles";        Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceDir}\generic\*";       DestDir: "{app}\generic";       Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceDir}\tls\*";           DestDir: "{app}\tls";           Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

[Icons]
Name: "{group}\{#MyAppName}";              Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Désinstaller {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}";        Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; 1. Installe le VC++ runtime silencieusement AVANT de lancer l'appli
;    Règle définitivement MSVCP140_1.dll et toutes les variantes manquantes
Filename: "{tmp}\vc_redist.x64.exe"; \
  Parameters: "/install /quiet /norestart"; \
  StatusMsg: "Installation du runtime Visual C++..."; \
  Flags: runascurrentuser waituntilterminated

; 2. Propose de lancer l'application à la fin
Filename: "{app}\{#MyAppExeName}"; \
  Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Type: filesandordirs; Name: "{localappdata}\{#MyAppName}"
