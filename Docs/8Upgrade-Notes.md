# Upgrading to sdm V8

Here are the things that you'll need to change or pay attention to when you upgrade from an earlier release to sdm V8.

## Switches removed

* `--apps` and `--xapps` &mdash; These switches are replaced by the `apps` plugin. 
* `--netman`, `--dhcpcd`, `--dhcpcdwait`, `--nowpa` &mdash; These switches are replaced by the `network` plugin
* `--mouse left` &mdash; This switch is replaced by the argument `lhmouse` to the `graphics` plugin
* Removed `--poptions`: apps, nodmconsole, xwindows, apps &mdash; `apps`, `xapps`, and `xwindows` poptions are no longer needed since the corresponding switches have been removed. The `nodmconsole` poption is now an argument to the `graphics` plugin.

## New plugins

Plugins <a href="Plugins.md">are fully described here</a>

* `apps` &mdash; The `apps` plugin replaces the `--apps` and `--xapps` command line switches. Use the `name=` argument to set a name for each one. The apps plugin can be specified on the command line as many times as desired, with a different `name=` for each one.

  Where you used `--apps @myapplist --xapps @myxapplist` prior to V8, you would now use

```
--plugin apps:"apps=@myapplist|name=myapps" --plugin apps:"apps=@myxapps|name=myxapps"
```
  
* `graphics` &mdash; Use the `graphics` plugin to configure graphics. This includes Wayland vs X11, graphics on the console, the video mode in cmdline.txt, and setting a left-handed mouse.
* `network` &mdash; Use the `network` plugin to configure various network settings, such as NetworkManager vs dhcpcd, WiFi configuration, and additional configuration for both dhcpcd and NetworkManager.
* `quietness` &mdash; The `quietness` plugin controls the cmdline.txt settings `quiet` and `splash`, as well as the plymouth graphical startup splash screens.
* `wificonfig` &mdash; Use the `wificonfig` plugin to enable over-the-air WiFi configuration of a Pi during the first system boot.

## Why move command line switches to plugins?

This change enables more modular code in sdm, which furthers additional development. The documentation is now clearer since each function is documented in one place, rather than being spread around the various pages.

A side effect of some of the plugins, such as the `apps` plugin in particular, is that there is no restriction on the number of times the plugin can be called. This enables you to partition your app install lists, for example, into `core-apps`, `core-xapps`, `non-core-apps`, and `non-core-xapps`.


## Other Useful info

* Bookworm &mdash; V8 has initial support for Bookworm. As this support was added based on a preview RasPiOS release, additional changes may be required once it is formally released.

  Releases of sdm prior to V8 do not include any formal Bookworm support.

<form>
<input type="button" value="Back" onclick="history.back()">
</form>
