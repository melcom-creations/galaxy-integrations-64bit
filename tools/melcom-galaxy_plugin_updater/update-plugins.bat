@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

rem =================================================================
rem  update-plugins.bat  -  melcom GOG Galaxy v2.1+ Plugin Updater v0.1.2
rem  Must stay in the same folder as: update-plugins-helpers.ps1
rem =================================================================

rem ---------------------------------------------------------------
rem  Console presentation
rem ---------------------------------------------------------------
for /F %%a in ('echo prompt $E^|cmd') do set "ESC=%%a"
set "C_RED=%ESC%[91m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_MAGENTA=%ESC%[95m"
set "C_GRAY=%ESC%[90m"
set "C_RESET=%ESC%[0m"
set "C_BOLD=%ESC%[1m"

rem ---------------------------------------------------------------
rem  Runtime paths and per-run files
rem ---------------------------------------------------------------
set "ROOT=%~dp0"
set "PS1=%ROOT%update-plugins-helpers.ps1"
set "PLUGINS_DIR=%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed"
set "STEAM_PLUGIN_DIR=steam_ca27391f-2675-49b1-92c0-896d43afa4f8"
set "BACKUP_DIR=%ROOT%backups"
set "LOG_DIR=%ROOT%logs"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

rem  Scan files are transient batch/PowerShell interchange files. A forced
rem  shutdown bypasses normal cleanup, so remove stale files before assigning
rem  this run's timestamped name.
if exist "%LOG_DIR%\_scan_*.tmp" del /q "%LOG_DIR%\_scan_*.tmp" >nul 2>&1

for /f %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "LOGFILE=%LOG_DIR%\update_%TS%.log"
set "SCANFILE=%LOG_DIR%\_scan_%TS%.tmp"
type nul > "%LOGFILE%"

if not exist "%PS1%" (
    echo %C_RED%[ERROR] update-plugins-helpers.ps1 not found next to this batch file.%C_RESET%
    echo %C_RED%[FEHLER] update-plugins-helpers.ps1 wurde nicht neben dieser Batch-Datei gefunden.%C_RESET%
    pause
    exit /b 1
)

rem ---------------------------------------------------------------
rem  Language selection
rem ---------------------------------------------------------------
:LANG_SELECT
cls
echo %C_BOLD%%C_CYAN%============================================================%C_RESET%
echo %C_BOLD%%C_CYAN%  melcom GOG Galaxy v2.1+ Plugin Updater v0.1.2%C_RESET%
echo %C_BOLD%%C_CYAN%============================================================%C_RESET%
echo.
echo %C_GRAY%  Checks, updates, and installs melcom's GOG Galaxy 2.1+ integrations.%C_RESET%
echo %C_GRAY%  Prueft, aktualisiert und installiert melcoms GOG Galaxy 2.1+ Integrationen.%C_RESET%
echo.
echo  [1] English (US)
echo  [2] Deutsch (DE)
echo.
echo  [x] Exit / Beenden
echo.
if defined LANG_INVALID (
    echo %C_YELLOW%Invalid input. Please choose 1, 2, or x. / Ungueltige Eingabe. Bitte 1, 2 oder x waehlen.%C_RESET%
    echo.
)
set "LANG_INVALID="
set "LANG="
set "LANGCHOICE="
set /p LANGCHOICE=Selection / Auswahl: 
if "%LANGCHOICE%"=="1" set "LANG=EN"
if "%LANGCHOICE%"=="2" set "LANG=DE"
if /i "%LANGCHOICE%"=="X" goto EXIT_NOW
if not defined LANG (
    set "LANG_INVALID=1"
    goto LANG_SELECT
)
goto LANG_DONE

:EXIT_NOW
if exist "%SCANFILE%" del /q "%SCANFILE%" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action MatrixExit -Lang "%LANG%"
endlocal
exit /b 0

:LANG_DONE
rem  Keep confirmation input consistent with the displayed language: English
rem  accepts Y, German accepts J. AskYesNo normalizes either accepted key to Y
rem  internally so downstream branches remain language-independent.
if /i "%LANG%"=="EN" (set "YESKEY=Y") else (set "YESKEY=J")

