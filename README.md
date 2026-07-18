# Community Integrations for GOG Galaxy 2.1+ (64-bit)

This page provides a central overview of community integrations available for the native 64-bit version of GOG Galaxy 2.1+. It includes plugins maintained by me as well as compatible integrations from other developers. Each plugin remains in its own repository and is linked separately below. All integrations listed here are intended exclusively for the new 64-bit GOG Galaxy client.

---

## 🔄 Get the 64-bit GOG Galaxy Client

These integrations require the native 64-bit version of GOG Galaxy 2.1 or later. If you are still using an older 32-bit installation, download and install the latest Windows version from the [official GOG Galaxy website](https://www.gog.com/galaxy). Once the current 64-bit client is installed, you can use the integrations listed below.

---

## 🚀 64-bit Community Integration Status

The table below provides an overview of community integrations for the native 64-bit version of GOG Galaxy 2.1+. It includes plugins maintained by me as well as compatible integrations from other developers. Integrations that are not yet available are clearly marked as being in development.

| Integration | Maintainer | Status | Achievements | Game Time | Download |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Amazon Games** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-amazon) |
| **Battle.net** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-battlenet) |
| **Humble Bundle** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-humble) |
| **itch.io** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-itch) |
| **Steam** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-steam) |
| **Ubisoft Connect** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-uplay) |
| **EA app** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-ea) |
| **Rockstar Games Launcher** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-rockstar) |
| **IndieGala** | **melcom** | ⏳ In Development | ❌ | ⏳ | ⏳ |
| **PlayStation Network** | **multimediality** | ✅ Released | ✅ | ✅ | [Download](https://github.com/multimediality/gog-psn-integration) |
| **Legacy Games** | **pippo-san** | ✅ Released | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

**Legend:**

* ✅ = Implemented / Supported
* ❌ = Unsupported / Not implemented
* ⏳ = In development / Planned

---

## 📦 How to Install a Plugin

Each released integration is hosted in its own repository. Open the repository linked in the table above and read its installation instructions before downloading anything. The required release package and folder structure may differ between plugins.

1. Exit GOG Galaxy completely and make sure it is no longer running in the system tray.
2. Open the repository of the integration you want to install.
3. Go to its latest release and download the package intended for GOG Galaxy 2.1+ 64-bit. Do not use the automatically generated GitHub source code archives unless the repository explicitly instructs you to do so.
4. Follow the installation instructions provided in that repository. Unless stated otherwise, Windows plugins are extracted into:

   ```text
   %localappdata%\GOG.com\Galaxy\plugins\installed
   ```

5. Restart GOG Galaxy and connect the account through Settings -> Integrations.

---

## 🧰 Plugin Maintenance Tools

Both maintenance tools are located in the central [`/tools/` directory](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools) of this repository. They are available exclusively here and are no longer included separately with each plugin. Each tool serves a different purpose, so choose the one appropriate for the task.

### 🔄 melcom GOG Galaxy Plugin Updater

The [melcom GOG Galaxy Plugin Updater](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_updater) is the primary and recommended tool for most users. It detects supported melcom integrations installed on Windows, checks for newer releases, and can also install integrations that are still missing. Before every update, it creates a complete ZIP backup and records the process in a log.

The updater can preserve personal Battle.net and itch.io credentials during an update. When installing the Steam integration, it can also offer optional automatic startup support for Steam Achievement Notifier. No separate Python installation is required to use the updater.

### 🔬 Galaxy Plugin Scout - Advanced Users Only

[melcom's Galaxy Plugin Scout](https://github.com/melcom-creations/galaxy-integrations-64bit/tree/main/tools/melcom-galaxy_plugin_scout) analyzes and maintains the Python libraries inside the `modules` folders of my integrations. It provides a safe dry-run mode, a library update check, and a full maintenance mode that can remove unused modules and install required dependencies. Unlike the regular updater, it requires Python 3.13 64-bit with pip.

The Scout is intended for experienced users who understand Python dependencies and bundled plugin libraries. Its maintenance modes can modify the contents of a plugin, although backups are created before changes are made. It supports my own integrations only and must not be used to modify third-party plugins.

---

## ⚙️ Technical Compatibility

The native 64-bit version of GOG Galaxy 2.1+ runs community integrations with Python 3.13. My integrations are built and tested specifically for this environment and are not compatible with the older 32-bit GOG Galaxy 2.0 client. Third-party integrations listed on this page may have additional requirements, so always check their repository before installation.

---

## ❤️ Special Thanks

I want to take a moment to thank the people who kept me going during this intense development phase:

* A huge thank you to my friend [**Hustlefan**](https://www.gog.com/u/Hustlefan). Over the past few days, you've been much more than just moral support. You gave me the encouragement I needed, patiently put up with all my Discord spam, and helped beta test the plugins. I'm really happy that you're pleased with the results. Thanks so much for all your support, my friend.

* And a big thank you to my girlfriend [**Florence H.** (fl0H0815)](https://www.gog.com/u/Florence_Heart). While she was enjoying the good life at her parents' place - complete with air conditioning and a huge swimming pool - she kept my spirits up by sending me photos of herself, her friends, her parents, and even her parents' dog. She reminded me that there's a wonderful world outside of a code editor every now and then... 🙈

  *Now that's what I call real support.* ❤️

Thank you both for having my back!

---

## 🤝 Support & Feedback

This project is maintained by a single individual. Response times may vary, especially during periods when health-related limitations reduce available development time.

**GitHub Issues are intentionally disabled.**

If you would like to report a bug or suggest an improvement, please use the contact form on my website:

📩 [melcom's Contact Form](https://melcom-creations.github.io/melcom-music/contact.html)

Thank you for your patience and support!
