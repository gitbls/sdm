# Migrating to sdm v9

This page should answer most questions about switching from sdm v8 or earlier to v9.

## Why convert all these switches to plugins?

As sdm has acquired functionality, the number of switches grew without bound, which creates user adoption issues (wow! there are so many switches), as well as adding complexity to adding new features. In the non-plugin model, at least 3, and sometimes more scripts required modification to add a new feature.

Now, all the functionality for a particular plugin is encapsulated in a single script. This simplifies usage code, and documentation.

My decision to move all these switches into plugins was not made lightly. Most importantly, there is the impact on you, an sdm user, since your sdm scripts likely require updates. I apologize for that, but future pertubations will be drastically reduced.

It was also a fair amount of code slinging! Hopefully after you've converted you'll agree it was a worthwhile investment.

## What plugin is this switch in?

Each relocated switch is an argument with the same name, unless specifically mentioned otherwise. The values for each argument are the same as the switch values, with a couple of special notes:

* Each argument can only be specified once in a plugin argument list, but many of the arguments take a list of something or another. See the plugin documentation for details.
* Plugins can be provided multiple times on the command line if desired, and can be used on both customize and burn

These switches have relocated to the `system` plugin <a href="Plugins.md#system">(Documentation)</a>

* `--cron-d`  
* `--cron-hourly` 
* `--cron-daily` 
* `--cron-weekly`  
* `--cron-monthly`  
* `--cron-systemd`  
* `--eeprom`  
* `--exports`  
* `--fstab` 
* `--journal`  
* `--modprobe`  
* `--motd` 
* `--sysctl`  
* `--systemd-config`  
* `--swap`  
* `--udev`  
* `--svc*disable`  
* `--svc*enable`  

These switches have relocated to the `bootconfig` plugin <a href="Plugins.md#bootconfig">(Documentation)</a>

* `--bootadd`  
* `--bootconfig`  
* `--dtoverlay`  
* `--dtparam`  
* `--hdmigroup`  
* `--hdmimode`  
* `--hdmi-force-hotplug`  
* `--hdmi-ignore-edid`  

This switch is in the `disables` plugin <a href="Plugins.md#disables">(Documentation)</a>

* `--disable` 

This switch is in the `raspiconfig` plugin <a href="Plugins.md#raspiconfig">(Documentation)</a>

* `--bootset`  

These switches have relocated to the `L10n` plugin <a href="Plugins.md#L10n">(Documentation)</a>

* `--keymap`  
* `--locale`  
* `--timezone`  
* `--L10n`

These switches have relocated to the `user` plugin <a href="Plugins.md#user">(Documentation)</a>

* `--user`  
* `--nouser`  
* `--nopassword`  
* `--uid`  
* `--password-pi`  
* `--password-user`  
* `--password-root`  
* `--password-same`  
* `--rename-pi`  
* `--rootpwd`  

These switches are in the `lxde` plugin <a href="Plugins.md#lxde">(Documentation)</a>

* `--lxde-config`  
* `--lhmouse`  

These switches are in the `network` plugin <a href="Plugins.md#network">(Documentation)</a>

* `--netman`  
* `--dhcpcdwait`  
* `--dhcpcd`  
* `--ssh`
* `--wificountry`
* `--wpa`  

## What is the replacement for this plugin?

* `adduser` &mdash; The `adduser` plugin is now the `user` plugin
* `burnpwd` &mdash; The `user` plugin includes the ability to prompt for a user's password

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
