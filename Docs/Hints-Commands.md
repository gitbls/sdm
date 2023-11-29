# sdm Command Hints and Tricks

I'll expand this with useful commands and what they do, often leaning more toward the intermediate to advanced user. Please feel free to open an issue with additional tips/suggestions!

* Do the most **minimal sdm command** to quickly test out a new plugin, or some other setting that depends only on the base system

  Test a new plugin doing as little as possible so that plugin test run is quick
```sh
sudo sdm --customize --nouser --poptions noupdate,noupgrade,noautoremove --plugin myplugin 2023-02-21-raspios-bullseye-arm64.img 
```
* **Consider using the `--plugin` switch with a plugin name of @file** if you have more than one or two plugins. This enables you to put your plugin details in a text file. This enables you to:
  * Rearrange the plugin ordering more easily
  * Worry a lot less about a missing double quote or breaking bash syntax when updating (double quotes not required in pluglist file)
  * See <a href="Docs//Plugins.md#invoking-a-plugin-on-the-sdm-command-line">Plugins </a> for details
* The **sdm history file (/etc/sdm/history) coding** is easily-missed, but provides additional information. Each message line (except for message continuations) starts with an indicator about the line content.
  * `*` Start of a new 'section' (e.g., `* Start Phase 1 image customization`)
  * `>` Inform you of something that sdm is doing
  * `%` Warning you that something isn't quite right, but forging ahead
  * `?` An error was identified. sdm will stop operation

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
