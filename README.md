# galaxy-integrations-64bit

> **Notice:** This page is currently a preview to share ongoing progress and inform you about what is coming soon. Official releases will be linked here as they become available.

A collection of community integrations modernized for the native **64-bit version of GOG Galaxy 2.1+**.

The goal is to keep community integrations alive, compatible, and ready for the 64-bit client by updating dependencies and replacing outdated libraries.

---

## 🚀 Supported Integrations & Status

The following integrations have been updated and validated for the 64-bit client. Download links will be added here as they are released.

| Integration | Status | Download |
| :--- | :--- | :--- |
| **Amazon Games** | ✅ Beta | *Coming soon* |
| **Battle.net** | ✅ Beta | *Coming soon* |
| **Humble Bundle** | ✅ Beta | *Coming soon* |
| **itch.io** | ✅ Beta | *Coming soon* |
| **Steam** | ✅ Beta | *Coming soon* |
| **IndieGala** | ⏳ In Progress (Qt6 issue) | *Planned* |
| **Rockstar Games** | 💤 Planned | *Planned* |
| **PlayStation** | 💤 Planned | *Planned* |

*(+ 1 more integration currently undergoing final internal testing)*

---

## 📦 How to Install

1. **Exit GOG Galaxy** completely (ensure it is not running in the system tray).
2. Download the desired integration ZIP file from the **Releases** tab.
3. Extract the contents into the GOG Galaxy plugins folder:
   * **Windows:** `%localappdata%\GOG.com\Galaxy\plugins\installed`
4. **Restart GOG Galaxy** and connect your accounts via Settings -> Integrations.

---

## 📢 Project Updates & Development Notes

<details>
<summary><b>Click to expand: Developer Update & Tooling Details</b></summary>

### Why Python 3.13?
The native 64-bit version of **GOG Galaxy is built on Python 3.13**. To avoid compatibility issues, all integrations in this repository are specifically built and tested against this Python version.

### Internal Developer Tools
To streamline updating and maintaining dependencies, I developed a unified PowerShell utility:
* **melcom's Galaxy Plugin Scout (v1.1.8)**:
  An analyzer, cleaner, and dependency updater designed for GOG Galaxy 2.x plugins. It scans the plugin root, resolves import dependency trees (filtering standard libraries and internal namespaces), automatically backs up and purges unused modules, and uses `pip` to safely fetch and install updated Python 3.13 AMD64 dependencies.

*Note: This is currently a private utility for my personal development workflow. However, if there is enough interest, I would be glad to release this little utility once it reaches a suitable state for a public release.*
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

This project is a solo effort maintained entirely by a single developer. Please keep in mind that response times may vary, particularly during periods when health-related limitations restrict my available development time.

**GitHub Issues are disabled on this repository.** 
If you would like to report a bug, suggest an improvement, or share your feedback, please use the contact form on my website:

👉 [melcom-creations Contact Form](https://melcom-creations.github.io/melcom-music/contact.html)

Thank you for your patience and understanding!