# Programming Plugins and Custom Phase Scripts

This section provides context and details about the sdm environment for writing Plugins and Custom Phase Scripts.

See <a href="Plugins.md">Plugins</a> and <a href="Custom-Phase-Script.md">Custom Phase Scripts</a> for descriptions/overviews of these capabilities.

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

### plugin_addnote

plugin_addnote provides a way for plugins to create a set of messages that are output at the end of a customization to both the console and /etc/sdm/history. For example, if a plugin needs to tell or remind you about additional steps that need to be done to fully configure the service, this would be a way to communicate that information.

Several of the plugins now use this, including imon, knockd, pistrong, postfix, and samba.

#### Arguments
```
plugin_addnote string
```

Where:

* **string** is the text of the string to add to the notes. plugin_addnote does no formatting, so the format and readability are up to the plugin author.

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

### Handling plugin deferred actions

Sometimes a plugin needs to defer an action until the system is actually booted. For instance, if a plugin needs the actual running hostname of a system (instead of the hostname on which sdm is running), the plugin needs to delay this actino until the system actually boots for the first time.

The easiest way to do this is to create an executable script named /etc/sdm/0*-*.sh, place the necessary commands in it, and they will be run automatically during the first boot of the system.

#### Example code creating a deferred action script
This creates a deferred action script that is run during the first system boot. It enables hostapd and dnsmasq for all subsequent boots. Note that this code should only be run in Phase 1 or the post-install phase; it will modify the running system if run in Phase 0 as is.

```sh
cat > /etc/sdm/0piboot/040-hostapd-enable.sh <<EOF
#!/bin/bash
# This script runs as root during the first boot of the system
#source /etc/sdm/sdm-readparams  #Not needed for this example
echo "hostname: $(hostname)" >> /etc/myservice/myservice.conf
EOF
```
### Updating plugins during --burn

By default, sdm does not update plugins at burn time. If you want to use a plugin at burn time that is different from the one already in the IMG:

* Use `--plugin /full/path/to/plugin` on the burn command line (`--bupdate plugin` is not required)
* Use `--bupdate plugin` to actually force the plugin to be updated

In these two cases, sdm will update the plugin in the burned output if the source plugin is newer.

## Running only plugins

sdm can run plugins a couple of different ways:

* As part of a `--customize` command
* As part of a `--burn` command
* By itself using the `--runonly plugin` command

The first two above are described above. The `--runonly plugin` command can operate on three different system locations: a RasPiOS IMG, RasPiOS burned onto a storage device, and lastly, the running host OS.

When using `--runonly` on an IMG or storage device, the environment in which the plugins run is exactly as described above (Phase 0, Phase 1, post-install)

To `--runonly` on the running system specify `--directory /` in addition to other switches on the `--runonly` command line. Do not specify an IMG or device name. In this mode, if the running host OS is RasPiOS, you will be prompted to confirm that you want to run the plugins. The `--oklive` switch bypasses the confirmation. If the host OS is not RasPiOS and `--oklive` was specified, the plugins will be run, otherwise sdm will exit.

When `--runonly` is run on the live host OS, the env var $SDMNSPAWN has the value **Live0** or **Live1**. Plugins can take action on that. For instance, if your plugin installs a service, if $SDMNSPAWN is **Live1** you can do commands such as `systemctl daemon-reload` and `systemctl start mydaemon`, whereas if the plugin is running in "standard" sdm Phase1 in an IMG those commands would fail. For instance:
```sh
    if [ "$SDMNSPAWN" == "Live1" ]
    then
        systemctl daemon-reload
        systemctl start mydaemon
    fi
```

## Building Custom Phase Scripts

Start with the file /usr/local/sdm/sdm-customphase, and similarly, copy it somewhere with a new filename, and work on it. Plugins are a better approach, however.

## Hints for Plugins and Custom Phase Scripts

If you run into problems, `logtoboth` is your friend. It will write the string to the console and $SDMPT/etc/sdm/history in the IMG (or burned device in the case of `--burn`).

Remember that sdm copies itself into the IMG during customization phase 0. If you change any of the sdm files, it's easiest on your brain if you start over and re-customize. More than once I've been mystified why my change didn't work, because I tried to shortcut some steps.

## What variables are controlled by command line switches?

sdm keeps all the context in /etc/sdm/cparams, which is read by each module (via $SDMPT/etc/sdm/sdm-readparams), so that all variables are defined.

* `--1piboot` conf-file &mdash; $pi1bootconf
* `--apt`-dist-upgrade  &mdash; $aptdistupgrade
* `--aptcache` IPADDR   &mdash; $aptcache
* `--aptmaint` options  &mdash; $aptmaint
* `--autologin`         &mdash; $autologin
* `--batch`             &mdash; $batch
* `--b0script` script   &mdash; $b0script
* `--b1script` script   &mdash; $b1script
* `--bootscripts`       &mdash; $bootscripts
* `--cscript` script    &mdash; $cscript
* `--csrc` dir          &mdash; $csrc
* `--custom[1-4]` str   &mdash; $custom[1-4]
* `--datefmt` str       &mdash; $datefmt
* `--ddsw` str          &mdash; $ddsw
* `--debug` apt         &mdash; $debugs
* `--directory`         &mdash; $fdirtree=1
* `--domain` name       &mdash; $domain
* `--ecolors` fg:bg:cur &mdash; $ecolors
* `--expand-root`       &mdash; $expandroot=1
* `--extend`            &mdash; $fextend=1
* `--groups` list       &mdash; $groups
* `--host` hostname     &mdash; $hostname
* `--loadlocal` args    &mdash; $loadlocal
* `--logwidth` N        &mdash; $logwidth
* `--mcolors` fg:bg:cur &mdash; $mcolors
* `--nowait-timesync`   &mdash; $nowaittimesync=1
* `--nspawnsw` str      &mdash; $nspawnsw
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
* `--sdmdir` /path/to/sdm &mdash; $sdmdir
* `--showapt`           &mdash; $showapt=1
* `--plugin user:"useradd=name"` &mdash; $myuser
* `--update-plugins`    &mdash; $fupdateplugins=1
* `--wifi-country` country &mdash; $wificountry
* `--xmb` n             &mdash; $imgext

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