rem ---------------------------------------------------------------
rem  Text strings per language
rem ---------------------------------------------------------------
if "%LANG%"=="EN" (
    set "MSG_TITLE=melcom GOG Galaxy v2.1+ Plugin Updater v0.1.2"
    set "MSG_SCANNING=Scanning installed plugins ..."
    set "MSG_TABLE_HEAD=Folder / Status / Name"
    set "MSG_VALID=OK (melcom)"
    set "MSG_INVALID=EXCLUDED (not a melcom plugin)"
    set "MSG_NOMANIFEST=EXCLUDED (no manifest.json found)"
    set "MSG_BADJSON=EXCLUDED (manifest.json unreadable)"
    set "MSG_LEGACY=LEGACY (incomplete manifest)"
    set "MSG_LEGACY_TITLE=Legacy melcom integration detected"
    set "MSG_LEGACY_NOTICE=The manifest is incomplete, so this may be an older melcom plugin."
    set "MSG_LEGACY_RECOMMEND=Recommended: replace it with the current integration?"
    set "MSG_LEGACY_YES=[y] Yes, back up and replace"
    set "MSG_LEGACY_NO=[n] No, keep this plugin"
    set "MSG_LEGACY_UNKNOWN=No current replacement is available for this folder."
    set "MSG_SAN_TITLE=Steam Achievement Notifier"
    set "MSG_SAN_ADD_Q=Do you have the Steam Achievement Notifier installed?"
    set "MSG_SAN_ADD_EXPLAIN=If so, I can automatically add a bit of code to your plugin.py so the Steam Achievement Notifier no longer needs to be started by hand. From then on, launching a Steam game from the GOG Galaxy client will automatically start the Steam Achievement Notifier first."
    set "MSG_SAN_ADD_HINT=Not interested, or don't have it installed? Choose [n]. Already have it installed and want this? Choose [y]."
    set "MSG_SAN_DETECTED=Your Steam plugin already contains the code that automatically starts the Steam Achievement Notifier (a small free tool that pops up a notification whenever you unlock a Steam achievement) whenever you launch a Steam game from GOG."
    set "MSG_SAN_KEEP_Q=Do you want to keep it in?"
    set "MSG_SAN_YES=[y] Yes"
    set "MSG_SAN_NO=[n] No"
    set "MSG_SAN_KEPT=Steam Achievement Notifier integration kept."
    set "MSG_SAN_REMOVED=Steam Achievement Notifier integration removed."
    set "MSG_SAN_STRIP_FAIL=Could not remove the Steam Achievement Notifier integration:"
    set "MSG_SAN_ADDED=Steam Achievement Notifier integration added."
    set "MSG_SAN_ADD_FAIL=Could not add the Steam Achievement Notifier integration:"
    set "MSG_NONE_VALID=No installed melcom plugins found."
    set "MSG_INSTALL_TITLE=Install integrations"
    set "MSG_INSTALL_INTRO=Choose an integration to install:"
    set "MSG_INSTALL_ALL=[a] Install all available integrations"
    set "MSG_INSTALL_UPDATES=[n] Continue to updates"
    set "MSG_INSTALL_BACK=[b] Back to language selection"
    set "MSG_INSTALL_EXIT=[x] Exit"
    set "MSG_INSTALL_PROMPT=Selection: "
    set "MSG_INSTALL_INVALID=Invalid input. Choose a number, a, b, or x."
    set "MSG_INSTALLING=Downloading and installing ..."
    set "MSG_INSTALL_OK=Installed successfully."
    set "MSG_INSTALL_FAIL=Installation FAILED:"
    set "MSG_INSTALL_EXISTS=Already installed - skipped."
    set "MSG_INSTALLED=INSTALLED"
    set "MSG_MORE_OF=of"
    set "MSG_MORE_TITLE=Additional integrations"
    set "MSG_MORE_STATUS=melcom integrations are installed."
    set "MSG_MORE_ASK=Would you like to install more integrations?"
    set "MSG_MORE_YES=[y] Yes, show available integrations"
    set "MSG_MORE_NO=[n] No, continue to updates"
    set "MSG_MORE_INVALID=Invalid input. Only y or n are allowed."
    set "MSG_INSTALL_SUMMARY=Installation summary"
    set "MSG_DONE_INSTALLED=installed"
    set "MSG_CONFIRM_Q=Proceed and check the plugins above marked OK for updates?"
    set "MSG_CONFIRM_YES=[y] Yes, proceed"
    set "MSG_CONFIRM_BACK=[b] Back to language selection"
    set "MSG_CONFIRM_EXIT=[x] Exit"
    set "MSG_CONFIRM_PROMPT=Selection: "
    set "MSG_INVALID_INPUT=Invalid input. Only y, b, or x are allowed."
    set "MSG_ABORTED=Aborted by user. No changes were made."
    set "MSG_CHECKING=Checking for updates ..."
    set "MSG_UPTODATE=Already up to date."
    set "MSG_LOCAL_AHEAD=Locally installed version is newer than the latest published release - nothing to do."
    set "MSG_UPDATE_FOUND=Update available:"
    set "MSG_CHECK_ERROR=Could not check for updates:"
    set "MSG_BACKUP_START=Creating backup ..."
    set "MSG_BACKUP_OK=Backup created."
    set "MSG_BACKUP_FAIL=Backup FAILED - skipping this plugin for safety. See the log for details."
    set "MSG_SECRET_BN_FILE=consts.py contains your Battle.net CLIENT_ID and CLIENT_SECRET."
    set "MSG_SECRET_IT_FILE=credentials.json contains your personal itch.io access token."
    set "MSG_SECRET_BACKUP_PREFIX=Back up"
    set "MSG_SECRET_BACKUP_SUFFIX=and restore it after the update?"
    set "MSG_SECRET_SKIPPED=Skipped. You will need to sign in again after the update."
    set "MSG_SECRET_NONE=No active credentials found."
    set "MSG_SECRET_BK_OK=saved."
    set "MSG_SECRET_BK_FAIL=Could not back up the secret file - update of this plugin will be skipped:"
    set "MSG_DOWNLOADING=Downloading and installing update ..."
    set "MSG_UPDATE_OK=Update installed successfully."
    set "MSG_UPDATE_FAIL=Update FAILED. Your backup is still available in the backups folder."
    set "MSG_RESTORE_PREFIX=Restore"
    set "MSG_RESTORE_SUFFIX=now?"
    set "MSG_YN_PROMPT=[Y/N]: "
    set "MSG_YN_INVALID=Invalid input. Only y or n are allowed."
    set "MSG_RESTORE_OK=Secret file restored."
    set "MSG_RESTORE_FAIL=Could not restore the secret file. Please copy it back manually from:"
    set "MSG_SUMMARY=Summary"
    set "MSG_DONE_UPDATED=updated"
    set "MSG_DONE_SKIPPED=skipped / already up to date"
    set "MSG_DONE_FAILED=failed"
    set "MSG_LOG_SAVED=Log saved to:"
    set "MSG_PRESS_KEY=Press any key to exit ..."
    set "MSG_PLUGINSDIR_MISSING=Plugin folder not found:"
    set "MSG_PLUGINSDIR_CREATED=Plugin folder created:"
) else (
    set "MSG_TITLE=melcom GOG Galaxy v2.1+ Plugin Updater v0.1.2"
    set "MSG_SCANNING=Installierte Plugins werden gescannt ..."
    set "MSG_TABLE_HEAD=Ordner / Status / Name"
    set "MSG_VALID=OK (melcom)"
    set "MSG_INVALID=AUSGESCHLOSSEN (kein melcom-Plugin)"
    set "MSG_NOMANIFEST=AUSGESCHLOSSEN (keine manifest.json gefunden)"
    set "MSG_BADJSON=AUSGESCHLOSSEN (manifest.json nicht lesbar)"
    set "MSG_LEGACY=ALT (unvollstaendiges Manifest)"
    set "MSG_LEGACY_TITLE=Alte melcom-Integration gefunden"
    set "MSG_LEGACY_NOTICE=Das Manifest ist unvollstaendig. Es kann ein aelteres melcom-Plugin sein."
    set "MSG_LEGACY_RECOMMEND=Empfehlung: Mit der aktuellen Integration ersetzen?"
    set "MSG_LEGACY_YES=[j] Ja, sichern und ersetzen"
    set "MSG_LEGACY_NO=[n] Nein, dieses Plugin behalten"
    set "MSG_LEGACY_UNKNOWN=Fuer diesen Ordner ist keine aktuelle Integration verfuegbar."
    set "MSG_SAN_TITLE=Steam Achievement Notifier"
    set "MSG_SAN_ADD_Q=Hast du den Steam Achievement Notifier installiert?"
    set "MSG_SAN_ADD_EXPLAIN=Falls ja, kann ich automatisch etwas Code in deine plugin.py einfuegen, damit der Steam Achievement Notifier nicht mehr manuell gestartet werden muss. Startest du kuenftig ein Steam-Spiel aus dem GOG Galaxy Client heraus, wird der Steam Achievement Notifier zuvor automatisch gestartet."
    set "MSG_SAN_ADD_HINT=Kein Interesse oder nicht installiert? Waehle [n]. Bereits installiert und interessiert? Waehle [j]."
    set "MSG_SAN_DETECTED=In deinem Steam-Plugin ist bereits der Code enthalten, der den Steam Achievement Notifier (ein kleines kostenloses Tool, das eine Benachrichtigung einblendet, sobald du eine Steam-Errungenschaft freischaltest) automatisch startet, sobald du ein Steam-Spiel aus GOG heraus startest."
    set "MSG_SAN_KEEP_Q=Willst du ihn weiterhin drin haben?"
    set "MSG_SAN_YES=[j] Ja"
    set "MSG_SAN_NO=[n] Nein"
    set "MSG_SAN_KEPT=Steam Achievement Notifier Integration beibehalten."
    set "MSG_SAN_REMOVED=Steam Achievement Notifier Integration entfernt."
    set "MSG_SAN_STRIP_FAIL=Steam Achievement Notifier Integration konnte nicht entfernt werden:"
    set "MSG_SAN_ADDED=Steam Achievement Notifier Integration hinzugefuegt."
    set "MSG_SAN_ADD_FAIL=Steam Achievement Notifier Integration konnte nicht hinzugefuegt werden:"
    set "MSG_NONE_VALID=Keine installierten melcom-Plugins gefunden."
    set "MSG_INSTALL_TITLE=Integrationen installieren"
    set "MSG_INSTALL_INTRO=Bitte eine Integration zum Installieren auswaehlen:"
    set "MSG_INSTALL_ALL=[a] Alle verfuegbaren Integrationen installieren"
    set "MSG_INSTALL_UPDATES=[n] Mit Updates fortfahren"
    set "MSG_INSTALL_BACK=[b] Zurueck zur Sprachauswahl"
    set "MSG_INSTALL_EXIT=[x] Beenden"
    set "MSG_INSTALL_PROMPT=Auswahl: "
    set "MSG_INSTALL_INVALID=Ungueltige Eingabe. Bitte Nummer, a, b oder x waehlen."
    set "MSG_INSTALLING=Download und Installation laufen ..."
    set "MSG_INSTALL_OK=Erfolgreich installiert."
    set "MSG_INSTALL_FAIL=Installation FEHLGESCHLAGEN:"
    set "MSG_INSTALL_EXISTS=Bereits installiert - uebersprungen."
    set "MSG_INSTALLED=INSTALLIERT"
    set "MSG_MORE_OF=von"
    set "MSG_MORE_TITLE=Weitere Integrationen"
    set "MSG_MORE_STATUS=melcom-Integrationen sind installiert."
    set "MSG_MORE_ASK=Moechtest du weitere Integrationen installieren?"
    set "MSG_MORE_YES=[j] Ja, verfuegbare Integrationen anzeigen"
    set "MSG_MORE_NO=[n] Nein, mit Updates fortfahren"
    set "MSG_MORE_INVALID=Ungueltige Eingabe. Nur j oder n sind erlaubt."
    set "MSG_INSTALL_SUMMARY=Installations-Zusammenfassung"
    set "MSG_DONE_INSTALLED=installiert"
    set "MSG_CONFIRM_Q=Oben mit OK markierte Plugins auf Updates pruefen?"
    set "MSG_CONFIRM_YES=[j] Ja, fortfahren"
    set "MSG_CONFIRM_BACK=[b] Zurueck zur Sprachauswahl"
    set "MSG_CONFIRM_EXIT=[x] Beenden"
    set "MSG_CONFIRM_PROMPT=Auswahl: "
    set "MSG_INVALID_INPUT=Ungueltige Eingabe. Nur j, b oder x sind erlaubt."
    set "MSG_ABORTED=Vom Benutzer abgebrochen. Es wurden keine Aenderungen vorgenommen."
    set "MSG_CHECKING=Update wird geprueft ..."
    set "MSG_UPTODATE=Bereits aktuell."
    set "MSG_LOCAL_AHEAD=Lokal installierte Version ist neuer als die aktuellste veroeffentlichte Version - nichts zu tun."
    set "MSG_UPDATE_FOUND=Update verfuegbar:"
    set "MSG_CHECK_ERROR=Update-Pruefung fehlgeschlagen:"
    set "MSG_BACKUP_START=Sicherung wird erstellt ..."
    set "MSG_BACKUP_OK=Sicherung erstellt."
    set "MSG_BACKUP_FAIL=Sicherung FEHLGESCHLAGEN - Plugin wird zur Sicherheit uebersprungen. Details stehen im Log."
    set "MSG_SECRET_BN_FILE=consts.py enthaelt deine Battle.net CLIENT_ID und CLIENT_SECRET."
    set "MSG_SECRET_IT_FILE=credentials.json enthaelt deinen persoenlichen itch.io-Token."
    set "MSG_SECRET_BACKUP_PREFIX=Sichere"
    set "MSG_SECRET_BACKUP_SUFFIX=und spiele sie nach dem Update zurueck?"
    set "MSG_SECRET_SKIPPED=Uebersprungen. Nach dem Update musst du dich erneut anmelden."
    set "MSG_SECRET_NONE=Keine aktiven Zugangsdaten gefunden."
    set "MSG_SECRET_BK_OK=gesichert."
    set "MSG_SECRET_BK_FAIL=Sicherung der sensiblen Datei fehlgeschlagen - Update dieses Plugins wird uebersprungen:"
    set "MSG_DOWNLOADING=Update wird heruntergeladen und installiert ..."
    set "MSG_UPDATE_OK=Update erfolgreich installiert."
    set "MSG_UPDATE_FAIL=Update FEHLGESCHLAGEN. Die Sicherung liegt weiterhin im backups-Ordner."
    set "MSG_RESTORE_PREFIX=Spiele"
    set "MSG_RESTORE_SUFFIX=jetzt zurueck?"
    set "MSG_YN_PROMPT=[J/N]: "
    set "MSG_YN_INVALID=Ungueltige Eingabe. Nur j oder n sind erlaubt."
    set "MSG_RESTORE_OK=Datei wurde zurueckgespielt."
    set "MSG_RESTORE_FAIL=Datei konnte nicht zurueckgespielt werden. Bitte manuell kopieren von:"
    set "MSG_SUMMARY=Zusammenfassung"
    set "MSG_DONE_UPDATED=aktualisiert"
    set "MSG_DONE_SKIPPED=uebersprungen / bereits aktuell"
    set "MSG_DONE_FAILED=fehlgeschlagen"
    set "MSG_LOG_SAVED=Log gespeichert unter:"
    set "MSG_PRESS_KEY=Beliebige Taste zum Beenden druecken ..."
    set "MSG_PLUGINSDIR_MISSING=Plugin-Ordner nicht gefunden:"
    set "MSG_PLUGINSDIR_CREATED=Plugin-Ordner erstellt:"
)

