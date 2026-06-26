# galaxy-integrations-64bit

A collection of community integrations for the native 64-bit version of GOG Galaxy 2.1+.

This project is focused on preserving, modernizing, and maintaining community integrations that were originally developed for older versions of GOG Galaxy and are no longer compatible with the current 64-bit client.

The goal is simple: keep community integrations alive and working on modern systems while ensuring compatibility with current and future releases of GOG Galaxy.

## Current Status

Several integrations are already functional and are currently being tested by a small group of beta testers.

The following integrations are presently in active beta testing:

* Amazon Games
* Humble Bundle
* Battle.net
* Steam

These integrations have already received significant compatibility updates and are being validated through real-world testing before public release.

## Project Update - June 26, 2026

A small update from me.

At the moment, **six integrations are already working really well** and I'm very happy with the current progress.

That doesn't mean I'm going to release them right away, though. I want to do this properly. Before anything becomes public, I want to replace outdated libraries, update dependencies where needed, and make sure everything is as clean and stable as possible.

Some people have asked why I'm targeting **Python 3.13** instead of the newer Python 3.14. The answer is simple. The current native 64-bit version of GOG Galaxy itself is based on Python 3.13. By using the same Python version, the integrations stay fully compatible with the client and unnecessary compatibility issues can be avoided. Once GOG Galaxy moves to a newer Python version, the integrations can move with it.

To make replacing libraries as simple as possible - both now and in the future - I wrote two small tools for myself.

**melcoms_clean-modules v1.4.7** removes the existing Python libraries from an integration, giving me a clean starting point before rebuilding the dependency folder.

**melcoms_galaxy-aligner-toolkit v3.1.4** automatically downloads the required libraries and prepares everything for the current GOG Galaxy environment. This saves a lot of manual work whenever dependencies need to be updated.

At the moment these tools are private and only exist to support my own workflow. I may decide to release them publicly one day, but for now they're simply helping me maintain the integrations.

Overall, I still need a few more days before I'm ready for a public release.

Feel free to stop by the repository from time to time to see if there's anything new:

https://github.com/melcom-creations/galaxy-integrations-64bit

Have a great weekend!

melcom

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
