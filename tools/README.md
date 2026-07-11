# melcom's Galaxy Plugin Scout

**Latest version: v1.2.0** — `GalaxyPluginScout_v1.2.0.zip` below. Older versions, if any, live under [`old/`](old/) and are kept only for reference; always grab the one listed here.

A Windows tool that analyzes and updates the Python libraries bundled inside a GOG Galaxy plugin's `modules` folder — built for keeping melcom's plugins current, and for the heavier lifting of porting one from 32-bit to 64-bit.

**Scope:** melcom's own GOG Galaxy plugins only (Amazon Games, Battle.net, EA app, Rockstar, Steam, Ubisoft Connect, Humble Bundle, itch.io).

## Download

Grab `GalaxyPluginScout_v1.2.0.zip`, extract it anywhere, then double-click `GalaxyPluginScout.bat` inside. Full instructions, changelog, and license are included in the zip.

## Requirements

- Windows 10/11 (64-bit), PowerShell 5.1+
- GOG Galaxy 2.1+
- [Python 3.13 (64-bit) with pip](https://www.python.org/downloads/windows/)

## What it does

Three modes, picked interactively when you start the tool:

| | What it does |
|---|---|
| **Dry-run** | Preview only — dependency report, nothing is changed or installed. |
| **Update** | Full maintenance: backup, remove unused modules, install/update libraries via pip. |
| **Library check** | Compares installed libraries against PyPI and, if you confirm, updates them via pip. |

**Which one do you actually need?** If you just downloaded a plugin from this repo, you usually only need the Library check — the plugin's dependency tree is already resolved. Update is for structural changes, like porting a plugin to 64-bit, where the dependencies themselves change.

## License

MIT — see `LICENSE` inside the zip.