# Community Integrations for GOG Galaxy 2.1+ (64-bit)

> **Notice:** This page is currently a preview to share ongoing progress and inform you about what is coming soon. Official releases will be linked here as they become available.

GOG Galaxy is quietly moving to a native 64-bit client, and a lot of community integrations were never built with that in mind. Old 32-bit assumptions, outdated dependencies, deprecated APIs on the platform side - all of it adds up to plugins that simply stop working the moment you switch.

This repository is my attempt to keep that from happening. It is a collection of community integrations that have been rebuilt, dependency by dependency, for the **native 64-bit version of GOG Galaxy 2.1+** - so the tools you are used to keep working instead of quietly breaking under you.

---

## 🔄 Step 1: Get the 64-bit Galaxy Client

Before any of the integrations below will do you any good, you need the 64-bit client itself. If you are still on GOG Galaxy 2.0, here is how to switch:

![How to enable the 64-bit GOG Galaxy client](images/screenshot_2026-07-06%20042105.png)

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
| **IndieGala** | **melcom** | ⏳ In Progress (Qt6 issue) | ❌ | ⏳ | ⏳ |
| **Rockstar Games** | **melcom** | ⏳ | ✅ | ✅ | ⏳ |
| **PlayStation** | **melcom** | 💤 Maybe | ❌ | ✅ | ⏳ |
| **Legacy Games** | **pippo-san** | ✅ Released | ❌ | ✅ | [Download](https://github.com/pippo-san/galaxy-integration-legacy-games) |

**Legend:**
* ✅ = Implemented / Supported
* ❌ = Unsupported / Not implemented
* ⏳ = Planned

---

## 📦 How to Install

1. **Exit GOG Galaxy** completely (ensure it is not running in the system tray).
2. Pick the integration you want from the **Download** column in the table above and grab the ZIP file from its repository.
3. Extract the contents into the GOG Galaxy plugins folder:
   * **Windows:** `%localappdata%\GOG.com\Galaxy\plugins\installed`
4. **Restart GOG Galaxy** and connect your accounts via **Settings -> Integrations**.

---

## 🧰 Keeping Your Plugins Up to Date

Every integration in this repository ships with a small `/tools/` folder. It is easy to miss, but worth knowing about if you plan to keep a plugin installed for a while.

Inside is **Galaxy Plugin Scout** - a PowerShell tool I built specifically for the plugin structure used here. Point it at an installed plugin folder and it will:

* scan the plugin and resolve its actual Python dependency tree,
* tell you exactly which libraries in `/modules/` are still needed, which are just taking up space, and which are missing,
* back up the plugin before touching anything,
* and fetch the correct Python 3.13 64-bit versions of anything that needs updating.

In short: if a plugin's bundled libraries ever fall behind - now, in six months, or whenever GOG Galaxy or a platform API changes underneath it - you do not need to wait for me to push a new release. Run the Scout, review its report, and update the plugin yourself. There is also a dry-run mode if you just want to see what it would do before committing to any changes.

You will find the current build of the tool, together with its own README and changelog, in the `/tools/` folder of each plugin repository.

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