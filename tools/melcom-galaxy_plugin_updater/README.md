# melcom GOG Galaxy v2.1+ Plugin Updater v0.1.5

A colorized Windows command-line tool that keeps your melcom GOG Galaxy 2.1+ integrations up to date.

The supported plugins are available at [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit).

---

## ✨ Features

- Compatible with GOG Galaxy 2.1+ on Windows
- English and German interface
- Checks installed supported plugins for available updates
- Offers available integrations for installation when none are installed
- Includes IndieGala in the automatic installation catalog
- Offers to hook up automatic [Steam Achievement Notifier](https://github.com/SteamAchievementNotifier/SteamAchievementNotifier) startup when installing the Steam plugin
- Creates a ZIP backup before every update
- Refuses to change plugin files while GOG Galaxy is still running
- Validates downloaded release archives before replacing an installed plugin
- Leaves externally stored Battle.net and itch.io authentication untouched
- Colorized output and a log for every run
- Optional GitHub token support for a higher API limit

---

## 📦 Installation and Usage

1. Download and extract the release ZIP to any folder.
1. Keep `update-plugins.bat` and `update-plugins-helpers.ps1` together in that folder.
1. Close GOG Galaxy completely, including the system tray application.
1. Double-click `update-plugins.bat`.
1. Select English or German, then review the displayed plugins.
1. Confirm the update when you are ready.

If one or more supported integrations are installed, the updater asks whether you want to install additional ones. If none are installed, it opens the installation list directly. Choose one integration by number, choose `a` to install all missing integrations, or choose `n` to continue to the update check.

The updater automatically looks for plugins in:

```text
%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed\
```

> **Important:** Do not move or rename `update-plugins-helpers.ps1`. The batch file needs it in the same folder.

Older melcom integrations with incomplete manifest data are marked separately. The updater can back up and replace a recognized older integration with its current release.

---

## 🔄 Updates, Backups, and Logs

The updater checks your installed supported plugins, skips plugins that are already current, and creates a complete ZIP backup before installing an available update. First-time installations do not overwrite existing plugin folders.

Before changing plugin files, the updater verifies that GOG Galaxy is fully closed. It also validates the downloaded archive's repository, plugin GUID, version, project URL, manifest, and entry script. The new files are prepared separately and swapped into place only after those checks succeed. If the final replacement fails, the previous plugin folder is restored automatically.

Backups and logs are created next to `update-plugins.bat` and `update-plugins-helpers.ps1`, in the `backups` and `logs` folders.

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
