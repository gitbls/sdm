# Programming Plugins and Custom Phase Scripts

This section provides context and details about the sdm environment for writing Plugins and Custom Phase Scripts.

## sdm Operation Principles

sdm provides Plugins and Custom Phase Scripts with 3 operating environments:

* **Phase 0, or Mounted Disk Environment**: This environment runs in the context of the host (like pretty much every other script that you run). The disk or IMG that sdm is operating on is mounted in the host OS. Since the directory name can change, sdm provides the environment variable $SDMPT that always points to the top of the directory tree on the IMG being customized. 

  Thus, a correct reference to a file in the IMG in the mounted disk environment is, for example, `$SDMPT/etc/rc.local` **If you don't include $SDMPT, you will access or modify files on your host operating system.**

  System management commands such as systemctl, and journalctl affect the host OS. This is probably not what you want to do! You can, however, access the network, host storage, mounted network shares, use the scp and curl commands, etc.

  Keep work in this environment minimized to copying needed files from the host OS into the IMG somewhere. You can copy files directly to target locations in the IMG, prefaced by $SDMPT, or you can stage files into $SDMPT/etc/sdm/local-assets if desired.

* **Phase 1, or Container environment**: This environment runs in a container that is isolated from the host OS. The container file system is, er, contained, and code running in the container cannot access the host OS file system, only files in the IMG being customized. $SDMPT is not needed so is set to an empty string. This means that you can safely reference it in this environment, since $SDMPT/etc/rc.local and /etc/rc.local are equivalent, and both refer to the file in the IMG being customized. But it is not required in Phase 1, like it is for the Phase 0 mounted disk environment.

  Phase 1 starts when the container is entered. At the conclusion of Phase 1, sdm performs an `apt update` and `apt upgrade`. After that completes sdm runs plugin and custom phase script Phase 1 code.

  After Phase 1 for plugins and custom phase scripts completes, sdm runs the apps/xapps installs, and then enters the post-install phase.

* **post-install**: The post-install phase environment is the same as Phase 1 and all rules/guidelines for Phase 1 apply to the post-install phase. The difference between Phase 1 and the post-install phase is the timing of _**when**_ they are run.

  Work done in the post-install phase is typically focused on configuring the just-installed packages. After sdm completes its post-install work, the plugin and custom phase script post-installs are called. Note that anything that can be done in the Container environment can be done in post-install. This includes installing more packages, if you determine you need do it in the post-install phase for some reason.

## How Does This Work When Burning?

Think about the _environments_ described above, rather than phases. sdm creates an environment that is the same as that of the Phase 0 environment, and then calls selected plugins to run Phase 0.

Similarly, it creates a Container environment and runs the Phase 1 and post-install code for plugins.

In other words, sdm runs the plugin script 3 times (Phase 0, Phase 1, and post-install), operating on the newly-burned disk rather than the source IMG.

Most plugin code doesn't need to know that it's running as part of a burn operation. For code that does, the env var $SDMNSPAWN can be inspected. It's value will be "Burn0" when a plugin is running Phase 0 during a burn operation. It will be set to "Burn1" in Phase 1 and post-install code. (In a standard customize operation, SDMNSPAWN will be "Phase0" during Phase 0, and "Phase1" during Phase 1 and post-install phases.)

b0script/b1script use the same technique.

## Building Plugins

Take a copy of sdm-plugin-template, rename it to your plugin's name, and edit that copy.

The code in the template for Phase 0 is sample code to show how to parse the arguments and print them out. Other than that, you can write bash code to implement your plugin.

### plugin_getargs

plugin_getargs parses the plugin arguments and returns them in bash variables. For instance, for `--plugin foo:"key1=abc|key2=def"` plugin_getargs will create the bash variable *key1* with the value *abc*, and the bash variable *key2* with the value *def*.

plugin_getargs also defines the varible *keysfound* which is a list of the keys found, separated by vertical bars (e.g. "|key1|key2|"). 

#### Arguments
```
plugin_getargs plugin-name argument-list valid-keys required-keys
```
Where:

