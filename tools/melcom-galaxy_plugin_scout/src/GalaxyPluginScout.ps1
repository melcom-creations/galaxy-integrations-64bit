#Requires -Version 5.1
<#
.SYNOPSIS
    melcom's Galaxy Plugin Scout  -  Analyzer & Updater
    Version 1.2.0  |  For GOG Galaxy 2.x  (64-bit, Python 3.13)
.NOTES
    Author  : melcom
    Created : 2026-07-11
    Target  : Windows 10/11, PowerShell 5.1+
#>

param(
    [switch]$DryRun
)

Set-StrictMode -Off
$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Logging
# Writes colored output to the console and a plain-text copy to a log file.
# ---------------------------------------------------------------------------
$global:LogFile  = $null
$global:BatchLogFile = $null
$global:PathError = $null

function Write-Msg {
    param(
        [Parameter(ValueFromPipeline=$true, Position=0)]
        [string]$Text = "",
        [switch]$NoNewline,
        [switch]$LogOnly
    )

    if (-not $LogOnly) {
        if ($NoNewline) { Write-Host $Text -NoNewline }
        else            { Write-Host $Text }
    }

    $targets = New-Object 'System.Collections.Generic.List[string]'
    if ($global:LogFile) { [void]$targets.Add($global:LogFile) }
    if ($global:BatchLogFile -and $global:BatchLogFile -ne $global:LogFile) { [void]$targets.Add($global:BatchLogFile) }

    if ($targets.Count -gt 0) {
        $clean = $Text -replace '\x1B\[[0-9;]*m', ''
        foreach ($target in $targets) {
            if ($NoNewline) {
                [System.IO.File]::AppendAllText($target, $clean, [System.Text.Encoding]::UTF8)
            } else {
                [System.IO.File]::AppendAllText($target, $clean + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
            }
        }
    }
}

function Read-Msg {
    param([string]$Prompt)
    $ans = (Read-Host $Prompt).Trim()
    if ($global:LogFile -or $global:BatchLogFile) {
        $cleanPrompt = $Prompt -replace '\x1B\[[0-9;]*m', ''
        $targets = New-Object 'System.Collections.Generic.List[string]'
        if ($global:LogFile) { [void]$targets.Add($global:LogFile) }
        if ($global:BatchLogFile -and $global:BatchLogFile -ne $global:LogFile) { [void]$targets.Add($global:BatchLogFile) }
        foreach ($target in $targets) {
            [System.IO.File]::AppendAllText($target, "${cleanPrompt}: $ans" + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
        }
    }
    return $ans
}

# ---------------------------------------------------------------------------
# ANSI color helpers
# ---------------------------------------------------------------------------
$ESC = [char]27
function clr     { param($code,$txt); return "$ESC[${code}m${txt}${ESC}[0m" }
function Red     ($t){ clr '91' $t }
function Green   ($t){ clr '92' $t }
function Yellow  ($t){ clr '93' $t }
function Cyan    ($t){ clr '96' $t }
function White   ($t){ clr '97' $t }
function Bold    ($t){ clr '1'  $t }
function Dim     ($t){ clr '2'  $t }
function Magenta ($t){ clr '95' $t }

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------
$TOOL_NAME    = "melcom's Galaxy Plugin Scout"
$TOOL_VERSION = "v1.2.0"
# Sentinel returned by Select-PluginFromInventory when the person picks
# "[a] All plugins" instead of a single one. Not a real path, so it can
# never collide with an actual plugin RootPath.
$ALL_PLUGINS_SENTINEL = '::ALL_MELCOM_PLUGINS::'
# Sentinel returned by Select-PluginFromInventory / Get-PluginRoot when the
# person wants to back out to the "Select mode" screen instead of picking a
# plugin. Not a real path, so it can never collide with an actual RootPath.
$BACK_TO_MODE_SENTINEL = '::BACK_TO_MODE_SELECT::'

# ---------------------------------------------------------------------------
# Matrix-style farewell animation, shown when quitting via 'q'.
#
# Deliberately uses Write-Host directly, NEVER Write-Msg -- this is a purely
# cosmetic goodbye screen and must never end up in a log file, regardless of
# whether $global:LogFile / $global:BatchLogFile happen to still be set from
# the last run.
# ---------------------------------------------------------------------------
function Show-MatrixExit {
    param($lang)

    # Half-width katakana (the actual character set used in the film),
    # mixed with digits and a few Latin letters for variety.
    $katakana = @()
    for ($cp = 0xFF66; $cp -le 0xFF9D; $cp++) { $katakana += [char]$cp }
    $chars = $katakana + @('0','1','2','3','4','5','6','7','8','9') + @('A','B','C','D','E','F')

    $width = 80
    try { $width = $Host.UI.RawUI.WindowSize.Width } catch { $width = 80 }
    if ($width -lt 20) { $width = 80 }

    # "Matrix green" -- true-color ANSI, brighter head / dimmer trail chars
    # mixed per frame for a flickering rain effect.
    $bright = "$([char]27)[38;2;170;255;170m"
    $mid    = "$([char]27)[38;2;0;255;65m"
    $dim    = "$([char]27)[38;2;0;110;30m"
    $reset  = "$([char]27)[0m"

    Clear-Host
    $rng = [System.Random]::new()
    $frames = 22
    for ($f = 0; $f -lt $frames; $f++) {
        $line = New-Object System.Text.StringBuilder
        for ($x = 0; $x -lt $width; $x++) {
            $ch = $chars[$rng.Next($chars.Count)]
            $roll = $rng.Next(100)
            if     ($roll -lt 8)  { [void]$line.Append($bright + $ch) }
            elseif ($roll -lt 55) { [void]$line.Append($mid    + $ch) }
            else                  { [void]$line.Append($dim    + $ch) }
        }
        [void]$line.Append($reset)
        Write-Host $line.ToString()
        Start-Sleep -Milliseconds 90
    }

    Start-Sleep -Milliseconds 300
    Clear-Host
    Write-Host ""
    if ($lang -eq '1') {
        Write-Host ("  " + $mid + "Goodbye. Happy gaming!" + $reset)
    } elseif ($lang -eq '2') {
        Write-Host ("  " + $mid + "Tschuess. Viel Spass beim Zocken!" + $reset)
    } else {
        Write-Host ("  " + $mid + "Goodbye! / Tschuess!" + $reset)
    }
    Write-Host ""
    Start-Sleep -Milliseconds 700
    exit 0
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
function Show-Banner {
    Clear-Host
    Write-Msg ""
    Write-Msg (Bold (Cyan "  +==============================================================+"))
    Write-Msg (Bold (Cyan ("  |       melcom's Galaxy Plugin Scout  " + $TOOL_VERSION + "                   |")))
    Write-Msg (Bold (Cyan "  |       GOG Galaxy 2.1+  |  Python 3.13  |  64-bit             |"))
    Write-Msg (Bold (Cyan "  +==============================================================+"))
    if ($DryRun) {
        Write-Msg ""
        Write-Msg (Bold (Yellow "  *** DRY-RUN MODE -- no files will be modified in this run ***"))
    }
    Write-Msg ""
}

# ---------------------------------------------------------------------------
# Language selector
# Redraws the banner on invalid input instead of just printing an error below.
# ---------------------------------------------------------------------------
function Select-Language {
    $choice   = ""
    $errorMsg = $null

    while ($choice -ne '1' -and $choice -ne '2') {
        Show-Banner
        Write-Msg (Dim "  Cleans up and updates the bundled Python libraries in melcom's GOG Galaxy plugins.")
        Write-Msg ""
        Write-Msg (Yellow "  Select language / Sprache waehlen:")
        Write-Msg        "    [1]  English"
        Write-Msg        "    [2]  Deutsch"
        Write-Msg        "    [q]  Quit / Beenden"
        Write-Msg ""

        if ($errorMsg) {
            Write-Msg (Red "  [!] $errorMsg")
            Write-Msg ""
            $errorMsg = $null
        }

        $choice = Read-Msg "  > Your choice / Deine Wahl [1/2/q]"

        if ($choice -eq 'q' -or $choice -eq 'Q') { Show-MatrixExit -lang $null }

        if ($choice -ne '1' -and $choice -ne '2') {
            $errorMsg = "Only 1 or 2 are allowed. / Nur 1 oder 2 sind erlaubt."
        }
    }
    return $choice
}

# ---------------------------------------------------------------------------
# Greeting
# ---------------------------------------------------------------------------
function Show-Greeting {
    param($lang)
    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg (Green "  Welcome to Galaxy Plugin Scout.")
        Write-Msg        "  This tool analyses your GOG Galaxy plugin folder,"
        Write-Msg        "  maps all modules, resolves the dependency tree,"
        Write-Msg        "  and can update all libraries to their latest versions."
    } else {
        Write-Msg (Green "  Willkommen beim Galaxy Plugin Scout.")
        Write-Msg        "  Dieses Tool analysiert deinen GOG Galaxy Plugin-Ordner,"
        Write-Msg        "  kartiert alle Module, loest den Abhaengigkeitsbaum auf,"
        Write-Msg        "  und kann alle Bibliotheken auf den neuesten Stand bringen."
    }
    Write-Msg ""
}

# ---------------------------------------------------------------------------
# Mode selector
# There is no standalone "batch" mode anymore. Instead, modes 1, 2 and 3 each
# offer an [a] "all plugins" option in the plugin picker (Select-PluginFromInventory).
# For mode 2, choosing [a] asks the three risk-bearing questions (backup,
# unused-module removal, library updates) ONCE up front for the whole run,
# then applies those answers to every plugin without further prompts.
# ---------------------------------------------------------------------------
function Select-Mode {
    param($lang, [switch]$ForceDryRun)

    if ($ForceDryRun) { return '1' }

    $choice   = ""
    $errorMsg = $null

    while ($choice -notin @('1','2','3')) {
        Show-Banner

        if ($lang -eq '1') {
            Write-Msg (Yellow "  Select mode:")
            Write-Msg        "    [1]  Dry-run -- analyze only, nothing is changed"
            Write-Msg (Dim   "         Preview what would happen to a plugin (or all): dependency report,")
            Write-Msg (Dim   "         which pip launcher stubs would be removed. No files touched.")
            Write-Msg ""
            Write-Msg        "    [2]  Update -- full maintenance run"
            Write-Msg (Dim   "         Backup, remove unused modules, and install/update libraries via pip,")
            Write-Msg (Dim   "         all in one pass. Use this for a complete refresh of a plugin.")
            Write-Msg ""
            Write-Msg        "    [3]  Library check -- compares installed libraries against PyPI"
            Write-Msg (Dim   "         No module cleanup, but a backup IS made before the first real install.")
            Write-Msg (Dim   "         Asks Y/N/A per outdated library before installing anything.")
            Write-Msg ""
            Write-Msg (Dim   "  Rule of thumb: freshly downloaded from GitHub? You usually don't need Mode 2 --")
            Write-Msg (Dim   "  melcom already ran it before releasing the plugin. Mode 3 is enough to stay current.")
            Write-Msg (Dim   "  Mode 2 is for when the dependency tree itself changed (e.g. a 32-to-64bit move).")
        } else {
            Write-Msg (Yellow "  Modus waehlen:")
            Write-Msg        "    [1]  Dry-Run -- nur Analyse, es wird nichts veraendert"
            Write-Msg (Dim   "         Vorschau, was bei einem Plugin (oder allen) passieren wuerde:")
            Write-Msg (Dim   "         Abhaengigkeitsbericht, welche pip-Launcher-Stubs entfernt wuerden.")
            Write-Msg ""
            Write-Msg        "    [2]  Update -- kompletter Wartungslauf"
            Write-Msg (Dim   "         Backup, Entfernen ungenutzter Module UND Installieren/Aktualisieren")
            Write-Msg (Dim   "         der Bibliotheken per pip, alles in einem Durchgang. Fuer eine")
            Write-Msg (Dim   "         vollstaendige Auffrischung eines Plugins.")
            Write-Msg ""
            Write-Msg        "    [3]  Library-Check -- prueft installierte Bibliotheken gegen PyPI"
            Write-Msg (Dim   "         Kein Modul-Cleanup, aber ein Backup wird vor der ersten echten")
            Write-Msg (Dim   "         Installation angelegt. Fragt J/N/A pro veralteter Library.")
            Write-Msg ""
            Write-Msg (Dim   "  Faustregel: frisch von GitHub geladen? Dann meist kein Mode 2 noetig --")
            Write-Msg (Dim   "  melcom hat ihn schon vor dem Release des Plugins durchlaufen lassen. Mode 3")
            Write-Msg (Dim   "  reicht, um aktuell zu bleiben. Mode 2 ist fuer echte strukturelle Aenderungen")
            Write-Msg (Dim   "  am Abhaengigkeitsbaum gedacht (z.B. ein 32-auf-64bit-Umzug).")
        }
        Write-Msg ""
        if ($lang -eq '1') {
            Write-Msg        "    [q]  Quit"
        } else {
            Write-Msg        "    [q]  Beenden"
        }
        Write-Msg ""

        if ($errorMsg) {
            Write-Msg (Red "  [!] $errorMsg")
            Write-Msg ""
            $errorMsg = $null
        }

        if ($lang -eq '1') {
            $choice = Read-Msg "  > Your choice [1/2/3/q]"
        } else {
            $choice = Read-Msg "  > Deine Wahl [1/2/3/q]"
        }

        if ($choice -eq 'q' -or $choice -eq 'Q') { Show-MatrixExit -lang $lang }

        if ($choice -notin @('1','2','3')) {
            $errorMsg = "Only 1, 2 or 3 are allowed. / Nur 1, 2 oder 3 sind erlaubt."
        }
    }

    return $choice
}

# ---------------------------------------------------------------------------
# Manifest helpers for batch mode
# ---------------------------------------------------------------------------
function Test-MelcomManifest {
    param($manifest)

    if (-not $manifest) { return $false }

    $author = [string]$manifest.author
    if ($author.Trim().ToLowerInvariant() -ne 'melcom') { return $false }

    $url  = [string]$manifest.url
    $repo = $null
    if ($manifest.external_updater -and $manifest.external_updater.repo) {
        $repo = [string]$manifest.external_updater.repo
    }

    if ($url -notlike '*github.com/melcom-creations/*' -and $repo -notlike 'melcom-creations/*') {
        return $false
    }

    return $true
}

function Get-InstalledPluginInventory {
    param($installedRoot)

    $result = [ordered]@{
        Valid   = New-Object 'System.Collections.Generic.List[object]'
        Skipped = New-Object 'System.Collections.Generic.List[object]'
    }

    if (-not (Test-Path $installedRoot -PathType Container)) {
        return [pscustomobject]$result
    }

    foreach ($dir in (Get-ChildItem -Path $installedRoot -Directory -ErrorAction SilentlyContinue)) {
        $manifestPath = Join-Path $dir.FullName 'manifest.json'
        if (-not (Test-Path $manifestPath -PathType Leaf)) { continue }

        try {
            $manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
        } catch {
            $manifest = $null
        }

        if (-not $manifest) { continue }

        $entry = [pscustomobject]@{
            RootPath     = $dir.FullName
            ManifestPath = $manifestPath
            Name         = [string]$manifest.name
            Guid         = [string]$manifest.guid
            Author       = [string]$manifest.author
            Url          = [string]$manifest.url
            Repo         = if ($manifest.external_updater -and $manifest.external_updater.repo) { [string]$manifest.external_updater.repo } else { '' }
            IsMelcom     = (Test-MelcomManifest -manifest $manifest)
        }

        if ($entry.IsMelcom) { [void]$result.Valid.Add($entry) }
        else                 { [void]$result.Skipped.Add($entry) }
    }

    return [pscustomobject]$result
}

# ---------------------------------------------------------------------------
# Plugin root path prompt
# Accepts %env% variables in the input. Validates that the folder exists and
# contains at least plugin.py or manifest.json so we know it is a plugin root.
# On a bad entry the screen is redrawn cleanly instead of appending errors.
# ---------------------------------------------------------------------------
function Get-PluginRoot {
    param($lang)

    $raw        = ""
    $isFirstRun = $true

    while ($true) {
        if (-not $isFirstRun) { Show-Banner }
        $isFirstRun = $false

        if ($lang -eq '1') {
            Write-Msg (Yellow "  Enter the ROOT path of your GOG Galaxy plugin folder.")
            Write-Msg (Dim   "  Typical location:")
            Write-Msg (Dim   "    %localappdata%\GOG.com\Galaxy\plugins\installed\<plugin_folder>")
            Write-Msg (Dim   "    You can also paste the path directly from the Explorer address bar.")
            Write-Msg (Dim   "    Type 'b' to go back to mode selection.")
        } else {
            Write-Msg (Yellow "  Bitte den ROOT-Pfad des GOG Galaxy Plugin-Ordners eingeben.")
            Write-Msg (Dim   "  Typischer Speicherort:")
            Write-Msg (Dim   "    %localappdata%\GOG.com\Galaxy\plugins\installed\<plugin_ordner>")
            Write-Msg (Dim   "    Den Pfad einfach aus der Adressleiste des Explorers einfuegen.")
            Write-Msg (Dim   "    'b' eingeben, um zurueck zur Modusauswahl zu gehen.")
        }
        Write-Msg ""

        if ($global:PathError) {
            Write-Msg (Red "  [!] $global:PathError")
            Write-Msg ""
            $global:PathError = $null
        }

        if ($lang -eq '1') {
            $raw = (Read-Msg "  > Path (or 'b' for back)").Trim()
        } else {
            $raw = (Read-Msg "  > Pfad (oder 'b' fuer zurueck)").Trim()
        }

        if ($raw -eq 'b' -or $raw -eq 'B') { return $BACK_TO_MODE_SENTINEL }

        # Tolerate common paste artifacts from terminals/chats (quotes,
        # markdown backticks, trailing caret) before path validation.
        $raw = $raw.Trim('"').Trim("'").Trim('`')
        $raw = $raw.TrimEnd('^').TrimEnd('\\').Trim()

        if (-not $raw) {
            if ($lang -eq '1') { $global:PathError = "Path cannot be empty. Please enter a valid directory." }
            else               { $global:PathError = "Der Pfad darf nicht leer sein. Bitte ein Verzeichnis eingeben." }
            continue
        }

        # Expand %LOCALAPPDATA% and similar environment variables
        $raw = [System.Environment]::ExpandEnvironmentVariables($raw)

        if (-not (Test-Path $raw -PathType Container)) {
            if ($lang -eq '1') { $global:PathError = "Directory not found: $raw" }
            else               { $global:PathError = "Verzeichnis nicht gefunden: $raw" }
            continue
        }

        # Verify this is a GOG plugin root (must contain plugin.py or manifest.json)
        $hasPluginPy     = Test-Path (Join-Path $raw 'plugin.py')      -PathType Leaf
        $hasManifestJson = Test-Path (Join-Path $raw 'manifest.json')   -PathType Leaf

        if (-not $hasPluginPy -and -not $hasManifestJson) {
            if ($lang -eq '1') {
                $global:PathError = "The folder contains neither 'plugin.py' nor 'manifest.json'. Please select a valid GOG plugin root."
            } else {
                $global:PathError = "Der Ordner enthaelt weder 'plugin.py' noch 'manifest.json'. Das ist kein gueltiger GOG-Plugin-Root-Ordner."
            }
            continue
        }

        break
    }
    return $raw + '\'
}

# ---------------------------------------------------------------------------
# Plugin picker for Mode 1 / Mode 2
# Lists every melcom plugin already detected under the standard GOG Galaxy
# installed-plugins folder (same detection every mode uses) so the person can
# just pick a number instead of typing/pasting a path every time. Non-melcom
# plugins found in the same folder are shown too, but clearly marked as
# excluded and why -- so nobody can quietly pass off a foreign plugin as one
# of melcom's by dropping it into the same directory. Manual path entry is
# kept as a fallback option for anything installed outside the standard
# location (custom Galaxy install, a plugin still being developed elsewhere).
# ---------------------------------------------------------------------------
function Select-PluginFromInventory {
    param($lang)

    $installedRoot = Join-Path $env:LOCALAPPDATA 'GOG.com\Galaxy\plugins\installed'
    $inventory = Get-InstalledPluginInventory -installedRoot $installedRoot

    if ($inventory.Valid.Count -eq 0) {
        if ($lang -eq '1') {
            Write-Msg (Yellow "  No melcom plugins detected under:")
        } else {
            Write-Msg (Yellow "  Keine melcom-Plugins gefunden unter:")
        }
        Write-Msg (Dim "    $installedRoot")
        Write-Msg ""
        return (Get-PluginRoot -lang $lang)
    }

    $sorted = @($inventory.Valid | Sort-Object Name, Guid)

    while ($true) {
        Write-Msg ""
        Write-Msg (Cyan "  ================================================================")
        if ($lang -eq '1') { Write-Msg (Bold (Cyan "   Detected melcom plugins")) }
        else               { Write-Msg (Bold (Cyan "   Erkannte melcom-Plugins")) }
        Write-Msg (Cyan "  ================================================================")
        Write-Msg ""
        Write-Msg ("  " + (White "Installed root :") + " " + (White $installedRoot))
        Write-Msg ""

        for ($i = 0; $i -lt $sorted.Count; $i++) {
            Write-Msg ("    " + (Green ("[{0}]" -f ($i + 1))) + "  " + $sorted[$i].Name + "  (" + $sorted[$i].Guid + ")")
        }
        Write-Msg ""

        if ($lang -eq '1') {
            Write-Msg ("    " + (Green "[a]") + "  All plugins listed above (asks its questions once, then runs through all of them)")
        } else {
            Write-Msg ("    " + (Green "[a]") + "  Alle oben gelisteten Plugins (fragt einmal, laeuft dann durch alle durch)")
        }
        Write-Msg ""

        $manualOption = $sorted.Count + 1
        if ($lang -eq '1') {
            Write-Msg ("    " + (White ("[{0}]" -f $manualOption)) + "  Enter a path manually instead (e.g. a plugin outside this folder)")
        } else {
            Write-Msg ("    " + (White ("[{0}]" -f $manualOption)) + "  Stattdessen Pfad manuell eingeben (z.B. Plugin ausserhalb dieses Ordners)")
        }
        Write-Msg ""

        if ($lang -eq '1') {
            Write-Msg ("    " + (White "[b]") + "  Back to mode selection")
        } else {
            Write-Msg ("    " + (White "[b]") + "  Zurueck zur Modusauswahl")
        }
        Write-Msg ""

        if ($inventory.Skipped.Count -gt 0) {
            if ($lang -eq '1') { Write-Msg (Bold (Yellow "  Excluded (not a melcom plugin):")) }
            else               { Write-Msg (Bold (Yellow "  Ausgeschlossen (kein melcom-Plugin):")) }
            foreach ($entry in ($inventory.Skipped | Sort-Object Name, Guid)) {
                $authorLabel = if ($entry.Author) { $entry.Author } elseif ($lang -eq '1') { 'unknown author' } else { 'unbekannter Autor' }
                Write-Msg ("    " + (Yellow "[-] ") + $entry.Name + "  (" + $entry.Guid + ")")
                if ($lang -eq '1') {
                    Write-Msg (Dim "        Excluded: manifest author/url/repo do not match melcom ($authorLabel).")
                } else {
                    Write-Msg (Dim "        Ausgeschlossen: Manifest-Autor/URL/Repo passen nicht zu melcom ($authorLabel).")
                }
            }
            Write-Msg ""
        }

        if ($lang -eq '1') {
            $choice = (Read-Msg "  > Your choice [1-$manualOption, a, b]").Trim()
        } else {
            $choice = (Read-Msg "  > Deine Wahl [1-$manualOption, a, b]").Trim()
        }

        if ($choice -eq 'a' -or $choice -eq 'A') { return $ALL_PLUGINS_SENTINEL }
        if ($choice -eq 'b' -or $choice -eq 'B') { return $BACK_TO_MODE_SENTINEL }

        $asInt = 0
        if (-not [int]::TryParse($choice, [ref]$asInt)) { continue }
        if ($asInt -eq $manualOption) { return (Get-PluginRoot -lang $lang) }
        if ($asInt -ge 1 -and $asInt -le $sorted.Count) {
            return ($sorted[$asInt - 1].RootPath + '\')
        }
        # Anything else (0, out of range, etc.) just loops and shows the list again.
    }
}

# ---------------------------------------------------------------------------
# Step header
# ---------------------------------------------------------------------------
function Write-StepHeader {
    param($step, $total, $title)
    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    Write-Msg (Bold (Cyan "   [$step/$total] $title"))
    Write-Msg (Cyan "  ================================================================")
    Write-Msg ""
}

# ---------------------------------------------------------------------------
# Collect .py files in ROOT only (excludes /modules/)
# ---------------------------------------------------------------------------
function Get-RootPyFiles {
    param($rootPath)
    $modulesDir = Join-Path $rootPath 'modules'
    $all = Get-ChildItem -Path $rootPath -Filter '*.py' -Recurse -File -ErrorAction SilentlyContinue
    return @($all | Where-Object { $_.FullName -notlike ($modulesDir + '*') })
}

# ---------------------------------------------------------------------------
# Collect ALL .py files recursively including /modules/
# Used to build the full transitive import set.
# ---------------------------------------------------------------------------
function Get-AllPyFiles {
    param($rootPath)
    return @(Get-ChildItem -Path $rootPath -Filter '*.py' -Recurse -File -ErrorAction SilentlyContinue)
}

# ---------------------------------------------------------------------------
# Parse import statements from a list of .py files.
# Filters out a package's own self-imports so internal relative imports
# inside a library do not count as external dependencies.
# ---------------------------------------------------------------------------
function Get-Imports {
    param($pyFiles, $rootPath)

    $imports    = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $rxImport   = [regex]'^\s*import\s+(.+)$'
    $rxFrom     = [regex]'^\s*from\s+([\w\.]+)\s+import'
    $modulesDir = Join-Path $rootPath 'modules'

    foreach ($f in $pyFiles) {
        # Determine which package this file belongs to (if inside /modules/)
        $currentPackage = $null
        if ($f.FullName -like ($modulesDir + '*')) {
            $relPath = $f.FullName.Substring($modulesDir.Length).TrimStart('\')
            $currentPackage = ($relPath -split '\\')[0]
            if ($currentPackage -match '\.py$') {
                $currentPackage = [System.IO.Path]::GetFileNameWithoutExtension($currentPackage)
            }
        }

        $lines = Get-Content $f.FullName -ErrorAction SilentlyContinue
        if (-not $lines) { continue }

        foreach ($line in $lines) {
            $m = $rxImport.Match($line)
            if ($m.Success) {
                # Handle multi-import lines like: import a, b as c
                $importList = ($m.Groups[1].Value -split '#')[0]
                foreach ($part in ($importList -split ',')) {
                    $cleanPart = $part.Trim()
                    if (-not $cleanPart) { continue }

                    $baseName = ($cleanPart -split '\s+as\s+')[0].Trim()
                    if (-not $baseName) { continue }

                    $imp = ($baseName -split '\.')[0]
                    if (-not $imp) { continue }

                    if (-not $currentPackage -or ($imp -ne $currentPackage)) {
                        [void]$imports.Add($imp)
                    }
                }
            }
            $m = $rxFrom.Match($line)
            if ($m.Success) {
                $imp = ($m.Groups[1].Value -split '\.')[0]
                if ($imp -and $imp -notmatch '^\.') {
                    if (-not $currentPackage -or ($imp -ne $currentPackage)) {
                        [void]$imports.Add($imp)
                    }
                }
            }
        }
    }
    return $imports
}

# ---------------------------------------------------------------------------
# Map /modules/ directory into typed buckets:
#   PythonPackages  - folders that contain .py or .pyd files
#   DistInfos       - <pkg>-<ver>.dist-info metadata folders
#   Singles         - standalone .py or .pyd files at the modules root
#   NonPython       - everything else (binary blobs, data dirs, etc.)
# ---------------------------------------------------------------------------
function Get-ModulesMap {
    param($rootPath)

    $modulesDir = Join-Path $rootPath 'modules'

    $result = @{
        PythonPackages = [ordered]@{}
        DistInfos      = [ordered]@{}
        NonPython      = New-Object 'System.Collections.Generic.List[string]'
        Singles        = [ordered]@{}
    }

    if (-not (Test-Path $modulesDir)) { return $result }

    foreach ($item in (Get-ChildItem -Path $modulesDir -ErrorAction SilentlyContinue)) {
        if ($item.Name -match '\.dist-info$') {
            $pkgName = ($item.Name -replace '-[^-]+\.dist-info$', '')
            $result.DistInfos[$item.Name] = $pkgName
        }
        elseif ($item.PSIsContainer) {
            $pyCount  = (Get-ChildItem $item.FullName -Filter '*.py'  -Recurse -ErrorAction SilentlyContinue).Count
            $pydCount = (Get-ChildItem $item.FullName -Filter '*.pyd' -Recurse -ErrorAction SilentlyContinue).Count
            if ($pyCount -gt 0 -or $pydCount -gt 0) {
                $hasInit = Test-Path (Join-Path $item.FullName '__init__.py')
                $result.PythonPackages[$item.Name] = @{ Path=$item.FullName; HasInit=$hasInit }
            } else {
                $result.NonPython.Add($item.Name)
            }
        }
        elseif ($item.Extension -in @('.py','.pyd')) {
            $result.Singles[$item.BaseName] = $item.FullName
        }
        else {
            $result.NonPython.Add($item.Name)
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Resolve the full dependency tree.
#
# Classification buckets:
#   Direct        - imported directly by the plugin's own root .py files
#   Transitive    - not in root imports but used somewhere inside /modules/
#   AliasResolved - import name differs from the PyPI package name (e.g. attr -> attrs)
#   ProtectedKept - non-Python dirs, galaxy internals, binary blobs
#   ToRemove      - present in /modules/ but never imported anywhere
#
# Dev-tool blacklist:
#   Build and test packages (pytest, pip, setuptools, ...) are always marked
#   for removal even if the BFS scanner finds a transitive import path to them,
#   because those packages import each other and would otherwise create a
#   circular false-positive.
# ---------------------------------------------------------------------------
function Resolve-DependencyTree {
    param($rootImports, $allImports, $modulesMap)

    # Maps import-time names to their real PyPI distribution names
    $aliases = @{
        'attr'     = 'attrs'
        'yaml'     = 'PyYAML'
        'PIL'      = 'Pillow'
        'cv2'      = 'opencv-python'
        'bs4'      = 'beautifulsoup4'
        'sklearn'  = 'scikit-learn'
        'dateutil' = 'python-dateutil'
        'google'   = 'protobuf'
        'galaxy'   = 'galaxy_plugin_api'
    }

    # Expand the full import set with alias targets so that e.g. 'attr' being
    # imported also marks 'attrs' as referenced, preventing false REMOVE hits.
    $expandedImports = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($imp in $allImports) {
        [void]$expandedImports.Add($imp)
        if ($aliases.ContainsKey($imp)) { [void]$expandedImports.Add($aliases[$imp]) }
    }
    foreach ($imp in $rootImports) {
        [void]$expandedImports.Add($imp)
        if ($aliases.ContainsKey($imp)) { [void]$expandedImports.Add($aliases[$imp]) }
    }

    $allModuleKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($k in $modulesMap.PythonPackages.Keys) { [void]$allModuleKeys.Add($k) }
    foreach ($k in $modulesMap.Singles.Keys)        { [void]$allModuleKeys.Add($k) }

    $stdlib = @(
        'os','sys','re','json','time','datetime','logging','pathlib','shutil',
        'subprocess','collections','itertools','functools','threading','asyncio',
        'typing','abc','io','math','hashlib','hmac','base64','copy','struct',
        'socket','ssl','http','urllib','email','html','xml','csv','sqlite3',
        'configparser','argparse','traceback','inspect','platform','uuid',
        'contextlib','dataclasses','enum','queue','weakref','gc','signal',
        'glob','fnmatch','tempfile','zipfile','tarfile','gzip','zlib',
        'random','secrets','string','textwrap','unicodedata','codecs',
        'builtins','warnings','unittest','ctypes','winreg','msvcrt',
        'concurrent','multiprocessing','pickle','array','decimal',
        'fractions','statistics','heapq','bisect','pprint','distutils',
        'importlib','pkg_resources','site','atexit','ntpath','posixpath',
        'numbers','operator','reprlib','types','token','tokenize','errno',
        'locale','gettext','binascii'
    )

    # Galaxy internals and binary/runtime namespaces that must never be removed.
    # cffi/pycparser/_cffi_backend plus packaging/mypy_extensions can be needed
    # by transitive runtime stacks even if static import scanning does not see them.
    $protectedNamespaces = @('galaxy_api','bnet','bin','splash','cffi','pycparser','_cffi_backend','packaging','mypy_extensions')

    # Dev / build / test packages that are never needed at plugin runtime
    $devToolsBlacklist = @(
        'pytest','_pytest','py','pluggy','iniconfig','atomicwrites',
        'pip','pip_tools','setuptools','wheel','piptools','pep517',
        'click','colorama','invoke','pyparsing','build','pyproject_hooks',
        '_distutils_hack','importlib_metadata','zipp','tomli',
        'asynctest'
    )

    $direct        = New-Object 'System.Collections.Generic.List[string]'
    $transitive    = New-Object 'System.Collections.Generic.List[string]'
    $aliasResolved = New-Object 'System.Collections.Generic.List[string]'
    $protectedKept = New-Object 'System.Collections.Generic.List[string]'
    $toRemove      = New-Object 'System.Collections.Generic.List[string]'

    # Pass 1: classify direct imports from the plugin's root files
    foreach ($imp in $rootImports) {
        if ($imp -in $stdlib)             { continue }
        if ($imp -in $protectedNamespaces) {
            if (-not $protectedKept.Contains($imp)) { $protectedKept.Add($imp) }
            continue
        }
        if ($allModuleKeys.Contains($imp)) {
            if (-not $direct.Contains($imp)) { $direct.Add($imp) }
            continue
        }
        if ($aliases.ContainsKey($imp)) {
            $real = $aliases[$imp]
            if ($allModuleKeys.Contains($real)) {
                if (-not $aliasResolved.Contains($imp))  { $aliasResolved.Add($imp) }
                if (-not $aliasResolved.Contains($real)) { $aliasResolved.Add($real) }
            }
        }
    }

    # Pass 2: classify everything else found across the full project scan
    foreach ($pkg in $modulesMap.PythonPackages.Keys) {
        if ($pkg -in $protectedNamespaces) {
            if (-not $protectedKept.Contains($pkg)) { $protectedKept.Add($pkg) }
            continue
        }
        if ($pkg -in $devToolsBlacklist) {
            if (-not $toRemove.Contains($pkg)) { $toRemove.Add($pkg) }
            continue
        }
        if ($direct.Contains($pkg) -or $aliasResolved.Contains($pkg)) { continue }

        if ($expandedImports.Contains($pkg)) {
            $transitive.Add($pkg)
        } else {
            if (-not $toRemove.Contains($pkg)) { $toRemove.Add($pkg) }
        }
    }

    foreach ($s in $modulesMap.Singles.Keys) {
        if ($s -in $protectedNamespaces) {
            if (-not $protectedKept.Contains($s)) { $protectedKept.Add($s) }
            continue
        }
        if ($s -in $devToolsBlacklist) {
            if (-not $toRemove.Contains($s)) { $toRemove.Add($s) }
            continue
        }
        if ($direct.Contains($s) -or $aliasResolved.Contains($s) -or $transitive.Contains($s)) { continue }

        # Strip compiled-extension suffix before matching (e.g. foo.cp313-win.* -> foo)
        $cleanS = $s -replace '\.cp\d+-win.*$', ''
        if ($expandedImports.Contains($s) -or $expandedImports.Contains($cleanS)) {
            $transitive.Add($s)
        } else {
            if (-not $toRemove.Contains($s)) { $toRemove.Add($s) }
        }
    }

    foreach ($np in $modulesMap.NonPython) {
        if (-not $protectedKept.Contains($np)) { $protectedKept.Add($np) }
    }

    return @{
        Direct        = $direct
        Transitive    = $transitive
        AliasResolved = $aliasResolved
        ProtectedKept = $protectedKept
        ToRemove      = $toRemove
    }
}

# ---------------------------------------------------------------------------
# Print the full analysis report
# ---------------------------------------------------------------------------
function Write-Report {
    param($rootPath, $pyFiles, $modulesMap, $tree, $lang)

    $modulesDir  = Join-Path $rootPath 'modules'
    $totalPython = $modulesMap.PythonPackages.Count + $modulesMap.Singles.Count

    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    Write-Msg (Bold (White "   ANALYSIS REPORT  --  $TOOL_NAME $TOOL_VERSION"))
    Write-Msg (Cyan "  ================================================================")
    Write-Msg ""
    Write-Msg ("  ROOT path  : " + (White $rootPath))

    if (Test-Path $rootPath) {
        Write-Msg ("  " + (Green "[OK]") + " ROOT    : " + (White $rootPath))
    } else {
        Write-Msg ("  " + (Red  "[!!]") + " ROOT    : " + (White $rootPath))
    }
    if (Test-Path $modulesDir) {
        Write-Msg ("  " + (Green "[OK]") + " Modules : " + (White $modulesDir))
    } else {
        Write-Msg ("  " + (Yellow "[--]") + " Modules : " + (White $modulesDir))
    }
    Write-Msg ""

    if ($lang -eq '1') { $t = 'Scanning .py files in ROOT...' } else { $t = 'Scanne .py-Dateien im ROOT...' }
    Write-StepHeader '1' '4' $t
    if ($lang -eq '1') {
        Write-Msg ("  " + (Green "Found") + " " + (White "$($pyFiles.Count)") + " .py file(s).")
    } else {
        Write-Msg ("  " + (Green "Gefunden:") + " " + (White "$($pyFiles.Count)") + " .py-Datei(en).")
    }
    foreach ($f in $pyFiles) { Write-Msg ("    " + (Dim $f.Name)) }

    if ($lang -eq '1') { $t = '/modules/ content map' } else { $t = '/modules/ Inhalts-Karte' }
    Write-StepHeader '2' '4' $t
    Write-Msg ("  " + (Cyan "Python items") + " : " + (White "$totalPython"))
    Write-Msg ("  " + (Cyan "Dist-Infos  ") + " : " + (White "$($modulesMap.DistInfos.Count)"))
    Write-Msg ("  " + (Cyan "Non-Python  ") + " : " + (White "$($modulesMap.NonPython.Count)"))

    if ($lang -eq '1') { $t = 'Resolving full dependency tree...' } else { $t = 'Abhaengigkeitsbaum aufloesen...' }
    Write-StepHeader '3' '4' $t
    if ($lang -eq '1') {
        Write-Msg ("  " + (Green "Direct dependencies kept    ") + " : " + (White "$($tree.Direct.Count)"))
        Write-Msg ("  " + (Green "Transitive dependencies kept") + " : " + (White "$($tree.Transitive.Count)"))
        Write-Msg ("  " + (Yellow "Alias-resolved kept         ") + " : " + (White "$($tree.AliasResolved.Count)"))
        Write-Msg ("  " + (Red   "To remove                   ") + " : " + (White "$($tree.ToRemove.Count)"))
    } else {
        Write-Msg ("  " + (Green "Direkte Abhaengigkeiten    ") + " : " + (White "$($tree.Direct.Count)"))
        Write-Msg ("  " + (Green "Transitive Abhaengigkeiten ") + " : " + (White "$($tree.Transitive.Count)"))
        Write-Msg ("  " + (Yellow "Alias-aufgeloest           ") + " : " + (White "$($tree.AliasResolved.Count)"))
        Write-Msg ("  " + (Red   "Zu entfernen               ") + " : " + (White "$($tree.ToRemove.Count)"))
    }
    Write-Msg ""

    if ($tree.Direct.Count -gt 0) {
        if ($lang -eq '1') { $lbl = "KEEP  - Direct imports ($($tree.Direct.Count)):" }
        else               { $lbl = "KEEP  - Direkte Importe ($($tree.Direct.Count)):" }
        Write-Msg ("  " + (Bold (Green $lbl)))
        foreach ($d in ($tree.Direct | Sort-Object)) { Write-Msg ("    " + (Green "[+]") + " $d") }
        Write-Msg ""
    }

    if ($tree.Transitive.Count -gt 0) {
        if ($lang -eq '1') { $lbl = "KEEP  - Transitive & METADATA Dependencies ($($tree.Transitive.Count)):" }
        else               { $lbl = "KEEP  - Transitive & METADATA Abhaengigkeiten ($($tree.Transitive.Count)):" }
        Write-Msg ("  " + (Bold (Cyan $lbl)))
        foreach ($t2 in ($tree.Transitive | Sort-Object)) { Write-Msg ("    " + (Cyan "[~]") + " $t2") }
        Write-Msg ""
    }

    if ($tree.AliasResolved.Count -gt 0) {
        if ($lang -eq '1') { $lbl = "KEEP  - Alias-resolved ($($tree.AliasResolved.Count)):" }
        else               { $lbl = "KEEP  - Alias-aufgeloest ($($tree.AliasResolved.Count)):" }
        Write-Msg ("  " + (Bold (Yellow $lbl)))
        foreach ($a in ($tree.AliasResolved | Sort-Object)) { Write-Msg ("    " + (Yellow "[a]") + " $a") }
        Write-Msg ""
    }

    if ($tree.ProtectedKept.Count -gt 0) {
        if ($lang -eq '1') { $lbl = "SKIP  - Protected / Internal ($($tree.ProtectedKept.Count)):" }
        else               { $lbl = "SKIP  - Geschuetzt / Intern ($($tree.ProtectedKept.Count)):" }
        Write-Msg ("  " + (Bold (Magenta $lbl)))
        foreach ($n in ($tree.ProtectedKept | Sort-Object)) { Write-Msg ("    " + (Magenta "[!]") + " $n") }
        Write-Msg ""
    }

    if ($tree.ToRemove.Count -gt 0) {
        if ($lang -eq '1') { $lbl = "REMOVE - Unused Python lib ($($tree.ToRemove.Count)):" }
        else               { $lbl = "REMOVE - Ungenutzte Python-Lib ($($tree.ToRemove.Count)):" }
        Write-Msg ("  " + (Bold (Red $lbl)))
        foreach ($r in ($tree.ToRemove | Sort-Object)) { Write-Msg ("    " + (Red "[-]") + " $r") }
    } else {
        if ($lang -eq '1') { $lbl = "REMOVE - Unused Python lib (0)  -- nothing to remove" }
        else               { $lbl = "REMOVE - Ungenutzte Python-Lib (0)  -- nichts zu entfernen" }
        Write-Msg ("  " + (Bold (Red $lbl)))
    }
    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
}

# ---------------------------------------------------------------------------
# Library name helpers
# Normalizes import/module names to stable pip package identifiers so the
# generated LIBRARIES list stays deterministic across reruns.
# ---------------------------------------------------------------------------
function Get-LibraryKey {
    param([string]$Name)

    if (-not $Name) { return $null }
    return (($Name.Trim().ToLowerInvariant()) -replace '[_-]', '')
}

function Get-CanonicalLibraryName {
    param([string]$Name)

    if (-not $Name) { return $null }

    switch -Regex ($Name.Trim().ToLowerInvariant()) {
        '^python[_-]?dateutil$|^dateutil$' { return 'python-dateutil' }
        '^pyyaml$|^yaml$|^_yaml$'          { return 'PyYAML' }
        '^scikit[_-]?learn$'               { return 'scikit-learn' }
        '^opencv[_-]?python$'              { return 'opencv-python' }
        '^beautifulsoup4$|^bs4$'          { return 'beautifulsoup4' }
        '^pil$|^pillow$'                   { return 'Pillow' }
        '^galaxy$'                         { return 'galaxy_plugin_api' }
        '^google$'                         { return 'protobuf' }
        default                            { return $Name.Trim() }
    }
}

# ---------------------------------------------------------------------------
# Backup
# Zips the /modules/ folder into a timestamped archive next to this script.
# ---------------------------------------------------------------------------
function New-Backup {
    param($rootPath, $lang, [switch]$NoPrompt)

    if ($NoPrompt) {
        $yes = $true
    } elseif ($lang -eq '1') {
        $ask = Read-Msg (Yellow "  Create a backup of the /modules/ folder? [Y/N]")
        $yes = ($ask -eq 'Y' -or $ask -eq 'y')
    } else {
        $ask = Read-Msg (Yellow "  Backup des /modules/-Ordners anlegen? [J/N]")
        $yes = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
    }
    if (-not $yes) { return $null }

    $modulesDir = Join-Path $rootPath 'modules'
    if (-not (Test-Path $modulesDir)) {
        if ($lang -eq '1') { Write-Msg (Red "  [!] No /modules/ folder found - skipping backup.") }
        else               { Write-Msg (Red "  [!] Kein /modules/-Ordner gefunden - Backup uebersprungen.") }
        return $null
    }

    $pluginName = Split-Path $rootPath -Leaf
    $timestamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupDir  = Join-Path $PSScriptRoot ('backups\' + $pluginName)
    $zipPath    = Join-Path $backupDir ($pluginName + '_' + $timestamp + '.zip')

    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($modulesDir, $zipPath)

    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg ("  " + (Green "[OK] Backup created:"))
    } else {
        Write-Msg ("  " + (Green "[OK] Backup erstellt:"))
    }
    Write-Msg (White "       $zipPath")
    Write-Msg ""
    return $zipPath
}

# ---------------------------------------------------------------------------
# Remove unused modules from /modules/
# Also removes associated .dist-info metadata folders.
# ---------------------------------------------------------------------------
function Remove-UnusedModules {
    param($rootPath, $toRemove, $modulesMap, $lang, [switch]$NoPrompt)

    if ($toRemove.Count -eq 0) { return $false }

    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    Write-Msg (Bold (White "   CLEANUP  --  Remove Unused Modules"))
    Write-Msg (Cyan "  ================================================================")
    Write-Msg ""

    if ($NoPrompt) {
        $yes = $true
    } elseif ($lang -eq '1') {
        $ask = Read-Msg "  Remove $($toRemove.Count) unused module(s) from /modules/? [Y/N]"
        $yes = ($ask -eq 'Y' -or $ask -eq 'y')
    } else {
        $ask = Read-Msg "  $($toRemove.Count) ungenutzte(s) Modul(e) aus /modules/ loeschen? [J/N]"
        $yes = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
    }

    if (-not $yes) {
        if ($lang -eq '1') { Write-Msg (Dim "  Cleanup skipped.") }
        else               { Write-Msg (Dim "  Bereinigung uebersprungen.") }
        return $false
    }

    $modulesDir = Join-Path $rootPath 'modules'

    foreach ($item in $toRemove) {
        $targetPath = $null
        if ($modulesMap.PythonPackages.Contains($item)) { $targetPath = $modulesMap.PythonPackages[$item].Path }
        elseif ($modulesMap.Singles.Contains($item))    { $targetPath = $modulesMap.Singles[$item] }

        if ($targetPath -and (Test-Path $targetPath)) {
            Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
            if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed: $item") }
            else               { Write-Msg ("  " + (Red "[-]") + " Geloescht: $item") }
        }

        # Remove associated .dist-info folder if present
        foreach ($dist in $modulesMap.DistInfos.Keys) {
            if ($modulesMap.DistInfos[$dist] -eq $item) {
                $distPath = Join-Path $modulesDir $dist
                if (Test-Path $distPath) {
                    Remove-Item -Path $distPath -Recurse -Force -ErrorAction SilentlyContinue
                    if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed metadata: $dist") }
                    else               { Write-Msg ("  " + (Red "[-]") + " Metadaten geloescht: $dist") }
                }
            }
        }
    }
    Write-Msg ""
    return $true
}

# ---------------------------------------------------------------------------
# Post-update reconciliation
#
# Re-scans the updated tree and removes anything the generic resolver now
# marks as removable. This keeps post-update cleanup based on the live tree
# instead of a stale pre-update removal list.
# ---------------------------------------------------------------------------
function Invoke-PostUpdateCleanup {
    param($rootPath, $lang)

    $pyFilesRoot = Get-RootPyFiles -rootPath $rootPath
    $pyFilesAll  = Get-AllPyFiles -rootPath $rootPath
    $modulesMap  = Get-ModulesMap -rootPath $rootPath
    $rootImports = Get-Imports -pyFiles $pyFilesRoot -rootPath $rootPath
    $allImports  = Get-Imports -pyFiles $pyFilesAll  -rootPath $rootPath
    $tree        = Resolve-DependencyTree -rootImports $rootImports -allImports $allImports -modulesMap $modulesMap

    if ($tree.ToRemove.Count -gt 0) {
        $cleanupApplied = Remove-UnusedModules -rootPath $rootPath -toRemove $tree.ToRemove -modulesMap $modulesMap -lang $lang -NoPrompt
        if ($cleanupApplied -and $lang -eq '1') {
            Write-Msg (Dim "  Post-update rescan cleanup applied.")
        } elseif ($cleanupApplied -and $lang -ne '1') {
            Write-Msg (Dim "  Bereinigung nach Update-Rescan angewendet.")
        }
    }
}

# ---------------------------------------------------------------------------
# Write plugin-config.txt next to this script.
# Maps module folder names to their real PyPI package names where needed.
# Skips internal, binary-only, and dev-tool entries.
# ---------------------------------------------------------------------------
function Write-Config {
    param($rootPath, $modulesMap)

    $modulesDir = Join-Path $rootPath 'modules'
    $configPath = Join-Path $PSScriptRoot 'plugin-config.txt'
    $timestamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $backupDir  = Join-Path $PSScriptRoot 'backups'
    $cacheDir   = Join-Path $PSScriptRoot 'pip-cache'

    # Entries that must never appear in the LIBRARIES list
    $blacklist = @(
        'galaxy_api','bnet','examples','bin','splash','test','tests','docs','doc',
        'steam_network',
        'pytest','_pytest','py','pluggy','iniconfig','atomicwrites',
        'pip','pip_tools','setuptools','wheel','piptools','pep517',
        'click','colorama','invoke','pyparsing','build','pyproject_hooks',
        '_distutils_hack','importlib_metadata','zipp','tomli',
        'asynctest'
    )

    $blacklistKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($item in $blacklist) {
        [void]$blacklistKeys.Add((Get-LibraryKey $item))
    }

    $seenLibraryKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $addLibrary = {
        param([string]$candidateName)

        $canonical = Get-CanonicalLibraryName $candidateName
        $key = Get-LibraryKey $canonical
        if (-not $key) { return }
        if ($blacklistKeys.Contains($key)) { return }
        if ($seenLibraryKeys.Add($key)) {
            [void]$libs.Add($canonical)
        }
    }

    # Maps folder/import names to their installable PyPI package names
    $packageMapping = @{
        'galaxy'   = 'galaxy_plugin_api'
        'google'   = 'protobuf'
        'yaml'     = 'PyYAML'
        'PIL'      = 'Pillow'
        'cv2'      = 'opencv-python'
        'bs4'      = 'beautifulsoup4'
        'sklearn'  = 'scikit-learn'
        'dateutil' = 'python-dateutil'
        'attr'     = 'attrs'
    }

    $libs = New-Object 'System.Collections.Generic.SortedSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($k in $modulesMap.PythonPackages.Keys) {
        $mapped = if ($packageMapping.ContainsKey($k)) { $packageMapping[$k] } else { $k }
        & $addLibrary $mapped
    }
    foreach ($v in $modulesMap.DistInfos.Values) {
        $mapped = if ($packageMapping.ContainsKey($v)) { $packageMapping[$v] } else { $v }
        & $addLibrary $mapped
    }
    foreach ($s in $modulesMap.Singles.Keys) {
        $ext = [System.IO.Path]::GetExtension($modulesMap.Singles[$s])
        if ($ext -eq '.pyd') { continue }
        if (-not ($s -match '^_')) {
            $mapped = if ($packageMapping.ContainsKey($s)) { $packageMapping[$s] } else { $s }
            & $addLibrary $mapped
        }
    }

    # Compiled extension files (.pyd) that pip cannot reinstall -- listed separately
    $deleteOnly = New-Object 'System.Collections.Generic.List[string]'
    foreach ($s in $modulesMap.Singles.Keys) {
        $ext = [System.IO.Path]::GetExtension($modulesMap.Singles[$s])
        if ($ext -eq '.pyd') { $deleteOnly.Add($s + $ext) }
    }

    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add("# ================================================================")
    $lines.Add("# $TOOL_NAME  -  Configuration File")
    $lines.Add("# Generated by $TOOL_NAME $TOOL_VERSION")
    $lines.Add("# $timestamp")
    $lines.Add("# ================================================================")
    $lines.Add("")
    $lines.Add("TOOL_NAME    = $TOOL_NAME")
    $lines.Add("TOOL_VERSION = $TOOL_VERSION")
    $lines.Add("")
    $lines.Add("PLUGIN_DIR     = $modulesDir")
    $lines.Add("PYTHON_VERSION = 3.13")
    $lines.Add("")
    $lines.Add("PIP_CACHE_DIR               = $cacheDir")
    $lines.Add("BACKUP_DIR                  = $backupDir")
    $lines.Add("CLEANUP_CACHE_AFTER_INSTALL = false")
    $lines.Add("KEEP_BACKUP_AFTER_SUCCESS   = true")
    $lines.Add("")

    if ($deleteOnly.Count -gt 0) {
        $lines.Add("DELETE_ONLY =")
        foreach ($d in $deleteOnly) { $lines.Add($d) }
        $lines.Add("")
    }

    $lines.Add("LIBRARIES =")
    foreach ($lib in $libs) {
        if (-not ($lib -match '^_')) { $lines.Add($lib) }
    }

    [System.IO.File]::WriteAllLines($configPath, $lines, (New-Object System.Text.UTF8Encoding $false))
    return $configPath
}

# ---------------------------------------------------------------------------
# Step 4 summary: show config path and backup path
# ---------------------------------------------------------------------------
function Write-Step4Summary {
    param($configPath, $backupPath, $lang)

    if ($lang -eq '1') { $t = 'Summary & next steps' } else { $t = 'Zusammenfassung' }
    Write-StepHeader '4' '4' $t

    if ($lang -eq '1') {
        Write-Msg ("  " + (Green "[OK]") + " plugin-config.txt written:")
    } else {
        Write-Msg ("  " + (Green "[OK]") + " plugin-config.txt geschrieben:")
    }
    Write-Msg (White "       $configPath")

    if ($backupPath) {
        Write-Msg ("  " + (Green "[OK]") + " Backup: " + (White $backupPath))
    }
    Write-Msg ""
}

# ---------------------------------------------------------------------------
# Updater
#
# Reads PLUGIN_DIR and LIBRARIES from plugin-config.txt, finds any available
# Python 3.x (prefers 3.13), and installs each library with pip using
# cross-version wheel targeting:
#   --python-version 3.13  --platform win_amd64  --abi cp313
# This works even when the installed Python is not 3.13.
#
# Fallback chain per library:
#   1. cp313 binary wheel  (--only-binary :all:  with version/platform flags)
#   2. any pure-Python wheel  (--only-binary :all:  without version flags)
#   3. source build  (no binary restriction)
# ---------------------------------------------------------------------------
function Get-PythonExecutable {
    param($lang)

    $candidates313 = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'),
        'C:\Python313\python.exe',
        'C:\Program Files\Python313\python.exe'
    )
    $candidatesAny = @()
    $fromPath = Get-Command python  -ErrorAction SilentlyContinue
    if ($fromPath) { $candidatesAny += $fromPath.Source }
    $from3    = Get-Command python3 -ErrorAction SilentlyContinue
    if ($from3)    { $candidatesAny += $from3.Source }

    $pyBase = Join-Path $env:LOCALAPPDATA 'Programs\Python'
    if (Test-Path $pyBase) {
        Get-ChildItem $pyBase -Filter 'Python3*' -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { $candidatesAny += (Join-Path $_.FullName 'python.exe') }
    }

    $py = $null
    $pyVer = $null
    foreach ($cand in ($candidates313 + $candidatesAny)) {
        if (-not $cand) { continue }
        if (-not (Test-Path $cand -ErrorAction SilentlyContinue)) { continue }
        $ver = (& $cand --version 2>&1)
        if ($ver -match '(\d+\.\d+)') {
            if (-not $py) { $py = $cand; $pyVer = $Matches[1] }
            if ($ver -match '3\.13') { $py = $cand; $pyVer = '3.13'; break }
        }
    }

    if (-not $py) {
        if ($lang -eq '1') {
            Write-Msg (Red "  [!] No Python installation found.")
            Write-Msg (Dim "      Install any Python 3.x from python.org and retry.")
        } else {
            Write-Msg (Red "  [!] Keine Python-Installation gefunden.")
            Write-Msg (Dim "      Beliebiges Python 3.x von python.org installieren und nochmal versuchen.")
        }
        return $null
    }

    return @{ Path = $py; Version = $pyVer; CrossVersion = ($pyVer -ne '3.13') }
}

function Remove-SupersededMetadata {
    param($pluginDir, $lang)

    # Remove superseded .dist-info folders: when a package's on-disk name
    # does not change between versions, pip can leave the old version's
    # metadata folder sitting right next to the newly installed one
    # (e.g. aiohappyeyeballs-2.6.2.dist-info AND -2.7.1.dist-info at once).
    # Keep only the highest version per package name and drop the rest.
    $distInfoDirs2 = Get-ChildItem -Path $pluginDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '\.dist-info$' }

    $groupedByPkg = $distInfoDirs2 | Group-Object { $_.Name -replace '-[^-]+\.dist-info$', '' }

    foreach ($grp in $groupedByPkg) {
        if ($grp.Count -le 1) { continue }

        $entries = foreach ($d in $grp.Group) {
            $verStr = $d.Name -replace '^.*-([^-]+)\.dist-info$', '$1'
            # Compare only the leading numeric dotted segment so suffixes
            # like '.post0' or pre-release tags don't break [version] parsing.
            $numericPart = ([regex]::Match($verStr, '^[0-9]+(\.[0-9]+)*')).Value
            $verObj = $null
            if ($numericPart) { try { $verObj = [version]$numericPart } catch { $verObj = $null } }
            [PSCustomObject]@{ Item = $d; VerObj = $verObj }
        }

        $sorted     = $entries | Sort-Object { if ($_.VerObj) { $_.VerObj } else { [version]'0.0' } } -Descending
        $superseded = $sorted | Select-Object -Skip 1

        foreach ($sup in $superseded) {
            Remove-Item -Path $sup.Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed superseded metadata: $($sup.Item.Name)") }
            else               { Write-Msg ("  " + (Red "[-]") + " Veraltete Metadaten geloescht: $($sup.Item.Name)") }
        }
    }
}

function Install-SingleLibrary {
    param($py, $pluginDir, $cacheDir, $lib, $lang, $outFile, $errFile)

    # Attempt 1: cp313 binary wheel with explicit platform targeting
    $pipBase = @(
        '-m','pip','install',
        '--target', "`"$pluginDir`"",
        '--cache-dir', "`"$cacheDir`"",
        '--upgrade',
        '--python-version', '3.13',
        '--platform', 'win_amd64',
        '--implementation', 'cp',
        '--abi', 'cp313',
        '--only-binary', ':all:'
    )
    $proc = Start-Process -FilePath $py -ArgumentList ($pipBase + $lib) `
                -Wait -PassThru -NoNewWindow -WorkingDirectory $pluginDir `
                -RedirectStandardOutput $outFile -RedirectStandardError $errFile

    if ($proc.ExitCode -eq 0) {
        Write-Msg (" " + (Green "[OK]"))
        return $true
    }

    # Attempt 2: any pure-Python wheel (no platform/abi constraints)
    $pipPure = @(
        '-m','pip','install',
        '--target', "`"$pluginDir`"",
        '--cache-dir', "`"$cacheDir`"",
        '--upgrade',
        '--only-binary', ':all:'
    )
    $proc2 = Start-Process -FilePath $py -ArgumentList ($pipPure + $lib) `
                 -Wait -PassThru -NoNewWindow -WorkingDirectory $pluginDir `
                 -RedirectStandardOutput $outFile -RedirectStandardError $errFile

    if ($proc2.ExitCode -eq 0) {
        if ($lang -eq '1') { Write-Msg (" " + (Yellow "[OK - pure wheel]")) }
        else               { Write-Msg (" " + (Yellow "[OK - Pure Wheel]")) }
        return $true
    }

    # Attempt 3: allow source build as last resort
    $pipSrc = @(
        '-m','pip','install',
        '--target', "`"$pluginDir`"",
        '--cache-dir', "`"$cacheDir`"",
        '--upgrade'
    )
    $proc3 = Start-Process -FilePath $py -ArgumentList ($pipSrc + $lib) `
                 -Wait -PassThru -NoNewWindow -WorkingDirectory $pluginDir `
                 -RedirectStandardOutput $outFile -RedirectStandardError $errFile

    if ($proc3.ExitCode -eq 0) {
        if ($lang -eq '1') { Write-Msg (" " + (Yellow "[OK - source build]")) }
        else               { Write-Msg (" " + (Yellow "[OK - Source-Build]")) }
        return $true
    }

    Write-Msg (" " + (Red "[FAILED]"))
    $errTxt = Get-Content $errFile -ErrorAction SilentlyContinue
    if ($errTxt) {
        $short = ($errTxt | Select-Object -Last 3) -join ' | '
        Write-Msg (Red "         $short")
    }
    return $false
}

function Start-Updater {
    param($configPath, $lang, [switch]$NoPrompt)

    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    Write-Msg (Bold (White "   UPDATER  --  $TOOL_NAME $TOOL_VERSION"))
    Write-Msg (Cyan "  ================================================================")
    Write-Msg ""

    if ($NoPrompt) {
        $yes = $true
    } elseif ($lang -eq '1') {
        $ask = Read-Msg "  Start Updater? Installs/updates all libs via pip [Y/N]"
        $yes = ($ask -eq 'Y' -or $ask -eq 'y')
    } else {
        $ask = Read-Msg "  Updater starten? Alle Bibliotheken per pip aktualisieren [J/N]"
        $yes = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
    }

    if (-not $yes) {
        if ($lang -eq '1') { Write-Msg (Dim "  Updater skipped.") }
        else               { Write-Msg (Dim "  Updater uebersprungen.") }
        return
    }

    if (-not (Test-Path $configPath)) {
        if ($lang -eq '1') { Write-Msg (Red "  [!] plugin-config.txt not found: $configPath") }
        else               { Write-Msg (Red "  [!] plugin-config.txt nicht gefunden: $configPath") }
        return
    }

    # Parse PLUGIN_DIR and LIBRARIES from config
    $cfgLines  = Get-Content $configPath -Encoding UTF8
    $pluginDir = $null
    $libraries = New-Object 'System.Collections.Generic.List[string]'
    $inLibs    = $false

    foreach ($line in $cfgLines) {
        $line = $line.Trim()
        if ($line -match '^#' -or $line -eq '') { $inLibs = $false; continue }
        if ($line -match '^PLUGIN_DIR\s*=\s*(.+)$') { $pluginDir = $Matches[1].Trim(); $inLibs = $false; continue }
        if ($line -eq 'LIBRARIES =') { $inLibs = $true; continue }
        if ($line -match '^[A-Z_]+=') { $inLibs = $false; continue }
        if ($inLibs -and $line -ne '') { $libraries.Add($line) }
    }

    if (-not $pluginDir) {
        if ($lang -eq '1') { Write-Msg (Red "  [!] PLUGIN_DIR not found in config.") }
        else               { Write-Msg (Red "  [!] PLUGIN_DIR nicht in der Config gefunden.") }
        return
    }

    $pluginRoot = Split-Path $pluginDir -Parent
    $pluginName = if ($pluginRoot) { Split-Path $pluginRoot -Leaf } else { $null }

    # Locate Python -- prefer 3.13, accept any 3.x
    $pyInfo = Get-PythonExecutable -lang $lang
    if (-not $pyInfo) { return }
    $py           = $pyInfo.Path
    $pyVer        = $pyInfo.Version
    $crossVersion = $pyInfo.CrossVersion

    if ($lang -eq '1') {
        if ($pluginName) { Write-Msg ("  " + (Cyan "Plugin :") + " " + (White $pluginName)) }
        Write-Msg ("  " + (Green "[OK] Python found :") + " " + (White "$py  ($pyVer)"))
        if ($crossVersion) {
            Write-Msg ("  " + (Yellow "[i]  Not 3.13 -- pip will target 3.13 wheels via --python-version 3.13"))
        }
    } else {
        if ($pluginName) { Write-Msg ("  " + (Cyan "Plugin :") + " " + (White $pluginName)) }
        Write-Msg ("  " + (Green "[OK] Python gefunden :") + " " + (White "$py  ($pyVer)"))
        if ($crossVersion) {
            Write-Msg ("  " + (Yellow "[i]  Nicht 3.13 -- pip holt 3.13-Wheels via --python-version 3.13"))
        }
    }
    Write-Msg ("  " + (Green "[OK] Target :") + " " + (White $pluginDir))
    Write-Msg ""

    if (-not (Test-Path $pluginDir)) { New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null }

    $cacheDir = Join-Path $PSScriptRoot 'pip-cache'
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }

    $total   = $libraries.Count
    $i       = 0
    $outFile = Join-Path $env:TEMP 'gps_pip_out.txt'
    $errFile = Join-Path $env:TEMP 'gps_pip_err.txt'

    if ($lang -eq '1') { Write-Msg (Bold "  Installing $total libraries...") }
    else               { Write-Msg (Bold "  Installiere $total Bibliotheken...") }
    Write-Msg ""

    foreach ($lib in $libraries) {
        $i++
        Write-Msg ("  " + (Cyan "[$i/$total]") + " " + (White $lib) + " ...") -NoNewline
        Install-SingleLibrary -py $py -pluginDir $pluginDir -cacheDir $cacheDir -lib $lib -lang $lang -outFile $outFile -errFile $errFile | Out-Null
    }

    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg (Bold (Green "  Update complete!"))
        Write-Msg (Dim  "  All libraries installed to: $pluginDir")
    } else {
        Write-Msg (Bold (Green "  Update abgeschlossen!"))
        Write-Msg (Dim  "  Alle Bibliotheken installiert in: $pluginDir")
    }

    # Post-install cleanup: remove orphaned .dist-info folders and known dev-tool leftovers
    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg (Bold (White "  [*] Post-install cleanup..."))
    } else {
        Write-Msg (Bold (White "  [*] Post-Install Bereinigung..."))
    }

    # Some dist-info names differ from their package folder name
    $distInfoFolderMap = @{
        'galaxy_plugin_api' = 'galaxy'
        'protobuf'          = 'google'
        'python_dateutil'   = 'dateutil'
        'pyyaml'            = 'yaml'
        'beautifulsoup4'    = 'bs4'
        'scikit_learn'      = 'sklearn'
        'opencv_python'     = 'cv2'
        'pillow'            = 'PIL'
    }

    # Remove .dist-info folders whose matching package folder no longer exists
    $distInfoDirs = Get-ChildItem -Path $pluginDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '\.dist-info$' }

    foreach ($di in $distInfoDirs) {
        $pkgName   = ($di.Name -replace '-[^-]+\.dist-info$', '')
        $candidateBase = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        [void]$candidateBase.Add($pkgName)

        if ($distInfoFolderMap.ContainsKey($pkgName)) {
            [void]$candidateBase.Add($distInfoFolderMap[$pkgName])
        }

        # Normalize common naming variants between dist names and import/module names.
        [void]$candidateBase.Add(($pkgName -replace '-', '_'))
        [void]$candidateBase.Add(($pkgName -replace '_', '-'))
        [void]$candidateBase.Add(($pkgName -replace '[-_]', ''))
        if ($pkgName -match '^python[_-](.+)$') {
            [void]$candidateBase.Add($Matches[1])
            [void]$candidateBase.Add(($Matches[1] -replace '_', '-'))
            [void]$candidateBase.Add(($Matches[1] -replace '-', '_'))
        }

        $hasMatch = $false
        foreach ($cand in $candidateBase) {
            if (-not $cand) { continue }
            $pkgPath = Join-Path $pluginDir $cand
            $pyPath  = Join-Path $pluginDir ($cand + '.py')
            $pydPath = Join-Path $pluginDir ($cand + '.pyd')

            if ((Test-Path $pkgPath) -or (Test-Path $pyPath) -or (Test-Path $pydPath)) {
                $hasMatch = $true
                break
            }
        }

        if (-not $hasMatch) {
            Remove-Item -Path $di.FullName -Recurse -Force -ErrorAction SilentlyContinue
            if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed orphaned metadata: $($di.Name)") }
            else               { Write-Msg ("  " + (Red "[-]") + " Verwaiste Metadaten geloescht: $($di.Name)") }
        }
    }

    Remove-SupersededMetadata -pluginDir $pluginDir -lang $lang

    # Remove pip-generated console-script launcher stubs (e.g. modules\bin\idna.exe).
    # pip auto-creates these for any installed package that defines a
    # console_scripts entry point, even though a GOG Galaxy plugin only ever
    # imports these packages as libraries and never runs them from a shell.
    #
    # Detected purely by on-disk shape, never by package name: a Windows PE
    # executable with a valid ZIP archive appended that contains a
    # '__main__.py' entry. That exact combination is specific to pip's
    # (distlib-based) launcher format, so a real bundled binary belonging to
    # some other plugin is never mistaken for one and is left untouched.
    # Added as part of v1.2.0.
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    # pip's script generation for --target installs is not guaranteed to
    # write into --target itself -- observed in practice landing inside
    # modules\bin (idna.exe, normalizer.exe) but also directly in the
    # plugin ROOT's own bin folder (chardetect.exe), most likely because no
    # -WorkingDirectory was pinned on the pip subprocess, so script output
    # fell back to wherever the shell's current directory happened to be.
    # The pip invocation now pins -WorkingDirectory to prevent new cases,
    # but this scan also checks the plugin ROOT's bin folder so anything
    # already misplaced by a prior run still gets found and removed.
    $rootDir    = Split-Path $pluginDir -Parent
    $rootBinDir = Join-Path $rootDir 'bin'
    $exeFiles   = @(Get-ChildItem -Path $pluginDir -Filter '*.exe' -Recurse -File -ErrorAction SilentlyContinue)
    if (Test-Path $rootBinDir) {
        $exeFiles += @(Get-ChildItem -Path $rootBinDir -Filter '*.exe' -Recurse -File -ErrorAction SilentlyContinue)
    }
    if ($lang -eq '1') { Write-Msg (Dim "  Scanning $($exeFiles.Count) .exe file(s) for pip launcher stubs...") }
    else               { Write-Msg (Dim "  Durchsuche $($exeFiles.Count) .exe-Datei(en) nach pip-Launcher-Stubs...") }
    foreach ($exe in $exeFiles) {
        $isLauncherStub = $false
        $diag = $null

        # Freshly pip-installed .exe files (downloaded from the internet) are
        # frequently locked for a brief moment by Windows Defender's
        # real-time / Mark-of-the-Web scan right after pip's own process
        # exits, even though `pip install -Wait` already finished. Reading
        # the file during that window can yield a valid-looking but empty
        # zip view. Retry a few times with a short backoff before giving up,
        # instead of trusting a single read.
        $maxAttempts = 5
        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            try {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($exe.FullName)
                try {
                    $entryNames = ($zip.Entries | ForEach-Object { $_.Name }) -join ', '
                    $diag = "zip OK, entries: $entryNames"
                    if ($zip.Entries | Where-Object { $_.Name -eq '__main__.py' }) {
                        $isLauncherStub = $true
                    }
                } finally {
                    $zip.Dispose()
                }
            } catch {
                $diag = "not readable as zip ($($_.Exception.Message))"
                $isLauncherStub = $false
            }

            if ($isLauncherStub -or $attempt -eq $maxAttempts) { break }
            Start-Sleep -Milliseconds 250
        }

        # DIAGNOSTIC: print every .exe checked and why it was or was not
        # classified as a launcher stub, including how many read attempts it
        # took. Real-world runs (idna.exe, then charset_normalizer's
        # normalizer.exe) previously showed a valid-but-empty zip on the
        # first read despite the on-disk file being fully well-formed
        # (confirmed by byte-level inspection) -- most likely a brief
        # Windows Defender lock on freshly pip-installed .exe files right
        # after the process exits. The retry loop above targets exactly
        # that. Keeping this log line in case a different root cause ever
        # shows up.
        if ($lang -eq '1') { Write-Msg (Dim "    [.] Checked: $($exe.FullName) -> stub=$isLauncherStub ($diag, attempt $attempt/$maxAttempts)") }
        else               { Write-Msg (Dim "    [.] Geprueft: $($exe.FullName) -> Stub=$isLauncherStub ($diag, Versuch $attempt/$maxAttempts)") }

        if ($isLauncherStub) {
            $parentDir = $exe.Directory.FullName
            Remove-Item -Path $exe.FullName -Force -ErrorAction SilentlyContinue
            if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed pip launcher stub: $($exe.Name)") }
            else               { Write-Msg ("  " + (Red "[-]") + " Pip-Launcher-Stub entfernt: $($exe.Name)") }

            # Clean up the containing folder if it's now empty (e.g. the
            # 'bin' folder pip created just to hold this one launcher).
            if ((Test-Path $parentDir) -and ((Get-ChildItem -Path $parentDir -Force -ErrorAction SilentlyContinue).Count -eq 0)) {
                $emptyName = Split-Path $parentDir -Leaf
                Remove-Item -Path $parentDir -Force -ErrorAction SilentlyContinue
                if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed now-empty folder: $emptyName") }
                else               { Write-Msg ("  " + (Red "[-]") + " Jetzt leeren Ordner entfernt: $emptyName") }
            }
        }
    }

    # Remove modules/bin only when it is empty. Do not delete plugin-owned
    # files just because they happen to be inside a bin folder.
    $binDir = Join-Path $pluginDir 'bin'
    if ((Test-Path $binDir) -and ((Get-ChildItem -Path $binDir -Force -ErrorAction SilentlyContinue).Count -eq 0)) {
        Remove-Item -Path $binDir -Force -ErrorAction SilentlyContinue
        if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed now-empty folder: bin") }
        else               { Write-Msg ("  " + (Red "[-]") + " Jetzt leeren Ordner entfernt: bin") }
    }
    # Same check for a stray bin folder directly under the plugin ROOT.
    if ((Test-Path $rootBinDir) -and ((Get-ChildItem -Path $rootBinDir -Force -ErrorAction SilentlyContinue).Count -eq 0)) {
        Remove-Item -Path $rootBinDir -Force -ErrorAction SilentlyContinue
        if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed now-empty folder: ROOT\\bin") }
        else               { Write-Msg ("  " + (Red "[-]") + " Jetzt leeren Ordner entfernt: ROOT\\bin") }
    }

    # Remove bytecode caches recursively for deterministic module trees.
    $pycacheDirs = Get-ChildItem -Path $pluginDir -Directory -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq '__pycache__' } |
        Sort-Object { $_.FullName.Length } -Descending

    $pycacheRemoved = 0
    foreach ($pc in $pycacheDirs) {
        if (Test-Path $pc.FullName) {
            Remove-Item -Path $pc.FullName -Recurse -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $pc.FullName)) { $pycacheRemoved++ }
        }
    }
    if ($pycacheRemoved -gt 0) {
        if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed __pycache__ folders: $pycacheRemoved") }
        else               { Write-Msg ("  " + (Red "[-]") + " __pycache__-Ordner geloescht: $pycacheRemoved") }
    }

    # Remove known dev-tool single-file leftovers that pip may have dropped.
    # typing_extensions.py and typing_inspect.py are legitimate -- leave them alone.
    # FIX in v1.1.20: Removed 'six.py' from the deletion array because it is a legitimate runtime library
    $devToolFiles = @('zipp.py','py.py','tomli.py')
    foreach ($pyFile in $devToolFiles) {
        $pyPath = Join-Path $pluginDir $pyFile
        if (Test-Path $pyPath) {
            Remove-Item -Path $pyPath -Force -ErrorAction SilentlyContinue
            if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed leftover: $pyFile") }
            else               { Write-Msg ("  " + (Red "[-]") + " Uebriggebliebene Datei geloescht: $pyFile") }
        }
    }

    $mypycPyd = Get-ChildItem -Path $pluginDir -File -Filter '*__mypyc.cp*-win*.pyd' -ErrorAction SilentlyContinue
    foreach ($mp in $mypycPyd) {
        Remove-Item -Path $mp.FullName -Force -ErrorAction SilentlyContinue
        if ($lang -eq '1') { Write-Msg ("  " + (Red "[-]") + " Removed mypyc sidecar: $($mp.Name)") }
        else               { Write-Msg ("  " + (Red "[-]") + " mypyc-Sidecar geloescht: $($mp.Name)") }
    }
    Write-Msg ""
}

