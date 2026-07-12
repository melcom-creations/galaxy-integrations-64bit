# Changelog

All notable changes to this project will be documented in this file.

---

## Version 0.1.0

### Added in Version 0.1.0

- **Initial release:** Introduces the Galaxy Plugin Updater.
- **Language selection:** Provides English and German output, including an exit option in the startup menu.
- **Plugin discovery:** Scans `%LOCALAPPDATA%\GOG.com\Galaxy\plugins\installed\` automatically.
- **Trust validation:** Verifies each `manifest.json` against the `melcom` author and `https://github.com/melcom-creations` URL. Untrusted plugins remain visible but are excluded from updates.
- **Release comparison:** Compares locally installed plugin versions with the latest GitHub release.
- **Automatic backups:** Creates a ZIP backup of the complete plugin folder before every update at `backups\<FolderName>\<FolderName>_YYYYMMDD_HHMMSS.zip`.
- **Battle.net credential backup:** Backs up `consts.py` when `CLIENT_ID` and `CLIENT_SECRET` contain values, then offers to restore the file after an update.
- **itch.io credential backup:** Backs up `credentials.json` when `access_token` contains a value, then offers to restore the file after an update.
- **Console output:** Uses colors for success, notices, errors, excluded plugins, and informational messages.
- **Run logs:** Creates a log for every run at `logs\update_YYYYMMDD_HHMMSS.log`.
- **Exit animation:** Shows a Matrix-style farewell animation after the run finishes.
- **GitHub token support:** Supports the optional `GITHUB_TOKEN` environment variable, increasing the GitHub API limit from 60 to 5,000 requests per hour.
- **Documentation:** Includes a README covering the workflow, backup structure, and known limitations.

### Planned for Future Versions

- **Individual plugin selection:** Select individual plugins instead of updating all trusted plugins at once.
- **Automatic cleanup:** Remove old backups and logs automatically.
- **Release verification:** Verify signatures of downloaded release assets.