cls
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "%C_BOLD%%C_CYAN%" " %MSG_TITLE%"
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "" ""

if not exist "%PLUGINS_DIR%" (
    mkdir "%PLUGINS_DIR%" >nul 2>&1
    if not exist "%PLUGINS_DIR%" (
        call :SAY "%C_RED%" "%MSG_PLUGINSDIR_MISSING% %PLUGINS_DIR%"
        goto FINISH
    )
    call :SAY "%C_YELLOW%" "%MSG_PLUGINSDIR_CREATED% %PLUGINS_DIR%"
)

rem ---------------------------------------------------------------
rem  Discover installed plugins and classify their manifests
rem ---------------------------------------------------------------
call :SAY "%C_CYAN%" "%MSG_SCANNING%"
call :ScanInstalledPlugins

if !N! equ 0 (
    set "AFTER_INSTALL=SUMMARY"
    set "INSTALL_ENTRY=EMPTY"
    goto INSTALL_CATALOG
)

call :LOAD_INSTALL_CATALOG
set /a CNT_UPDATED=0
set /a CNT_SKIPPED=0
set /a CNT_FAILED=0
for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="2" call :HandleLegacyPlugin "%%i"
)

set /a ANYVALID=0
for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="1" set /a ANYVALID+=1
)

if !ANYVALID! equ 0 (
    set "AFTER_INSTALL=SUMMARY"
    set "INSTALL_ENTRY=EMPTY"
    goto INSTALL_CATALOG
)

