# galaxy-integrations-64bit

A collection of community integrations for the native 64-bit version of GOG Galaxy 2.1+.

This project is focused on preserving, modernizing, and maintaining community integrations that were originally developed for older versions of GOG Galaxy and are no longer compatible with the current 64-bit client.

The goal is simple: keep community integrations alive and working on modern systems while ensuring compatibility with current and future releases of GOG Galaxy.

## 📢 Project Update - June 26, 2026

Hey everyone, just a quick heads-up on how things are going!

I’m happy to say that **six integrations are already up and running** really well. However, I’m not just going to "throw them out" there. I want to do this right, which means replacing old libraries and making sure everything is as clean and stable as possible before you guys get your hands on them.

**Why am I sticking with Python 3.13?**
You might wonder why I'm not using 3.14. It’s pretty simple: the current 64-bit GOG Galaxy client itself is based on **Python 3.13**. As long as GOG doesn't move to a newer version, it makes the most sense for me to stay on 3.13 too. It avoids unnecessary bugs and keeps everything perfectly compatible.

To make my life easier when swapping out libraries—now and in the future—I’ve built two little helper tools for myself:

*   **melcom's Clean-Modules (v1.4.7 )**: This one wipes out old dependency libraries from an integration, giving me a fresh, clean start before I rebuild them.
*   **melcom's Galaxy-Aligner-Toolkit (v3.1.4) - Dependency Maintenance Tool**: This tool automatically downloads and prepares all the libraries needed for the GOG Galaxy environment. 

Together, they save me a ton of manual work. For now, these tools are **private** and just for my own workflow, but I’m thinking about releasing them for everyone somewhere down the road.

I still need a few more days to wrap things up. Feel free to check back here every now and then to see if the first releases are live.

Have a great weekend!
**melcom**

---

## Current Status

Several integrations are already functional and are currently being tested by a small group of beta testers.

The following integrations are presently in active beta testing:

* Amazon Games
* Humble Bundle
* Battle.net
* Steam

These integrations have already received significant compatibility updates and are being validated through real-world testing before public release.

## Planned Integrations

The following integrations are currently planned for 64-bit modernization and compatibility updates:

* IndieGala
* itch.io

If time permits, additional integrations may also receive updates in the future, including:

* Rockstar Games Launcher
* PlayStation
* Additional community integrations that have not yet been publicly announced

Development priorities may change depending on complexity, available time, and testing results.

## Releases

This repository currently serves as both a project hub and development tracker.

Public releases will be published as testing and validation are completed.

Several releases are expected to become available within the coming days, provided no major issues are discovered during the final testing phase.

## Support & Feedback

This project is developed and maintained by a single individual.

As a result, response times may vary, especially during periods when health-related limitations reduce the time available for development and support.

GitHub Issues are intentionally disabled for this repository.

If you would like to report a bug, suggest an improvement, or get in touch, please use the contact form on my website:

https://melcom-creations.github.io/melcom-music/contact.html

Thank you for your patience, feedback, and support.