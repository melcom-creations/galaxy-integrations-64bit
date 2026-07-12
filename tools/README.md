# melcom Galaxy Tools

This folder contains the companion tools for the [melcom GOG Galaxy integrations](https://github.com/melcom-creations/galaxy-integrations-64bit).

---

## 🧰 Available Tools

|Tool|Purpose|Recommended for|Download|
|---|---|---|---|
|[melcom Galaxy Plugin Updater](melcom-galaxy_plugin_updater/README.md)|Keeps installed melcom GOG Galaxy plugins up to date and creates backups before updating.|Plugin users|[v0.1.0 ZIP](melcom-galaxy_plugin_updater/melcom-galaxy_plugin_updater_v0.1.0.zip)|
|[melcom Galaxy Plugin Scout](melcom-galaxy_plugin_scout/README.md)|Analyzes and maintains the bundled Python libraries in plugin `modules` folders.|Plugin development and maintenance|[v1.2.0 ZIP](melcom-galaxy_plugin_scout/melcom-galaxy_plugin_scout_1.2.0.zip)|

---

## 🔄 melcom Galaxy Plugin Updater

The Plugin Updater is the normal tool for users. It checks installed supported plugins for updates, creates backups, installs available releases, and keeps Battle.net and itch.io credentials safe when needed.

Use it when you want to update your installed integrations without downloading and replacing every plugin manually.

Start `update-plugins.bat` after extracting the updater release. Backups and logs are created in folders next to the updater files.

See [the Plugin Updater README](melcom-galaxy_plugin_updater/README.md) for the full instructions.

---

## 🔍 melcom Galaxy Plugin Scout

The Plugin Scout is a maintenance tool for the Python libraries bundled with the plugins. It can inspect the dependency state, preview changes, and update libraries when plugin maintenance requires it.

It is mainly intended for development and maintenance work. Normal plugin users do not need to run it after downloading a regular plugin release.

Start `GalaxyPluginScout.bat` and choose the appropriate mode. The tool offers a preview mode as well as maintenance modes that create backups before changing files.

See [the Plugin Scout README](melcom-galaxy_plugin_scout/README.md) for requirements and mode descriptions.

---

## 📦 Plugin Releases

The current GOG Galaxy integrations are available in the [galaxy-integrations-64bit repository](https://github.com/melcom-creations/galaxy-integrations-64bit).