set "AFTER_INSTALL=UPDATE"
set "INSTALL_ENTRY=ADDITIONAL"
call :LOAD_INSTALL_CATALOG
if !AVAILABLE_COUNT! gtr 0 goto INSTALL_OFFER
goto CONFIRM_PROMPT

:INSTALL_OFFER
call :DRAW_TABLE SAY
call :DRAW_MORE_MENU SAY
goto INSTALL_OFFER_INPUT

:INSTALL_OFFER_REDRAW
call :DRAW_TABLE ECHO2
call :DRAW_MORE_MENU ECHO2
call :ECHO2 "%C_YELLOW%" "%MSG_MORE_INVALID%"
call :ECHO2 "" ""

:INSTALL_OFFER_INPUT
set "MORE_CHOICE="
set /p MORE_CHOICE=%MSG_INSTALL_PROMPT%
if /i "%MORE_CHOICE%"=="%YESKEY%" goto INSTALL_CATALOG
if /i "%MORE_CHOICE%"=="N" goto CONFIRM_PROMPT
goto INSTALL_OFFER_REDRAW

rem ===================================================================
rem  :DRAW_MORE_MENU <PrintRoutine>
rem  PrintRoutine is SAY (console and log) or ECHO2 (console only).
rem ===================================================================
:DRAW_MORE_MENU
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_CYAN%" "--------------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_MORE_TITLE%"
call :%~1 "%C_BOLD%%C_CYAN%" "--------------------------------------------------------------------"
call :%~1 "%C_GREEN%" "  !ANYVALID! %MSG_MORE_OF% !CATALOG_COUNT! %MSG_MORE_STATUS%"
call :%~1 "" ""
call :%~1 "%C_BOLD%" "  %MSG_MORE_ASK%"
call :%~1 "" "    %MSG_MORE_YES%"
call :%~1 "" "    %MSG_MORE_NO%"
call :%~1 "" ""
goto :eof

:CONFIRM_PROMPT
rem  Log the first rendering as the authoritative record of the prompt.
call :DRAW_TABLE SAY
call :DRAW_MENU SAY
goto CONFIRM_INPUT

:CONFIRM_REDRAW
rem  Invalid-input redraws stay console-only to avoid duplicate log entries.
rem  DRAW_TABLE clears and rebuilds the screen; print the warning last so it
rem  remains immediately above the input line.
call :DRAW_TABLE ECHO2
call :DRAW_MENU ECHO2
call :ECHO2 "%C_YELLOW%" "%MSG_INVALID_INPUT%"
call :ECHO2 "" ""
goto CONFIRM_INPUT

:CONFIRM_INPUT
set "CONFIRM="
set /p CONFIRM=%MSG_CONFIRM_PROMPT%
if /i "%CONFIRM%"=="%YESKEY%" goto CONFIRM_PROCEED
if /i "%CONFIRM%"=="B" goto LANG_SELECT
if /i "%CONFIRM%"=="X" goto CONFIRM_EXIT
goto CONFIRM_REDRAW

:CONFIRM_EXIT
call :SAY "%C_YELLOW%" "%MSG_ABORTED%"
set "SKIP_LOG=1"
goto FINISH

:CONFIRM_PROCEED
call :SAY "" ""

set /a CNT_UPDATED=0
set /a CNT_SKIPPED=0
set /a CNT_FAILED=0

rem ---------------------------------------------------------------
rem  Update loop
rem ---------------------------------------------------------------
for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="1" (
        call :ProcessPlugin "%%i"
    )
)

goto SUMMARY

rem ===================================================================
:INSTALL_CATALOG
if /i "%INSTALL_ENTRY%"=="EMPTY" (
    call :SAY "" ""
    call :SAY "%C_YELLOW%" "%MSG_NONE_VALID%"
)
set "INSTALL_SUCCESS_COUNT=0"
set "INSTALL_FAILURE_COUNT=0"
call :LOAD_INSTALL_CATALOG

:INSTALL_MENU
call :REFRESH_AVAILABLE
if !AVAILABLE_COUNT! equ 0 goto INSTALL_FINISHED
call :DRAW_INSTALL_MENU SAY
goto INSTALL_INPUT

rem ===================================================================
rem  :ScanInstalledPlugins
rem  Rescans %PLUGINS_DIR% and rebuilds the N / DIRNAME / VALID /
rem  PNAME / PLATFORM / PGUID / PVERSION / PREPO / PAPI / PPATTERN
rem  arrays from current disk state. The post-install rescan is required because
rem  the table and update loop consume these arrays rather than the filesystem.
rem ===================================================================
:ScanInstalledPlugins
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action ScanPlugins -PluginsDir "%PLUGINS_DIR%" > "%SCANFILE%"
set /a N=0
for /f "usebackq tokens=1-9 delims=|" %%a in ("%SCANFILE%") do (
    set /a N+=1
    set "DIRNAME[!N!]=%%a"
    set "VALID[!N!]=%%b"
    set "PNAME[!N!]=%%c"
    set "PLATFORM[!N!]=%%d"
    set "PGUID[!N!]=%%e"
    set "PVERSION[!N!]=%%f"
    set "PREPO[!N!]=%%g"
    set "PAPI[!N!]=%%h"
    set "PPATTERN[!N!]=%%i"
)
goto :eof

