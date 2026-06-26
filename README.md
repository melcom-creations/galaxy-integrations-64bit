# galaxy-integrations-64bit

A collection of community integrations for the native 64-bit version of GOG Galaxy 2.1+.

This project is focused on preserving, modernizing, and maintaining community integrations that were originally developed for older versions of GOG Galaxy and are no longer compatible with the current 64-bit client.

The goal is simple: keep community integrations alive and working on modern systems while making sure they stay compatible with current and future releases of GOG Galaxy.

## Current Status

Several integrations are already working well and are being tested right now.

As of 2026-06-26, six plugins are already running really well in practice. I am still not just throwing them out there, though, because I want to do this properly. That means swapping out libraries where needed, checking everything carefully, and bringing the whole stack up to date with Python 3.13, which matches the basis of the new 64-bit GOG Galaxy client. That makes a lot more sense here than jumping to Python 3.14 too early, because I want to stay aligned with the client version that the integrations are actually built around and avoid unnecessary compatibility problems.

The following integrations are presently in active beta testing:

* Amazon Games
* Humble Bundle
* Battle.net
* Steam
* plus two more integrations that are already in the same update cycle and working well in my tests

These integrations have already received a good amount of compatibility work and are being checked in real-world use before I release anything publicly.

## Planned Integrations

The following integrations are currently planned for 64-bit modernization and compatibility updates:

* IndieGala
* itch.io

If time permits, additional integrations may also receive updates in the future, including:

* Rockstar Games Launcher
* PlayStation
* Additional community integrations that have not yet been publicly announced

Development priorities may still change depending on complexity, available time, and testing results.

## Releases

This repository currently serves as both a project hub and development tracker.

Public releases will be published as testing and validation are completed.

A few releases should be ready in the next days, as long as no major issues show up during the final testing phase.

## Support & Feedback

This project is developed and maintained by a single person.

Because of that, response times can vary, especially when health or time limitations slow things down a bit.

GitHub Issues are intentionally disabled for this repository.

If you would like to report a bug, suggest an improvement, or get in touch, please use the contact form on my website:

https://melcom-creations.github.io/melcom-music/contact.html

Thanks for your patience, feedback, and support.

## About the tools

To make the library exchange as easy as possible, even for future updates, I wrote two small private tools for myself: melcoms_clean-modules_v1.4.7 and melcoms_galaxy-aligner-toolkit_v3_1_4.

Both tools help with cleaning up and replacing modules in a controlled way, so the integrations can be kept in shape without doing everything by hand every time. Right now they are private tools that I made for my own workflow, but I am thinking about making them available to everyone at some point in the future.

---

Sometimes the best way is simply to take a little more time and do it properly.
Please check back here from time to time:
https://github.com/melcom-creations/galaxy-integrations-64bit

Have a nice weekend
melcom
