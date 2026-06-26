# galaxy-integrations-64bit

A collection of community integrations for the native 64-bit version of GOG Galaxy 2.1+.

---

### 📢 Update: June 26, 2026
**A quick status report from my side:**

I can finally say: **6 plugins are now working really well!** But I can't just "throw them out" yet. To do this right, I need to swap out the libraries and bring everything up to the latest **Python 3.13** standards. 

**Why not Python 3.14?** 
Simply because the new 64-bit GOG Galaxy client itself is based on **3.13**. If we were to use 3.14 now, it would just lead to trouble with incompatible modules and errors. We’re sticking with exactly the version the client uses to keep everything stable and crash-free.

To make swapping libraries as easy as possible (now and in the future), I’ve written two small tools:
*   **melcoms_clean-modules_v1.4.7**: This is basically my digital broom. It sweeps old "module corpses" out of the folders so we don't get version conflicts.
*   **melcoms_galaxy-aligner-toolkit_v3_1_4**: My little Swiss Army knife. It ensures that plugin paths and dependencies are perfectly "aligned" for the 64-bit client.

**Just so you know:** I wrote these two tools for my own private use to speed things up. I might think about making them available to you guys one day, though.

All in all, I still need a few more days. Just check back here (https://github.com/melcom-creations/galaxy-integrations-64bit) every now and then to see if I have an update for you.

Have a great weekend!
**melcom**

---

## Current Status

This project is focused on preserving, modernizing, and maintaining community integrations that were originally developed for older versions of GOG Galaxy and are no longer compatible with the current 64-bit client.

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