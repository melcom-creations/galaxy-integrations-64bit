# Changelog

All notable changes to this project will be documented in this file.

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
