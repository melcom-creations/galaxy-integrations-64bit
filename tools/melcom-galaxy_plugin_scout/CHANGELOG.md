# Changelog

All notable changes to **melcom's Galaxy Plugin Scout** will be documented in this file. The versioning scheme follows semantic guidelines.

## Version 1.2.0

### Overview for Version 1.2.0

Full refactor from 1.1.20's single hardcoded flow to a mode-driven launcher (dry-run / update / library-check, each with an `[a]` all-plugins option), plus a correctness pass across dependency resolution, pip installs, and post-update cleanup.

### Added in Version 1.2.0

**Launcher & modes**

- Mode-driven launcher: dry-run, update, or library-check, each covering one plugin or all of them via `[a]`. No separate "batch" mode.
- Plugin picker: numbered list of detected melcom plugins, `[a]` for all, manual path entry as fallback. Non-melcom plugins are shown but marked excluded (manifest author/url/repo mismatch).
- Mode 3 (library check): compares installed libraries against PyPI, asks `[Y/N/A]` before installing, now backs up `modules` before the first real install of the run.
- Post-run sanity check after every real update: verifies `plugin.py`, `manifest.json`, and `modules\galaxy\` are still present, warns pointing at the backup if not.
- `[b] Back to mode selection` and `[q] Quit` available throughout the flow (language, mode, and after every run) instead of only at the very end.
- Mode-selection screen and README now explain when Mode 2 is actually needed (structural dependency changes, e.g. a 32-to-64bit port) versus Mode 3 (routine library updates on an already-resolved plugin).

**Cleanup & dependency resolution**

- pip launcher stub removal (e.g. `idna.exe`, `chardetect.exe`), including empty `bin` folder cleanup with retry for Defender-locked files.
- Recursive `__pycache__` and mypyc `.pyd` sidecar cleanup after every real update.
- Duplicate and orphaned `.dist-info` pruning, with hardened name-variant matching.
- Library name canonicalization and de-duplication (`python-dateutil` / `python_dateutil` no longer double-installed).
- Post-update rescan: re-applies the resolver against the live tree instead of a stale pre-update list.
- Multi-import parsing (`import a, b as c`) instead of only the first symbol on the line.

### Fixed in Version 1.2.0

- Already-broken plugins (near-empty `/modules/` despite real root `.py` files) are no longer processed further -- the tool stops before touching anything.
- pip installs now pin `-WorkingDirectory`, so launcher stubs land where cleanup actually looks for them.
- Runtime protection list extended (`cffi`, `pycparser`, `_cffi_backend`, `packaging`, `mypy_extensions`) to stop them being wrongly removed as unused.
- Console now shows which plugin is currently running during an `[a]` run, not just the log file.
- Path entry now tolerates pasted quotes, backticks, and trailing carets.
- Mode 2 `[a]` with zero detected melcom plugins no longer hard-exits the tool.

---

## Version 1.1.20

### Fixed in Version 1.1.20

- **Restored `six.py` runtime dependency:** Removed `six.py` from the post-install `$devToolFiles` deletion blacklist. `six` is a legitimate runtime library required by packages like `python-dateutil` and must not be treated as a dev-tool leftover.

---

## Version 1.1.19

### Fixed in Version 1.1.19

- **Alphanumeric metadata parsing:** Improved `.dist-info` folder parsing to correctly handle package versions containing letters or post-release suffixes (e.g., `python_dateutil-2.9.0.post0.dist-info`). The parser regex was upgraded from `-[\d\.]+\.dist-info$` to `-[^-]+\.dist-info$` to prevent pip from attempting to install literal `.dist-info` paths as packages.

---

## Version 1.1.18

### Fixed in Version 1.1.18

- **Unique backup archive names:** Backup archives are no longer overwritten when running the Scout multiple times on the same plugin. Every backup now uses the plugin folder name together with a timestamp, ensuring each archive is stored as a new file.

  Example: `PluginName_ba170431-0649-482f-863b-d248592f1842-20260628_173512.zip`

---

## Version 1.1.17

### Added in Version 1.1.17

- **Persistent DRY-RUN banner:** When the `-DryRun` switch is active, the UI now displays a highly visible `*** DRY-RUN MODE ***` banner directly below the main banner, making it immediately obvious that no files will be modified, no backup will be created and no pip operations will be performed.

---

## Version 1.1.16

### Added in Version 1.1.16

- **`-DryRun` switch:** Running `GalaxyPluginScout.ps1 -DryRun` executes the full analysis and prints the complete report (KEEP / REMOVE / SKIP) without touching any files. No backup is created, no modules are deleted, pip is not invoked. Useful before working on an unknown plugin or after making changes to the resolver to verify the output is correct before committing.

  Usage: `powershell -File GalaxyPluginScout.ps1 -DryRun`

---

## Version 1.1.15

### Fixed in Version 1.1.15

- **`steam_network` attempted pip install:** `steam_network` is plugin-own code for the Steam plugin and does not exist on PyPI. It was landing in LIBRARIES because `Write-Config` did not have it blacklisted. Added to the `Write-Config` blacklist so it is never forwarded to the Updater.
- **Post-install cleanup incorrectly removed valid dist-infos:** The orphaned dist-info check compared the dist-info package name directly to a folder name. Packages where these differ (`galaxy_plugin_api` → `galaxy/`, `protobuf` → `google/`) were falsely flagged as orphaned and deleted. Fixed by introducing a `$distInfoFolderMap` lookup table that maps known dist-info names to their actual folder names before checking for existence.
- **`typing_extensions.py` and `typing_inspect.py` incorrectly deleted:** These are legitimate single-file packages installed by pip. They were listed in the leftover `.py` cleanup and removed even though they are required at runtime. Removed from the cleanup list. Only true dev-tool `.py` files (`zipp.py`, `six.py`, `py.py`, `tomli.py`) are now deleted.

---

## Version 1.1.14

### Added in Version 1.1.14

- **Post-install cleanup phase:** After every Updater run, two automatic cleanup passes now run against the `/modules/` directory.
  - **Orphaned dist-info removal:** Any `.dist-info` folder whose corresponding package folder no longer exists is automatically deleted. This catches leftover metadata from packages that pip removed or replaced (e.g. `pip_tools-7.5.3.dist-info`, old `galaxy_plugin_api-0.70.dist-info`).
  - **Leftover `.py` file removal:** Known standalone `.py` files that pip places as part of certain packages (`typing_extensions.py`, `zipp.py`, `mypy_extensions.py`, `tomli.py`, `six.py`, `py.py`) are automatically deleted after install, keeping `/modules/` free of stray files.

---

## Version 1.1.13

### Fixed in Version 1.1.13

- **Dev tools reinstalled by pip after cleanup:** `Write-Config` had its own separate `$blacklist` that did not include the dev tools from `$devToolsBlacklist`. Items like `piptools` were not blocked in `Write-Config` and landed in LIBRARIES, causing pip to reinstall them (along with their own dependencies like `build`, `pyproject_hooks`, `click`, `colorama` etc.) during the update phase.
- **`build` and `pyproject_hooks` added to both blacklists:** These two pip build-system packages were missing from both `$devToolsBlacklist` and the `Write-Config` `$blacklist`. Added to both so they are always removed and never reinstalled.
- **`Write-Config` blacklist unified with `$devToolsBlacklist`:** The `Write-Config` internal blacklist now mirrors `$devToolsBlacklist` exactly, ensuring no dev tool can slip through into LIBRARIES.

---

## Version 1.1.12

### Fixed in Version 1.1.12

- **`py` added to `$devToolsBlacklist`:** The `py/` package (a pytest compatibility shim) was incorrectly kept in KEEP Transitive because pytest imports it internally. Added to the dev tools blacklist so it always lands in REMOVE.
- **Duplicate entries in REMOVE list:** When a package existed as both a folder and a `.py` file in `/modules/` (e.g. `zipp/` and `zipp.py`), it appeared twice in the REMOVE list. Fixed by adding `.Contains()` guards before every `$toRemove.Add()` call.

---

## Version 1.1.11

### Added in Version 1.1.11

- **`$devToolsBlacklist` - Developer tool filter:** Introduced a hardcoded blacklist of development and build tools that are never needed by a GOG plugin at runtime. Items in this list always land in REMOVE, even when the BFS scanner finds transitive imports leading to them. This fixes a false-positive loop where tools like `pytest`, `pip`, and `setuptools` kept each other alive by importing each other internally.

  Blacklisted packages: `pytest`, `_pytest`, `pluggy`, `iniconfig`, `atomicwrites`, `pip`, `setuptools`, `wheel`, `piptools`, `pep517`, `click`, `colorama`, `invoke`, `pyparsing`, `_distutils_hack`, `importlib_metadata`, `zipp`, `tomli`, `asynctest`, `mypy_extensions`.

---

## Version 1.1.10

### Fixed in Version 1.1.10

- **`plugin-config.txt` written to plugin ROOT:** `Write-Config` was using `$rootPath` (the scanned plugin folder) as the output directory for `plugin-config.txt`, placing the file inside the user's GOG plugin folder. Changed to `$PSScriptRoot` so the file is always written next to the Scout script itself.

---

## Version 1.1.9

### Fixed in Version 1.1.9

- **Instant Greeting Wipe (UX Bug):** In `Get-PluginRoot`, the console clearing mechanism inside `Show-Banner` was being executed immediately on the very first path prompt iteration, erasing the welcome greeting before the user could read it. Implemented an `$isFirstRun` guard so the host is only cleared on invalid retry attempts, preserving the onboarding greeting on startup.
- **Header Synchronization:** Synced the script's header comment block (.SYNOPSIS) to correctly match the active release version.

---

## Version 1.1.8

### Fixed in Version 1.1.8

- **`OrderedDictionary.ContainsKey()` Crash:** PowerShell's `[ordered]@{}` returns a `System.Collections.Specialized.OrderedDictionary` which does not expose a `.ContainsKey()` method. All affected lookups in `Remove-UnusedModules` replaced with `.Contains()`, which is the correct method for this type. Without this fix, the cleanup phase crashed immediately after the user confirmed deletion.

---

## Version 1.1.7

### Changed in Version 1.1.7

- **`galaxy` removed from `$protectedNamespaces`:** `galaxy` is now treated as a resolvable import alias instead of a hard-protected internal namespace. This allows the dependency resolver to correctly classify it as a direct import and forward it to `Write-Config` for pip name mapping.
- **`galaxy` alias added to `$aliases`:** `galaxy` now maps to `galaxy_plugin_api` in the resolver's alias table, mirroring the existing `google` → `protobuf` mapping. The Updater installs `galaxy_plugin_api` via pip when needed.

---

## Version 1.1.6

### Changed in Version 1.1.6

- **`galaxy` removed from `Write-Config` blacklist:** `galaxy` was previously blacklisted from appearing in `LIBRARIES`, preventing the Updater from ever reinstalling it. Removed from blacklist so it participates in the standard pip name mapping pipeline.
- **`galaxy` → `galaxy_plugin_api` added to `$packageMapping`:** The `Write-Config` translation table now correctly maps the `galaxy` folder name to its PyPI distribution name `galaxy_plugin_api`.

---

## Version 1.1.5

### Overview for Version 1.1.5

This release resolves critical edge cases in recursive dependency resolution and enhances CLI report transparency by introducing dedicated status segments for protected local files.

### Fixed in Version 1.1.5

- **Transitive Alias Resolution (`attr` vs `attrs`):** Expanded alias mapping globally across both direct and transitive import paths. If a transitively kept dependency (like `aiohttp`) imports the legacy `attr` namespace, the script now automatically resolves it and preserves the required `attrs` metadata directory from deletion.

### Added in Version 1.1.5

- **Dedicated Protected Namespace UI Section:** Introduced a visible, pink-coded `"SKIP - Protected / Internal"` section in the CLI analysis report. Internal or local directories (such as GOG's `galaxy` API, `bnet` protocol folders, `bin`, and `splash`) are now explicitly listed as skipped, providing clear visual confirmation of their safe state.

---

## Version 1.1.4

### Overview for Version 1.1.4

This update introduces strict dynamic filtering to prevent inactive packages from falsely keeping themselves alive during recursive dependency scans.

### Fixed in Version 1.1.4

- **Dynamic Self-Import Filtering:** Implemented a directory-aware self-import filter within the `Get-Imports` parser. While scanning files inside `/modules/XYZ/`, any imports pointing to `XYZ` itself are now silently ignored. This resolves an issue where unused packages (like `aiohttp` or `cffi`) avoided removal because they imported their own submodules.

---

## Version 1.1.3

### Overview for Version 1.1.3

This usability release simplifies first-time setup instructions and adds automatic operating system shortcut handling for paths.

### Added in Version 1.1.3

- **Environment Variable Expansion:** The path entry prompt now automatically expands Windows environment variables (e.g. `%localappdata%`) to their absolute equivalent in the background before validation.

### Changed in Version 1.1.3

- **Simplified Location Prompts:** Replaced long absolute example paths in the prompt with cleaner, standard variable examples pointing to `%localappdata%\GOG.com\Galaxy\plugins\installed\<plugin_folder>`.

---

## Version 1.1.2

### Overview for Version 1.1.2

A quality-of-life interface update to clean up CLI navigation and prevent prompt clutter during language selection.

### Fixed in Version 1.1.2

- **CLI Prompt Stacking:** Entering an invalid choice (anything other than `1` or `2`) in the language selector now clears the console buffer, redraws the banner, and displays a single, clean red error message above the input field instead of appending stacked prompt lines.

---

## Version 1.1.1

### Overview for Version 1.1.1

This release focuses on platform compatibility, clean error handling, and strict directory validation to prevent accidental runs on non-plugin folders.

### Fixed in Version 1.1.1

- **Interactive Handshake Crash:** Replaced the unreliable `$MyInvocation.ScriptName` evaluation with the native `$PSScriptRoot` automatic variable, preventing script path binding failures in environments where the script name is passed as an empty string.
- **Path Verification Guard:** Upgraded the directory verification process to strictly check for the existence of `plugin.py` or `manifest.json`. If neither is found, the path is rejected as invalid, protecting non-GOG folders from accidental modifications.
- **Path Input UI Reset:** Invalid path entries now cleanly clear the console and redraw the prompt with a red error alert, eliminating stacked prompt lines.

---

## Version 1.1.0

### Overview for Version 1.1.0

A major architectural leap introducing a deep transitive dependency scanner, an interactive physical cleanup stage, and package name translations for standard PyPI distributions.

### Added in Version 1.1.0

- **Recursive Transitive Dependency Scanner:** Upgraded the dependency resolution engine to recursively parse import statements from all `.py` files inside `/modules/`.
- **Physical Cleanup / Deletion Phase:** The tool now offers an interactive prompt to physically delete unused dependencies (and their corresponding `.dist-info` directories) from disk before updating. The module map is refreshed dynamically post-deletion.
- **Pip Package Name Mapping:** Implemented a static translation map (e.g., `google` $\rightarrow$ `protobuf`, `attr` $\rightarrow$ `attrs`, `yaml` $\rightarrow$ `PyYAML`) inside `Write-Config` to translate raw code imports into their correct PyPI distribution names.
- **Pip Update Blacklist:** Hardcoded strict update exclusions for local, protected, or internal plugin directories (`galaxy`, `galaxy_api`, `bnet`, etc.) to prevent `pip` from searching for or overwriting private files on PyPI.

---

## Version 1.0.3

### Overview for Version 1.0.3

This release implements a robust logging engine to record and audit execution steps chronological-by-run.

### Added in Version 1.0.3

- **Dual-Stream Logging Wrapper:** Engineered custom `Write-Msg` and `Read-Msg` wrappers. The engine prints fully colored ANSI text in the console, while silently stripping the color escapes to write clean, plain text logs.
- **Chronological Audit Logs:** Execution logs are automatically saved under a `/logs/` subfolder using a `YYYY-MM-DD_HH-mm-ss_<plugin_name>.log` naming convention.

---

## Version 1.0.2

### Overview for Version 1.0.2

A stability update protecting local API bindings and binary extensions from updater exceptions.

### Changed in Version 1.0.2

- **GOG API Update Protection:** Excluded GOG-specific dependencies (such as `galaxy`) from being forwarded to the `pip` installation list.
- **Binary Extension Filter:** Prevented `.pyd` compiled files from being sent as target update packages to `pip`, avoiding unnecessary package manager errors.

---

## Version 1.0.1

### Overview for Version 1.0.1

A path-handling hotfix addressing execution issues on directories containing whitespace or special characters.

### Fixed in Version 1.0.1

- **Double-Quoted CLI Arguments:** Enclosed `$pluginDir` and `$cacheDir` inside literal double quotes in all `pip` execution arguments. This prevents `Start-Process` from failing when the tool is run from a path containing spaces or apostrophes (e.g., `melcom's Galaxy Plugin Scout`).

---

## Version 1.0.0

### Overview for Version 1.0.0

Initial stable release of **melcom's Galaxy Plugin Scout**.

- Functional analyzer and dependency resolution CLI for GOG Galaxy 2.x 64-bit Python 3.13 libraries.
- Automates configuration generation (`plugin-config.txt`) and basic backups.