function Invoke-VersionCheck {
    param($root, $lang)

    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    if ($lang -eq '1') { Write-Msg (Bold (White "   LIBRARY UPDATE CHECK  --  asks before installing anything")) }
    else               { Write-Msg (Bold (White "   LIBRARY-UPDATE-CHECK  --  fragt nach, bevor irgendwas installiert wird")) }
    Write-Msg (Cyan "  ================================================================")
    Write-Msg ""

    $pluginName = Split-Path ($root.TrimEnd('\')) -Leaf
    Write-Msg ("  " + (Cyan "Plugin :") + " " + (White $pluginName))
    Write-Msg ""

    $modulesDir = Join-Path $root 'modules'
    if (-not (Test-Path $modulesDir)) {
        if ($lang -eq '1') { Write-Msg (Red "  [!] No /modules/ folder found -- nothing to check.") }
        else               { Write-Msg (Red "  [!] Kein /modules/-Ordner gefunden -- nichts zu pruefen.") }
        return [PSCustomObject]@{ Plugin = $pluginName; UpToDate = 0; Outdated = 0; Unknown = 0; Updated = 0; Failed = 0; Error = 'no-modules' }
    }

    $pyInfo = Get-PythonExecutable -lang $lang
    if (-not $pyInfo) { return [PSCustomObject]@{ Plugin = $pluginName; UpToDate = 0; Outdated = 0; Unknown = 0; Updated = 0; Failed = 0; Error = 'no-python' } }
    $py = $pyInfo.Path

    if ($lang -eq '1') { Write-Msg ("  " + (Green "[OK] Python found :") + " " + (White "$py  ($($pyInfo.Version))")) }
    else               { Write-Msg ("  " + (Green "[OK] Python gefunden :") + " " + (White "$py  ($($pyInfo.Version))")) }
    Write-Msg ""

    # Read package name + installed version straight from each dist-info
    # folder name (format: <name>-<version>.dist-info). Read-only, no
    # dependency-tree resolution needed here -- everything already
    # installed under /modules/ is in scope for the version check.
    $packages = New-Object 'System.Collections.Generic.List[hashtable]'
    foreach ($item in (Get-ChildItem -Path $modulesDir -Directory -ErrorAction SilentlyContinue)) {
        if ($item.Name -match '^(?<name>.+)-(?<ver>[^-]+)\.dist-info$') {
            [void]$packages.Add(@{ Name = $Matches['name']; Installed = $Matches['ver'] })
        }
    }

    if ($packages.Count -eq 0) {
        if ($lang -eq '1') { Write-Msg (Yellow "  No installed packages with version metadata found.") }
        else               { Write-Msg (Yellow "  Keine installierten Pakete mit Versionsmetadaten gefunden.") }
        return [PSCustomObject]@{ Plugin = $pluginName; UpToDate = 0; Outdated = 0; Unknown = 0; Updated = 0; Failed = 0; Error = 'no-packages' }
    }

    if ($lang -eq '1') { Write-Msg (Bold "  Checking $($packages.Count) package(s) against PyPI...") }
    else               { Write-Msg (Bold "  Pruefe $($packages.Count) Paket(e) gegen PyPI...") }
    Write-Msg ""

    $upToDate = New-Object 'System.Collections.Generic.List[string]'
    $outdated = New-Object 'System.Collections.Generic.List[string]'
    $unknown  = New-Object 'System.Collections.Generic.List[string]'
    $updated  = New-Object 'System.Collections.Generic.List[string]'
    $failed   = New-Object 'System.Collections.Generic.List[string]'
    $updateAll = $false
    $anyInstallAttempted = $false
    $backupOffered = $false

    $cacheDir = Join-Path $PSScriptRoot 'pip-cache'
    if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null }
    $outFile = Join-Path $env:TEMP 'gps_pip_out.txt'
    $errFile = Join-Path $env:TEMP 'gps_pip_err.txt'

    foreach ($pkg in ($packages | Sort-Object { $_.Name })) {
        $out = & $py -m pip index versions $pkg.Name --disable-pip-version-check 2>&1
        $latest = $null
        foreach ($line in $out) {
            if ($line -match '^\S+\s+\(([^)]+)\)') { $latest = $Matches[1]; break }
        }

        if (-not $latest) {
            [void]$unknown.Add($pkg.Name)
            Write-Msg ("    " + (Dim "[?]") + " " + $pkg.Name.PadRight(28) + (Dim "$($pkg.Installed) installed  ->  could not check"))
            continue
        }

        if ($latest -eq $pkg.Installed) {
            [void]$upToDate.Add($pkg.Name)
            Write-Msg ("    " + (Green "[OK]") + " " + $pkg.Name.PadRight(28) + (Dim "$($pkg.Installed) installed  ->  up to date"))
            continue
        }

        # Compare the leading numeric dotted segment of both versions so
        # suffixes like '.post0' or pre-release tags don't break [version]
        # parsing. This matters because "different string" does not mean
        # "newer": PyPI's index can list an older version as the plain
        # "latest" release while a newer pre-release/build is what's
        # actually installed (exactly what melcom spotted: galaxy_plugin_api
        # 0.71 installed vs. 0.69 "available"). Never offer that as an
        # update -- it would silently be a downgrade.
        $instNum = ([regex]::Match($pkg.Installed, '^[0-9]+(\.[0-9]+)*')).Value
        $latNum  = ([regex]::Match($latest,        '^[0-9]+(\.[0-9]+)*')).Value
        $instVer = $null; $latVer = $null
        if ($instNum) { try { $instVer = [version]$instNum } catch { $instVer = $null } }
        if ($latNum)  { try { $latVer  = [version]$latNum }  catch { $latVer  = $null } }

        if ($instVer -and $latVer -and $instVer -ge $latVer) {
            [void]$upToDate.Add($pkg.Name)
            if ($lang -eq '1') {
                Write-Msg ("    " + (Cyan "[i]") + " " + $pkg.Name.PadRight(28) + (Dim "$($pkg.Installed) installed  ->  $latest listed on PyPI (installed is newer/equal, not offered as an update)"))
            } else {
                Write-Msg ("    " + (Cyan "[i]") + " " + $pkg.Name.PadRight(28) + (Dim "$($pkg.Installed) installiert  ->  $latest auf PyPI gelistet (installiert ist neuer/gleich, wird nicht als Update angeboten)"))
            }
            continue
        }

        [void]$outdated.Add($pkg.Name)
        Write-Msg ("    " + (Yellow "[!]") + " " + $pkg.Name.PadRight(28) + (White "$($pkg.Installed) installed  ->  $latest available"))

        $doUpdate = $false
        if ($updateAll) {
            $doUpdate = $true
        } else {
            if ($lang -eq '1') {
                $ask = Read-Msg "        Update to $latest now? [Y/N/A=yes to all remaining]"
                if ($ask -eq 'A' -or $ask -eq 'a') { $updateAll = $true; $doUpdate = $true }
                elseif ($ask -eq 'Y' -or $ask -eq 'y') { $doUpdate = $true }
            } else {
                $ask = Read-Msg "        Jetzt auf $latest aktualisieren? [J/N/A=Ja zu allen weiteren]"
                if ($ask -eq 'A' -or $ask -eq 'a') { $updateAll = $true; $doUpdate = $true }
                elseif ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y') { $doUpdate = $true }
            }
        }

        if (-not $doUpdate) {
            if ($lang -eq '1') { Write-Msg (Dim "        Skipped.") }
            else               { Write-Msg (Dim "        Uebersprungen.") }
            continue
        }

        $anyInstallAttempted = $true

        # First real change this run is about to happen -- back up /modules/
        # once before touching anything, same safety net Mode 2 gives you.
        # Asked once per plugin, not once per library.
        if (-not $backupOffered) {
            $backupOffered = $true
            New-Backup -rootPath $root -lang $lang | Out-Null
        }

        Write-Msg ("        " + (White $pkg.Name) + " ...") -NoNewline
        $ok = Install-SingleLibrary -py $py -pluginDir $modulesDir -cacheDir $cacheDir -lib $pkg.Name -lang $lang -outFile $outFile -errFile $errFile
        if ($ok) { [void]$updated.Add($pkg.Name) } else { [void]$failed.Add($pkg.Name) }
    }

    if ($anyInstallAttempted) {
        Write-Msg ""
        if ($lang -eq '1') { Write-Msg (Bold (White "  [*] Cleaning up metadata after update(s)...")) }
        else               { Write-Msg (Bold (White "  [*] Bereinige Metadaten nach dem Update...")) }
        Remove-SupersededMetadata -pluginDir $modulesDir -lang $lang
    }

    Write-Msg ""
    Write-Msg (Cyan "  ----------------------------------------------------------------")
    if ($lang -eq '1') {
        Write-Msg ("  " + (White "Summary:") + " $($upToDate.Count) up to date, " + (Yellow "$($outdated.Count) outdated") + ", $($unknown.Count) could not be checked.")
        if ($updated.Count -gt 0 -or $failed.Count -gt 0) {
            Write-Msg ("  " + (Green "$($updated.Count) updated now") + ", " + (Red "$($failed.Count) failed") + ".")
        }
        if ($outdated.Count -gt ($updated.Count + $failed.Count)) {
            Write-Msg (Dim "  Remaining outdated libraries were skipped and were not changed.")
        }
    } else {
        Write-Msg ("  " + (White "Zusammenfassung:") + " $($upToDate.Count) aktuell, " + (Yellow "$($outdated.Count) veraltet") + ", $($unknown.Count) nicht pruefbar.")
        if ($updated.Count -gt 0 -or $failed.Count -gt 0) {
            Write-Msg ("  " + (Green "$($updated.Count) jetzt aktualisiert") + ", " + (Red "$($failed.Count) fehlgeschlagen") + ".")
        }
        if ($outdated.Count -gt ($updated.Count + $failed.Count)) {
            Write-Msg (Dim "  Uebersprungene veraltete Bibliotheken wurden nicht veraendert.")
        }
    }
    Write-Msg ""

    return [PSCustomObject]@{
        Plugin   = $pluginName
        UpToDate = $upToDate.Count
        Outdated = $outdated.Count
        Unknown  = $unknown.Count
        Updated  = $updated.Count
        Failed   = $failed.Count
        Error    = $null
    }
}

function Show-LauncherStubPreview {
    param($rootPath, $lang)

    $modulesDir = Join-Path $rootPath 'modules'
    $rootBinDir = Join-Path $rootPath 'bin'
    $exeFiles   = @(Get-ChildItem -Path $modulesDir -Filter '*.exe' -Recurse -File -ErrorAction SilentlyContinue)
    if (Test-Path $rootBinDir) {
        $exeFiles += @(Get-ChildItem -Path $rootBinDir -Filter '*.exe' -Recurse -File -ErrorAction SilentlyContinue)
    }
    if ($exeFiles.Count -eq 0) { return }

    $stubHits = New-Object 'System.Collections.Generic.List[string]'
    foreach ($exe in $exeFiles) {
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($exe.FullName)
            try {
                if ($zip.Entries | Where-Object { $_.Name -eq '__main__.py' }) {
                    [void]$stubHits.Add($exe.FullName)
                }
            } finally {
                $zip.Dispose()
            }
        } catch {
            # Not readable as a zip right now -- not a stub as far as this
            # read-only preview can tell. The real run has a retry loop for
            # freshly pip-installed files; a dry run isn't installing
            # anything new, so a single read is representative here.
        }
    }

    if ($stubHits.Count -eq 0) { return }

    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg (Yellow "  [DRY-RUN] The following pip launcher stub(s) would be removed on a real run:")
    } else {
        Write-Msg (Yellow "  [DRY-RUN] Folgende pip-Launcher-Stub(s) wuerden bei einem echten Lauf entfernt:")
    }
    foreach ($hit in $stubHits) {
        Write-Msg ("    " + (Yellow "[-] ") + $hit)
    }
}

