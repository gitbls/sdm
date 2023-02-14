# Burn Scripts

Burn scripts enable you to do updates that are specific to a single system as you burn the media for it. An obvious use case for burn scripts is for use with scripted burning of IMGs. For instance `sdm-gburn` uses burn scripts to programmatically perform per-destination custom updates.

For more general use, <a href="Plugins.md">Plugins</a> are a better solution. Plugins can be used during IMG customization, and hence available to all systems burned from that IMG, or burning an IMG and only available on that particular burn target.

## Overview

There are cases where it is desirable to do per-system customization on the SD Card or burn image after it has been burned. Examples include:

* Copy additional files onto the SD Card
* Configuration file customizations for a specific system
* Apps installed for a specific system

If the only differences between your "standard" image and per-device customizations are relatively modest (from your perspective), you can use Burn Scripts to implement these customizations on the burn output device or file.

In the first case (copying additional files), your script will need access to both the host system and the SD Card. `--b0script` should be used for this. The execution environment for `--b0script` is the same as *Phase 0* (see <a href="Custom-Phase-Script.md">Custom Phase Script</a>), and should follow the guidelines for a Custom Phase Script Phase 0. sdm will invoke the procedure `do_b0script` in the b0script file.

In the second and third cases, your script wants to do things in the context of the newly-created system. Use `--b1script` for that. sdm will nspawn into the SD Card, so your script should follow the guidelines for a Custom Phase Script Phase 1.

The argument to both switches is a /complete/path/to/script.

## Logging to /etc/sdm/history
* For `--b0script`: Use `logtoboth "string to log"` in your `--b0script`
* For `--b1script`: `source /etc/sdm/sdm-readparams` at the top of your script, then use `logtoboth "string to log"` 

The `--b1script` script will be copied to /etc/sdm/assets on the SD Card/image before the nspawn, and is not deleted.

See <a href="Example-Burn-Scripts.md">Example Burn Scripts</a> for examples of b0script and b1script

## Switches that work with --burn

These switches can be used with `--burn`. When used this way, they affect only the output SSD/SD Card, and not the IMG file.

* `--apip`
* `--apssid`
* `--autologin`
* `--b0script`
* `--b1script`
* `--bootscripts`
* `--bootset`
* `--dhcpcd`
* `--disables`
* `--expand-root`
* `--exports`
* `--hostname`
* `--keymap`
* `--locale`
* `--noreboot`
* `--nowait-timesync`
* `--rebootwait`
* `--password-pi`
* `--password-user`
* `--password-root`
* `--redact`
* `--regen-ssh-keys`
* `--plugin`
* `--plugin-debug`
* `--rclocal`
* `--reboot`
* `--svc-disable`
* `--svc-enable`
* `--sysctl`
* `--timezone`
* `--uid`
* `--user`
* `--update-plugins`
* `--wifi-country`
* `--wpa`
<br>
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
