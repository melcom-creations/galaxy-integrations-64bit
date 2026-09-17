# Community Integrations for GOG Galaxy 2.1+ (64-bit)

This repository provides a central overview of community integrations compatible with GOG Galaxy 2.1+ 64-bit. Each integration remains in its own repository and is linked in the table below.

[Integrations](#-64-bit-community-integration-status) | [Installation](#-installation) | [Tools](#-plugin-maintenance-tools) | [Troubleshooting](#-troubleshooting) | [Support & Feedback](#-support--feedback)

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
| **IndieGala** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-indiegala) |
| **Legacy Games** | **pippo-san** | ✅ Released | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

> [!IMPORTANT]
> For questions or problems, contact the maintainer listed for the affected integration.
>
> Developers who want their own plugin listed here must [contact me](https://github.com/melcom-creations/galaxy-integrations-64bit#-support--feedback) directly. I only add plugins that are actively maintained and whose developers support their users.

✅ Supported · ❌ Not supported · ⏳ Planned or in development

---

## 📦 Installation

### 🔄 Automatic Installation with Plugin Updater (Recommended)

Use the [melcom GOG Galaxy Plugin Updater](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_updater) for integrations supported by the tool.

1. Download and extract the Plugin Updater.
2. Double-click `update-plugins.bat`.
3. Select your preferred language and follow the displayed instructions.

### 📂 Manual Installation

1. Close GOG Galaxy completely, including the system tray application.
2. Open the integration's repository using the **Download** link in the table, then download its latest 64-bit package from **Releases**.
3. Extract the plugin folder into:

   ```text
   %localappdata%\GOG.com\Galaxy\plugins\installed
   ```

   `manifest.json` must be directly inside the extracted plugin folder, without an extra nested folder.
4. Start GOG Galaxy and connect the account through **Settings -> Integrations**.

**Next step:** Follow the integration's README for any required setup and the first synchronization. Battle.net and itch.io require personal authentication setup; other integrations may ask you to configure game folders.

Keep backup copies of plugin folders outside `plugins\installed`. Duplicate folders can cause conflicts when Galaxy loads integrations.

---

## 🧰 Plugin Maintenance Tools

Both maintenance tools are available exclusively from this repository's [`/tools/` directory](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools).

### 🔄 melcom GOG Galaxy Plugin Updater

The [melcom GOG Galaxy Plugin Updater](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_updater) is the recommended Windows tool for installing and updating supported integrations. It creates a complete plugin ZIP backup and a log before each update, and offers optional Steam Achievement Notifier startup support. No separate Python installation is required.

Current Battle.net and itch.io plugin versions store personal authentication data outside the plugin folder. Plugin updates do not overwrite these files. See each integration's README for setup and storage details.

### 🔬 Galaxy Plugin Scout - Advanced Users Only

[melcom's Galaxy Plugin Scout](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_scout) is an advanced tool for analyzing and maintaining Python libraries inside plugin `modules` folders. It provides a dry-run mode, library update checks, and maintenance that can remove unused modules and install required dependencies. It creates backups before making changes and requires Python 3.13 64-bit with pip.

---

## ⚙️ Technical Compatibility

All integrations listed on this page are intended for GOG Galaxy 2.1+ 64-bit, which uses Python 3.13 for community plugins. They are not compatible with the older 32-bit GOG Galaxy 2.0 client; check the linked repository for any additional requirements.

---

## 🛠️ Troubleshooting

First restart Galaxy and the required store client, then try one synchronization. Check the affected integration's README for known limitations and specific troubleshooting steps.

### 🧪 Create a Fresh Diagnostic Log

Before contacting the maintainer, create a fresh plugin log. Old logs may contain information from previous sessions. A database reset is not required to collect a log.

1. Close GOG Galaxy completely, including the system tray application.
2. Open the logs directory:

   ```text
   %ProgramData%\GOG.com\Galaxy\logs
   ```

3. Find the affected integration's log; its README gives the exact filename. Move the existing log to a backup folder outside this directory, if present. Leave other integrations' logs in place.
4. Start the required store client and Galaxy, reproduce the problem, then close Galaxy completely so the new log is fully written.
5. Send only the newly created log for the affected integration, not the entire folder.

Include the affected integration, plugin and Galaxy versions, the exact steps taken, the expected and actual result, and whether the problem can be reproduced.

Without a fresh plugin log and a detailed description, I cannot reliably determine what is causing the problem.

### 🔄 Reset Plugin Storage (Last Resort)

If a reset is necessary, follow the affected integration's README and preserve its database as a backup. A reset can affect cached library data, locally tracked playtime, or the login session. Do not delete databases belonging to other integrations.

For integrations maintained by **melcom**, continue with [Support & Feedback](#-support--feedback). For other integrations, contact the maintainer listed in the table.

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

Before contacting me about an integration maintained by **melcom**, follow [Troubleshooting](#-troubleshooting) and prepare a fresh plugin log with a detailed description.

* **GOG:** Send me a message or add me as a friend through my [GOG profile](https://www.gog.com/u/melcom).
* **Email:** `melcom @ gmx.net`
* **Discord:** `.melcom` - the leading dot is part of the username. You can send me a message or add me as a friend.

Logs can be attached directly or shared using an accessible cloud storage link, such as Dropbox, OneDrive, Google Drive, or a similar service.

Response times may vary depending on my health and available development time. Thank you for your understanding.
