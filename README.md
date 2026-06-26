# galaxy-integrations-64bit

A collection of community integrations for the native **64-bit version of GOG Galaxy 2.1+**.

This project focuses on preserving, modernizing, and maintaining community integrations originally developed for older versions of GOG Galaxy that are no longer compatible with the current 64-bit client.

The goal is simple: keep community integrations alive, compatible, and ready for the native 64-bit GOG Galaxy client.

---

## 📢 Project Update - June 26, 2026

> **Hey everyone,**
>
> Just a quick heads-up on the progress. I'm happy to announce that **six integrations are already working really well**.
>
> However, I'm not going to rush the releases. Before anything goes public, I want to replace outdated libraries, update dependencies, and make sure every integration is as clean and stable as possible.

### 🐍 Why Python 3.13?

Some of you may wonder why I'm not using Python 3.14 yet. The answer is simple: the current native 64-bit version of **GOG Galaxy itself is based on Python 3.13**. As long as that doesn't change, it makes the most sense to build and test against the same version. This avoids unnecessary compatibility issues and keeps everything rock-solid.

### 🛠️ Internal Developer Tools

To make updating libraries easier, both now and in the future, I wrote two helper tools for my workflow:

* **melcom's Clean-Modules v1.4.7**
  *GOG Galaxy Plugin Dependency Cleaner* - Removes outdated dependency libraries from an integration, giving me a clean starting point before rebuilding everything.

* **melcom's Galaxy-Aligner-Toolkit v3.1.4**
  *Dependency Maintenance Tool* - Automatically downloads, updates, and prepares all required dependency libraries for the current GOG Galaxy environment.

Together, these tools save me a lot of manual work whenever dependencies need to be refreshed.

**Note:** Right now, these are private tools I use for development. I might release them publicly one day, but for now, they are simply helping me keep all integrations up to date.

I still need a few more days before the first public releases. Feel free to stop by every now and then to check for updates:

https://github.com/melcom-creations/galaxy-integrations-64bit

**Have a great weekend!**

*melcom*

---

## 🚀 Current Status

The following integrations have received significant compatibility updates and are currently being validated through real-world testing:

* ✅ **Amazon Games** (Beta)
* ✅ **Humble Bundle** (Beta)
* ✅ **Battle.net** (Beta)
* ✅ **Steam** (Beta)
* ✅ **itch.io** (Beta)
* *(+ 1 more currently undergoing final internal testing)*

## 📅 Planned Integrations

The following integrations are currently slated for 64-bit modernization:

* **IndieGala** (In progress - I'm currently investigating an issue involving `Qt6WebEngineCore.dll` and I'm in contact with GOG to find a solution.)
* **Rockstar Games Launcher** (Time permitting)
* **PlayStation** (Time permitting)
* *Additional community integrations to be announced.*

## 📦 Releases

This repository serves as both a project hub and development tracker.

* **Public releases** will be published as testing and validation are completed.
* Several public releases are expected over the next few days, provided no major issues are discovered during final testing.

## ❤️ Special Thanks

I want to take a moment to thank the people who kept me going during this intense development phase:

* A huge thank you to my friend [**Hustlefan**](https://www.gog.com/u/Hustlefan). Over the past few days, you've been much more than just moral support. You gave me the encouragement I needed, patiently put up with all my Discord spam, and helped beta test the plugins. I'm really happy that you're pleased with the results. Thanks so much for all your support, my friend.

* And a big thank you to my girlfriend [**Florence H.** (fl0H0815)](https://www.gog.com/u/Florence_Heart). While she was enjoying the good life at her parents' place - complete with air conditioning and a huge swimming pool - she kept my spirits up by sending me photos of herself, her friends, her parents, and even her parents' dog. She reminded me that there's a wonderful world outside of a code editor every now and then... 🙈

  *Now that's what I call real support.* ❤️

Thank you both for having my back!

## 🤝 Support & Feedback

This project is maintained by a single individual. Response times may vary, especially during periods when health-related limitations reduce available development time.

**GitHub Issues are intentionally disabled.**

If you would like to report a bug or suggest an improvement, please use the contact form on my website:

https://melcom-creations.github.io/melcom-music/contact.html

Thank you for your patience and support!
