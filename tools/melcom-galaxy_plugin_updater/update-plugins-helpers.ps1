<#
    update-plugins-helpers.ps1
    ---------------------------------------------------------------
    Action-based helper engine for update-plugins.bat.

    Stdout is a machine-readable interface consumed by FOR /F in the batch file.
    Most actions therefore emit one pipe-delimited status record; ScanPlugins and
    GetInstallCatalog intentionally emit one record per item, while MatrixExit
    writes directly to the console. Keep data fields free of pipes and newlines.

    Must stay in the SAME folder as update-plugins.bat.
    ---------------------------------------------------------------
#>

param(
    [Parameter(Mandatory = $true)][string]$Action,
    [string]$PluginsDir,
    [string]$BackupDir,
    [string]$PluginDirName,
    [string]$Repo,
    [string]$LatestApi,
    [string]$AssetPattern,
    [string]$LocalVersion,
    [string]$DownloadUrl,
    [string]$SecretFile,
    [string]$SecretType,
    [string]$TargetFile,
    [string]$Lang
)

$ErrorActionPreference = "Stop"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

function Get-Timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }

function Clean([string]$s) {
    if ($null -eq $s) { return "" }
    return ($s -replace '[\|\r\n]', ' ')
}

# Extract numeric segments and compare them positionally, padding missing trailing
# segments with zero. This deliberately ignores prefixes/suffixes such as "v" and
# "-64bit". Return $null when neither side has a usable numeric representation so
# the caller can choose a conservative fallback instead of guessing precedence.
function Compare-VersionStrings([string]$a, [string]$b) {
    $partsA = [regex]::Matches($a, '\d+') | ForEach-Object { [int]$_.Value }
    $partsB = [regex]::Matches($b, '\d+') | ForEach-Object { [int]$_.Value }
    if ($partsA.Count -eq 0 -or $partsB.Count -eq 0) { return $null }

    $len = [Math]::Max($partsA.Count, $partsB.Count)
    for ($i = 0; $i -lt $len; $i++) {
        $x = if ($i -lt $partsA.Count) { $partsA[$i] } else { 0 }
        $y = if ($i -lt $partsB.Count) { $partsB[$i] } else { 0 }
        if ($x -gt $y) { return 1 }
        if ($x -lt $y) { return -1 }
    }
    return 0
}

