# melcom GOG Galaxy v2.1+ Plugin Updater v0.1.6

A colorized Windows command-line tool that keeps your melcom GOG Galaxy 2.1+ integrations up to date.

The supported plugins are available at [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit).

---

## ✨ Features

- Compatible with GOG Galaxy 2.1+ on Windows
- English and German interface
- Optional updater update check, with a separate confirmation before installation
- Sends replaced updater versions and cleanup files to the Windows Recycle Bin; never falls back to permanent deletion
- Checks installed supported plugins for available updates
- Offers available integrations for installation when none are installed
- Includes IndieGala in the automatic installation catalog
- Offers to hook up automatic [Steam Achievement Notifier](https://github.com/SteamAchievementNotifier/SteamAchievementNotifier) startup when installing the Steam plugin
- Creates a ZIP backup before every update
- Refuses to change plugin files while GOG Galaxy is still running
- Validates downloaded release archives before replacing an installed plugin
- Leaves externally stored Battle.net and itch.io authentication untouched
- A compact plugin overview with installed versions, colorized output, and a log for every run
- Matrix-style farewell animation, including the "Follow melcom." effect
- Optional GitHub token support for a higher API limit

---

## 📦 Installation and Usage

1. Download and fully extract the release ZIP to a writable folder, such as Downloads. Do not run it from inside the ZIP.
1. Keep the extracted folder structure: the BAT and both Markdown files are in the main folder, PowerShell and C# files are in `scripts`, and `LICENSE` is in `licenses`.
1. Close GOG Galaxy completely, including the system tray application.
1. Double-click `update-plugins.bat`.
1. Select English or German, then review the displayed plugins.
1. Confirm the update when you are ready.

If one or more supported integrations are installed, the updater asks whether you want to install additional ones. If none are installed, it opens the installation list directly. Choose one integration by number, choose `a` to install all missing integrations, or choose `n` to continue to the update check.

No Python installation, PowerShell 7, administrator rights, or GitHub account is required. The tool uses Windows PowerShell 5.1 included with Windows 10 and 11. It works with the current Windows user's Galaxy installation.

Supported integrations: Amazon Games, Battle.net, Humble Bundle, IndieGala, itch.io, EA app, Rockstar Games, Steam, and Ubisoft Connect. Legacy Games belongs to another maintainer and is excluded. Unreleased integrations such as ZOOM are also excluded. "Legacy" replacement prompts refer only to older supported melcom integrations, not to Legacy Games.

The updater automatically looks for plugins in:

```text
%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed\
```

> **Important:** Extract the complete ZIP. Keep the `scripts` and `licenses` subfolders alongside the batch file. The C# file provides the Windows Recycle Bin interface; no additional compiler installation is required.

Older melcom integrations with incomplete manifest data are marked separately. The updater can back up and replace a recognized older integration with its current release.

---

## Updating the Updater

After you select a language, the updater asks whether you want to check for updates to the tool itself. Choose No or press Enter to go directly to the plugins without a self-update network request. If you choose Yes, it checks the ZIP files in [the official updater folder](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_updater). It compares numeric versions from filenames such as `melcom-galaxy_plugin_updater-v0.1.7.zip` and offers only newer versions. This does not depend on GitHub Releases.

If a newer version is found, a second prompt asks whether to install it. Choose Yes to download, validate, install, and restart the new version in the same window. Choose No or press Enter to keep using the installed version. If the updater is current or the check fails, the result stays visible until you press Enter. An unavailable network or GitHub API does not prevent normal plugin updates from continuing.

The download must match GitHub's recorded size and Git blob hash. The updater also checks the ZIP contents, version, and PowerShell syntax before replacing its own files. Only the seven updater release files are replaced. Plugin backups, logs, and other files in the folder remain untouched.

After successful replacement, the complete previous version is sent to the Windows Recycle Bin. If that is unavailable, the previous files remain in the displayed `.self-update` recovery directory. A failed replacement restores the previous files; a failed restoration leaves the recovery copies in place and stops. There is no permanent-delete fallback. The same recycle-only rule applies to plugin update staging files and cleanup files.

Self-updating requires a writable folder on a local fixed drive. Linked folders and network/removable drives are not supported for automatic replacement. On those locations, keep using the tool and install updater releases manually. Version 0.1.5 and earlier need one manual installation of v0.1.6 to gain this feature.

For maintainers: publish a ZIP containing exactly the seven release files with the same `scripts` and `licenses` subfolders. The BAT and both Markdown files must be at the ZIP root. Keep the `UPDATER_VERSION` value in the batch file, the README version, and the ZIP filename consistent. No separate update manifest or GitHub Release is required.

---

## 🔄 Updates, Backups, and Logs

The updater checks your installed supported plugins, skips plugins that are already current, and creates a complete ZIP backup, including hidden files, before installing an available update. Every backup has a unique filename. First-time installations do not overwrite existing plugin folders.

Before changing plugin files, the updater verifies that GOG Galaxy is fully closed. It also validates the downloaded archive's repository, plugin GUID, version, project URL, manifest, and entry script. The new files are prepared separately and swapped into place only after those checks succeed. If the final replacement fails, the previous plugin folder is restored automatically.

Backups and logs are created next to `update-plugins.bat`, in the `backups` and `logs` folders.

On startup, the tool checks separately whether any logs or any backups are older than 60 days and, if so, asks once per category whether to delete them. Logs and backups are asked about independently, so you can clear one and keep the other. Nothing is deleted without confirmation, and nothing is asked if there is nothing old to delete.

---

## 🏆 Steam Achievement Notifier Integration

[Steam Achievement Notifier](https://github.com/SteamAchievementNotifier/SteamAchievementNotifier) is a free third-party tool that pops up a notification whenever you unlock a Steam achievement. It normally has to be started by hand before you launch a game.

When installing the Steam plugin for the first time, the updater offers to add a small piece of code to `plugin.py` so Steam Achievement Notifier starts automatically whenever you launch a Steam game from the GOG Galaxy client - no more starting it manually. If you already have this integration and later run an update, the updater asks whether to keep it; declining removes the code again.

> **Note:** This only wires up automatic startup. Steam Achievement Notifier itself is a separate tool and must be downloaded and installed on its own from the link above.

---

## 🔐 External Battle.net and itch.io Authentication

Current Battle.net and itch.io plugin versions store personal authentication outside their plugin folders under `%LOCALAPPDATA%\melcom-creations\GOG Galaxy Integrations\`.

The updater no longer reads, separately backs up, or restores `consts.py` and `credentials.json`. Updating either plugin leaves its external authentication file untouched. The normal complete plugin ZIP backup is still created before every update.

When updating an older plugin release that still stored credentials inside the plugin folder, the guided setup may appear once after the update. Follow the displayed instructions to save the authentication in its new external location.

---

## 🔑 GitHub API Rate Limit

GitHub allows a limited number of unauthenticated requests. If you encounter `403 Forbidden` messages repeatedly, you can use a personal GitHub access token to raise the limit.

Create a token with no special permissions and set it before starting the updater:

```powershell
setx GITHUB_TOKEN "ghp_your_token_here"
```

Open a new terminal window, or sign out and back in, after setting the variable.