function Start-CombinedLog {
    param($lang, $prefix)

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $logDir = Join-Path $PSScriptRoot 'logs'
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    $global:BatchLogFile = Join-Path $logDir ("${prefix}_" + $timestamp + ".log")
    if ($lang -eq '1') { Write-Msg (Dim ("  Combined log file: " + $global:BatchLogFile)) }
    else               { Write-Msg (Dim ("  Kombinierte Log-Datei: " + $global:BatchLogFile)) }
}

function Invoke-PluginRun {
    param(
        $root,
        $lang,
        [switch]$DryRun,
        [switch]$AutoBackup,
        [switch]$AutoRemove,
        [switch]$AutoUpdate
    )

    $pluginName = Split-Path ($root.TrimEnd('\')) -Leaf

    # Always show which plugin is being processed right now, on the console
    # too -- not just in the log file. Without this, an "[a] all plugins"
    # run (single shared BatchLogFile, no per-plugin log line printed) gave
    # zero visible indication on screen of which plugin was currently being
    # scanned; only the step headers ([1/4], [2/4], ...) showed up, repeated
    # identically for every plugin in the run.
    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    Write-Msg (Bold (White "   Plugin: $pluginName"))
    Write-Msg (Cyan "  ================================================================")

    # Only create a separate per-plugin log file when NOT running as part of
    # an "all plugins" run (the [a] option already writes everything into the
    # single shared BatchLogFile; creating individual log files next to it
    # as well was the original bug here).
    if ($global:BatchLogFile) {
        $global:LogFile = $null
    } else {
        $timestamp  = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
        $logDir     = Join-Path $PSScriptRoot 'logs'
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
        $global:LogFile = Join-Path $logDir "${timestamp}_${pluginName}.log"

        if ($lang -eq '1') {
            Write-Msg (Dim ("  Log file: " + $global:LogFile))
        } else {
            Write-Msg (Dim ("  Log-Datei: " + $global:LogFile))
        }
    }

    Write-Msg "================================================================" -LogOnly
    Write-Msg "$TOOL_NAME $TOOL_VERSION - Execution Log" -LogOnly
    Write-Msg "Date    : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -LogOnly
    Write-Msg "Plugin  : $pluginName" -LogOnly
    Write-Msg "Path    : $root" -LogOnly
    Write-Msg "Language: $(if($lang -eq '1'){'English'}else{'Deutsch'})" -LogOnly
    Write-Msg "================================================================" -LogOnly
    Write-Msg "" -LogOnly

    # Step 1
    if ($lang -eq '1') { $stepTitle = 'Scanning .py files in ROOT...' } else { $stepTitle = 'Scanne .py-Dateien im ROOT...' }
    Write-StepHeader '1' '4' $stepTitle
    $pyFilesRoot = Get-RootPyFiles -rootPath $root
    if ($lang -eq '1') {
        Write-Msg ("  " + (Green "Found") + " " + (White "$($pyFilesRoot.Count)") + " .py file(s) in ROOT.")
    } else {
        Write-Msg ("  " + (Green "Gefunden:") + " " + (White "$($pyFilesRoot.Count)") + " .py-Datei(en) im ROOT.")
    }

    # Step 2
    if ($lang -eq '1') { $stepTitle = 'Mapping /modules/ content...' } else { $stepTitle = 'Kartiere /modules/-Inhalte...' }
    Write-StepHeader '2' '4' $stepTitle
    $modulesMap = Get-ModulesMap -rootPath $root
    $totalPy    = $modulesMap.PythonPackages.Count + $modulesMap.Singles.Count
    Write-Msg ("  " + (Cyan "Python items") + " : " + (White "$totalPy"))
    Write-Msg ("  " + (Cyan "Dist-Infos  ") + " : " + (White "$($modulesMap.DistInfos.Count)"))
    Write-Msg ("  " + (Cyan "Non-Python  ") + " : " + (White "$($modulesMap.NonPython.Count)"))

    # ------------------------------------------------------------------
    # Safety trip-wire: a real plugin with several root .py files always
    # has real library content in /modules/. If the root has a normal
    # amount of code but /modules/ comes back with essentially nothing,
    # something already went wrong before this run started (a prior bug,
    # a manual mistake, an interrupted operation, does not matter which).
    # Continuing as if this were a normal, mostly-empty plugin would let
    # the Updater/Cleanup steps quietly finish 'successfully' on top of
    # an already-broken plugin instead of stopping to say so. Skip this
    # plugin entirely (no backup, no cleanup, no update) and warn loudly,
    # instead of silently completing the workflow on a corrupted plugin.
    # This does not try to guess or fix a specific past bug -- it makes
    # any future occurrence of this class of problem impossible to miss.
    # ------------------------------------------------------------------
    if ($pyFilesRoot.Count -gt 3 -and $totalPy -eq 0) {
        Write-Msg ""
        if ($lang -eq '1') {
            Write-Msg (Bold (Red "  [!] SAFETY STOP: /modules/ is essentially empty for a plugin with $($pyFilesRoot.Count) root .py files."))
            Write-Msg (Red   "      This plugin was already broken before this run started. Skipping it untouched.")
            Write-Msg (Red   "      Restore /modules/ from an older backup, or reinstall the plugin via GOG Galaxy, then run the Scout again.")
        } else {
            Write-Msg (Bold (Red "  [!] SICHERHEITSSTOPP: /modules/ ist praktisch leer bei einem Plugin mit $($pyFilesRoot.Count) Root-.py-Dateien."))
            Write-Msg (Red   "      Dieses Plugin war schon vor diesem Lauf kaputt. Wird unangetastet uebersprungen.")
            Write-Msg (Red   "      Stelle /modules/ aus einem aelteren Backup wieder her, oder installiere das Plugin ueber GOG Galaxy neu, und lass den Scout danach erneut laufen.")
        }
        Write-Msg ""
        return
    }

    # Step 3
    if ($lang -eq '1') { $stepTitle = 'Resolving full dependency tree...' } else { $stepTitle = 'Abhaengigkeitsbaum aufloesen...' }
    Write-StepHeader '3' '4' $stepTitle
    $pyFilesAll  = Get-AllPyFiles -rootPath $root
    $rootImports = Get-Imports -pyFiles $pyFilesRoot -rootPath $root
    $allImports  = Get-Imports -pyFiles $pyFilesAll  -rootPath $root
    $tree        = Resolve-DependencyTree -rootImports $rootImports -allImports $allImports -modulesMap $modulesMap

    Write-Report -rootPath $root -pyFiles $pyFilesRoot -modulesMap $modulesMap -tree $tree -lang $lang

    if ($DryRun) {
        Show-LauncherStubPreview -rootPath $root -lang $lang
        Write-Msg ""
        if ($lang -eq '1') {
            Write-Msg (Bold (Yellow "  [DRY-RUN] Simulation complete. No files were changed."))
            Write-Msg (Dim   "  To apply these changes, run this plugin again and choose Mode 2 (Update).")
        } else {
            Write-Msg (Bold (Yellow "  [DRY-RUN] Simulation abgeschlossen. Keine Dateien wurden veraendert."))
            Write-Msg (Dim   "  Um diese Aenderungen anzuwenden, das Plugin erneut ausfuehren und Modus 2 (Update) waehlen.")
        }
        Write-Msg ""
        return
    }

    $backupPath = New-Backup -rootPath $root -lang $lang -NoPrompt:$AutoBackup

    if ($tree.ToRemove.Count -gt 0) {
        Remove-UnusedModules -rootPath $root -toRemove $tree.ToRemove -modulesMap $modulesMap -lang $lang -NoPrompt:$AutoRemove
        $modulesMap = Get-ModulesMap -rootPath $root
    }

    $configPath = Write-Config -rootPath $root -modulesMap $modulesMap

    Write-Step4Summary -configPath $configPath -backupPath $backupPath -lang $lang

    Start-Updater -configPath $configPath -lang $lang -NoPrompt:$AutoUpdate

    Invoke-PostUpdateCleanup -rootPath $root -lang $lang

    # ------------------------------------------------------------------
    # Post-run sanity check. Cheap, structural checks only -- this cannot
    # catch every possible breakage, but it catches the specific failure
    # mode that bit us with the Rockstar/Battle.net incident: a plugin
    # that looks like it updated fine in the log, but is actually broken
    # and won't connect in GOG Galaxy, with nobody noticing until later.
    # ------------------------------------------------------------------
    $sanityProblems = New-Object 'System.Collections.Generic.List[string]'

    $pluginPyPath = Join-Path $root 'plugin.py'
    if (-not (Test-Path $pluginPyPath -PathType Leaf)) {
        if ($lang -eq '1') { [void]$sanityProblems.Add("plugin.py is missing.") }
        else               { [void]$sanityProblems.Add("plugin.py fehlt.") }
    }

    $manifestPath = Join-Path $root 'manifest.json'
    if (-not (Test-Path $manifestPath -PathType Leaf)) {
        if ($lang -eq '1') { [void]$sanityProblems.Add("manifest.json is missing.") }
        else               { [void]$sanityProblems.Add("manifest.json fehlt.") }
    } else {
        try {
            Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop | Out-Null
        } catch {
            if ($lang -eq '1') { [void]$sanityProblems.Add("manifest.json is no longer valid JSON.") }
            else               { [void]$sanityProblems.Add("manifest.json ist kein gueltiges JSON mehr.") }
        }
    }

    $galaxyCorePath = Join-Path $root 'modules\galaxy'
    if (-not (Test-Path $galaxyCorePath -PathType Container)) {
        if ($lang -eq '1') { [void]$sanityProblems.Add("modules\galaxy\ (the GOG Galaxy SDK core) is missing.") }
        else               { [void]$sanityProblems.Add("modules\galaxy\ (der GOG-Galaxy-SDK-Kern) fehlt.") }
    }

    if ($sanityProblems.Count -gt 0) {
        Write-Msg ""
        if ($lang -eq '1') {
            Write-Msg (Bold (Red "  [!] POST-RUN WARNING: this plugin may be broken after this run:"))
        } else {
            Write-Msg (Bold (Red "  [!] WARNUNG NACH DEM LAUF: dieses Plugin ist moeglicherweise kaputt:"))
        }
        foreach ($problem in $sanityProblems) {
            Write-Msg (Red "      - $problem")
        }
        if ($lang -eq '1') {
            Write-Msg (Dim "      Restore from the backup created earlier in this run if GOG Galaxy fails to connect.")
        } else {
            Write-Msg (Dim "      Aus dem in diesem Lauf erstellten Backup wiederherstellen, falls GOG Galaxy nicht mehr verbindet.")
        }
        Write-Msg ""
    }

    Write-Msg ""
    if ($lang -eq '1') {
        Write-Msg (Bold (Green "  Galaxy Plugin Scout finished. Happy gaming!"))
    } else {
        Write-Msg (Bold (Green "  Galaxy Plugin Scout fertig. Viel Spass beim Zocken!"))
    }
    Write-Msg ""
}

# ===========================================================================
#  MAIN
# ===========================================================================
try {
Show-Banner
$lang = Select-Language

while ($true) {
    $mode = Select-Mode -lang $lang -ForceDryRun:$DryRun
    Show-Banner
    Show-Greeting -lang $lang
    $backToMode = $false

    switch ($mode) {
        '1' {
        $root = Select-PluginFromInventory -lang $lang
        if ($root -eq $BACK_TO_MODE_SENTINEL) {
        $backToMode = $true
        } elseif ($root -eq $ALL_PLUGINS_SENTINEL) {
            $installedRoot = Join-Path $env:LOCALAPPDATA 'GOG.com\Galaxy\plugins\installed'
            $inventory = Get-InstalledPluginInventory -installedRoot $installedRoot
            Start-CombinedLog -lang $lang -prefix 'dryrun_all_plugins'
            $checkedNames = New-Object 'System.Collections.Generic.List[string]'
            foreach ($plugin in ($inventory.Valid | Sort-Object Name, Guid)) {
                Invoke-PluginRun -root $plugin.RootPath -lang $lang -DryRun
                [void]$checkedNames.Add($plugin.Name)
            }
            $global:BatchLogFile = $null

            Write-Msg ""
            Write-Msg (Cyan "  ================================================================")
            if ($lang -eq '1') { Write-Msg (Bold (Green "   ALL PLUGINS CHECKED (dry-run) -- $($checkedNames.Count) plugin(s) done")) }
            else               { Write-Msg (Bold (Green "   ALLE PLUGINS GEPRUEFT (Dry-Run) -- $($checkedNames.Count) Plugin(s) fertig")) }
            Write-Msg (Cyan "  ================================================================")
            foreach ($n in $checkedNames) { Write-Msg ("    " + (Green "[OK]") + " " + $n) }
            Write-Msg ""
        } else {
            Invoke-PluginRun -root $root -lang $lang -DryRun
        }
    }
    '2' {
        $root = Select-PluginFromInventory -lang $lang
        if ($root -eq $BACK_TO_MODE_SENTINEL) {
        $backToMode = $true
        } elseif ($root -eq $ALL_PLUGINS_SENTINEL) {
            $installedRoot = Join-Path $env:LOCALAPPDATA 'GOG.com\Galaxy\plugins\installed'
            $inventory = Get-InstalledPluginInventory -installedRoot $installedRoot

            if ($inventory.Valid.Count -eq 0) {
                if ($lang -eq '1') { Write-Msg (Red "  [!] No melcom plugins found under installed.") }
                else               { Write-Msg (Red "  [!] Keine melcom-Plugins unter installed gefunden.") }
                Write-Msg ""
                $backToMode = $true
            } else {

            # Asks the three risk-bearing questions ONCE, up front, for the whole
            # run, instead of either (a) silently auto-confirming everything for
            # every plugin, or (b) asking the same three questions again for
            # every single plugin. You still make a conscious Y/N decision for
            # backup / unused-module removal / library updates before anything
            # happens -- it is just one decision for the whole run instead of
            # one per plugin.
            Write-Msg ""
            if ($lang -eq '1') {
                Write-Msg (Yellow "  The following three answers apply to every plugin in this run:")
            } else {
                Write-Msg (Yellow "  Die folgenden drei Antworten gelten fuer alle Plugins in diesem Durchlauf:")
            }
            Write-Msg ""

            if ($lang -eq '1') {
                $ask = Read-Msg "  Create a backup of /modules/ for every plugin? [Y/N]"
                $autoBackup = ($ask -eq 'Y' -or $ask -eq 'y')
            } else {
                $ask = Read-Msg "  Backup des /modules/-Ordners bei jedem Plugin anlegen? [J/N]"
                $autoBackup = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
            }

            if ($lang -eq '1') {
                $ask = Read-Msg "  Remove unused modules for every plugin (where found)? [Y/N]"
                $autoRemove = ($ask -eq 'Y' -or $ask -eq 'y')
            } else {
                $ask = Read-Msg "  Ungenutzte Module bei jedem Plugin entfernen (falls gefunden)? [J/N]"
                $autoRemove = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
            }

            if ($lang -eq '1') {
                $ask = Read-Msg "  Install/update all libraries via pip for every plugin? [Y/N]"
                $autoUpdate = ($ask -eq 'Y' -or $ask -eq 'y')
            } else {
                $ask = Read-Msg "  Alle Bibliotheken per pip fuer jedes Plugin installieren/aktualisieren? [J/N]"
                $autoUpdate = ($ask -eq 'J' -or $ask -eq 'j' -or $ask -eq 'Y' -or $ask -eq 'y')
            }

            Start-CombinedLog -lang $lang -prefix 'update_all_plugins'
            Write-Msg ""
            if ($lang -eq '1') {
                Write-Msg (Dim "  Running now without further prompts, using the answers above for every plugin...")
            } else {
                Write-Msg (Dim "  Laeuft jetzt ohne weitere Rueckfragen, mit den obigen Antworten fuer jedes Plugin...")
            }
            Write-Msg ""

            $processedNames = New-Object 'System.Collections.Generic.List[string]'
            foreach ($plugin in ($inventory.Valid | Sort-Object Name, Guid)) {
                Invoke-PluginRun -root $plugin.RootPath -lang $lang -AutoBackup:$autoBackup -AutoRemove:$autoRemove -AutoUpdate:$autoUpdate
                [void]$processedNames.Add($plugin.Name)
            }

            $global:BatchLogFile = $null

            Write-Msg ""
            Write-Msg (Cyan "  ================================================================")
            if ($lang -eq '1') { Write-Msg (Bold (Green "   ALL PLUGINS PROCESSED -- $($processedNames.Count) plugin(s) done")) }
            else               { Write-Msg (Bold (Green "   ALLE PLUGINS VERARBEITET -- $($processedNames.Count) Plugin(s) fertig")) }
            Write-Msg (Cyan "  ================================================================")
            foreach ($n in $processedNames) { Write-Msg ("    " + (Green "[OK]") + " " + $n) }
            Write-Msg ""
            }
        } else {
            Invoke-PluginRun -root $root -lang $lang
        }
    }
    '3' {
        $root = Select-PluginFromInventory -lang $lang
        if ($root -eq $BACK_TO_MODE_SENTINEL) {
        $backToMode = $true
        } elseif ($root -eq $ALL_PLUGINS_SENTINEL) {
            $installedRoot = Join-Path $env:LOCALAPPDATA 'GOG.com\Galaxy\plugins\installed'
            $inventory = Get-InstalledPluginInventory -installedRoot $installedRoot
            Start-CombinedLog -lang $lang -prefix 'versioncheck_all_plugins'

            $results = New-Object 'System.Collections.Generic.List[object]'
            foreach ($plugin in ($inventory.Valid | Sort-Object Name, Guid)) {
                $r = Invoke-VersionCheck -root $plugin.RootPath -lang $lang
                [void]$results.Add($r)
            }

            $global:BatchLogFile = $null

            $totalUpdated  = ($results | Measure-Object -Property Updated  -Sum).Sum
            $totalFailed   = ($results | Measure-Object -Property Failed   -Sum).Sum
            $totalOutdated = ($results | Measure-Object -Property Outdated -Sum).Sum

            Write-Msg ""
            Write-Msg (Cyan "  ================================================================")
            if ($lang -eq '1') { Write-Msg (Bold (Green "   ALL PLUGINS CHECKED -- $($results.Count) plugin(s) done")) }
            else               { Write-Msg (Bold (Green "   ALLE PLUGINS GEPRUEFT -- $($results.Count) Plugin(s) fertig")) }
            Write-Msg (Cyan "  ================================================================")
            Write-Msg ""

            foreach ($r in $results) {
                if ($r.Error) {
                    if ($lang -eq '1') { Write-Msg ("    " + (Dim "[?]") + " " + $r.Plugin.PadRight(45) + (Dim "could not be checked")) }
                    else               { Write-Msg ("    " + (Dim "[?]") + " " + $r.Plugin.PadRight(45) + (Dim "konnte nicht geprueft werden")) }
                    continue
                }
                $line = "$($r.UpToDate) OK, $($r.Outdated) outdated, $($r.Updated) updated, $($r.Failed) failed"
                if ($lang -eq '1') { $marker = if ($r.Failed -gt 0) { Red "[!]" } elseif ($r.Outdated -gt 0) { Yellow "[!]" } else { Green "[OK]" } }
                else               { $marker = if ($r.Failed -gt 0) { Red "[!]" } elseif ($r.Outdated -gt 0) { Yellow "[!]" } else { Green "[OK]" } }
                Write-Msg ("    " + $marker + " " + $r.Plugin.PadRight(45) + (Dim $line))
            }

            Write-Msg ""
            if ($lang -eq '1') {
                Write-Msg ("  " + (White "Overall:") + " $totalUpdated updated, $totalFailed failed, $($totalOutdated - $totalUpdated - $totalFailed) left outdated across $($results.Count) plugin(s).")
            } else {
                Write-Msg ("  " + (White "Insgesamt:") + " $totalUpdated aktualisiert, $totalFailed fehlgeschlagen, $($totalOutdated - $totalUpdated - $totalFailed) weiterhin veraltet, ueber $($results.Count) Plugin(s).")
            }
            Write-Msg ""
        } else {
            Invoke-VersionCheck -root $root -lang $lang | Out-Null
        }
    }
    }

    if ($backToMode) { continue }

    Write-Msg ""
    Write-Msg (Cyan "  ================================================================")
    if ($lang -eq '1') {
        Write-Msg (Yellow "  Run finished.")
        $nextChoice = Read-Msg "  > Press Enter to return to mode selection, or 'q' to quit"
    } else {
        Write-Msg (Yellow "  Durchlauf beendet.")
        $nextChoice = Read-Msg "  > Enter druecken fuer zurueck zur Modusauswahl, oder 'q' zum Beenden"
    }
    if ($nextChoice -eq 'q' -or $nextChoice -eq 'Q') { Show-MatrixExit -lang $lang }
}
} catch {
    # Unexpected crash: report it plainly and exit non-zero so the .bat
    # launcher knows to keep the window open instead of closing instantly.
    Write-Host ""
    Write-Host "  [!] Unexpected error -- the tool stopped." -ForegroundColor Red
    Write-Host ("  " + $_.Exception.Message) -ForegroundColor Red
    Write-Host ""
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}