* **plugin-name** &mdash; Plugin name for messages. The default sdm-plugin-template uses the plugin filename.
* **argument-list** &mdash; The argument list passed to the plugin
* **valid-keys** &mdash; [Optional] Vertical bar-separated list of valid keynames. If provided, keys in the argument list that are not in the valid-keys list are flagged with a message
* **required-keys** &mdash; [Optional] Vertical bar-separated list of required keynames. If provided, keys in the required-keys list that are not present in the argument list are flagged with a message

### plugin_printkeys

plugin_printkeys formats the retrieved argument data and prints it on the console and into the sdm history log. It expects the following variables set, which should happen by default.

* **pfx** &mdash; The plugin name
* **foundkeys** &mdash; The list of keys found in the argument list, created by plugin_getargs
* And the variables as described above in plugin_getargs

The output from plugin_getargs looks like this in /etc/sdm/history:
```
2022-11-01 19:32:24 > Plugin postfix: Keys/values found:
2022-11-01 19:32:24    relayhost: mail.mydomain.com
2022-11-01 19:32:24    mailname: mydomain.com
2022-11-01 19:32:24    rootmail: myemail@somedomain.com
```

### plugin_dbgprint

plugin_dbgprint is like logtoboth, but with two exceptions:

* The line is only printed if `--plugin-debug` was specified on the command line
* The line is printed with "D!Plugin plugin-name: " preceding the message text

For instance:
```
2022-11-01 19:32:24 D!Plugin sdm-plugin-template: Test printout from sdm-plugin-template
```

### Updating plugins during --burn

By default, sdm does not update plugins at burn time. If you want to use a plugin at burn time that is different from the one already in the IMG:

* Use `--plugin /full/path/to/plugin` on the burn command line (`--bupdate plugin` is not required)
* Use `--bupdate plugin` to actually force the plugin to be updated

In these two cases, sdm will update the plugin in the burned output if the source plugin is newer.

## Building Custom Phase Scripts

Start with the file /usr/local/sdm/sdm-customphase, and similarly, copy it somewhere with a new filename, and work on it.

## HInts for both Plugins and Custom Phase Scripts

If you run into problems, `logtoboth` is your friend. It will write the string to the console and $SDMPT/etc/sdm/history in the IMG (or burned device in the case of `--burn`).

Remember that sdm copies itself into the IMG during customization phase 0. If you change any of the sdm files, it's easiest on your brain if you start over and re-customize. More than once I've been mystified why my change didn't work, because I tried to shortcut some steps.

## What variables are controlled by command line switches?

sdm keeps all the context in /etc/sdm/cparams, which is read by each module (via $SDMPT/etc/sdm/sdm-readparams), so that all variables are defined.

