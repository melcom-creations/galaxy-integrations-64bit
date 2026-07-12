# melcom's Galaxy Plugin Updater v0.1.0

A colorized Windows command-line tool that keeps your melcom GOG Galaxy 2.1+ integrations up to date.

The supported plugins are available at [melcom-creations/galaxy-integrations-64bit](https://github.com/melcom-creations/galaxy-integrations-64bit).

---

## ✨ Features

- Compatible with GOG Galaxy 2.1+ on Windows
- English and German interface
- Checks installed supported plugins for available updates
- Creates a ZIP backup before every update
- Preserves Battle.net and itch.io credentials when needed
- Colorized output and a log for every run
- Optional GitHub token support for a higher API limit

---

## 📦 Installation and Usage

1. Download and extract the release ZIP to any folder.
1. Keep `update-plugins.bat` and `update-plugins-helpers.ps1` together in that folder.
1. Double-click `update-plugins.bat`.
1. Select English or German, then review the displayed plugins.
1. Confirm the update when you are ready.
1. Answer any credential-restoration prompts after an update.

The updater automatically looks for plugins in:

```text
%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed\
```

> **Important:** Do not move or rename `update-plugins-helpers.ps1`. The batch file needs it in the same folder.

---

## 🔄 Updates, Backups, and Logs

The updater checks your installed supported plugins, skips plugins that are already current, and creates a complete ZIP backup before installing an available update.

Backups and logs are created next to `update-plugins.bat` and `update-plugins-helpers.ps1`, in the `backups` and `logs` folders.

---

## 🔐 Battle.net and itch.io Credentials

The Battle.net plugin can use personal credentials in `consts.py`, while the itch.io plugin can use a personal access token in `credentials.json`.

When active credentials are found, the updater creates an additional backup before updating and offers to restore the file afterwards. This allows both integrations to keep working without requiring you to enter the credentials again.

> **Security:** Never upload, post, or send `consts.py` or `credentials.json` to anyone. These files can contain personal authentication data.

---

## 🔑 GitHub API Rate Limit

GitHub allows a limited number of unauthenticated requests. If you encounter `403 Forbidden` messages repeatedly, you can use a personal GitHub access token to raise the limit.

Create a token with no special permissions and set it before starting the updater:

```powershell
setx GITHUB_TOKEN "ghp_your_token_here"
```

Open a new terminal window, or sign out and back in, after setting the variable.