rem  Load the helper's pipe-delimited catalog into parallel CAT_* arrays.
:LOAD_INSTALL_CATALOG
set /a CATALOG_COUNT=0
for /f "usebackq tokens=1-5 delims=|" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action GetInstallCatalog`) do (
    set /a CATALOG_COUNT+=1
    set "CAT_DIR[!CATALOG_COUNT!]=%%a"
    set "CAT_NAME[!CATALOG_COUNT!]=%%b"
    set "CAT_REPO[!CATALOG_COUNT!]=%%c"
    set "CAT_API[!CATALOG_COUNT!]=%%d"
    set "CAT_PATTERN[!CATALOG_COUNT!]=%%e"
)

call :REFRESH_AVAILABLE
goto :eof

rem  Build the menu-facing AVAILABLE_* arrays from catalog entries whose exact
rem  target directory is absent. Rebuild after each install to keep indexes valid.
:REFRESH_AVAILABLE
set /a AVAILABLE_COUNT=0
for /l %%i in (1,1,!CATALOG_COUNT!) do (
    if not exist "%PLUGINS_DIR%\!CAT_DIR[%%i]!" (
        set /a AVAILABLE_COUNT+=1
        set "AVAILABLE_DIR[!AVAILABLE_COUNT!]=!CAT_DIR[%%i]!"
        set "AVAILABLE_NAME[!AVAILABLE_COUNT!]=!CAT_NAME[%%i]!"
        set "AVAILABLE_REPO[!AVAILABLE_COUNT!]=!CAT_REPO[%%i]!"
        set "AVAILABLE_API[!AVAILABLE_COUNT!]=!CAT_API[%%i]!"
        set "AVAILABLE_PATTERN[!AVAILABLE_COUNT!]=!CAT_PATTERN[%%i]!"
    )
)
goto :eof

:INSTALL_REDRAW
call :DRAW_INSTALL_MENU ECHO2
call :ECHO2 "%C_YELLOW%" "%MSG_INSTALL_INVALID%"
call :ECHO2 "" ""

:INSTALL_INPUT
set "INSTALL_CHOICE="
set /p INSTALL_CHOICE=%MSG_INSTALL_PROMPT%
if /i "%INSTALL_CHOICE%"=="A" goto INSTALL_ALL
if /i "%INSTALL_CHOICE%"=="B" goto LANG_SELECT
if /i "%INSTALL_CHOICE%"=="X" goto INSTALL_EXIT
if /i "%INSTALL_CHOICE%"=="N" if /i "%AFTER_INSTALL%"=="UPDATE" goto INSTALL_FINISHED

set "AVAILABLE_INDEX="
for /l %%i in (1,1,!AVAILABLE_COUNT!) do (
    if "%INSTALL_CHOICE%"=="%%i" set "AVAILABLE_INDEX=%%i"
)
if not defined AVAILABLE_INDEX goto INSTALL_REDRAW
call :InstallCatalogPlugin "%AVAILABLE_INDEX%"
goto INSTALL_MENU

:INSTALL_ALL
for /l %%i in (1,1,!AVAILABLE_COUNT!) do call :InstallCatalogPlugin "%%i"
goto INSTALL_MENU

:INSTALL_EXIT
goto INSTALL_FINISHED

:INSTALL_FINISHED
call :ScanInstalledPlugins
if /i "%AFTER_INSTALL%"=="UPDATE" (
    if !INSTALL_SUCCESS_COUNT! gtr 0 goto INSTALL_SUMMARY
    goto CONFIRM_PROMPT
)
goto INSTALL_SUMMARY

:INSTALL_SUMMARY
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "%C_BOLD%%C_CYAN%" " %MSG_INSTALL_SUMMARY%"
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "%C_GREEN%" "  !INSTALL_SUCCESS_COUNT! %MSG_DONE_INSTALLED%"
call :SAY "%C_RED%" "  !INSTALL_FAILURE_COUNT! %MSG_DONE_FAILED%"
call :SAY "" ""
if /i "%AFTER_INSTALL%"=="UPDATE" goto CONFIRM_PROMPT
goto FINISH

rem ===================================================================
:HandleLegacyPlugin
set "LEGACY_INDEX=%~1"
set "LEGACY_DIR=!DIRNAME[%LEGACY_INDEX%]!"
set "LEGACY_CATALOG_INDEX="
for /l %%i in (1,1,!CATALOG_COUNT!) do (
    if /i "!LEGACY_DIR!"=="!CAT_DIR[%%i]!" set "LEGACY_CATALOG_INDEX=%%i"
)

if not defined LEGACY_CATALOG_INDEX (
    call :SAY "%C_YELLOW%" "%MSG_LEGACY_UNKNOWN% !LEGACY_DIR!"
    goto :eof
)

call :AskYesNo DRAW_LEGACY_PROMPT
if /i "!ASKYN_RESULT!"=="Y" goto LEGACY_REPLACE
goto :eof

rem ===================================================================
rem  :DRAW_LEGACY_PROMPT <printroutine>  -  draws the legacy-plugin
rem  replacement question for the plugin currently held in
rem  LEGACY_INDEX / LEGACY_DIR.
rem ===================================================================
:DRAW_LEGACY_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_YELLOW%" "----------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_LEGACY_TITLE%"
call :%~1 "%C_GRAY%" "  !PNAME[%LEGACY_INDEX%]! - !LEGACY_DIR!"
call :%~1 "%C_BOLD%%C_YELLOW%" "----------------------------------------------------------------"
call :%~1 "%C_YELLOW%" "  %MSG_LEGACY_NOTICE%"
call :%~1 "%C_BOLD%" "  %MSG_LEGACY_RECOMMEND%"
call :%~1 "" "    %MSG_LEGACY_YES%"
call :%~1 "" "    %MSG_LEGACY_NO%"
call :%~1 "" ""
goto :eof


:LEGACY_REPLACE
set "VALID[%LEGACY_INDEX%]=1"
set "PREPO[%LEGACY_INDEX%]=!CAT_REPO[%LEGACY_CATALOG_INDEX%]!"
set "PAPI[%LEGACY_INDEX%]=!CAT_API[%LEGACY_CATALOG_INDEX%]!"
set "PPATTERN[%LEGACY_INDEX%]=!CAT_PATTERN[%LEGACY_CATALOG_INDEX%]!"
set "PVERSION[%LEGACY_INDEX%]=0"
call :ProcessPlugin "%LEGACY_INDEX%"
goto :eof

rem ===================================================================
rem  :SanCheckCurrentAndPrompt <PluginDirName>
rem  Used when the plugin is already up to date (or locally ahead), so
rem  no download/overwrite happens. Reads the current state of the
rem  already-installed plugin.py directly and forwards it to
rem  :HandleSanIntegration, which itself only acts on the Steam plugin.
rem ===================================================================
:SanCheckCurrentAndPrompt
if /i not "%~1"=="%STEAM_PLUGIN_DIR%" goto :eof
set "SANCHECK="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckSanMarker -PluginsDir "%PLUGINS_DIR%" -PluginDirName "%~1"`) do set "SANCHECK=%%R"
set "SAN_CURRENT_STATE=NOTPRESENT"
for /f "tokens=1 delims=|" %%a in ("!SANCHECK!") do set "SAN_CURRENT_STATE=%%a"
call :HandleSanIntegration "%~1" "!SAN_CURRENT_STATE!"
goto :eof

rem ===================================================================
rem  :HandleSanIntegration <PluginDirName> <CurrentState>
rem  Steam-only policy layer for the optional notifier modification. PRESENT
rem  means marker blocks currently exist in plugin.py; every other state is
rem  treated as absent. The helper performs the actual guarded file edit.
rem ===================================================================
:HandleSanIntegration
if /i not "%~1"=="%STEAM_PLUGIN_DIR%" goto :eof
set "SAN_DN=%~1"
set "SAN_OLDSTATE=%~2"

