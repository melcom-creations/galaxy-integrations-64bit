Hier ist der Entwurf für dein Update. Ich habe es direkt ganz oben unter den Titel gepackt, damit jeder sofort sieht, was Sache ist. Der Ton ist locker, so wie du es wolltest, und die Erklärungen zu Python und deinen Tools sind kurz und knackig eingebaut.

***

# galaxy-integrations-64bit

A collection of community integrations for the native 64-bit version of GOG Galaxy 2.1+.

---

### 📢 Update: 26. Juni 2026
**Kurzer Statusbericht von mir:**

Mittlerweile kann ich sagen: **6 Plugins funktionieren schon richtig gut!** Aber ich kann die Dinger nicht einfach so „raushauen“. Damit das Ganze Hand und Fuß hat, müssen wir die Sache ordentlich angehen. Das heißt: Bibliotheken austauschen und alles auf den neuesten Stand von **Python 3.13** bringen. 

**Warum nicht Python 3.14?** 
Ganz einfach: Der neue 64-bit Client von GOG Galaxy arbeitet intern selbst noch auf Basis von **3.13**. Würden wir jetzt auf die 3.14 gehen, gäbe es nur Stress mit inkompatiblen Modulen und Fehlermeldungen. Wir bleiben also genau bei der Version, die der Client vorgibt, damit alles stabil und ohne Abstürze rennt.

Damit der Austausch der Bibliotheken so simpel wie möglich bleibt (auch für später), habe ich mir zwei kleine Helfer geschrieben:
*   **melcoms_clean-modules_v1.4.7**: Das Tool ist quasi mein digitaler Besen. Es putzt alte „Modul-Leichen“ aus den Ordnern, damit keine Versionskonflikte entstehen.
*   **melcoms_galaxy-aligner-toolkit_v3_1_4**: Mein kleines Schweizer Taschenmesser. Es sorgt dafür, dass die Pfade und Abhängigkeiten der Plugins perfekt auf den 64-bit Client „ausgerichtet“ werden.

**Wichtig:** Diese beiden Tools habe ich aktuell erst mal nur für mich privat geschrieben, um den Workflow zu beschleunigen. Ich überlege aber, sie euch eines Tages ebenfalls zur Verfügung zu stellen.

Alles in allem brauche ich noch ein paar Tage Geduld von euch. Schaut einfach hin und wieder hier vorbei, ob es ein neues Release gibt.

Schönes Wochenende!
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