switch ($Action) {

    # This is the authoritative install catalog. The batch side derives menu
    # indexes and availability from these stable directory identifiers.
    "GetInstallCatalog" {
        $catalog = @(
            @("amazon_c2cd2e29-8b02-35a9-86fc-3faf90255857", "Amazon Games Plugin", "melcom-creations/galaxy-integration-amazon"),
            @("battlenet_ba170431-0649-482f-863b-d248592f1842", "Battle.net Plugin", "melcom-creations/galaxy-integration-battlenet"),
            @("humble_f0ca3d80-a432-4d35-a9e3-60f27161ac3a", "Humble Bundle Plugin", "melcom-creations/galaxy-integration-humble"),
            @("itch_2df02142-4d8a-4a4b-9b6e-c3a0bc62f93b", "itch.io Plugin", "melcom-creations/galaxy-integration-itch"),
            @("origin_7f53219b-4e2b-4591-9f4f-dfc5f4ba9eb0", "EA app Plugin", "melcom-creations/galaxy-integration-ea"),
            @("rockstar_774732b5-69c4-405c-b6c9-92cd55740cfe", "Rockstar Games Plugin", "melcom-creations/galaxy-integration-rockstar"),
            @("steam_ca27391f-2675-49b1-92c0-896d43afa4f8", "Steam Plugin", "melcom-creations/galaxy-integration-steam"),
            @("uplay_afb5a69c-b2ee-4d58-b916-f4cd75d4999a", "Ubisoft Connect Plugin", "melcom-creations/galaxy-integration-uplay")
        )

        foreach ($item in $catalog) {
            $repo = $item[2]
            Write-Output "$($item[0])|$($item[1])|$repo|https://api.github.com/repos/$repo/releases/latest|*-64bit.zip"
        }
    }

    # ---------------------------------------------------------
    # Checks whether plugin.py in the given plugin folder already
    # contains the Steam Achievement Notifier integration markers.
    # Output: PRESENT|  /  NOTPRESENT|  /  NOFILE|
    # ---------------------------------------------------------
    "CheckSanMarker" {
        $filePath = Join-Path (Join-Path $PluginsDir $PluginDirName) "plugin.py"
        if (-not (Test-Path -LiteralPath $filePath)) {
            Write-Output "NOFILE|"
            break
        }
        try {
            $content = Get-Content -Raw -LiteralPath $filePath -Encoding UTF8
            if ($content -match "# === SAN_INTEGRATION_START ===") {
                Write-Output "PRESENT|"
            } else {
                Write-Output "NOTPRESENT|"
            }
        } catch {
            Write-Output "NOTPRESENT|"
        }
    }

    # ---------------------------------------------------------
    # Removes every marker-wrapped Steam Achievement Notifier
    # block from plugin.py. Blocks are matched non-greedily so
    # multiple, non-nested START/END pairs are each removed on
    # their own. Aborts without touching the file if the number
    # of START markers does not match the number of END markers,
    # since that indicates the file was edited unexpectedly.
    # Output: OK|path  /  ERROR|message
    # ---------------------------------------------------------
    "StripSanBlocks" {
        $filePath = Join-Path (Join-Path $PluginsDir $PluginDirName) "plugin.py"
        try {
            if (-not (Test-Path -LiteralPath $filePath)) {
                Write-Output "ERROR|PLUGIN_PY_NOT_FOUND"
                break
            }
            $content = Get-Content -Raw -LiteralPath $filePath -Encoding UTF8

            $startCount = ([regex]::Matches($content, "# === SAN_INTEGRATION_START ===")).Count
            $endCount   = ([regex]::Matches($content, "# === SAN_INTEGRATION_END ===")).Count
            if ($startCount -ne $endCount) {
                Write-Output "ERROR|MARKER_MISMATCH"
                break
            }
            if ($startCount -eq 0) {
                Write-Output "OK|$filePath"
                break
            }

            $patternStr = "[ \t]*# === SAN_INTEGRATION_START ===\r?\n.*?[ \t]*# === SAN_INTEGRATION_END ===\r?\n"
            $stripped = [regex]::Replace($content, $patternStr, "", [System.Text.RegularExpressions.RegexOptions]::Singleline)

            if ($stripped -match "SAN_INTEGRATION") {
                Write-Output "ERROR|MARKER_LEFTOVER"
                break
            }

            Set-Content -LiteralPath $filePath -Value $stripped -NoNewline -Encoding UTF8
            Write-Output "OK|$filePath"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Inserts the marker-wrapped Steam Achievement Notifier
    # integration into plugin.py: the NOTIFIER_PATH constant, the
    # _launch_external_notifier method, and the call site inside
    # _update_local_games. Anchored on stable, unique text that is
    # expected to exist in the currently installed Steam plugin.
    # Aborts without touching the file if any anchor is missing,
    # or if the markers are already present (idempotent).
    # Output: OK|path  /  ALREADY|path  /  ERROR|message
    # ---------------------------------------------------------
    "InsertSanBlocks" {
        $filePath = Join-Path (Join-Path $PluginsDir $PluginDirName) "plugin.py"
        try {
            if (-not (Test-Path -LiteralPath $filePath)) {
                Write-Output "ERROR|PLUGIN_PY_NOT_FOUND"
                break
            }
            $content = Get-Content -Raw -LiteralPath $filePath -Encoding UTF8

            if ($content.Contains("# === SAN_INTEGRATION_START ===")) {
                Write-Output "ALREADY|$filePath"
                break
            }

            $nl = "`n"
            if ($content.Contains("`r`n")) { $nl = "`r`n" }

            # --- Anchor 1: NOTIFIER_PATH constant, right after the module logger line ---
            $anchor1 = "logger = logging.getLogger(__name__)"
            if (-not $content.Contains($anchor1)) {
                Write-Output "ERROR|ANCHOR_LOGGER_NOT_FOUND"
                break
            }
            $const1 = @'
# === SAN_INTEGRATION_START ===
# Path to the Steam Achievement Notifier executable
NOTIFIER_PATH = os.path.expandvars(r"%LOCALAPPDATA%\Programs\steamachievementnotifierv1.9\Steam Achievement Notifier (V1.9).exe")
# === SAN_INTEGRATION_END ===
'@
            $const1 = $const1 -replace "`r?`n", $nl
            $content = $content.Replace($anchor1, $anchor1 + $nl + $nl + $const1)

            # --- Anchor 2: _launch_external_notifier method, right before _update_local_games ---
            $anchor2 = "    async def _update_local_games(self):"
            if (-not $content.Contains($anchor2)) {
                Write-Output "ERROR|ANCHOR_UPDATE_LOCAL_GAMES_NOT_FOUND"
                break
            }
            $method2 = @'
    # === SAN_INTEGRATION_START ===
    def _launch_external_notifier(self):
        """Starts the achievement notifier application if available."""
        if is_windows() and os.path.exists(NOTIFIER_PATH):
            try:
                logger.info(f"Launching external notifier: {NOTIFIER_PATH}")
                subprocess.Popen([NOTIFIER_PATH], creationflags=subprocess.CREATE_NO_WINDOW if hasattr(subprocess, 'CREATE_NO_WINDOW') else 0)
            except Exception as e:
                logger.error(f"Failed to launch external notifier: {e}")
        else:
            logger.debug("External notifier not found or platform incompatible.")
    # === SAN_INTEGRATION_END ===

'@
            $method2 = $method2 -replace "`r?`n", $nl
            $content = $content.Replace($anchor2, $method2 + $anchor2)

            # --- Anchor 3: call site inside _update_local_games. Anchored
            # on the "for game in notify_list:" loop header itself (stable
            # across plugin versions) rather than on any specific line
            # inside the loop body, since that body can differ between
            # versions. The inserted block is self-contained - it adds its
            # own Running-state check as the first statement in the loop,
            # independent of whatever else the loop already does. ---
            $anchor3 = "        for game in notify_list:"
            if (-not $content.Contains($anchor3)) {
                Write-Output "ERROR|ANCHOR_NOTIFY_LIST_LOOP_NOT_FOUND"
                break
            }
            $call3 = @'
            # === SAN_INTEGRATION_START ===
            if LocalGameState.Running in game.local_game_state:
                self._launch_external_notifier()
            # === SAN_INTEGRATION_END ===
'@
            $call3 = $call3 -replace "`r?`n", $nl
            $content = $content.Replace($anchor3, $anchor3 + $nl + $call3)

            Set-Content -LiteralPath $filePath -Value $content -NoNewline -Encoding UTF8
            Write-Output "OK|$filePath"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Scan every immediate plugin directory and assign a trust state:
    # 0 = excluded/unreadable, 1 = current melcom repository, 2 = legacy melcom.
    # Clean manifest-derived fields because stdout is parsed on pipes and lines.
    # Output per line:
    # DirName|Valid|Name|Platform|Guid|Version|Repo|LatestApi|AssetPattern
    # ---------------------------------------------------------
    "ScanPlugins" {
        if (-not (Test-Path -LiteralPath $PluginsDir)) {
            Write-Output "ERROR|PLUGINSDIR_NOT_FOUND"
            break
        }
        $dirs = Get-ChildItem -LiteralPath $PluginsDir -Directory -ErrorAction SilentlyContinue
        foreach ($d in $dirs) {
            $manifestPath = Join-Path $d.FullName "manifest.json"
            if (-not (Test-Path -LiteralPath $manifestPath)) {
                Write-Output "$($d.Name)|0|NOMANIFEST||||||"
                continue
            }
            try {
                $raw = Get-Content -Raw -LiteralPath $manifestPath -Encoding UTF8
                $m = $raw | ConvertFrom-Json
            } catch {
                Write-Output "$($d.Name)|0|BADJSON||||||"
                continue
            }

            $author = "$($m.author)"
            $url    = "$($m.url)"
            $valid  = 0
            if ($author -match "(?i)melcom") {
                $valid = 2
                if ($url -match [regex]::Escape("https://github.com/melcom-creations")) {
                    $valid = 1
                }
            }

            $repo = ""; $api = ""; $pattern = ""
            if ($m.external_updater) {
                $repo    = "$($m.external_updater.repo)"
                $api     = "$($m.external_updater.latest_release_api)"
                $pattern = "$($m.external_updater.asset_pattern)"
            }

            $name     = Clean "$($m.name)"
            $platform = Clean "$($m.platform)"
            $guid     = Clean "$($m.guid)"
            $version  = Clean "$($m.version)"

            Write-Output "$($d.Name)|$valid|$name|$platform|$guid|$version|$repo|$api|$pattern"
        }
    }

    # ---------------------------------------------------------
    # Asks the GitHub API for the latest release and compares it
    # against the locally installed version string.
    # Output: UPDATE|tag|url / UPTODATE|tag|url / AHEAD|tag|url / ERROR|message
    # ---------------------------------------------------------
    "CheckUpdate" {
        try {
            $headers = @{ "User-Agent" = "melcom-galaxy-updater"; "Accept" = "application/vnd.github+json" }
            # Use an existing token opportunistically; credentials are never read
            # from or written to disk by this helper.
            if ($env:GITHUB_TOKEN) {
                $headers["Authorization"] = "Bearer $($env:GITHUB_TOKEN)"
            }
            $rel = $null
            try {
                $rel = Invoke-RestMethod -Uri $LatestApi -Headers $headers -Method Get
            } catch {
                $statusCode = $null
                $respHeaders = $null
                if ($_.Exception.Response) {
                    try { $statusCode = [int]$_.Exception.Response.StatusCode } catch {}
                    try { $respHeaders = $_.Exception.Response.Headers } catch {}
                }
                if ($statusCode -eq 404 -or $_.Exception.Message -match '404') {
                    # GitHub's /releases/latest excludes drafts and prereleases and
                    # may return 404 even when releases exist. The list endpoint is
                    # the compatibility fallback; its first item is newest.
                    $listUrl = "https://api.github.com/repos/$Repo/releases"
                    $list = Invoke-RestMethod -Uri $listUrl -Headers $headers -Method Get
                    if ($list -and $list.Count -gt 0) {
                        $rel = $list | Select-Object -First 1
                    } else {
                        Write-Output "ERROR|NO_RELEASES_FOUND"
                        break
                    }
                } elseif ($statusCode -eq 403) {
                    # A 403 from the GitHub API is almost always either the hourly
                    # rate limit (60 requests/hour without a token) or the shorter
                    # secondary/abuse limit (many requests in quick succession).
                    # Both look identical to the user without extra detail, so read
                    # the rate-limit headers GitHub sends along with the 403 and put
                    # them into the error message instead of just "(403) Forbidden".
                    $remaining = $null
                    $resetAt   = $null
                    if ($respHeaders) {
                        try {
                            if ($respHeaders["X-RateLimit-Remaining"]) { $remaining = $respHeaders["X-RateLimit-Remaining"][0] }
                            if ($respHeaders["X-RateLimit-Reset"]) {
                                $resetEpoch = [long]$respHeaders["X-RateLimit-Reset"][0]
                                $resetAt = ([DateTimeOffset]::FromUnixTimeSeconds($resetEpoch)).ToLocalTime().ToString("HH:mm:ss")
                            }
                        } catch {}
                    }
                    if ($remaining -eq "0" -and $resetAt) {
                        Write-Output "ERROR|RATE_LIMIT_EXCEEDED (resets $resetAt, add a GITHUB_TOKEN environment variable to raise the limit)"
                    } elseif ($remaining -or $resetAt) {
                        Write-Output "ERROR|HTTP_403_FORBIDDEN (rate-limit-remaining=$remaining, resets $resetAt)"
                    } else {
                        Write-Output "ERROR|HTTP_403_FORBIDDEN (likely rate limit or abuse detection - see README)"
                    }
                    break
                } else {
                    throw
                }
            }
            $tag = "$($rel.tag_name)"

            $asset = $rel.assets | Where-Object { $_.name -like $AssetPattern } | Select-Object -First 1
            if (-not $asset) {
                Write-Output "ERROR|NO_MATCHING_ASSET_$AssetPattern"
                break
            }

            $tagClean   = ($tag -replace '-64bit$', '') -replace '^[vV]', ''
            $localClean = ($LocalVersion -replace '-64bit$', '') -replace '^[vV]', ''

            $cmp = Compare-VersionStrings $tagClean $localClean
            if ($null -eq $cmp) {
                # Could not parse numeric version segments from one of the
                # two strings - fall back to the old equality-only check
                # rather than guessing a direction.
                if ($tagClean -eq $localClean) {
                    Write-Output "UPTODATE|$tag|$($asset.browser_download_url)"
                } else {
                    Write-Output "UPDATE|$tag|$($asset.browser_download_url)"
                }
            } elseif ($cmp -eq 0) {
                Write-Output "UPTODATE|$tag|$($asset.browser_download_url)"
            } elseif ($cmp -gt 0) {
                Write-Output "UPDATE|$tag|$($asset.browser_download_url)"
            } else {
                # The published release is OLDER than what's installed
                # locally (e.g. an in-development build ahead of the last
                # release) - never overwrite it with something older.
                Write-Output "AHEAD|$tag|$($asset.browser_download_url)"
            }
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Create a point-in-time recovery ZIP before any destructive replacement.
    # Output: OK|zipPath / ERROR|message
    # ---------------------------------------------------------
    "BackupPlugin" {
        try {
            $src = Join-Path $PluginsDir $PluginDirName
            $destDir = Join-Path $BackupDir $PluginDirName
            if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
            $ts = Get-Timestamp
            $zipPath = Join-Path $destDir "$($PluginDirName)_$ts.zip"
            Compress-Archive -Path (Join-Path $src "*") -DestinationPath $zipPath -Force
            Write-Output "OK|$zipPath"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Checks whether a secret file (consts.py / credentials.json)
    # actually contains a usable, non-empty token.
    # Output: PRESENT|path  /  EMPTY|path  /  NOFILE|  /  ERROR|message
    # ---------------------------------------------------------
    "CheckSecret" {
        $filePath = Join-Path (Join-Path $PluginsDir $PluginDirName) $SecretFile
        if (-not (Test-Path -LiteralPath $filePath)) {
            Write-Output "NOFILE|"
            break
        }
        try {
            if ($SecretType -eq "battlenet") {
                $content  = Get-Content -Raw -LiteralPath $filePath -Encoding UTF8
                $idMatch  = [regex]::Match($content, 'CLIENT_ID\s*=\s*"([^"]*)"')
                $secMatch = [regex]::Match($content, 'CLIENT_SECRET\s*=\s*"([^"]*)"')
                $idVal  = if ($idMatch.Success)  { $idMatch.Groups[1].Value.Trim() }  else { "" }
                $secVal = if ($secMatch.Success) { $secMatch.Groups[1].Value.Trim() } else { "" }
                if ($idVal -ne "" -and $secVal -ne "") {
                    Write-Output "PRESENT|$filePath"
                } else {
                    Write-Output "EMPTY|$filePath"
                }
            } elseif ($SecretType -eq "itch") {
                $j   = Get-Content -Raw -LiteralPath $filePath -Encoding UTF8 | ConvertFrom-Json
                $tok = "$($j.access_token)".Trim()
                if ($tok -ne "") {
                    Write-Output "PRESENT|$filePath"
                } else {
                    Write-Output "EMPTY|$filePath"
                }
            } else {
                Write-Output "ERROR|UNKNOWN_SECRET_TYPE"
            }
        } catch {
            Write-Output "EMPTY|$filePath"
        }
    }

    # ---------------------------------------------------------
    # Copies the secret file into the plugin's backup folder
    # (plain copy, timestamped filename - deliberately NOT zipped
    # so it can be restored with a single click).
    # ---------------------------------------------------------
    "BackupSecret" {
        try {
            $filePath = Join-Path (Join-Path $PluginsDir $PluginDirName) $SecretFile
            $destDir  = Join-Path $BackupDir $PluginDirName
            if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
            $ts   = Get-Timestamp
            $leaf = Split-Path $SecretFile -Leaf
            $dest = Join-Path $destDir "$($leaf)_$ts"
            Copy-Item -LiteralPath $filePath -Destination $dest -Force
            Write-Output "OK|$dest"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Restores a previously backed-up secret file back into the
    # plugin folder. SecretFile = full path to the backup copy,
    # TargetFile = relative filename inside the plugin folder.
    # ---------------------------------------------------------
    "RestoreSecret" {
        try {
            $target = Join-Path (Join-Path $PluginsDir $PluginDirName) $TargetFile
            Copy-Item -LiteralPath $SecretFile -Destination $target -Force
            Write-Output "OK|$target"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        }
    }

    # ---------------------------------------------------------
    # Download and extract into unique temporary paths, then replace the installed
    # directory contents. Archives may contain either files at their root or one
    # wrapper directory; normalize both layouts before copying. The caller must
    # create a backup first because replacement is intentionally not transactional.
    # ---------------------------------------------------------
    "DoUpdate" {
        $pluginDir = Join-Path $PluginsDir $PluginDirName
        $tempDir   = Join-Path $env:TEMP ("galaxy_update_" + [guid]::NewGuid().ToString("N"))
        $tempZip   = Join-Path $env:TEMP ("galaxy_update_" + [guid]::NewGuid().ToString("N") + ".zip")
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempZip -Headers @{ "User-Agent" = "melcom-galaxy-updater" }
            New-Item -ItemType Directory -Path $tempDir | Out-Null
            Expand-Archive -LiteralPath $tempZip -DestinationPath $tempDir -Force

            $items = Get-ChildItem -LiteralPath $tempDir
            $sourceRoot = $tempDir
            if ($items.Count -eq 1 -and $items[0].PSIsContainer) {
                $sourceRoot = $items[0].FullName
            }

            if (-not (Test-Path -LiteralPath $pluginDir)) {
                New-Item -ItemType Directory -Path $pluginDir | Out-Null
            } else {
                Get-ChildItem -LiteralPath $pluginDir -Force | Remove-Item -Recurse -Force
            }
            Copy-Item -Path (Join-Path $sourceRoot "*") -Destination $pluginDir -Recurse -Force

            Write-Output "OK|$pluginDir"
        } catch {
            Write-Output "ERROR|$(Clean $_.Exception.Message)"
        } finally {
            if (Test-Path -LiteralPath $tempZip) { Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue }
            if (Test-Path -LiteralPath $tempDir) { Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
        }
    }

    # ---------------------------------------------------------
    # Matrix-style farewell animation shown when the tool finishes.
    # Ported from GalaxyPluginScout's Show-MatrixExit. Purely cosmetic -
    # writes directly to the console and never returns a pipe-delimited
    # result line like the other actions, since there is nothing for
    # the batch file to parse afterwards.
    # ---------------------------------------------------------
    "MatrixExit" {
        $katakana = @()
        for ($cp = 0xFF66; $cp -le 0xFF9D; $cp++) { $katakana += [char]$cp }
        $chars = $katakana + @('0','1','2','3','4','5','6','7','8','9') + @('A','B','C','D','E','F')

        $width = 80
        try { $width = $Host.UI.RawUI.WindowSize.Width } catch { $width = 80 }
        if ($width -lt 20) { $width = 80 }

        # True-color ANSI sequences produce a bright head and dim trail; character
        # and intensity selection is randomized independently for each cell/frame.
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
        if ($Lang -eq "EN") {
            Write-Host ("  " + $mid + "Goodbye. Happy gaming!" + $reset)
        } elseif ($Lang -eq "DE") {
            Write-Host ("  " + $mid + "Tschuess. Viel Spass beim Zocken!" + $reset)
        } else {
            Write-Host ("  " + $mid + "Goodbye! / Tschuess!" + $reset)
        }
        Write-Host ""
        Start-Sleep -Milliseconds 1200

        # "Follow melcom." - starts almost invisible (dark green, close to
        # black), then a brightness glow travels across the letters left to
        # right, fading each letter back to dark as it passes, then travels
        # back right to left the same way, ending dark again.
        $waveDarkRGB = @(0, 25, 9)
        $wavePeakRGB = @(0, 190, 68)
        $glowWidth   = 2.6

        $followText = "Follow melcom."
        $textLen    = $followText.Length
        $travelFrom = -3
        $travelTo   = $textLen + 2
        $stepsPerPass = 26

        for ($pass = 0; $pass -lt 2; $pass++) {
            for ($s = 0; $s -le $stepsPerPass; $s++) {
                $progress = $s / $stepsPerPass
                if ($pass -eq 0) {
                    $peakPos = $travelFrom + ($travelTo - $travelFrom) * $progress
                } else {
                    $peakPos = $travelTo + ($travelFrom - $travelTo) * $progress
                }

                $line2 = New-Object System.Text.StringBuilder
                [void]$line2.Append("  ")
                for ($ci = 0; $ci -lt $textLen; $ci++) {
                    $dist = [Math]::Abs($ci - $peakPos)
                    $t = [Math]::Max(0.0, 1.0 - ($dist / $glowWidth))
                    $r = [int]($waveDarkRGB[0] + ($wavePeakRGB[0] - $waveDarkRGB[0]) * $t)
                    $g = [int]($waveDarkRGB[1] + ($wavePeakRGB[1] - $waveDarkRGB[1]) * $t)
                    $b = [int]($waveDarkRGB[2] + ($wavePeakRGB[2] - $waveDarkRGB[2]) * $t)
                    $col = "$([char]27)[38;2;${r};${g};${b}m"
                    [void]$line2.Append($col + $followText[$ci])
                }
                [void]$line2.Append($reset)
                Write-Host ("`r" + $line2.ToString()) -NoNewline
                Start-Sleep -Milliseconds 45
            }
        }
        Write-Host ""
        Write-Host ""
        Start-Sleep -Milliseconds 1000
    }

    default {
        Write-Output "ERROR|UNKNOWN_ACTION"
    }
}