call :AskYesNo DRAW_SAN_PROMPT
if /i "!ASKYN_RESULT!"=="Y" goto SAN_YES
goto SAN_NO

rem ===================================================================
rem  :DRAW_SAN_PROMPT <printroutine>  -  draws the Steam Achievement
rem  Notifier question. Used both for the first display (:SAY, so the
rem  log keeps a record) and for redraws after invalid input (:ECHO2,
rem  console only).
rem ===================================================================
:DRAW_SAN_PROMPT
call :%~1 "" ""
call :%~1 "%C_BOLD%%C_YELLOW%" "----------------------------------------------------------------"
call :%~1 "%C_BOLD%" "  %MSG_SAN_TITLE%"
call :%~1 "%C_BOLD%%C_YELLOW%" "----------------------------------------------------------------"
if /i "!SAN_OLDSTATE!"=="PRESENT" (
    call :%~1 "%C_YELLOW%" "  %MSG_SAN_DETECTED%"
    call :%~1 "%C_BOLD%" "  %MSG_SAN_KEEP_Q%"
) else (
    call :%~1 "%C_BOLD%" "  %MSG_SAN_ADD_Q%"
    call :%~1 "" "  %MSG_SAN_ADD_EXPLAIN%"
    call :%~1 "" ""
    call :%~1 "" "  %MSG_SAN_ADD_HINT%"
)
call :%~1 "" "    %MSG_SAN_YES%"
call :%~1 "" "    %MSG_SAN_NO%"
call :%~1 "" ""
goto :eof

rem User answered yes: if it was already there, just keep it; if it
rem was missing, insert it now.
:SAN_YES
if /i "!SAN_OLDSTATE!"=="PRESENT" goto SAN_KEEP
goto SAN_INSERT

rem User answered no: if it was there, strip it back out; if it was
rem already missing, there is nothing to do.
:SAN_NO
if /i "!SAN_OLDSTATE!"=="PRESENT" goto SAN_STRIP
goto :eof

:SAN_KEEP
call :SAY "%C_GREEN%" "  %MSG_SAN_KEPT%"
goto :eof

:SAN_STRIP
set "SANRESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action StripSanBlocks -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!SAN_DN!"`) do set "SANRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!SANRESULT!") do (set "SAN_STATUS=%%a" & set "SAN_PATH=%%b")
if "!SAN_STATUS!"=="OK" (
    call :SAY "%C_GREEN%" "  %MSG_SAN_REMOVED%"
) else (
    call :SAY "%C_RED%" "  %MSG_SAN_STRIP_FAIL% !SAN_PATH!"
)
goto :eof

:SAN_INSERT
set "SANRESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action InsertSanBlocks -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!SAN_DN!"`) do set "SANRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!SANRESULT!") do (set "SAN_STATUS=%%a" & set "SAN_PATH=%%b")
if "!SAN_STATUS!"=="OK" (
    call :SAY "%C_GREEN%" "  %MSG_SAN_ADDED%"
) else if "!SAN_STATUS!"=="ALREADY" (
    call :SAY "%C_GREEN%" "  %MSG_SAN_ADDED%"
) else (
    call :SAY "%C_RED%" "  %MSG_SAN_ADD_FAIL% !SAN_PATH!"
)
goto :eof

rem ===================================================================
rem  :AskYesNo <DrawLabel>
rem  Draw the question once through SAY, then accept only the localized YESKEY
rem  or N. ASKYN_RESULT is normalized to Y/N. Invalid attempts replace only the
rem  current prompt line with ANSI cursor controls, preserving scrollback and
rem  preventing repeated questions in the log. CALL-based invocation is safe
rem  from parenthesized blocks where delayed expansion is active.
rem ===================================================================
:AskYesNo
set "ASKYN_DRAW=%~1"
set "ASKYN_INVALID_SHOWN="
if defined ASKYN_DRAW call :%ASKYN_DRAW% SAY
goto AskYesNo_Input

:AskYesNo_Input
set "ASKYN_INPUT="
set /p ASKYN_INPUT=%MSG_YN_PROMPT%
if /i "!ASKYN_INPUT!"=="!YESKEY!" (
    set "ASKYN_RESULT=Y"
    goto :eof
)
if /i "!ASKYN_INPUT!"=="N" (
    set "ASKYN_RESULT=N"
    goto :eof
)
rem  Erase this wrong attempt's own prompt line in place (cursor up
rem  one row, clear that row) - nothing above it is touched.
<nul set /p "=%ESC%[1A%ESC%[2K"
if not defined ASKYN_INVALID_SHOWN (
    call :ECHO2 "%C_YELLOW%" "  %MSG_YN_INVALID%"
    call :ECHO2 "" ""
    set "ASKYN_INVALID_SHOWN=1"
)
goto AskYesNo_Input

rem ===================================================================
rem  :DRAW_SECRET_BACKUP_PROMPT <printroutine>  -  draws the question
rem  asking whether to back up the currently detected secret file
rem  (SECRET_TYPE / SECRET_FILE), used by :AskYesNo.
rem ===================================================================
:DRAW_SECRET_BACKUP_PROMPT
call :%~1 "" ""
if "!SECRET_TYPE!"=="battlenet" call :%~1 "%C_YELLOW%" "  %MSG_SECRET_BN_FILE%"
if "!SECRET_TYPE!"=="itch"      call :%~1 "%C_YELLOW%" "  %MSG_SECRET_IT_FILE%"
call :%~1 "%C_BOLD%" "  %MSG_SECRET_BACKUP_PREFIX% !SECRET_FILE! %MSG_SECRET_BACKUP_SUFFIX%"
call :%~1 "" ""
goto :eof

rem ===================================================================
rem  :DRAW_RESTORE_PROMPT <printroutine>  -  draws the question asking
rem  whether to restore the backed-up secret file, used by :AskYesNo.
rem ===================================================================
:DRAW_RESTORE_PROMPT
call :%~1 "%C_BOLD%" "  %MSG_RESTORE_PREFIX% !SECRET_FILE! %MSG_RESTORE_SUFFIX%"
call :%~1 "" ""
goto :eof

rem ===================================================================
:InstallCatalogPlugin
setlocal EnableDelayedExpansion
set "IDX=%~1"
set "DN=!AVAILABLE_DIR[%IDX%]!"
set "PN=!AVAILABLE_NAME[%IDX%]!"
set "RP=!AVAILABLE_REPO[%IDX%]!"
set "API=!AVAILABLE_API[%IDX%]!"
set "PAT=!AVAILABLE_PATTERN[%IDX%]!"

call :SAY "" ""
call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "----------------------------------------------------------------"
call :SAY "%C_BOLD%" "  !PN!"
call :SAY "%C_BOLD%%C_CYAN%" "----------------------------------------------------------------"

call :SAY "%C_CYAN%" "  %MSG_CHECKING%"

if exist "%PLUGINS_DIR%\!DN!" (
    call :SAY "%C_GRAY%" "  %MSG_INSTALL_EXISTS%"
    endlocal & goto :eof
)

