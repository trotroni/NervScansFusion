; ─────────────────────────────────────────────────────────────────────────────
; Inno Setup 6 — Script de packaging pour application Qt6 (C++17)
; Utilisé par : .github/workflows/build.yml
;
; Génère : dist\MyApp-Setup.exe
; Appelé avec : iscc.exe /DMyAppVersion="..." /DSourceDir="..." setup.iss
; ─────────────────────────────────────────────────────────────────────────────

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

#ifndef SourceDir
  #define SourceDir "..\..\deploy"
#endif

#define MyAppName      "NervScansFusion"
#define MyAppPublisher "Mon Entreprise"
#define MyAppURL       "https://example.com"
#define MyAppExeName   "NervScansFusion.exe"
#define OutDir         "..\..\dist"

[Setup]
; ── Identité ─────────────────────────────────────────────────────────────────
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}}
; IMPORTANT : Génère ton propre GUID avec https://guidgen.com
; Ne change jamais l'AppId une fois publié (Windows s'en sert pour la mise à jour)

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; ── Répertoire d'installation ─────────────────────────────────────────────────
DefaultDirName={autopf}\{#MyAppName}
; {autopf} = C:\Program Files sur 64-bit (correct, pas besoin de hardcoder)

DefaultGroupName={#MyAppName}
AllowNoIcons=yes

; ── Sortie ────────────────────────────────────────────────────────────────────
; OutputDir={#OutDir}
OutputDir=dist
OutputBaseFilename={#MyAppName}-Setup
; SetupIconFile=..\..\resources\app.ico   ; Ton icône .ico — commente si absent

; ── Compression ───────────────────────────────────────────────────────────────
Compression=lzma2/ultra64
SolidCompression=yes

; ── Architecture ──────────────────────────────────────────────────────────────
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

; ── Wizard (interface de l'installeur) ───────────────────────────────────────
WizardStyle=modern
WizardResizable=no

; ── Droits requis ─────────────────────────────────────────────────────────────
; "lowest" = pas besoin d'être admin (recommandé si possible)
; Change en "admin" si ton appli écrit dans Program Files strictement
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; ── Désinstalleur ─────────────────────────────────────────────────────────────
Uninstallable=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
CreateUninstallRegKey=yes

; ── Infos registre (ajout/suppression propre) ─────────────────────────────────
ChangesAssociations=no

; ── Redémarrage ───────────────────────────────────────────────────────────────
; Qt6 apps ne nécessitent pas de redémarrage
CloseApplications=no
RestartApplications=no

[Languages]
; Ajoute les langues voulues (les .isl sont dans l'install Inno Setup)
Name: "french";    MessagesFile: "compiler:Languages\French.isl"
Name: "english";   MessagesFile: "compiler:Default.isl"

[Tasks]
; Cases à cocher proposées à l'utilisateur pendant l'install
Name: "desktopicon";     Description: "{cm:CreateDesktopIcon}";     GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
; ── Exécutable principal ──────────────────────────────────────────────────────
Source: "{#SourceDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; ── DLL Qt (Core, Gui, Widgets, Network…) ────────────────────────────────────
; windeployqt les a toutes copiées dans {SourceDir}\
Source: "{#SourceDir}\Qt6Core.dll";    DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Qt6Gui.dll";     DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\Qt6Widgets.dll"; DestDir: "{app}"; Flags: ignoreversion
; Ajoute ici les DLL que ton app utilise réellement (Network, Sql, Svg…)
; Source: "{#SourceDir}\Qt6Network.dll"; DestDir: "{app}"; Flags: ignoreversion

; ── VCRUNTIME (runtime MSVC — critique pour les users sans VS installé) ────────
Source: "{#SourceDir}\vcruntime140.dll";     DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\vcruntime140_1.dll";   DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\msvcp140.dll";         DestDir: "{app}"; Flags: ignoreversion
; Note : windeployqt --release les copie déjà normalement dans SourceDir

; ── Plugin platform OBLIGATOIRE : qwindows.dll ────────────────────────────────
; Sans ce plugin, l'exe plante au démarrage avec "This application failed to start
; because no Qt platform plugin could be initialized"
; windeployqt crée ce dossier automatiquement.
Source: "{#SourceDir}\platforms\qwindows.dll"; DestDir: "{app}\platforms"; Flags: ignoreversion

; ── Plugins Qt supplémentaires copiés par windeployqt ────────────────────────
Source: "{#SourceDir}\imageformats\*";  DestDir: "{app}\imageformats";  Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\iconengines\*";   DestDir: "{app}\iconengines";   Flags: ignoreversion recursesubdirs createallsubdirs; Check: DirExists('{#SourceDir}\iconengines')
Source: "{#SourceDir}\styles\*";        DestDir: "{app}\styles";        Flags: ignoreversion recursesubdirs createallsubdirs; Check: DirExists('{#SourceDir}\styles')
; Source: "..\..\resources\*"; DestDir: "{app}\resources"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Raccourci dans le menu Démarrer
Name: "{group}\{#MyAppName}";           Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Désinstaller {#MyAppName}"; Filename: "{uninstallexe}"

; Raccourci bureau (seulement si l'utilisateur a coché la case)
Name: "{autodesktop}\{#MyAppName}";    Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Lancer l'application à la fin de l'installation (optionnel)
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Nettoie les fichiers créés à l'exécution (logs, préférences, etc.)
; Type: filesandordirs; Name: "{localappdata}\{#MyAppName}"
