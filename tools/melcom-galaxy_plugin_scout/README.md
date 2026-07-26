# melcom's Galaxy Plugin Scout

A Windows tool that analyzes and updates the Python libraries inside a GOG Galaxy plugin's `modules` folder.

**Scope:** melcom's own GOG Galaxy plugins only (Amazon Games, Battle.net, EA app, Rockstar, Steam, Ubisoft Connect, Humble Bundle, itch.io) — [all in one repo](https://github.com/melcom-creations/galaxy-integrations-64bit). Third-party plugins found in the same folder are detected and shown, but excluded.

## Requirements

- Windows 10/11 (64-bit), PowerShell 5.1+
- GOG Galaxy 2.1+
- [Python 3.13 (64-bit) with pip](https://www.python.org/downloads/windows/)

## Start

Double-click `GalaxyPluginScout.bat`. Then just follow the prompts:

1. Pick a language.
2. Pick a mode (below).
3. Pick a plugin from the list — or `[a]` for all of them at once.

The plugin picker has a `[b]` option to go back to mode selection, and after a run finishes you can jump straight into the next one without restarting the tool.

## Modes

| | What it does |
|---|---|
| **[1] Dry-run** | Preview only — dependency report, nothing is changed or installed. |
| **[2] Update** | Full maintenance: backup, remove unused modules, install/update libraries via pip. |
| **[3] Library check** | Compares installed libraries against PyPI and, if you confirm, updates them via pip — asked per library. Backs up `modules` before the first real change; skips the unused-module cleanup that Mode 2 does. |

Modes 2 and 3 are the ones that change files — both back up `modules` first and always ask for confirmation before installing anything.

**Which one do you actually need?** If you just downloaded a plugin from GitHub, you usually don't need Mode 2 — melcom already ran it before releasing the plugin, so the dependency tree is already resolved. Mode 3 is enough to keep libraries current. Mode 2 is for when the dependency tree itself changes, e.g. porting a plugin from 32-bit to 64-bit, where entirely different wheels and dependencies are pulled in.

## Output

- `logs\` — one file per run (or one combined file per `[a]` run)
- `plugin-config.txt` — generated updater input, written next to the script

## More

- Full change history: [CHANGELOG.md](CHANGELOG.md)
- License: MIT, see [LICENSE](LICENSE)