call :SAY "%C_CYAN%" "  %MSG_INSTALLING%"
set "RESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckUpdate -Repo "!RP!" -LatestApi "!API!" -AssetPattern "!PAT!" -LocalVersion "0"`) do set "RESULT=%%R"
for /f "tokens=1-3 delims=|" %%a in ("!RESULT!") do (
    set "U_STATUS=%%a"
    set "U_TAG=%%b"
    set "U_URL=%%c"
)

if "!U_STATUS!"=="ERROR" (
    call :SAY "%C_RED%" "  %MSG_INSTALL_FAIL% !U_TAG!"
    endlocal & set /a INSTALL_FAILURE_COUNT+=1 & goto :eof
)

set "IRESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DoUpdate -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -DownloadUrl "!U_URL!"`) do set "IRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!IRESULT!") do (set "I_STATUS=%%a" & set "I_PATH=%%b")

if not "!I_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_INSTALL_FAIL% !I_PATH!"
    endlocal & set /a INSTALL_FAILURE_COUNT+=1 & goto :eof
)

call :SAY "%C_GREEN%" "  %MSG_INSTALL_OK% (!U_TAG!)"
call :HandleSanIntegration "!DN!" "NOTPRESENT"
endlocal & set /a INSTALL_SUCCESS_COUNT+=1 & goto :eof

rem ===================================================================
:ProcessPlugin
setlocal EnableDelayedExpansion
set "IDX=%~1"
set "DN=!DIRNAME[%IDX%]!"
set "PN=!PNAME[%IDX%]!"
set "RP=!PREPO[%IDX%]!"
set "API=!PAPI[%IDX%]!"
set "PAT=!PPATTERN[%IDX%]!"
set "LV=!PVERSION[%IDX%]!"

call :SAY "" ""
call :SAY "%C_BOLD%%C_CYAN%" "----------------------------------------------------------------"
call :SAY "%C_BOLD%" "  !PN!"
call :SAY "%C_BOLD%%C_CYAN%" "----------------------------------------------------------------"
call :SAY "%C_CYAN%" "  %MSG_CHECKING%"

rem  Throttle consecutive API checks to reduce GitHub secondary-rate-limit hits.
rem  ping provides an approximately one-second delay without requiring timeout,
rem  whose behavior can vary when input is redirected in batch environments.
ping -n 2 127.0.0.1 >nul

set "RESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckUpdate -Repo "!RP!" -LatestApi "!API!" -AssetPattern "!PAT!" -LocalVersion "!LV!"`) do set "RESULT=%%R"

for /f "tokens=1-3 delims=|" %%a in ("!RESULT!") do (
    set "U_STATUS=%%a"
    set "U_TAG=%%b"
    set "U_URL=%%c"
)

if "!U_STATUS!"=="ERROR" (
    call :SAY "%C_RED%" "  %MSG_CHECK_ERROR% !U_TAG!"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
if "!U_STATUS!"=="UPTODATE" (
    call :SAY "%C_GREEN%" "  %MSG_UPTODATE% (!U_TAG!)"
    call :SanCheckCurrentAndPrompt "!DN!"
    endlocal & set /a CNT_SKIPPED+=1 & goto :eof
)
if "!U_STATUS!"=="AHEAD" (
    call :SAY "%C_GRAY%" "  %MSG_LOCAL_AHEAD% (!U_TAG!)"
    call :SanCheckCurrentAndPrompt "!DN!"
    endlocal & set /a CNT_SKIPPED+=1 & goto :eof
)

call :SAY "%C_YELLOW%" "  %MSG_UPDATE_FOUND% !U_TAG!"

set "SAN_OLDSTATE=NOTPRESENT"
if /i "!DN!"=="%STEAM_PLUGIN_DIR%" (
    set "SANCHECK="
    for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckSanMarker -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!"`) do set "SANCHECK=%%R"
    for /f "tokens=1 delims=|" %%a in ("!SANCHECK!") do set "SAN_OLDSTATE=%%a"
)

rem  The full backup is the safety gate: never overwrite a plugin if it fails.
call :SAY "%C_CYAN%" "  %MSG_BACKUP_START%"
set "BRESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action BackupPlugin -PluginsDir "%PLUGINS_DIR%" -BackupDir "%BACKUP_DIR%" -PluginDirName "!DN!"`) do set "BRESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!BRESULT!") do (set "B_STATUS=%%a" & set "B_PATH=%%b")

if not "!B_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_BACKUP_FAIL%"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
call :SAY "%C_GREEN%" "  %MSG_BACKUP_OK%"

rem  DoUpdate replaces the directory contents, so preserve known credentials
rem  separately when the user opts in; the full ZIP remains untouched either way.
set "SECRET_TYPE="
set "SECRET_FILE="
if /i "!DN!"=="battlenet_ba170431-0649-482f-863b-d248592f1842" (
    set "SECRET_TYPE=battlenet"
    set "SECRET_FILE=consts.py"
)
if /i "!DN!"=="itch_2df02142-4d8a-4a4b-9b6e-c3a0bc62f93b" (
    set "SECRET_TYPE=itch"
    set "SECRET_FILE=credentials.json"
)

set "SECRET_BACKUP_PATH="
if defined SECRET_TYPE (
    set "CRESULT="
    for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action CheckSecret -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -SecretFile "!SECRET_FILE!" -SecretType "!SECRET_TYPE!"`) do set "CRESULT=%%R"
    for /f "tokens=1,2 delims=|" %%a in ("!CRESULT!") do (set "C_STATUS=%%a" & set "C_PATH=%%b")

    if "!C_STATUS!"=="PRESENT" (
        call :AskYesNo DRAW_SECRET_BACKUP_PROMPT
        if /i "!ASKYN_RESULT!"=="Y" (
            set "SRESULT="
            for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action BackupSecret -PluginsDir "%PLUGINS_DIR%" -BackupDir "%BACKUP_DIR%" -PluginDirName "!DN!" -SecretFile "!SECRET_FILE!"`) do set "SRESULT=%%R"
            for /f "tokens=1,2 delims=|" %%a in ("!SRESULT!") do (set "S_STATUS=%%a" & set "S_PATH=%%b")

            if "!S_STATUS!"=="OK" (
                call :SAY "%C_GREEN%" "  !SECRET_FILE! %MSG_SECRET_BK_OK%"
                set "SECRET_BACKUP_PATH=!S_PATH!"
            ) else (
            call :SAY "%C_RED%" "  %MSG_SECRET_BK_FAIL% !S_PATH!"
                endlocal & set /a CNT_FAILED+=1 & goto :eof
            )
        ) else (
            call :SAY "%C_YELLOW%" "  %MSG_SECRET_SKIPPED%"
        )
    )
)

