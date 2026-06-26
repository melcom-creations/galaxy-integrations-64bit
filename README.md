# galaxy-integrations-64bit

A collection of community integrations for the native **64-bit version of GOG Galaxy 2.1+**.

This project focuses on preserving, modernizing, and maintaining community integrations originally developed for older versions of GOG Galaxy that are no longer compatible with the current 64-bit client.

---

## 📢 Project Update — June 26, 2026

> **Hey everyone,**
>
> Just a quick heads-up on the progress. I'm happy to announce that **six integrations are already working really well**. 
> 
> However, I'm not going to rush the releases. Before anything goes public, I want to replace outdated libraries, update dependencies, and make sure every integration is as clean and stable as possible.

### 🐍 Why Python 3.13?
Some of you may wonder why I'm not using Python 3.14 yet. The answer is simple: the current native 64-bit version of **GOG Galaxy itself is based on Python 3.13**. As long as that doesn't change, it makes the most sense to build and test against the same version. This avoids unnecessary compatibility issues and keeps everything rock-solid.

### 🛠️ Internal Developer Tools
To make updating libraries easier—both now and in the future—I wrote two helper tools for my workflow:

*   **melcom's Clean-Modules v1.4.7**  
    *GOG Galaxy Plugin Dependency Cleaner* — This tool removes outdated dependency libraries from an integration, giving me a clean starting point before rebuilding everything.
*   **melcom's Galaxy-Aligner-Toolkit v3.1.4**  
    *Dependency Maintenance Tool* — This one automatically downloads, updates, and prepares all required dependency libraries specifically for the current GOG Galaxy environment.

**Note:** Right now, these are private tools I use for development. I might release them publicly one day, but for now, they are simply helping me keep all integrations up to date.

I still need a few more days before the first public releases. Feel free to stop by every now and then to check for updates!

**Have a great weekend!**  
*— melcom*

---

## 🚀 Current Status

The following integrations have received significant compatibility updates and are currently being validated through real-world testing:

*   ✅ **Amazon Games** (Beta)
*   ✅ **Humble Bundle** (Beta)
*   ✅ **Battle.net** (Beta)
*   ✅ **Steam** (Beta)
*   ✅ **itch.io** (Beta)
*   *(+ 1 more currently in final internal testing)*

## 📅 Planned Integrations

The following integrations are currently slated for 64-bit modernization:

*   **IndieGala** (In progress – I'm currently dealing with some issues regarding `Qt6WebEngineCore.dll` and am in contact with GOG to find a solution.)
*   **Rockstar Games Launcher** (Time permitting)
*   **PlayStation** (Time permitting)
*   *Additional community integrations to be announced.*

## 📦 Releases

This repository serves as both a project hub and development tracker. 

*   **Public releases** will be published as testing and validation are completed.
*   Expect several releases within the coming days, provided no major issues are discovered during the final testing phase.

## ❤️ Special Thanks

I want to take a moment to thank the people who kept me going during this intense development phase:

*   A huge shout-out to my friend [**Hustlefan**](https://www.gog.com/u/Hustlefan). You weren't just a mental rock for me over the last few days, but you also gave me the strength to push through when I was close to giving up. He's also been beta testing these tools and—I think—he’s pretty happy with the results! Cheers for the support, man.
*   A massive thank you to my girlfriend, **Florence H.** ([**fl0H0815**](https://www.gog.com/u/Florence_Heart)). While she was living the good life at her parents' place—enjoying the AC and a giant pool—she kept my spirits high with photos of her, her friends, and her family. She reminded me how beautiful life can be outside of a code editor... though I definitely feel like I missed out on that pool! 😂

Thank you both for having my back!

## 🤝 Support & Feedback

This project is maintained by a single individual. Response times may vary, especially during periods when health-related limitations reduce available development time.

**GitHub Issues are intentionally disabled.**  
If you would like to report a bug or suggest an improvement, please use the contact form on my website:

👉 [**Contact melcom-creations**](https://melcom-creations.github.io/melcom-music/contact.html)

Thank you for your patience and support!