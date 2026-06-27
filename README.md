# galaxy-integrations-64bit

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
To streamline updating dependencies, I use two private utility tools:
* **melcom's Clean-Modules (v1.4.7)**: Automatically cleans outdated dependency libraries from integrations.
* **melcom's Galaxy-Aligner-Toolkit (v3.1.4)**: Automatically fetches and prepares the correct dependencies matching the GOG Galaxy environment.

I expect to release the first batch of public releases in the coming days.
</details>

---

## 🤝 Support & Feedback

This project is maintained by a single developer. Response times may vary. 

**GitHub Issues are disabled.** 
To report bugs or provide feedback, please use the contact form:
👉 [melcom-creations Contact Form](https://melcom-creations.github.io/melcom-music/contact.html)

---

## ❤️ Special Thanks

* [**Hustlefan**](https://www.gog.com/u/Hustlefan) – For the endless encouragement, beta testing, and putting up with my Discord spam.
* [**Florence H.** (fl0H0815)](https://www.gog.com/u/Florence_Heart) – For keeping my spirits high and reminding me that a world exists outside of the code editor.