rem --- Download and install the update ---
call :SAY "%C_CYAN%" "  %MSG_DOWNLOADING%"
set "URESULT="
for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action DoUpdate -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -DownloadUrl "!U_URL!"`) do set "URESULT=%%R"
for /f "tokens=1,2 delims=|" %%a in ("!URESULT!") do (set "UP_STATUS=%%a" & set "UP_PATH=%%b")

if not "!UP_STATUS!"=="OK" (
    call :SAY "%C_RED%" "  %MSG_UPDATE_FAIL%"
    endlocal & set /a CNT_FAILED+=1 & goto :eof
)
call :SAY "%C_GREEN%" "  %MSG_UPDATE_OK%"
call :HandleSanIntegration "!DN!" "!SAN_OLDSTATE!"

rem --- Restore the secret file if requested ---
if defined SECRET_BACKUP_PATH (
    call :AskYesNo DRAW_RESTORE_PROMPT
    if /i "!ASKYN_RESULT!"=="Y" (
        set "RRESULT="
        for /f "usebackq delims=" %%R in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action RestoreSecret -PluginsDir "%PLUGINS_DIR%" -PluginDirName "!DN!" -SecretFile "!SECRET_BACKUP_PATH!" -TargetFile "!SECRET_FILE!"`) do set "RRESULT=%%R"
        for /f "tokens=1,2 delims=|" %%a in ("!RRESULT!") do (set "R_STATUS=%%a" & set "R_PATH=%%b")
        if "!R_STATUS!"=="OK" (
            call :SAY "%C_GREEN%" "    %MSG_RESTORE_OK%"
        ) else (
            call :SAY "%C_RED%" "    %MSG_RESTORE_FAIL% !SECRET_BACKUP_PATH!"
        )
    )
)

call :SAY "" ""
endlocal & set /a CNT_UPDATED+=1 & goto :eof

rem ===================================================================
:SUMMARY
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "%C_BOLD%%C_CYAN%" " %MSG_SUMMARY%"
call :SAY "%C_BOLD%%C_CYAN%" "===================================================================="
call :SAY "%C_GREEN%" "  !CNT_UPDATED! %MSG_DONE_UPDATED%"
call :SAY "%C_YELLOW%" "  !CNT_SKIPPED! %MSG_DONE_SKIPPED%"
call :SAY "%C_RED%" "  !CNT_FAILED! %MSG_DONE_FAILED%"
call :SAY "" ""

:FINISH
if defined SKIP_LOG (
    if exist "%LOGFILE%" del /q "%LOGFILE%" >nul 2>&1
) else (
    call :SAY "%C_GRAY%" "%MSG_LOG_SAVED% %LOGFILE%"
)
if exist "%SCANFILE%" del /q "%SCANFILE%" >nul 2>&1
echo.
echo %MSG_PRESS_KEY%
pause >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action MatrixExit -Lang "%LANG%"
endlocal
exit /b 0

rem ===================================================================
rem  :SAY <colorcode> <message>  -  prints colored to console, plain to log
rem ===================================================================
:SAY
echo(%~1%~2%C_RESET%
>>"%LOGFILE%" echo(%~2
goto :eof

rem ===================================================================
rem  :ECHO2 <colorcode> <message>  -  same as :SAY but console only,
rem  does not write to the log file. Used to redraw the screen after
rem  an invalid input without piling up duplicate lines in the log.
rem ===================================================================
:ECHO2
echo(%~1%~2%C_RESET%
goto :eof

rem ===================================================================
rem  :DRAW_TABLE <printroutine>  -  clears the screen and draws the
rem  title plus the full plugin table, using either :SAY (console+log)
rem  or :ECHO2 (console only) as the print routine.
rem ===================================================================
:DRAW_TABLE
cls
call :%~1 "%C_BOLD%%C_CYAN%" "===================================================================="
call :%~1 "%C_BOLD%%C_CYAN%" " %MSG_TITLE%"
call :%~1 "%C_BOLD%%C_CYAN%" "===================================================================="
call :%~1 "" ""
call :%~1 "%C_BOLD%" "%MSG_TABLE_HEAD%"
call :%~1 "%C_GRAY%" "--------------------------------------------------------------------"
for /l %%i in (1,1,!N!) do (
    if "!VALID[%%i]!"=="1" (
        call :%~1 "%C_GREEN%" "  [OK]        !DIRNAME[%%i]!  -  !PNAME[%%i]!"
    ) else if "!VALID[%%i]!"=="2" (
        call :%~1 "%C_YELLOW%" "  [LEGACY]    !DIRNAME[%%i]!  -  !PNAME[%%i]!  -  %MSG_LEGACY%"
    ) else (
        if "!PNAME[%%i]!"=="NOMANIFEST" (
            call :%~1 "%C_RED%" "  [EXCLUDED]  !DIRNAME[%%i]!  -  %MSG_NOMANIFEST%"
        ) else if "!PNAME[%%i]!"=="BADJSON" (
            call :%~1 "%C_RED%" "  [EXCLUDED]  !DIRNAME[%%i]!  -  %MSG_BADJSON%"
        ) else (
            call :%~1 "%C_RED%" "  [EXCLUDED]  !DIRNAME[%%i]!  -  !PNAME[%%i]!  -  %MSG_INVALID%"
        )
    )
)
call :%~1 "" ""
goto :eof

rem ===================================================================
rem  :DRAW_MENU <printroutine>  -  draws the update confirmation
rem  question and its three options. Kept separate from :DRAW_TABLE so
rem  the "no eligible plugins" case can show the table without also
rem  showing a menu that would not apply.
rem ===================================================================
:DRAW_MENU
call :%~1 "%C_BOLD%" "%MSG_CONFIRM_Q%"
call :%~1 "" "  %MSG_CONFIRM_YES%"
call :%~1 "" "  %MSG_CONFIRM_BACK%"
call :%~1 "" ""
call :%~1 "" "  %MSG_CONFIRM_EXIT%"
call :%~1 "" ""
goto :eof

rem ===================================================================
:DRAW_INSTALL_MENU
cls
call :%~1 "%C_BOLD%%C_CYAN%" "===================================================================="
call :%~1 "%C_BOLD%%C_CYAN%" " %MSG_TITLE%"
call :%~1 "%C_BOLD%%C_CYAN%" "===================================================================="
call :%~1 "" ""
call :%~1 "%C_BOLD%" "%MSG_INSTALL_TITLE%"
call :%~1 "" "%MSG_INSTALL_INTRO%"
call :%~1 "" ""
for /l %%i in (1,1,!AVAILABLE_COUNT!) do (
    call :%~1 "%C_CYAN%" "  [%%i] !AVAILABLE_NAME[%%i]!"
)
call :%~1 "" ""
call :%~1 "" "  %MSG_INSTALL_ALL%"
if /i "%AFTER_INSTALL%"=="UPDATE" call :%~1 "" "  %MSG_INSTALL_UPDATES%"
call :%~1 "" "  %MSG_INSTALL_BACK%"
call :%~1 "" ""
call :%~1 "" "  %MSG_INSTALL_EXIT%"
call :%~1 "" ""
goto :eof