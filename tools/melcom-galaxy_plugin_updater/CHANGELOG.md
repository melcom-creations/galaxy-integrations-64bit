# Changelog

All notable changes to this project will be documented in this file.

---

## Version 0.1.1

### Added in Version 0.1.1

- **Integration installation:** Offers missing integrations for individual or complete installation when no supported integration is installed.
- **Installation prompt:** When supported integrations are already installed, shows their count and asks whether to install additional integrations before continuing to updates.
- **Update continuation:** Allows returning from the installation list to the normal update check.
- **Legacy integration handling:** Detects older melcom manifests with incomplete metadata and offers a backed-up replacement with the current release.
- **Plugin folder creation:** Creates the GOG Galaxy plugin folder when it does not already exist.

---

## Version 0.1.0

### Added in Version 0.1.0

- **Initial release:** Introduces the Galaxy Plugin Updater.
- **Language selection:** Provides English and German output, including an exit option in the startup menu.
- **Plugin discovery:** Detects installed supported integrations and leaves unrelated plugins unchanged.
- **Release comparison:** Compares locally installed plugin versions with the latest GitHub release.
- **Automatic backups:** Creates a ZIP backup of the complete plugin folder before every update.
- **Battle.net credential backup:** Backs up `consts.py` when `CLIENT_ID` and `CLIENT_SECRET` contain values, then offers to restore the file after an update.
- **itch.io credential backup:** Backs up `credentials.json` when `access_token` contains a value, then offers to restore the file after an update.
- **Console output:** Uses colors for success, notices, errors, excluded plugins, and informational messages.
- **Run logs:** Creates a log for every run.
- **Exit animation:** Shows a Matrix-style farewell animation after the run finishes.
- **GitHub token support:** Supports the optional `GITHUB_TOKEN` environment variable, increasing the GitHub API limit from 60 to 5,000 requests per hour.
- **Documentation:** Includes a README covering the workflow, backup structure, and credential safety.
