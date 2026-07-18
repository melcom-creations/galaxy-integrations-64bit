# Community Integrations for GOG Galaxy 2.1+ (64-bit)

This repository provides a central overview of community integrations compatible with GOG Galaxy 2.1+ 64-bit. Each integration remains in its own repository and is linked in the table below.

---

## 🔄 Get the 64-bit GOG Galaxy Client

These integrations require the native 64-bit version of GOG Galaxy 2.1 or later. If you still use an older 32-bit installation, download the latest Windows client from the [official GOG Galaxy website](https://www.gog.com/galaxy).

---

## 🚀 64-bit Community Integration Status

| Integration | Maintainer | Status | Achievements | Game Time | Download |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Amazon Games** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-amazon) |
| **Battle.net** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-battlenet) |
| **Humble Bundle** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-humble) |
| **itch.io** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-itch) |
| **Steam** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-steam) |
| **Ubisoft Connect** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-uplay) |
| **EA app** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-ea) |
| **Rockstar Games** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-rockstar) |
| **IndieGala** | **melcom** | ⏳ In Progress (Qt6 issue) | ❌ | ⏳ | ⏳ |
| **PlayStation Network** | **multimediality** | ✅ Released | ✅ | ✅ | [Download](https://github.com/multimediality/gog-psn-integration) |
| **Legacy Games** | **pippo-san** | ✅ Released | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

> [!IMPORTANT]
> This repository is an overview, not a central support hub. For questions and bug reports, contact the maintainer listed in the table. I provide support only for integrations maintained by **melcom**.

✅ Supported · ❌ Not supported · ⏳ Planned or in development

---

## 📦 How to Install a Plugin

1. Close GOG Galaxy completely, including the system tray application.
2. Use the **Download** link in the table and download the latest 64-bit release.
3. Extract the plugin folder into:

   ```text
   %localappdata%\GOG.com\Galaxy\plugins\installed
   ```

4. Start GOG Galaxy and connect the account through **Settings -> Integrations**.

---

## 🧰 Plugin Maintenance Tools

Both maintenance tools are available exclusively from this repository's [`/tools/` directory](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools).

### 🔄 melcom GOG Galaxy Plugin Updater

The [melcom GOG Galaxy Plugin Updater](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_updater) is the recommended Windows tool for installing missing integrations and updating existing ones. It creates a ZIP backup and log before each update, can preserve Battle.net and itch.io credentials, and offers optional Steam Achievement Notifier startup support. No separate Python installation is required.

### 🔬 Galaxy Plugin Scout - Advanced Users Only

[melcom's Galaxy Plugin Scout](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_scout) is an advanced tool for analyzing and maintaining Python libraries inside plugin `modules` folders. It provides a dry-run mode, library update checks, and maintenance that can remove unused modules and install required dependencies. It creates backups before making changes, requires Python 3.13 64-bit with pip, and must not be used on third-party plugins.

---

## ⚙️ Technical Compatibility

These integrations target GOG Galaxy 2.1+ 64-bit, which uses Python 3.13 for community plugins. They are not compatible with the older 32-bit GOG Galaxy 2.0 client; check the linked repository for any additional requirements.

---

## 🛠️ What to Do If a Plugin Has Problems

Before reporting a problem, create fresh diagnostic files. Old logs may contain information from previous sessions and often do not show the current problem.

1. Close GOG Galaxy completely, including the system tray application.
2. Open the following directory and delete the existing log files:

   ```text
   %ProgramData%\GOG.com\Galaxy\logs
   ```

3. Open the plugin storage directory and delete only the `-storage.db` file belonging to the affected integration:

   ```text
   C:\ProgramData\GOG.com\Galaxy\storage\plugins
   ```

   Do not delete database files belonging to other integrations. If you are unsure which file is correct, do not delete anything from this directory.
4. Start GOG Galaxy, reproduce the problem, and close the client completely again so the new log is fully written.
5. Return to the logs directory and send only the newly created log belonging to the affected integration, not the entire folder.

Include the affected integration, the exact steps taken, the expected and actual result, and whether the problem can be reproduced.

Without a fresh plugin log and a detailed description, I cannot reliably determine what is causing the problem.

Once everything is ready, continue with [Support & Feedback](#-support--feedback) for contact options.

---

## ❤️ Special Thanks

I want to take a moment to thank the people who kept me going during this intense development phase:

* A huge thank you to my friend [**Hustlefan**](https://www.gog.com/u/Hustlefan). Over the past few days, you've been much more than just moral support. You gave me the encouragement I needed, patiently put up with all my Discord spam, and helped beta test the plugins. I'm really happy that you're pleased with the results. Thanks so much for all your support, my friend.

* And a big thank you to my girlfriend [**Florence H.** (fl0H0815)](https://www.gog.com/u/Florence_Heart). While she was enjoying the good life at her parents' place - complete with air conditioning and a huge swimming pool - she kept my spirits up by sending me photos of herself, her friends, her parents, and even her parents' dog. She reminded me that there's a wonderful world outside of a code editor every now and then... 🙈

  *Now that's what I call real support.* ❤️

Thank you both for having my back!

---

## 🤝 Support & Feedback

**GitHub Issues are intentionally disabled.** Health-related limitations prevent me from reliably managing separate issue trackers across all of my plugin repositories.

Before contacting me, follow **What to Do If a Plugin Has Problems** and prepare a fresh plugin log with a detailed description.

* **GOG:** Send me a message or add me as a friend through my [GOG profile](https://www.gog.com/u/melcom).
* **Email:** `melcom @ gmx.net`
* **Discord:** `.melcom` - the leading dot is part of the username. You can send me a message or add me as a friend.

Logs can be attached directly or shared through Dropbox or OneDrive. These contact options apply only to integrations maintained by **melcom**; for third-party integrations, contact the maintainer listed in the table.

Response times may vary depending on my health and available development time. Thank you for your understanding.