* `--1piboot` conf-file &mdash; $pi1bootconf
* `--apps` applist      &mdash; $apps
* `--xapps` applist     &mdash; $xapps
* `--apip` IPADDR       &mdash; $apip
* `--apssid` ssidname   &mdash; $apssid
* `--apt`-dist-upgrade  &mdash; $aptdistupgrade
* `--aptcache` IPADDR   &mdash; $aptcache
* `--aptmaint` options  &mdash; $aptmaint
* `--autologin`         &mdash; $autologin
* `--batch`             &mdash; $batch
* `--b0script` script   &mdash; $b0script
* `--b1script` script   &mdash; $b1script
* `--bootadd` key:value,key:value,... &mdash; $bootadd
* `--bootconfig` key:value,key:value,... &mdash; $bootconfig
* `--bootset` key:value,key:value,.. &mdash; $bootset
* `--bootscripts`       &mdash; $bootscripts
* `--cron-d` file       &mdash; $crond
* `--cron-daily` file   &mdash; $crondaily
* `--cron-hourly` file  &mdash; $cronhourly
* `--cron-monthly` file &mdash; $cronmonthly
* `--cron-weekly` file  &mdash; $cronweekly
* `--cron-systemd`      &mdash; $cronsystemd
* `--cscript` script    &mdash; $cscript
* `--csrc` dir          &mdash; $csrc
* `--custom[1-4]` str   &mdash; $custom[1-4]
* `--datefmt` str       &mdash; $datefmt
* `--ddsw` str          &mdash; $ddsw
* `--debug` apt         &mdash; $debugs
* `--disable` arg,arg   &mdash; $disables
* `--directory`         &mdash; $fdirtree=1
* `--dhcpcd` file       &mdash; $dhcpcd
* `--dhcpcdwait`        &mdash; $dhcpcdwait
* `--domain` name       &mdash; $domain
* `--dtoverlay`         &mdash; $dtoverlay
* `--dtparam`           &mdash; $dtparam
* `--ecolors` fg:bg:cur &mdash; $ecolors
* `--eeprom` str        &mdash; $eeprom
* `--expand-root`       &mdash; $expandroot=1
* `--exports` file      &mdash; $exports
* `--extend`            &mdash; $fextend=1
* `--fstab` file        &mdash; $fstab
* `--groups` list       &mdash; $groups
* `--hdmi-force-hotplug` &mdash; $hdmiforcehotplug=1
* `--hdmi-ignore-edid`  &mdash; $hdmiignoreedid=1
* `--hdmigroup` n       &mdash; $hdmigroup=n
* `--hdmimode` n        &mdash; $hdmimode=n
* `--host` hostname     &mdash; $hostname
* `--hotspot` config    &mdash; $hotspot
* `--journal` type      &mdash; $journal
* `--keymap` keymapname &mdash; $keymap
* `--L10n`              &mdash; $loadl10n=1
* `--loadlocal` args    &mdash; $loadlocal
* `--locale` localename &mdash; $locale
* `--logwidth` N        &mdash; $logwidth
* `--lxde-config` files &mdash; $lxdeconfig
* `--mcolors` fg:bg:cur &mdash; $mcolors
* `--modprobe` file     &mdash; $modprobe
* `--motd` file         &mdash; $motd
* `--mouse` left        &mdash; $fmouse=1
* `--nopassword`        &mdash; $fnopassword=1
* `--nouser`            &mdash; $nouser=1
* `--nowait-timesync`   &mdash; $nowaittimesync=1
* `--nspawnsw` str      &mdash; $nspawnsw
* `--password-pi` pwd   &mdash; $passwordpi
* `--password-user` pwd &mdash; $passworduser
* `--password-root` pwd &mdash; $passwordroot
* `--password-same` y|n &mdash; $samepwd
* `--plugin` pname:"args" &mdash; $plugins
* `--plugin-debug`      &mdash; $plugindebug
* `--poptions` str      &mdash; $poptions
* `--redact`            &mdash; $redact=1
* `--norestart`         &mdash; $noreboot=1
* `--rclocal` string    &mdash; $rclocal
* `--reboot` n          &mdash; $rebootwait=n, $reboot=1
* `--redact`            &mdash; $redact=1
* `--redo-customize`    &mdash; $redocustomize=1
* `--regen-ssh-host-keys` &mdash; $regensshkeys=1
* `--restart`           &mdash; $rebootwait=20, $reboot=1
* `--rootpwd`           &mdash; $rootpwd
* `--sdmdir` /path/to/sdm &mdash; $sdmdir
* `--showapt`           &mdash; $showapt=1
* `--showpwd`           &mdash; $showpwd=1
* `--ssh` none|socket|service &mdash; $ssh
* `--swap` n            &mdash; $swapsize
* `--svcdisable` svc1,svc2,...  &mdash; $svcdisable
* `--svc`-disable svc1,svc2,... &mdash; $svcdisable
* `--svcenable`  svc1,svc2,...  &mdash; $svcenable
* `--svc-enable`  svc1,svc2,... &mdash; $svcenable
* `--sysctl` file       &mdash; $sysctl
* `--systemd-config` item:file,... &mdash; $systemdconfig
* `--timezone` tzname   &mdash; $timezone
* `--udev` file         &mdash; $udev
* `--uid` uid           &mdash; $myuid
* `--update-plugins`    &mdash; $fupdateplugins=1
* `--user` username     &mdash; $myuser
* `--vncbase` n         &mdash; $vncbase
* `--wifi-country` country &mdash; $wificountry
* `--wpa` wpaconf       &mdash; $wpa
* `--nowpa`             &mdash; $fnowpa=1
* `--xmb` n             &mdash; $imgext

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
