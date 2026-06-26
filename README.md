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

I thought I'd give you a quick update.

The good news is that **all six integrations are working really well**. I'm honestly happy with where things are right now.

The bad news? I don't want to rush the release. Before I publish anything, I want to replace outdated libraries and bring everything up to date with the **Python 3.13** environment used by the current native 64-bit GOG Galaxy client. Sticking to Python 3.13 simply makes the most sense for now, because that's what GOG Galaxy itself is using. It keeps everything as compatible and stable as possible.

To make all of this easier, I wrote two small tools for myself.

**melcoms_clean-modules v1.4.7** removes old libraries from an integration, while **melcoms_galaxy-aligner-toolkit v3.1.4** downloads fresh ones and prepares everything for the current Galaxy environment. They're private tools for now, but maybe I'll release them one day if there's enough interest.

So... I still need a few more days.

Feel free to check back every now and then:
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
