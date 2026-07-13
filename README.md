# Community Integrations for GOG Galaxy 2.1+ (64-bit)

> **Notice:** This page is currently a preview to share ongoing progress and inform you about what is coming soon. Official releases will be linked here as they become available.

GOG Galaxy is quietly moving to a native 64-bit client, and a lot of community integrations were never built with that in mind. Old 32-bit assumptions, outdated dependencies, deprecated APIs on the platform side - all of it adds up to plugins that simply stop working the moment you switch.

This repository is my attempt to keep that from happening. It is a collection of community integrations that have been rebuilt, dependency by dependency, for the **native 64-bit version of GOG Galaxy 2.1+** - so the tools you are used to keep working instead of quietly breaking under you.

---

## 🔄 Get the 64-bit GOG Galaxy Client

Before any of the integrations below will do you any good, you need the 64-bit client itself. If you are still on GOG Galaxy 2.0, here is how to switch:

<img src="images/screenshot_2026-07-06%20042105.png" alt="How to enable the 64-bit GOG Galaxy client" width="500">

1. Open GOG Galaxy's settings (the gear icon) and go to **General**.
2. Under **Experimental features and updates**, enable **"Be the first to try out new features and help us improve them"** (see the highlighted areas in the screenshot above).
3. Wait a few minutes, or click the gear icon again and choose **Check for updates**.
4. Give it another 2 to 4 minutes. If no update shows up in that time, restart GOG Galaxy.
5. Shortly after restarting, you should see a notification that an update is available. Installing it takes you from the 32-bit version to the native 64-bit version.

Once GOG Galaxy has updated itself to the native 64-bit build, you are ready for the integrations below.

---

## 🚀 Supported Integrations & Status

The following integrations have been updated and validated for the 64-bit client.

| Integration | Maintainer | Status | Achievements | Game Time | Download |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Amazon Games** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-amazon) |
| **Battle.net** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-battlenet) |
| **Humble Bundle** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-humble) |
| **itch.io** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-itch) |
| **Steam** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-steam) |
| **Ubisoft Connect** | **melcom** | ✅ Released | ❌ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-uplay) |
| **EA App** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-ea) |
| **Rockstar Games** | **melcom** | ✅ Released | ✅ | ✅ | [Download](https://github.com/melcom-creations/galaxy-integration-rockstar) |
| **IndieGala** | **melcom** | ⏳ In Progress (Qt6 issue) | ❌ | ⏳ | ⏳ |
| **PlayStation** | **multimediality** | ✅ Released | ✅ | ✅ | [Download](https://github.com/FriendsOfGalaxy/galaxy-integration-psn) |
| **Legacy Games** | **pippo-san** | ✅ Released | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

**Legend:**
* ✅ = Implemented / Supported
* ❌ = Unsupported / Not implemented
* ⏳ = Planned

---

## 📦 How to Install a Plugin

Each entry in the table above is one of my plugins, hosted in its own repository. Clicking **Download** takes you to that plugin's GitHub page, where the actual release ZIP is available.

1. **Exit GOG Galaxy** completely (ensure it is not running in the system tray).
2. Click **Download** next to the integration you want and open that plugin's repository.
3. Grab the latest release ZIP from there.
4. Extract the contents into the GOG Galaxy plugins folder:
   * **Windows:** `%localappdata%\GOG.com\Galaxy\plugins\installed`
5. **Restart GOG Galaxy** and connect your accounts via **Settings -> Integrations**.

---

## 🧰 Keeping the Bundled Libraries Up to Date

Every one of **my** integrations - meaning any row in the table above where the maintainer is listed as **melcom** - ships with a small `/tools/` folder. It is easy to miss, but worth knowing about if you plan to keep one of my plugins installed for a while.

Inside is **Galaxy Plugin Scout** - a PowerShell tool I built specifically for the plugin structure used in my own repositories. It does not update the plugin itself, but the Python libraries bundled inside it under `/modules/`. Point it at an installed plugin folder and it will:

* scan the plugin and resolve its actual Python dependency tree,
* tell you exactly which libraries in `/modules/` are still needed, which are just taking up space, and which are missing,
* back up the plugin before touching anything,
* and fetch the correct Python 3.13 64-bit versions of anything that needs updating.

In short: if a plugin's bundled libraries ever fall behind - now, in six months, or whenever GOG Galaxy or a platform API changes underneath it - you do not need to wait for me to push a new release. Run the Scout, review its report, and update the libraries yourself. There is also a dry-run mode if you just want to see what it would do before committing to any changes.

You will find the current build of the tool, together with its own README and changelog, in the `/tools/` folder of each plugin repository.

> **Please note:** This tool was built for and tested against my own plugins only. I recommend using it exclusively on integrations marked with **melcom** as the maintainer in the table above. Using it on plugins from other maintainers is not supported and not something I recommend.

---

## 📢 Project Updates & Development Notes

<details>
<summary><b>Click to expand: Developer Update & Tooling Details</b></summary>

### Why Python 3.13?

The native 64-bit version of **GOG Galaxy** is built on Python 3.13. To avoid compatibility issues, all integrations in this repository are specifically built and tested against this Python version.

</details>

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
