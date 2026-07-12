# Changelog

All notable changes to this project will be documented in this file.

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
