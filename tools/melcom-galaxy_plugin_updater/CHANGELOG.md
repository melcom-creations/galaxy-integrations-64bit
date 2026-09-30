# Changelog

All notable changes to this project will be documented in this file.

---

## Version 0.1.6

### Added in Version 0.1.6

- **Optional self-updates:** After language selection, choose whether to check for a newer updater. Installation requires a separate confirmation. Declining either prompt continues to the plugins. Check results remain visible until you continue.
- **Recoverable previous versions:** After a successful self-update, the previous version goes to the Windows Recycle Bin. If replacement fails, the updater restores the previous files or keeps recovery copies and displays their location.

### Improved in Version 0.1.6

- **Clearer plugin overview:** Installed versions appear next to integration names. Installation and updates are limited to the nine supported, published melcom integrations; other integrations remain untouched.
- **More reliable backups and updates:** Backups include hidden files and use unique filenames. Network requests have time limits, and failed checks stop the affected operation with an error message.
- **Recoverable cleanup:** Replaced files and temporary cleanup files go to the Windows Recycle Bin. If recycling is unavailable, files are retained instead of permanently deleted.
- **Tidier folder layout:** The main folder contains only the BAT, README.md, and CHANGELOG.md. Supporting scripts are in `scripts`, and the license is in `licenses`.
- **Clearer instructions:** The README explains setup, supported integrations, and how to update the tool itself.

Existing features, including English and German menus, plugin installation and updates, backups and rollback, Steam Achievement Notifier support, and the complete Matrix farewell, remain available.

---

## Version 0.1.5

### Changed in Version 0.1.5

- **External Battle.net and itch.io authentication:** Removed the obsolete checks, prompts, separate backups, and restore operations for Battle.net `consts.py` and itch.io `credentials.json`. Current plugin versions keep personal authentication outside their plugin folders, so regular plugin updates leave it untouched.
- **Full plugin backups remain unchanged:** The updater still creates a complete ZIP backup of every installed plugin before replacing it and still restores the previous plugin folder automatically if final replacement fails.
- **Documentation updated:** The README now explains the external authentication behavior and the possible one-time guided setup when upgrading from an older plugin release.

---

## Version 0.1.4

### Added in Version 0.1.4

- **IndieGala installation support:** Added the IndieGala integration to the built-in installation catalog, so it can now be installed through the updater as well as updated when already present.

### Changed in Version 0.1.4

- **Galaxy runtime safety check:** Plugin installations and updates are blocked while the interactive GOG Galaxy client, tray application, or communication process is still running. The persistent `GalaxyClientService` Windows service is intentionally not treated as an open client.
- **Validated release archives:** Before an installed plugin is touched, the updater now verifies the trusted GitHub source and checks the archive's manifest, repository, project URL, GUID, version, and entry script.
- **Safer plugin replacement:** Downloaded files are prepared separately before installation. Existing plugin files are moved aside only for the final replacement and are restored automatically if that replacement fails.
- **Clearer failure details:** Archive validation and installation errors are now included in the updater output and log.

---

## Version 0.1.3

### Added in Version 0.1.3

- **Optional cleanup of old logs and backups:** On startup, the tool checks separately whether any log files or any backup files are older than 60 days. If either is the case, a short explanation is shown first, then it asks once per category (logs and backups are asked about independently, so either can be kept while the other is cleared) whether to delete them. Nothing is shown or asked if there is nothing old to delete, and nothing is deleted without confirmation. Deleted files go to the Windows Recycle Bin rather than being removed permanently, and every deleted file's full path is written to the log (the on-screen summary still only shows a count, to keep the console output short).

### Fixed in Version 0.1.3

- **Tool failed with "'powershell' is not recognized as an internal or external command":** On systems where the PATH environment variable does not include the Windows System32 folder (broken PATH, restrictive policy, etc.), every PowerShell call in the tool failed immediately, most visibly during the initial plugin scan, so no plugins were ever detected. The tool now resolves the full path to `powershell.exe` directly instead of relying on PATH, so it no longer depends on PowerShell being reachable through the PATH variable. The resolved path is used unquoted at each call site (it never contains spaces) to avoid a `cmd.exe` quirk where a `for /f` command that both starts and ends with a quote gets its outer quotes stripped, which would otherwise corrupt the command and break every update check and backup.

---

## Version 0.1.2

### Added in Version 0.1.2

- **Steam Achievement Notifier integration:** When installing the Steam plugin for the first time, offers to build in automatic Steam Achievement Notifier startup, so it no longer needs to be launched manually and loads automatically whenever a Steam game starts.
- **Integration toggle on update:** When updating a Steam plugin that already has this integration, asks whether to keep it. Declining removes the related code from the updated plugin. Re-running the updater afterwards offers the one-time integration prompt again.

### Fixed in Version 0.1.2

- **Steam Achievement Notifier integration was not actually added:** When the Steam plugin was already up to date and did not yet contain the Steam Achievement Notifier code, confirming the offer to add it only displayed a confirmation message without changing `plugin.py`. The updater now inserts the marker-wrapped `NOTIFIER_PATH` constant, the `_launch_external_notifier` method, and its call site into `plugin.py`, so the integration is actually added. Removing an existing integration was not affected by this issue.
- **English "y" was accepted in the German interface:** Every yes/no prompt accepted both `y` and `j` regardless of the selected language, even though the German interface only ever displays `[j]`. Confirmation now only accepts the letter shown on screen for the active language (`y` in English, `j` in German).
- **A mistyped answer at the main update confirmation could silently abort the run:** The main confirmation prompt only displays `[y]/[j]`, `[b]`, and `[x]`, but the code also silently accepted `n` as an undocumented shortcut for exiting - a stray keystroke could end the program without warning. This hidden shortcut has been removed; the prompt now only accepts the options it actually displays, and anything else redraws the screen and asks again, exactly like every other menu.
- **Some yes/no prompts accepted anything as a silent "no":** The prompts asking to back up or restore `consts.py`/`credentials.json` did not validate input at all - a typo was silently treated as "no" and the run continued without asking again. These prompts now use the same strict validation as the rest of the tool and keep asking until a valid answer is given.

---

## Version 0.1.1

### Added in Version 0.1.1

- **Integration installation:** Offers missing integrations for individual or complete installation when no supported integration is installed.
- **Legacy integration handling:** Detects older melcom manifests with incomplete metadata and offers a backed-up replacement with the current release.
- **Plugin folder creation:** Creates the GOG Galaxy plugin folder automatically when it does not already exist, and first-time installations no longer overwrite existing plugin folders.

---

## Version 0.1.0

### Added in Version 0.1.0

- **Initial release:** Introduces the Galaxy Plugin Updater.
- **Plugin discovery and trust validation:** Scans installed plugins and verifies each manifest against the melcom author and repository URL.
- **Release comparison:** Compares locally installed plugin versions with the latest GitHub release.
- **Automatic backups:** Creates a ZIP backup of the complete plugin folder before every update.
- **Battle.net credential backup:** Backs up `consts.py` when `CLIENT_ID` and `CLIENT_SECRET` contain values, then offers to restore the file after an update.
- **itch.io credential backup:** Backs up `credentials.json` when `access_token` contains a value, then offers to restore the file after an update.
- **GitHub token support:** Supports the optional `GITHUB_TOKEN` environment variable, increasing the GitHub API limit from 60 to 5,000 requests per hour.
