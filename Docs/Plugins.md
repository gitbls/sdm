# Plugins

## Plugin Overview

Plugins are a modular way to extend sdm capabilities. Plugins are similar to <a href="Custom-Phase-Script.md">Custom Phase Scripts</a>, but can work both during customization and/or when burning an SSD/SD Card.

It makes sense to include some plugins into the IMG you're creating (e.g., postfix, samba) so they are installed onto every system burned from that IMG, but some are typically installed once per network (e.g., apt-cacher-ng), or not needed on every system. In that case you can use the plugin when burning the SSD/SD for that specific system.

The set of plugins provided with sdm are documented here.

Other plugins are planned. If there are any specific plugins you're interested in, let me know!

You can add your own plugins as well. Put your plugin script in /usr/local/sdm/local-plugins, and it will be automatically found. sdm looks at local-plugins first, so you can override an sdm-provided plugin with your modifications if desired.

You can also specify the plugin name with a full path. sdm will copy the plugin to /usr/local/sdm/local-plugins if it does not exist or the one specified is newer than the one in local_plugins.

## Invoking a plugin on the sdm command line

Specify each plugin with a separate `--plugin` switch:

```
sdm --plugin samba:"args" --plugin postfix:"args" . . .
```

Multiple `--plugin` switches can be used on the command line. This includes specifying the same plugin multiple times (the `apps` plugin, for example).

Another way to specify plugins is via the `--plugin @/path/to/pluglist`, where `pluglist` consists of plugin invocations, one per line, without the `--plugin` switch. For example:
```
user:userlist=/rpi/etc/sdm/bls-users
system:name=0|systemd-config=timesyncd=/rpi/systemd/timesyncd.conf|eeprom=stable|sysctl=/rpi/etc/sysctl.d/01-disable-ipv6.conf|fstab=/rpi/etc/fstab.lan|motd=/dev/null
system:name=1||service-disable=apt-daily.timer,apt-daily-upgrade.timer,wpa_supplicant,avahi-daemon,avahi-daemon.socket,ModemManager,rsync,mdadm-shutdown
network:nmconn=/rpi/etc/NetworkManager/system-connections/eth0.nmconnection,/rpi/etc/NetworkManager/system-connections/homewifi.nmconnection|wifissid=myhomewifif|wifipassword=homewifipassword|wificountry=US
disables:triggerhappy|wifi|bluetooth|piwiz
quietness:consoleblank=300|noquiet=keep|nosplash=keep|noplymouth
L10n:host
```

One key benefit of using a pluglist file is the argument list does not need to be quoted (`"`). This is only needed on the command line to keep bash from doing silly things.

Plugins are run in the order they are encountered on the command line or the plugin @file,

The complete plugin switch format is:
```sh
--plugin plugname:"key1=val1|key2=val2|key3=val3"
```
Enclose the keys/values in double quotes as above if there is more than one key/value or bash will be confused by the "|".

See below for plugin-specific examples and important information.

It is recommended that all files that you provide to sdm, whether on the command line or in arguments to a plugin, use full paths. For instance, to use a file in your home directory, don't use `file` or `~/file`, use `/home/<mylogin>/file`. Relative file paths generally work, but if you run into problems, switch to using a ful path.

It is not possible to use a tilde ("~") as an argument value for a plugin. A good example of this is for WiFi passwords for the `network` plugin. In this case (and if you encounter any others) you must provide a fully-formed .nmconnection file. The tilde is used internally by sdm to separate a plugins concatenated together (in a string).

NOTE: An argument can only be used once per plugin invocation. This is not a problem with most plugins, but you might find a use for multiple uses in some plugins, such as bootconfig. This is discussed in the <a href="#bootconfig">`bootconfig` plugin</a>.

## Burn Plugins

Burn plugins are special plugins that are run after a burn has completed on a disk (`--burn`) or disk image (`--burnfile`). Only plugins designated as burn plugins in this document can be used with `--burn-plugin`. sdm doesn't check whether a plugin is burn-plugin capable, so trying to use a non-burn-plugin as a burn-plugin will likely be *interesting*.

Burn plugins can also be used with `--runonly plugins` to operate on an IMG or disk. The `parted` plugin can be used in this manner.
```sh
sdm --runonly plugins --burn-plugin parted:"addpartition=2048,ext4" 2023-12-05-raspios-bookworm-arm64.img
sdm --runonly plugins --burn-plugin extractfs:"rootfs=/path/to/rootfs|bootfs=/path/to/bootfs" 2023-12-05-raspios-bookworm-arm64.img
```

## Plugin ordering notes

There are a couple of plugin ordering issues to be aware of.
* The `user` plugin(s) should be the first plugin. Several other plugins expect this.
* The `cryptroot` plugin must be after the graphics plugin in order to properly manage boot behavior during the encryption process
* The `boot_behavior` final setting is order-sensitive. The last modification wins.
  * During the post-install phase, if `--plugin graphics` is used, the `graphics` plugin will set the boot behavior. If the `graphics` plugin is not used, this will run automatically at the end of the post-install phase.
    * If the display manager is lightdm, `boot_behavior` is set: B3 or B4 per the `--autologin` switch
    * If the display manager is xdm or wdm, `boot_behavior` is set: B1 or B3 per the setting of `nodmconsole`
  * Calling the `raspiconfig` plugin during burn and specifying the `boot_behavior` argument will unconditionally set the new boot behavior

## WiFi device must have the WiFi country

If you want to use the WiFi device either configured for a network or simply enabled, you must specify the WiFi country.

Plugins `btwifi`, `L10n`, and `network` will all correctly configure the network country (and `rfkill`) if the `wificountry` argument is provided. If you simply want to have the WiFi enabled without configuring the WiFi network via any of these plugins, use `--plugin L10n:wificountry=xx`.

## Plugin-specific documentation

### sdm-plugin-template

sdm-plugin-template can be used to build your own plugin. It contains some code in Phase 0 demonstrating some of the things you can do with the *plugin_getargs* function and how to access the results.

### apps

Use the apps plugin to install applications. The apps plugin can be called multiple times on a command line or in a pluglist. The name can be any alphanumeric (including "-", "_", etc.) you want.

#### Arguments

* **apps** &mdash; Specifies the list of apps to install or @filename to provide a list of apps (one per line) to install. Comments are indicated by a pound sign (#) and are ignored, so you can document your app list if desired. If the specified @filename is not found, sdm will look in the sdm directory (/usr/local/sdm). 
* **name** &mdash; Specifies the name of the apps list. The default name is *default*. The `name` argument is a convenience and is not required.
* **remove** &mdash; Specifies the list of apps to remove ofr @filename to provide a list of apps (one per line) to remove. The `remove` argument is processed before the `apps` argument. If you try to remove an apt packge that doesn't exist it will log in /etc/sdm/apt.log and sdm will notify you at the end of the customize: '? apt reported errors; review /etc/sdm/apt.log'

#### Examples

* `--plugin apps:"remove=wolfram-engine|apps=emacs"` &mdash; Remove wolfram-engine, and install emacs
* `--plugin apps:"apps=@my-apps" --plugin apps:"apps=@my-xapps"` &mdash; Install the list of apps in the file @my-apps, and the list of apps in @my-xapps
* `--plugin apps:"apps=@my-apps|name=myapps" --plugin apps:"apps=@my-xapps|name=myxapps"` &mdash; Install the list of apps in the file @my-apps, and the list of apps in @my-xapps
* `--plugin apps:"apps=@mycoreapps|name=core-apps"` `--plugin apps:"apps=@myaddtlapps|name=extra-apps"` &mdash; Install the list of apps from @mycoreapps and @myaddtlapps

### apt-addrepo

apt-addrepo adds Repos and gpgkeys to apt

#### Arguments
* **gpgkey** &mdash; /path/to/keyname.gpg
* **gpgkeyname** &mdash; Provide a different filename for the key in /etc/apt/trusted.gpg.d
* **name** &mdash; Name of the repo file in /etc/apt/sources.list.d for a `repo` string
* **repo** &mdash; A repo string that will be written to the named file in /etc/apt/sources.list.d
* **repofile** &mdash; File containing an apt repo that is copied to /etc/apt/sources.list.d

#### Examples

* `--plugin apt-addrepo:"repo=deb  http://repo.feed.flightradar24.com flightradar24 raspberrypi-stable|gpgkey=/path/to/gpgkey.gpg"`
* `--plugin apt-addrepo:"repofile=/path/to/some-repo.list"`

### apt-cacher-ng

apt-cacher-ng installs the RasPiOS apt-cacher-ng service into the IMG or onto the SSD/SD card (If used with `--burn`).

#### Arguments

**NOTE: All arguments are optional**

* **gentargetmode** &mdash; Possible values: 'Set up once', 'Set up now and update later', and 'No automated setup'. [Default: 'No automated setup']. TBH not sure what this does. If you figure it out, let me know ;)
* **bindaddress** &mdash; the IP address to which the server should bind. [Default: 0.0.0.0], which is all IP addresses on the server.
* **cachedir** &mdash; apt-cacher-ng directory. [Default: */var/cache/apt-cacher-ng*]
* **port** &mdash; TCP port [Default: 3142]
* **tunnelenable** &mdash;Do not enable this. [Default: *false*]
* **proxy** &mdash;TBH not sure what this does. If you figure it out, let me know ;)

The default apt-cacher-ng server install uses port 3142. apt-cacher-ng will be enabled by sdm FirstBoot and ready to process requests after the FirstBoot process completes.

NOTE: The apt-cacher-ng plugin installs the apt-cacher-ng *server*. The `--aptcache` command line switch configures the IMG to be an apt-cacher-ng *client* and use the specified apt-cacher-ng server.

The plugin configures apt as a client to use itself as the apt caching server. This is typically not what you want on every system, so consider using `--plugin apt-cacher-ng` on the `--burn` command line for those systems that will be actually be deployed as apt caching servers.

#### NOTES

Unfortunately the `apt-cacher-ng` package has some issues. These show up at totally random times in cacher clients as "invalid hash" or "check DiMaxRetries" and probably some other strange and wondrous messages.

Quite annoying, but even so, I think `apt-cacher-ng` is still much better than waiting for apt downloads unless you're on a super-fast connection and have high-speed connectivity between you and the apt servers.

When `apt-cacher-ng` craps out, login on the caching server and issue the following command: `sudo reset-apt-cacher`, and then try the client operation again. The `apt-cacher-ng` plugin installs `reset-apt-cacher` during customization.

### apt-config

apt-config provides some control over apt in the customized IMG

#### Arguments

* `no-install-recommends` &mdash; Disable installing recommended software
* `confold` &mdash; &mdash; always keep old unmodified copy of a config file without prompting
* `confdef` &mdash; prefer the default method in the package for handling config file conflicts. If no default action specified by a package, falls back to `confold` if specified
* `nopager` &mdash; Disable use of pager in `apt` listing commands
* `nocolor` &mdash; Disable use of color in `apt` listing commands

#### Examples

* `--plugin apt-config:"no-install-recommends|nopager|nocolor"` &mdash; Disable installing recommended software and paged and colored apt listing output


### apt-file

apt-file installs the *apt-file* command and builds the database. This is very handy for looking up apt-related information.

#### Arguments

There are no `--plugin` arguments for apt-file

### bootconfig

The `bootconfig` plugin configures the contents of /boot/firmware/config.txt.

#### Arguments

* **comment** &mdash; Append the comment to the end of config.txt. Comments can also be specified by an argument starting with `#` or `\n`. In the latter case, the comment is transformed to `\n# comment string` resulting in a blank line before the comment.
* **commentize** &mdash; Comment out the specified line if it exists in config.txt. The line must be fully-specified and exactly match.
* **inline** &mdash; If `inline` is provided as an argument (does not take a value), the plugin will replace existing settings in config.txt (if they exist) with any new value provided to the plugin. If it doesn't exist, or if `inline` is not provided, new arguments are appended to the end of the file.
* **reset** &mdash; If `reset` is provided /boot/firmware/config.txt will be saved as /boot/firmware/config.txt.sdm. If no value is provided for `reset` then /boot/firmware/config.txt will be set to a null file. If `reset=/path/to/file` is provided, the specified file will replace /boot/firmware/config.txt. To work correctly, `reset` must be specified before any other arguments (this is not enforced or specifically logged by sdm).
* **section** &mdash; The `section` argument takes a value like `pi4` or `[pi4]`, and appends the appropriately-bracketed section value to the end of config.txt preceded by a blank line.

* **somename=somevalue** &mdash; All other key/value settings are presumed to be settings in config.txt and added to it. There is no validity checking, so typos are propagated. But, on the other hand, the `bootconfig` plugin doesn't need to be updated every time a brand new setting is added to config.txt.  **NOTE:** Each `somename` can only be used once per `bootconfig` plugin invocation. See the examples in the following section for further details.

#### Examples

* `--plugin bootconfig:"section=[pi4]|somesetting=somevalue"`
* `--plugin bootconfig:"commentize=camera_auto_detect=1"`
* `--plugin bootconfig:"inline|hdmi_group=72|hdmi_force_hotplug=1|hdmi_mode=40|hdmi_ignore_edid"` &mdash; The plugin adds the correct value for `hdmi_ignore_edid` (0xa5000080)
* `--plugin bootconfig:"reset|dtparam=audio=on|camera_auto_detect=1|display_auto_detect=1|dtoverlay=vc4-kms-v3d|max_framebuffers=2|arm_64bit=1|disable_overscan=1|section=cm4|otg_mode=1|section=pi4|arm_boost=1|section=all"` &mdash; An identical replacement for the Bullseye /boot/config.txt but with no comments or blank lines

You may want to add multiple `dtparam` items to config.txt, and be tempted to put all of them in a single invocation, such as:
```
--plugin bootconfig:"dtparam=fan_temp1=62500,fan_temp1_hyst=5000,fan_temp1_speed=128|dtparam=fan_temp0=55000,fan_temp0_hyst=5000,fan_temp0_speed=75"
```
This does not work. These must be broken up into separate plugin invocations:
```
--plugin bootconfig:"dtparam=fan_temp1=62500,fan_temp1_hyst=5000,fan_temp1_speed=128"
--plugin bootconfig:"dtparam=fan_temp0=55000,fan_temp0_hyst=5000,fan_temp0_speed=75"
```
Alternatively, you can use:
```
--plugin bootconfig:"dtparam=fan_temp1=62500,fan_temp1_hyst=5000,fan_temp1_speed=128,fan_temp0=55000,fan_temp0_hyst=5000,fan_temp0_speed=75"
```
RasPiOS has a line length limit of 98 for config.txt, and silently ignores characters beyond that length. The bootconfig plugin limits lines to 96 characters.

### btwifiset

btwifiset is a service that enables WiFi SSID and password configuration over Bluetooth using a mobile app. Once the service is running, you can use the `BTBerryWifi` iOS app to connect to the service running on your Pi and configure the WiFi. See https://github.com/nksan/Rpi-SetWiFi-viaBluetooth for details on btwifiset itself.

#### Arguments

* **country** &mdash; The WiFi country code. This argument OR **wificountry** is mandatory
* **wificountry** &mdash; Another way to specify the WiFi country code, compatible with other plugins
* **localsrc** &mdash; Locally accessible directory where the btwifiset.py can be found, instead of downloading from GitHub
* **btwifidir** &mdash; Directory where btwifiset will be installed. [Default: */usr/local/btwifiset*]
* **password** &mdash; Password to use for encrypted bluetooth communication [Default: Host name on which btwifiset runs after boot]
* **timeout** &mdash; After *timeout* seconds the btwifiset service will exit [Default: *15 minutes*]
* **logfile** &mdash; Full path to btwifiset log file [Default: *Writes to syslog*]

### chrony

Chrony installs the chronyd time service.

#### Arguments

* **conf** &mdash; /full/path/to/confname.conf that will be placed into /etc/chrony/conf.d
* **conf2** &mdash; /full/path/to/confname2.conf that will be placed into /etc/chrony/conf.d
* **conf3** &mdash; /full/path/to/confname3.conf that will be placed into /etc/chrony/conf.d
* **sources** &mdash; /full/path/to/sourcename.conf that will be placed into /etc/chrony/sources.d
* **sources2** &mdash; /full/path/to/sourcename2.conf that will be placed into /etc/chrony/sources.d
* **sources3** &mdash; /full/path/to/sourcename3.conf that will be placed into /etc/chrony/sources.d
* **nodistsources** &mdash; Removes the Debian vendor zone pool from chrony.conf

Chrony processes the files in the conf.d and sources.d directories on startup. Having 3 provides flexibility in how these are structured. See `man chrony.conf` for details.

A RasPiOS system should only have one time service enabled. It's up to you to disable others. For instance, on a standard RasPiOS IMG you should add `--svc-disable systemd-timesyncd` to disable the in-built time service, which is enabled by default.

NOTES:
* At least on Bookworm (didn't check earlier versions) installing chrony causes systemd-timesyncd to be removed.
* Adding `iburst` to a `server` or `pool` statement in a sources file seems to result in chrony syncing the time much more quickly

### clockfake

The fake-hwclock provided with RasPiOS runs hourly as a cron job. clockfake does the same thing as fake-hwclock, but you control the interval, and it's always running. Lower overhead, less processes activated, and more control. Life is good.

#### Arguments

* **interval** &mdash; Interval in minutes between fake hardware clock updates

### cloudinit

The `cloudinit` plugin facilitates adding additional yaml information to /boot/firmware/user-data, which will get processed at the next reboot.

#### Arguments

* **cfg** &mdash; Specifies a comma-separated list of yaml files with file type `.cfg` to place in /etc/cloud/cloud.cfg.d for system-level configuration
* **netconfig** &mdash; Specifies a comma-separated list of yaml files with file type `.yaml` to append to /boot/firmware/network-config for network configuration
* **userdata** &mdash; Specifies a comma-separated list of yaml files with file type `.yaml` to append to /boot/firmware/user-data for user-level configuration

The `cfg` files are processed by cloud-init in lexical order. Values in lexically later files overwrite values in earlier files.

See https://www.raspberrypi.com/news/cloud-init-on-raspberry-pi-os/ for overview information on RasPiOS and cloud-init.

Refer to <a href="https://cloudinit.readthedocs.io/en/latest/reference/modules.html">Complete cloud-init documentation</a> for details on the available cloud-init modules, examples, etc.

After cloud-init has processed the user-data file, subsequent runs will NOT redo the operations unless something changes in the OS (app or configuration removed, etc).

If desired, cloud-init processing can be disabled by: `sudo touch /etc/cloud/cloud-init.disabled`. Similarly, cloud-init can be re-enabled by `sudo rm -f /etc/cloud/cloud-init.disabled`.

#### Examples

* `--plugin cloudinit:"cfg=/path/to/99cfg1.cfg,/path/to/99cfg2.cfg|netconfig=/path/netcfg.yaml|userdata=/path/usercfg.yaml"`

### cmdline

Replace cmdline.txt with a new command line and/or modify the existing cmdline.txt. If /boot/firmware/cmdline.txt is present it will be used. If not, /boot/cmdline.txt is assumed.

#### Arguments

* **add** &mdash; Add the specified elements to the existing cmdline.txt. If element exists in cmdline.txt already it is replaced.
* **delete** &mdash;  Delete the specified elements from the existing cmdline.txt
* **replace** &mdash; Replace the entire contents of cmdline.txt with the provided new cmdline

`add`, `delete`, and `replace` can each only be specified once per plugin invocation. If there are multiple, the last one wins. If this is needed for some reason, use multiple invocations of the `cmdline` plugin.

#### Examples

* `--plugin cmdline:"add=video=HDMI-A-1:1920x1080@60D"` &mdash; Add the string `video=HDMI-A-1:1920x1080@60D` to cmdline.txt
* `--plugin cmdline:"delete=console splash"` &mdash; Remove the strings `console` and `splash` from cmdline.txt
* `--plugin cmdline:"replace="consoleblank=3600 root=PARTUUID=6ea5963a-02 rootfstype=ext4 fsck.repair=yes rootwait"` &mdash; Replace cmdline.txt with the provided new cmdline

### copydir

Copy a directory tree from the host system into the IMG

#### Arguments
* **from** &mdash; /full/path/to/sourcedir
* **to** &mdash; /full/path/to/destdir
* **rsyncopts** &mdash; Additional switches for the `rsync` command. If `rsyncopts` is specified, ALL desired rsync switches must be included. If `rsyncopts` is NOT provided, the default switch `-a` is used
* **stderr** &mdash; /path/to/file where stderr from the rsync command is written [D:/dev/null]
* **stdout** &mdash; /path/to/file where stdout from the rsync command is written [D:/dev/null]

The copydir plugin behavior is dependent on whether the `from` file contains a trailing slash, just like the rsync command. **The rsync man page states:** A trailing  slash on the source changes this behavior to avoid creating an additional directory level at the destination.  You can think of a trailing / on a source as meaning "copy the contents of this directory" as opposed to "copy the directory by name", but in both cases the attributes of the containing  directory are transferred to the containing directory on the destination. 

### copyfile

Copy one or more files from the host system into the IMG

#### Arguments

* **from** &mdash; /full/path/to/sourcefile on the host system
* **to** &mdash; /path/in/IMG to place the file in the IMG. This must be a directory, not a file. The directory must already exist
* **chown** &mdash; The `user:group` to set the file ownership
* **chmod** &mdash; The mode to set the file protection (e.g., 755, 644, etc)
* **mkdirif** &mdash; Create the directory if it doesn't exist
* **runphase** &mdash; Normally files are copied to their final destinations in Phase 1. Use `runphase=postinstall` to have a single file copied in the post-install phase
* **filelist** &mdash; The /full/path/to/file of a file on the host OS of a list of files to copy. See below.

The `filelist=/full/path/to/file` option points to a file that consists of one line per file in the format:
```
from=/path/to/file|to=/some/dir|chown=user:group|chmod=filemode|runphase=postinstall
```
chown and chmod are optional. If not specified, the file attributes will not be set, and will be whatever they were on the host system. `runphase` is optional, and if not specified, the file is copied in Phase 1.

copyfile copies the files into the IMG in /etc/sdm/assets/copyfile during Phase 0, and copies them into their target locations in the phase 1 or post-install phase (conditioned on `runphase`) once all packages have been installed, all users have been added, etc.

#### Examples

* `--plugin copyfile:"from=/usr/local/bin/myconf.conf|to=/usr/local/etc"` The config file will be copied from /usr/local/bin/myconf.conf on the host system to /usr/local/etc/myconf.conf in the IMG during Phase1. The file will be owned by the same user:group as on the host, the file protection will be the same as well.
* `--plugin copyfile:"filelist=/usr/local/bin/myfileslist"`. The list of files in the provided `filelist` will be processed per above.

### cryptroot

Configures the rootfs for encryption. See <a href="Disk-Encryption.md">Disk Encryption</a> for complete details

#### Arguments

* **authkeys** &mdash; Provides an SSH authorized keys file for use in the initramfs
* **crypto** &mdash; Specifies the encryption to use. `aes` used by default. Use `xchacha` on Pi4 and earlier for best performance.
* **dns** &mdash; DNS server address for the intramfs network client to use
* **gateway** &mdash; gateway address for the intramfs network client to use
* **ihostname** &mdash; hostname for the intramfs network client to use
* **ipaddr** &mdash; IP address for the intramfs network client to use
* **keyfile** &mdash; A keyfile used for passphrase-less booting. See <a href="Disk-Encryption.md#unlocking-rootfs-with-a-usb-keyfile-disk">Unlocking rootfs with a USB Keyfile Disk</a> for details
* **mapper** &mdash; Mapper name for the rootfs encryption (shows up, for instance, in the `df` listing)
* **netmask** &mdash; Network mask for the intramfs network client to use
* **no-expand-root** &mdash; Do not expand the encrypted rootfs. See <a href="Disk-Encryption.md#btrfs-rootfs-and-rootfs-expansion">btrfs and rootfs expansion</a> for details.
* **nopwd** &mdash; Configure only a keyfile to unlock the rootfs. No passphrase will be configured. The `keyfile` argument is required
* **ssh** &mdash; Enable SSH in the initramfs
* **sshbash** &mdash; Leave bash enabled in the SSH session rather than switching to the captive cryptroot-unlock (DEBUG only!)
* **sshport** &mdash; Use the specified port rather than the Default 22
* **sshtimeout** &mdash; Use the specified timeout rather than the Default 300 seconds
* **uniquesshkey** &mdash; Use a unique SSH key in the initramfs. Default is to use the host SSH key (of the system being encrypted)

`authkeys` is required with `ssh`

These are discussed further in the above-mentioned Disk Encryption page.

#### Examples

* `--plugin cryptroot:"authkeys=/home/bls/.ssh/authorized_keys|ssh` Configures the rootfs for encryption and enables SSH into the initramfs with keys authorized in the named authorized_keys file.

### disables

The disables plugin makes it easy to disable a few *complex* functions.

#### Arguments

* **bluetooth** &mdash; Disables bluetooth via a blacklist file in /etc/modprobe.d
* **cloudinit** &mdash; Disables cloud-init services.
* **piwiz** &mdash; Disables piwiz during the first system boot. You must set up everything with sdm that piwiz does or you may not like the results: User, Password, Keymap, Locale, and Timezone.
* **triggerhappy** &mdash; Disable the triggerhappy service. If you're not using it, this will eliminate the log spew it creates
* **wifi** &mdash; Disables WiFi via a blacklist file in /etc/modprobe.d

#### Examples

* `--plugin disables:"bluetooth|piwiz|triggerhappy"` &mdash; Disable Bluetooth, Triggerhappy, and piwiz, but leave WiFi enabled

### docker-install

Installs Docker per <a href="https://docs.docker.com/engine/install/debian/">the Docker install guide</a>.

#### Arguments

This plugin has no arguments

#### Examples

* `--plugin docker-install`

### dovecot-imap

The `dovecot-imap` installs and configures dovecot as an imap server.

#### Arguments

These arguments are for configuring the openssl cert that is generated. They are all optional at the moment.

* **email-address** &mdash; Specify the email address to include in the generated SSL Cert
* **common-name** &mdash; Specify the common name to include in the generated SSL Cert
* **org-name** &mdash; Specify the org name to include in the generated SSL Cert

#### Examples

* `--plugin dovecot-imap:"email-address=root@mydomain.com|common-name=MyCommonName.com|org-name=MyOrgname"`
* `--plugin dovecot-imap`

### explore

The `explore` plugin is a `--burn-plugin` that can be used to explore or mount the newly-burned device after the burn has completed.

### Arguments

* **mount** &mdash; Mount the device into the host system rather than exploring the device container

#### Examples

* `--burn-plugin explore` &mdash; After the burn completes mount the device and enter the container.
* `--burn-plugin explore:mount` &mdash; Like the previous example, but does not enter the container and operates in the context of the host system.

### extractfs

The `extractfs` plugin is a non-general purpose `--burn-plugin` that is used to copy the `boot` and `root` trees from an IMG into directories in the file system

#### Arguments

* **bootfs** &mdash; Directory where the `boot` tree will be written
* **rootfs** &mdash; Directory where the `root` tree will be written
* **img** &mdash; /path/to/IMG.IMG from which the trees will be copied

#### Examples

* `--burn-plugin extractfs:"bootfs=/path/to/bootfs|rootfs=/path/to/rootfs"`

### gadgetmode

Configures a Pi to be in gadget mode so it can connect via USB to a gadget mode host providing it with a network connection.

#### Arguments

* `autoconnect-retries` &mdash; Sets the number of retries for the gadget to obtain a DHCP address via the USB gadget connection [D:5]
* `dhcp-timeout` &mdash; Configures the DHCP timeout for each attempt to get a DHCP address via the USB connection [D:60]
* `gadget-mode` &mdash; Configures the gadget mode. Default is unshared `simple` mode. `gadget-mode=shared` enables the gadget device to be shared using libcomposite
* `mac-vendor` &mdash; Specifies the first 3 segments of the MAC address. [D:dc:a6:32]
* `static-ip` &mdash; Specifies a static IP address to be used for the gadget. This also forces a static MAC address
* `static-mac` &mdash; Configures the provided static MAC address for the USB gadget device. Useful so the Pi gets the same IP address every time, but only with `gadget-mode=simple` If `static-mode` is specified without a value, the plugin will generate a MAC address and make it static.
* `noipv6` &mdash; Do not configure ipv6 on the gadget USB connection

#### Examples

* `--plugin gadgetmode:"static-mac=aa:bb:cc:dd:ee:ff"` &mdash; Configure simple gadget mode with a static MAC address
* `--plugin gadgetmode:"gadget-mode=libcomposite|static-mac=fa:ce:fe:ed:00" &mdash; Configure shared gadget mode with a static MAC address

#### Notes

* The `autoconnect-retries` and `dhcp-timeout` values are set high to improve success when connected to slower devices

### git-clone

Clones the specified repository to the specified directory.

#### Arguments

* `repo` &mdash; Full path to the git repository. Must be network-accessible either via https or some other mechanism (NFS, etc)
* `gitdir` &mdash; Directory into which to place the clone. sdm will do a `mkdir -p` to ensure the directory exists. The clone is done directly into the specified directory
* `gitsw` &mdash; Additional switches to use on the `git` command
* `user` &mdash; User that will be used to run git. The user must already exist
* `preclone` &mdash; Command to run immediately before the clone. If the command starts with `@` it is the name of a script to run
* `postclone` &mdash; Command to run immediately after the clone. Otherwise same as `preclone`
* `gitphase` &mdash; By default the `git` command is run in sdm Phase 1. Specify `gitphase=post-install` to run git in the post-install phase.
* `cert` &mdash; Not Yet Implemented
* `logspace` &mdash; Specify this flag to have the disk space logged immediately before and after the `git clone`

#### Examples

* `--plugin git-clone:"repo=https://github.com/gitbls/sdm|gitdir=/home/bls/work/sdm|user=bls|logspace"` &mdash; Clone the sdm repo into /home/bls/work/sdm as user bls. Disk space will be logged before and after the clone.

### graphics

The graphics plugin configures various graphics-related settings. It doesn't do much for wayland at the current time, although you might use it to set the video mode in /boot/firmware/cmdline.txt.

#### Arguments

* **graphics** &mdash; Supported values for the graphics keyword are `labwc`, `wayfire` and `X11`.

    If `graphics` is set to `labwc` or `wayfire`, the corresponding software (labwc or wayfire) must already be installed. sdm will use raspi-config to appropriately configure lightdm as requested.

    If `graphics` is set to `X11`, the Core X11 packages (xserver-xorg, xserver-xorg-core, and xserver-common) are installed if not already installed. In the post-install phase, the plugin will look for a known Display Manager (lightdm, xdm, or wdm), and make appropriate adjustments (see below)

* **nodmconsole** &mdash; If `graphics=X11`, `nodmconsole` directs sdm to NOT start the Display Manager on the console, if the Display Manager is lightdm, wdm, or xdm.
* **videomode** &mdash; Specifies the string to add to the video= argument in cmdline.txt. See below for an example.

Currently, labwc is the Default graphics subsystem on Bookworm with Desktop images, so `graphics=labwc` is effectively redundant on those images. The plugin currently will not install labwc or wayfire on a Bookworm Lite IMG. labwc and wayfire are not supported by sdm on releases prior to Bookworm.

If `graphics=X11` and the Display Manager is known, the graphics plugin makes a few adjustments. Specifically:
* If LXDE is installed, the mouse will be set to left-handed if specified on the command line. This works for wayland as well.
* For Display Managers lightdm, wdm, and xdm, sdm will cause the boot behavior you might specify to be delayed until after the First Boot.

For `graphics=labwc` or `graphics=wayfire`, use the `labwc` or `lxde` plugin to perform specific configuration such as `lhmouse` and/or apply personalized configuration settings.

The videomode argument takes a string of the form: 'HDMI-A-1:1024x768M@60D'. sdm will add video=HDMI-A-1:1024x768M@60D to /boot/firmware/cmdline.txt

#### Examples

* `--plugin graphics:"graphics=X11|nodmconsole"` &mdash; Installs the X11 core components and disables the Display Manager on the console
* `--plugin graphics:"videomode=HDMI-A-1:1920x1280@60D"` &mdash; Sets the specified video mode in /boot/firmware/cmdline.txt

### hotspot

The hotspot plugin configures the specified wireless device or USB0 to be a hotspot. The hotspot plugin supports Bookworm and later releases and is implemented using NetworkManager. In most situations a routed hotspot is preferable, but both are provided.

#### Arguments

* **config** &mdash; Config file with all the arguments (see Example)
* **device** &mdash; Device name [D:wlan0]. Use `device=usb0` for a tether host.
* **dhcpmode** &mdash; Mode for DHCP server. Controls whether NetworkManager uses its internal dnsmasq DHCP server or not. Valid settings are `none` and `nm`. If set to `none`, you must configure a DHCP server for the hotspot. [D:nm] If `dhcpmode` == `none` then `wlanip` must be provided.
* **hsenable** &mdash; If **hsenable=y** set the hotspot to enable as part of system boot [D:y]. Can be specified as simply `hsenable`. To disable, use `hsenable=n`
* **hsname** &mdash; Set the hotspot name [D:Hotspot]
* **ipforward** &mdash; For routed hotspots, controls whether IP forwarding is enabled. If specified, must be the name of the network device to which network traffic is forwarded. [D:""] For bridged hotspots `ipforward` controls the network device to which the WiFi traffic is bridged [D:eth0]
* **portal** &mdash; Install the portal <a href="https://www.raspberrypi.com/tutorials/host-a-hotel-wifi-hotspot">described here</a> as a service that runs at system startup. `portalif` must be specified.
* **portalif** &mdash; Use the specified WiFi device for the portal. A second adapter is required, so typically it will be wlan1 (but not defaulted).
* **pskencrypt** &mdash; Save the encrypted PSK in the .nmconnection file rather than the plaintext PSK
* **type** &mdash; Type of hotspot (*routed* or *bridged*) [D:routed]
* **wifipassword** &mdash; WiFi hotspot password [D:password]
* **wifissid** &mdash; WiFi hotspot SSID [D:MyPiNet]
* **wlanip** &mdash; IP address of the hotspot in routed mode when `dhcpmode` == `none` [D:""]. `wlanip` is ignored in bridged mode and routed mode if `dhcpmode` == `nm` (the default)

These 3 arguments are used to augment the NetworkManager config settings for the hotspot or bridge. The argument string is taken *as is* and fed to an appropriate `nmcli` command. See the example below.

* **hotspot-add-config** &mdash; Add the specified config settings to the NetworkManager hotspot (routed or bridged hotspot)
* **bridge-add-config** &mdash; Add the specified config settings to the NetworkManager bridge (bridged hotspot)
* **bridge-slave-add-config** &mdash; Add the specified config settings to the NetworkManager bridge slave (bridged hotspot)

#### Examples

* `--plugin hotspot` &mdash; Create a routed hotspot named Hotspot on wlan0 with WiFi SSID 'MyPiNet', password 'password'. NetworkManager will use its internal DHCP server. wlan0's IP address will be set to the NetworkManager default (10.42.0.1). No IP forwarding is configured. The hotspot will be enabled.
* `--plugin hotspot:"hotspot-add-config=802-11-wireless.hidden true"` &mdash; As above, but add `802-11-wireless.hidden true` to the hotspot configuration. `bridge-add-config` and `bridge-slave-add-config` operate similarly.
* `--plugin hotspot:"hsname=myhotspot|wifissid=myssid|wifipassword=mypassword|ipforward=eth0|hsenable|type=routed"` &mdash; Configure a routed hotspot named `myhotspot` on wlan0 (the default), with SSID `myssid` and password `mypassword`, forwarding IP traffic to `eth0`.
* `--plugin hotspot:"device=wlan1|hsname=myhotspot|ipforward=eth0|hsenable|type=routed|dhcpmode=none|wlanip=10.6.0.1"` &mdash; Configure a routed hotspot on wlan1. wlan1's IP address will be set to 10.6.0.1, and you must configure your own DHCP server using, for instance, dnsmasq or the sdm plugin `ndm`

    **Example** using the ndm plugin to configure dnsmasq (in pluglist format):
    `ndm:dhcpserver=dnsmasq|dnsserver=dnsmasq|dobuild|doinstall|dhcprange=10.6.0.2,10.6.0.100|domain=me|externaldns=1.1.1.1|gateway=10.6.0.1|myip=10.6.0.1|hostname=myap|dnsfqdn=myap.me|mxfqdn=myap.me|timeserver=10.6.0.1|netdev=wlan0|enablesvcs`

* `--plugin hotspot:"device=usb0|hsname=myusbhotspot|ipforward=eth0|hsenable|type=routed"` &mdash; Configure a routed hotspot on usb0 so it can be a tethering host
* `--plugin hotspot:"hsname=myhotspot|hsenable|type=bridged"` &mdash; Configure a bridged hotspot

The Config file consists of the above arguments (except for `config`), one per line. Arguments that are not provided are defaulted as specified above.
```
device=wlan0
hsenable=true
hsname=myhotspot
ipforward=eth0
type=routed
wifipassword=SecretPassword
wifissid=myhotspot
```

#### Notes

The `hotspot` plugin does not configure a firewall. Adding an appropriate firewall is important in *risky* environments.

The wireless device (specified with `device` and defaults to `wlan0`) cannot be both an Access Point and a WiFi client. If you need both the Access Point and WiFi client (to another WiFi network), you will need to use a second WiFi adapter.

### imon

imon installs an <a href="https://github.com/gitbls/imon">Internet Monitor</a> that can monitor:

* **Dynamic DNS (DDNS) Monitor** &mdash; Monitors your external IP address. If it changes changes, your action script is called to take whatever you'd like, such as update your ddns IP address.
* **Network Failover Monitor** &mdash; If your system has two connections to the internet, imon can provide a higher availability internet connection using a primary/secondary standby model.
* **Ping monitor** &mdash; Retrieve ping statistics resulting from pinging an IP address at regular intervals.
* **Up/down IP Address Monitor** &mdash; Monitors a specified IP address, and logs outages.

#### Arguments

There are no `--plugin` arguments for imon

### knockd

knockd installs the knockd service and <a href="https://github.com/gitbls/pktables">pktables</a> to facilitate easier knockd iptables management.

#### Arguments

* **config** &mdash; Full path to your knockd.conf. If **config** isn't provided, /etc/knockd.conf will be the standard knockd.conf
* **localsrc** &mdash; Locally accessible directory where pktables, knockd-helper, and knockd.service can be found, instead of downloading them from GitHub. If there is a knockd.conf in this directory, it will be used, unless overridden with the **config** argument

### L10n

Use the `L10n` plugin to set the localization parameters: `keymap`, `locale`, and `timezone`. You can find the valid values for these arguments with
```
sudo sdm --info keymap     # Displays list of valid keymaps
sudo sdm --info locale     # Displays list of valid locales
sudo sdm --info timezone   # Displays list of valid timezones
```

#### Arguments

* **keymap** &mdash; Specify the keymap to set
* **locale** &mdash; Specify the locale for the system
* **timezone** &mdash; Specify the timezone
* **wificountry** &mdash; Specify the WiFi country setting
* **host** &mdash; Get the above settings from the host system on which sdm is running

**NOTE:** To disable the RasPiOS initial boot query for these configuration items, add `--plugin disables:piwiz` to your customize or burn command line. This works for both Desktop and Lite IMGs.

#### Examples

* `--plugin L10n:"keymap=us|locale=en_US.UTF-8|timezone=America/Los_Angeles"`
* `--plugin L10n:"host"`

### labwc

Provide labwc your fully-configured desktop settings.

#### Arguments

* **all-config** &mdash; Specify an existing directory created by `sdm-collect-labwc-config`. This includes all the files that can be provided with `app-config` and `labwc-config`, so those arguments are not needed if `all-config` is provided. sdm does not check for any argument conflicts, but `all-config` is processed before any other arguments.
* **app-config** &mdash; Specify existing config files for `libfm`, `pcmanfm`, and `lxterminal`. See the example, and see <a href="Using-LXDE-Config.md">Using LXDE configuration</a> for details
* **labwc-config** &mdash; Specify existing config files for 'autostart', 'desktop-items', 'environment', 'menu', 'rc' 'shutdown' and 'themerc'
* **lhmouse** &mdash; Configure labwc for a left-handed mouse
* **numlock** &mdash; Configure the numlock state. Values (sdm does not validate): 'on', 'off'
* **user** &mdash; The settings apply to the specified user. If no `user` argument is specified, they apply to the first user created with the `user` plugin. The `user` plugin must be specified on the command line before the `labwc` plugin
* **wf-panel-pi** &mdash; Specify existing wf-panel-pi.ini config file for `wayfire` which is copied to the ~/.config directory of the specified user. HINT: Use `position=bottom` in this file to move the task bar to the bottom of the screen.

Use the `L10n` plugin to configure the labwc keymap.

If the IMG being customized does not have labwc installed, the assets will be copied to /etc/sdm/assets in Phase 0, but not applied to the user's home directory

The best way to use this plugin is:
* Boot a RasPiOS Desktop system with labwc (the default as of 2024-10-22)
* Configure the system as you'd like it, including pcmanfm, lxterminal, and labwm itself
* Run `/usr/local/sdm/sdm-collect-labwc-config` /path/to/savedir as the logged in user (e.g., no sudo)
  * If no argument provided /tmp/labwc will be used
* Copy the created directory to the system where you run sdm to customize IMGs
* Provide that directory to sdm when customizing an IMG: `--plugin labwc:all-config=/path/to/dir`

#### Examples

* `--plugin labwc:"all-config=/path/to/labwc-config-dir"
* `--plugin labwc:"app-config=libfm:/path/to/libfm.conf,pcmanfm=/path/to/pcmanfm.conf,lxterminal=/path/to/lxterminal.conf"`
* `--plugin labwc:"lhmouse|user=someuser"`
* `--plugin labwc:"labwc-config=autostart:/path/to/autostart,environment=/path/to/environment"`

### logwatch

Use the `logwatch` plugin to install the logwatch package.

#### Arguments
* **sendto** &mdash; Email address where logwatch report should be mailed. You must have a properly configured mail server to send the mail. See the `postfix` plugin
* **sendfrom** &mdash; Email address for where the mail should be sent *from*

#### Examples

* `--plugin logwatch:"sendto=myname\<myuser@myemail.com\>|sendfrom=myhost-logwatch\<myuser@myemail.com\>"

### lxde

Use the `lxde` plugin with `wayfire` to establish your preferred settings, such as left-handed mouse, and config files for `libfm`, `pcmanfm`, and `lxterminal`. These are not well-documented. The best way to create your personalized versions is to use RasPiOS to configure the desktop as you'd like it, and then save the files. NOTE: Use the `labwc` plugin for configuring labwc.

#### Arguments

* **lhmouse** &mdash; Set LXDE for a left-handed mouse
* **lxde-config** &mdash; Specify existing config files for `libfm`, `pcmanfm`, and `lxterminal`. See the example, and see <a href="Using-LXDE-Config.md">Using LXDE configuration</a> for details
* **user** &mdash; The settings apply to the specified user. If no `user` argument is specified, they apply to the first user created with the `user` plugin. The `user` plugin must be specified on the command line before the `lxde` plugin
* **wayfire-ini** &mdash; Specify existing wayfire.ini config file for `wayfire` which is copied to the ~/.config directory of the specified user
* **wf-panel-pi** &mdash; Specify existing wf-panel-pi.ini config file for `wayfire` which is copied to the ~/.config directory of the specified user. HINT: Use `position=bottom` in this file to move the task bar to the bottom of the screen.

#### Examples

* `--plugin lxde:"lxde-config=libfm:/path/to/libfm.conf,pcmanfm=/path/to/pcmanfm.conf,lxterminal=/path/to/lxterminal.conf"`
* `--plugin lxde:"lhmouse|user=someuser"`

### mkdir

Create the specified directory and optionally set directory owner and protection

#### Arguments

* **dir** &mdash; Full path of the directory to create
* **chmod** &mdash; Directory protection
* **chown** &mdash; Directory owner:group

#### Examples

* `--plugin mkdir:"dir=/usr/local/foobar|chown=bls:users|chmod=740"`

NOTE: The directory is created in Phase 0, so it is available as early as during customization. The owner and protection are not set until the post-install phase, since it's possible that the owner account may not be created until Phase 1.

### modattr

Use the `modattr` plugin to change file attributes such as the file owner and file protection.

#### Arguments

* **path** &mdash; File specification (see below)
* **chmod** &mdash; Directory protection
* **chown** &mdash; Directory owner:group
* **R** &mdash; Perform the chmod and/or chown recursively
* **recursive** &mdash; Same as `R`
* **runphase** &mdash; Specify the phase in which the attribute modifications will be done (`phase1` or `post-install`). Default is `phase1`
* **verbose** &mdash; Specify the verbosity level (`changes`, `silent`, or `verbose`), corresponding to the chown/chmod switches `--changes`, `--silent`, and `--verbose`

#### Path argument processing notes

The `path` argument is processed as follows:
* **Single file:** Attributes of that file will be modified
* **Directory:**  Attributes of the directory will be modified, using `--recursive` if `R` or `recursive` provided
* **Wildcard specification:** each expanded element is examined and processed as either a directory or file

#### Examples

* `--plugin modattr:"path=/path/to/file|chown=user:group|chmod=644"` &mdash; Change the file owner and protection of the specified file
* `--plugin modattr:"path=/path/to/dir|chown=user:group|chmod=755|R"` &mdash; Change the file owner and protection recursively of the specified directory. If recursive is not specified, only the given directory will be modified.
* `--plugin modattr:"path=/path/to/dir/*|chmod=755|R"` &mdash; Change the file protection on all files matching the provided `path`. Matches that are directories will be processed per above.

### ndm

The `ndm` plugin installs ndm (https://github.com/gitbls/ndm), named (bind9) and isc-dhcp-server which enables the resulting system to operate as a full DHCP/DNS server with an easy-to-use command-line interface. ndm makes it super-simple to run your own DHCP/DNS server on RasPiOS with useful logging capabilities.

#### Arguments

* **config** &mdash; Existing ndm config file (dbndm.json) to build a new server with an existing ndm config file
* **dhcplease** &mdash; Sets the DHCP lease time in seconds (Default: ndm defaults to 86400)
* **dhcpserver** &mdash; Specifies which DHCP server to use (dnsmasq or isc-dhcp-server) (Default: isc-dhcp-server)
* **dnsserver** &mdash;  Specifies which DNS server to use (bind9 or dnsmasq). (Default: bind9). If dnsmasq is chosen for either dhcpserver or dnsserver they both must be set to dnsmasq.
* **dobuild** &mdash; Do an `ndm build` after the system has been configured. See <a href="Plugins.md#building-installing-and-enabling-services">building, installing and enabling services</a>
* **doinstall** &mdash; Do an `ndm install` after the system has been configured. See <a href="Plugins.md#building-installing-and-enabling-services">building, installing and enabling services</a>
* **enablesvcs** &mdash; Enable the DHCP and DNS server services after configuration. See <a href="Plugins.md#building-installing-and-enabling-services">building, installing and enabling services</a>
* **importnet** &mdash; Provides /path/to/import-host-list.txt, which is a list of host definitions to import. See <a href="https://github.com/gitbls/ndm#importing-a-network-database"> importing a network database</a> for details on the host definition format.
* **localsrc** &mdash; Specifies the directory containing the already-downloaded ndm files

In addition, these arguments, which control the ndm DHCP and DNS configuration, are also accepted. See the <a href="https://github.com/gitbls/ndm">ndm documentation </a> for details.

* **dhcprange** &mdash; Sets the range of addresses that the DHCP server will serve dynamically
* **dnsfqdn** &mdash; FQDN of the host on which ndm will be running [D:`hostname`.`domain`]
* **domain** &mdash; Domain name [D:my.sdm]
* **externaldns** &mdash; IP address of the external (internet) DNS server
* **gateway** &mdash; Gateway IP from LAN to the internet
* **hostname** &mdash; Hostname of the host on which ndm will be running
* **mxfqdn** &mdash; Mail server FQDN. Use the DNS server FQDN if you don't have a mail server
* **myip** &mdash; IP address of host on which ndm will be running. **NOTE:** This does NOT configure the network. Use the `network` plugin for that.
* **netdev** &mdash; Network device that the DNS and DHCP servers listen on [D:eth0]
* **timeserver** &mdash; IP address of timeserver to provide to DHCP clients

The `ndm` plugin will install the requested DHCP and DNS server services, and configure them appropriately per the provided arguments.

#### Building, installing, and enabling services

The `dobuild` argument requires one of:
* An ndm config file via argument `config`
* OR all of these arguments: `dhcprange`, `dnsfqdn`, `domain`, `externaldns`, `gateway`, `hostname`, `mxfqdn`, `myip`, `netdev`, and `timeserver`

The `doinstall` argument requires a satisfied `dobuild`

The `enablesvcs` argument requires satisfied `dobuild` and `doinstall` arguments

#### Examples

* `--plugin ndm` &mdash; Installs ndm, named, and isc-dhcp-server. Both named and isc-dhcp-server services are disabled, and must be re-enabled once ndm has been used to generate the config files for these two services.
* `--plugin ndm:"config=/path/to/dbndm.json|dhcpserver=dnsmasq|dnsserver=dnsmasq|dobuild|doinstall|netdev=eth0"` &mdash; Installs dnsmasq, performs an `ndm build` and `ndm install`, but does not enable the services.
* Also see the example <a href="#hotspot">used in conjunction with the `hotspot` plugin</a>

### network

Use the network plugin to configure various network settings. Each invocation of the `network` plugin performs one of two functions:
* Configure network settings using the `nmconf` and `nmconn` arguments to provide ready-to-go files for NetworkManager
* Configure a single connection for a single device. A device can have more than one connnection configured for it, but pay attention to `autoconnect` and `autoconnect-priority` so that the proper connection is started by default.

sdm does not pay attention to, nor do anything to improve or restrict multiple connections on a single device. They will work correctly when properly configured.

#### Arguments

All arguments except `dhcpcdappend`, `dhcpcdwait`, `nowifi`, and `wpa` are valid for NetworkManager. The only arguments valid for dhcpcd are these four plus `noipv6`

* **netman** &mdash; Specify which network manager to use. Supported values are `dhcpcd`, `network-manager`, and `nm` (short for network-manager). If `netman` is not specified, by default sdm will use dhcpcd on Bullseye (Debian 11) and earlier, while on Bookworm and later sdm will use NetworkManager.
* **autoconnect** &mdash; Takes the value `true` or `false`. Sets the connection's autoconnect value
* **autoconnect-priority** &mdash; Sets the connection's `autoconnect-priority` to the provided value
* **cname** &mdash; Name the NetworkManager connection. Default is `ifname`, the interface name
* **ctype** &mdash; If cname is a WiFi device with a name other than `wlan*`, specify `ctype=wifi`
* **dhcpcdappend** &mdash; Specifies a file that should be appended to /etc/dhcpcd.conf. Only processed if `netman=dhcpcd`
* **dhcpcdwait** &mdash; Specifies that dhcpcd wait for network online should be enabled. Only processed if `netman=dhcpcd`
* **ifname** &mdash; Specifies network device name to configure. Default is `eth0`. To configure WiFi using `wifissid` and `wifipassword` `ifname` must be specified and configured to a WiFi device (e.g., `wlan0`). 
* **ipv4-route-metric** &mdash; Specify the route metric for the network
* **nmconf** &mdash; Specifies a comma-separated list of NetworkManager config files that are to be copied to /etc/NetworkManager/conf.d (*.conf)
* **nmconn** &mdash; Specifies a comma-separated list of NetworkManager connection definitions (each a separate file) that are to be copied to /etc/NetworkManager/system-connections (*.nmconnection)
* **nmdebug** &mdash; Enables NetworkManager debug mode logging for those hard-to-diagnose NM issues
* **noipv6** &mdash; Specifies that IPv6 should be disabled for this connection. Works with both `netman=dhcpcd` and `netman=nm`
* **nowifi** &mdash; If `netman=dhcpcd` and WiFi settings not configured, this prevents a warning message about no WiFi configured
* **powersave** &mdash; Specify the WiFi powersave setting. Values: **0**:Use default value; **1**:Leave as is; **2**:Disable powersave; **3**:Enable powersave
* **ipv4-static-ip** &mdash; Configure the connection with this static IP address and subnet mask. The default subnet mask `/24`.
* **ipv4-static-gateway** &mdash; Configure the connection with this static gateway
* **ipv4-static-dns** &mdash; Configure the connection with this DNS server IP
* **ipv4-static-dns-search** &mdash; Set DNS suffix search list for the configuration (Ex: `ipv4-static-dns-search=my.com,dyn.my.com`)
* **pskencrypt** &mdash; Save the encrypted PSK in the .nmconnection file rather than the plaintext PSK
* **wifissid** or **wifi-ssid** &mdash; Specifies the WiFi SSID for the connection. If `ifname` is configured and is a WiFi device, and `wifissid`, `wifipassword`, and `wificountry` are all set, the network plugin will configure the WiFi connection (NetworkManager) or will create /etc/wpa_supplicant/wpa_supplicant.conf (if `netman=dhcpcd`).
* **wifipassword** or **wifi-password** &mdash; Password for the `wifissid` network. See `wifissid`
* **wificountry** or **wifi-country** &mdash; WiFi country for the `wifissid` network. See `wifissid`
* **wpa** &mdash; Specifies the file to be copied to /etc/wpa_supplicant/wpa_supplicant.conf. Only processed if `netman=dhcpcd`. NetworkManager does not use wpa_supplicant.conf
* **zeroconf** &mdash; (NetworkManager only) If eth0 does not properly connect (e.g., doesn't get a DHCP address) then bring up zeroconf (169.254.x.y) on the adapter.

  This can take some time due to NetworkManager default settings and timeouts. You can use the NetworkManager settings `ipv4.dhcp-timeout` and `connection.autoconnect-retries`  on the eth0 nmconnection to reduce the delay if desired.

  See <a href="https://networkmanager.dev/docs/api/latest/nm-settings-nmcli.html">Network Manager nmcli settings</a> for complete details on connection settings.

#### Examples

* `--plugin network:"ifname=eth0"` &mdash; Configure network connection for device `eth0`. It will be configured for both IPV4 and IPV6 DHCP configuration. The connection will be named `eth0`
* `--plugin network:"ifname=eth0|cname=myeth0"` &mdash; As above, but the connection will be named `myeth0`
* `--plugin network:"nmconf=file1.conf,file2.conf|nmconn=/path/to/myconn1.nmconnection,/path/to/myconn2.nmconnection"` &mdash; Copy the provided NetworkManager config files and nmconnection files to their destination directories. No other network configuration is done.
* `--plugin network:"ifname=wlp3s0|cname=wlan2|ctype=wifi|wifi-ssid=myssid|wifi-password=myssidpassword|wificountry=US"` &mdash; Configure a WiFi connection named `wlan2` configured with the provided SSID/Password/country for network device `wlp3s0`
* `--plugin network:"ipv4-static-ip=192.168.14.32|ipv4-static-gateway=192.168.41.1|ipv4-static-dns=192.168.14.1|ipv4-static-dns-search=mydom.com"` &mdash; Configure `eth0` (default if no `ifname`specified) with the specified static IP configuration. The DNS search mechanism will search unqualified names in the domain `mydom.com`
* `--plugin network:"netman=dhcpcd|noipv6"` &mdash; Set the network manager to dhcpcd (and disable NetworkManager), and do not request an IPv6 address.

### parted

parted is a `--burn-plugin` that operates on a device, disk, or disk image and enables you to
* Expand the root partition by a specified number of MiB
* Add one or more partitions of a specified size with a specified file system type on it

Using the `parted` burn plugin implicitly sets `--no-expand-root` when used on a burn command.

#### Arguments

* **rootexpand** &mdash; Expand the root partition by the number of MiB specified as the value for this argument. A value of 0 expands the partition to fill the disk. A value of 0 is not allowed when used with `--burnfile`. If specified, `rootexpand` must be used before any `addpartition` arguments.
* **addpartition** &mdash; Adds another partition at the end of the IMG. Arguments: size[fstype][,mountpoint,] where:
    * `size` is the number of MiB for the partition
    * `fstype` is the type of file system. Supported file systems are: `btrfs`, `ext2`, `ext3`, `ext4` [default], `fat16`, `fat32`, `hfs`, `linux-swap`, `ntfs`, `udf`, `vfs`, and `xfs`. Some file systems may require you to install additional apt packages on the host before running this plugin
    * `mountpoint` is the location in the filesystem where you expect to mount your new partition. This will be added to fstab, and is optional.
    * NOTE: Multiple partitions can be named on the command line by separating them with `+`. See example below.

#### Examples

* `--burn-plugin parted:"rootexpand=2048|addpartition=1024,ext4"` &mdash; Expand the RasPiOS root partition by 2048MiB and add a 1024MiB ext4 partition
* `--burn-plugin parted:"rootexpand=2048|addpartition=1024,ext4+2048,btrfs,/data/backups,MyBTRFS"`  &mdash; Expand the RasPiOS root partition by 2048MiB and add: a 1024MiB ext4 partition and a 2048MiB btrfs partition
* `--burn-plugin parted:"rootexpand=1024|addpartition=@/path/to/partition-list"` where the file partition-list has one line for each partition to be added in the form: `nnnn,fstype,partitiontype,label`

#### Example partition-list file

This is a sample file for the addpartition=@/path/to/partition-list directive. It will expand the root partition by 2048MiB (2GiB) add a 1024MiB partition and ext4 file system, a 4096MiB partition and btrfs file system, and a 16GiB Swap partition. This method enables easily adding multiple partitions with a single plugin invocation, so the ability to use `+` for multiple partitions mentioned above does not work in a partition-list file.

```
1024,ext4,,ext4label
4096,btrfs,/data/backups,btrfslabel
16384,linux-swap,,swaplabel
```
If you enable `--gpt`, and use `addpartition` to create one of every partition type, without adding optional mount points your /etc/fstab will look something like (note, however that a mount point was specified for the first btrfs partition, hence is preceded by a commented notice to alert that the mount point directory /mybtrfs was not created.

```
proc            /proc           proc    defaults          0       0
PARTUUID=c352087d-56a1-4dca-ad2e-e8a8fd0979fc  /boot/firmware  vfat    defaults          0       2
PARTUUID=35cadb8e-949c-4bad-89e2-d942a13c5dd8  /               ext4    defaults,noatime,commit=300  0       1
PARTUUID=b98b8d45-2d03-4d6e-b02f-aa5ff6cc5bdf  none             swap    defaults,nofail 0       0
#** Create mount point '/mybtrfs' before uncommenting this VV fstab entry
#PARTUUID=a834c0dd-a717-4c1e-8094-366f3b22b282  /mybtrfs                btrfs   defaults,noatime        0       0
#PARTUUID=de934be9-ad00-451a-8d8b-7df2ccb8ee7b  /mnt/p5/btrfs           btrfs   defaults,noatime        0       0
#PARTUUID=172a749a-7e6a-405e-806d-3de45dcf6787  /mnt/p6/ext2            ext2    defaults,errors=remount-ro,noatime      0       2
#PARTUUID=5c41fe01-7299-4e95-92ed-501f8b332116  /mnt/p7/ext3            ext3    defaults,errors=remount-ro,noatime      0       2
#PARTUUID=3397c0e0-954c-45c1-9647-11d3104016e6  /mnt/p8/ext4            ext4    defaults,errors=remount-ro,noatime      0       2
#PARTUUID=a0eaa88b-2d1e-4a18-9266-e4c94ee9e583  /mnt/p9/fat16           vfat    defaults,noatime        0       0
#PARTUUID=94ad3300-2a73-43e6-a1b0-c72c3b9c5aba  /mnt/p10/fat32          vfat    defaults,noatime        0       0
#PARTUUID=71ebc6f1-04e0-4f2d-8337-e12f2059529c  /mnt/p11/vfat           vfat    defaults,noatime        0       0
#PARTUUID=5d71f86d-1baa-4ab7-8433-40f4d48506b7  /mnt/p12/hfs            hfs     defaults,noatime        0       0
#PARTUUID=2c3bee4f-47cf-4aaf-b882-f8d041d72fe8  /mnt/p13/ntfs           ntfs    defaults,noatime        0       0
#PARTUUID=16e7158f-aba4-45b0-abe0-3e80fa128ff8  /mnt/p14/udf            udf     defaults,noatime        0       0
#PARTUUID=4020da32-ac0e-43f0-8775-231e5da6dfd7  /mnt/p15/xfs            xfs     defaults,noatime        0       0
```
#### Notes
* The `parted` plugin can only create up to 4 partitions when burning to an IMG, and conversion to GPT partition table is not supported
* Partition type `hfs` creates a HFS+ partition
* The `parted` burn plugin adds an entry to /etc/fstab for each additional partition. These won't interfere with use of the `system` plugin's `fstab` feature if you also use that.
    * `linux-swap`: Provides an uncommented fstab entry so that your swap partition will activate on boot
       * All others: If the specified mount point does not exist, the entry is commented out, but provides useful information such as the PARTUUID, partition number, and filesystem type. The other settings are sane for most partitions, although you should check they meet your needs.
       * If you create your mount point during `customize` or `burn` with the `mkdir` plugin before the `parted` plugin runs, the partition will be uncommented and effective when the system boots. If the directory does not exist, you should only need to create the directory later, edit /etc/fstab, uncomment the line, and check the mount options to complete the process
       * Be sure to check that fstab is set how you want. Refer to man swapon(8), mount(8), and fstab(5) for additional information


### piapps

Installs pi-apps (https://github.com/Botspot/pi-apps). That's it!

#### Arguments

* **user** &mdash; Specify the user that piapps should be installed for. The user must already exist. If not specified, the first created user ($myuser) will be used

#### Examples

* `--plugin piapps:"user=bls"` &mdash; Install piapps for user bls. The user was already created with the `user` plugin

### pistrong

<a href="https://github.com/gitbls/pistrong">pistrong</a> installs the strongSwan IPSEC VPN server and `pistrong`. pistrong provides

* A fully-documented, easy-to-use Certificate Manager for secure VPN authentication with Android, iOS, Linux, MacOS, and Windows clients
* Tools to fully configure a Client/Server Certificate Authority and/or site-to-site/host-to-host VPN Tunnels. Both can be run on the same VPN server instance

In addition to simply installing pistrong and strongSwan, this plugin enables:
* After FirstBoot system can be fully configured and operational with host/host tunnels and/or client/server VPNs with no intervention
* Two hosts can be built up from scratch with an operational site/site host/host VPN tunnel with one sdm customize and 2 sdm burn commands

#### Arguments

* **calife** &mdash; Set the CA Certificate lifetime in days [Default: 3650 days]
* **uclife** &mdash; Set the User Certificate lifetime in days [Default: 730 days]
* **certpack** &mdash; Import an already-generated CertPack and install it in the customized IMG or burned disk
* **enablesvc** &mdash; Enable the `strongswan` service to start on first system boot
* **ipforward** &mdash; Enable IP forwarding from the VPN server onto the LAN. Value can be `yes` or `no` [Default: *no*]
* **iptables** &mdash; Collect the iptables configuration from available CA and Tunnel definitions into /etc/swanctl/pistrong/iptables and enable the service pistrong-iptables-load
* **makemyca** &mdash; Provide a configuration answer file for MakeMyCA to enable the CA to be automatically configured with no intervention
* **maketunnel** &mdash; Provide a configuration answer file for makeTunnel to enable the tunnel to be automatically configured with no intervention
* **hostname** &mdash; Provide the hostname that will ultimately be used for the host so makeTunnel recognizes that the Tunnel configuration is for this host
* **vpnmon** &mdash; Enable the VPN monitor on this host, which tries to always keep the VPN tunnel connection up. Requires `vpnmonping`
* **vpnmonping** &mdash; Specifies the IP address that the VPN monitor should test for the VPN tunnel being up. Typically this would be the LAN IP address of the VPN server at the other end of the tunnel

#### Examples

* `--plugin pistrong:"calife=7300|uclife=7300|makemyca=/path/to/makemyca.conf"` &mdash; Install strongSwan, create a CA with the specified Cert lifetimes, and configure the CA with the parameters provided in makemyca.conf
* `--plugin pistrong:"maketunnel=/path/to/maketunnel.conf"` &mdash; Install pistrong and build a VPN tunnel with the parameters defined in maketunnel.conf
* `--plugin pistrong:"certpack=/path/to/Tunnel-node1-node2.zip|enablesvc|vpnmon|vpnmonping=192.168.47.3"` &mdash; Install pistrong, import the VPN CertPack and install it. Enable the VPN monitor checking the LAN IP address on the other end of the tunnel specified by `vpnmonping`

**NOTE:** Documentation on the makemyca and maketunnel config files is not yet available. If you're interested in using this capability, please post an issue on the sdm GitHub.

### postburn

postburn is a `--burn-plugin` that enables you to:
* Copy files from the burned disk to the host OS file system
* Run a script that has access to the burned disk in either Phase 0 or Phase 1 *mode*

#### Arguments

* `savefrom` &mdash; /path/to/file for the file(s) to be copied from the burned disk. `*` is supported for use in the filename
* `saveto` &mdash; /path/to/dir to define where the files will be copied to
* `runscript` &mdash; /path/to/script of a script that will be run after the burn completes. The script must exist and be executable
* `runphase` &mdash; Specify context for running `runscript`. [Default: `phase1`]. Supported values:
  * `phase0` &mdash; Runs `runscript` in the context of the burned disk being mounted in the host OS
  * `phase1` &mdash; Runs `runscript` in the context of the burned disk in a container
* `where` &mdash; Where the script is located. `host` specifies that `runscript` path is in the host OS. Any other value: `runscript` path is in the burned disk

#### Examples

* `--burn-plugin postburn:"savefrom=/etc/swanctl/pistrong/server-assets/*.zip|saveto=/my/dir"` &mdash; Copies all the *.zip files from the specified directory in the burned disk to `/my/dir` on the host file system
* `--burn-plugin postburn:"runscript=/usr/local/bin/do-something|runphase=phase0|where=host"` &mdash; Runs the host-located script `/usr/local/bin/do-something` in the context of the host OS
* `--burn-plugin postburn:"runscript=/usr/local/bin/do-something|runphase=phase1|where=host"` &mdash; Runs the host-located script `/usr/local/bin/do-something` in the context of the burned disk container. The `runscript` is copied onto the burned disk in /usr/local/bin, and removed after it has been run
* `--burn-plugin postburn:"runscript=/usr/local/bin/do-something|runphase=phase1"` &mdash; Runs the burned disk-located script `/usr/local/bin/do-something` in the context of the burned disk container

### postfix

postfix installs the postfix mail server. This plugin installs the postfix server but at the moment doesn't do too much to simplify configuring postfix. BUT, once you have a working /etc/postfix/main.cf, it can be fed into this plugin to effectively complete the configuration.

#### Arguments

* **enablesvc** &mdash; Enable the postfix service
* **maincf** &mdash; The full /path/to/main.cf for an already-configured /etc/postfix/main.cf. If provided, it is placed into /etc/postfix after postfix has been installed.
* **mailname** &mdash; Domain name [Default: *NoDomain.com*]
* **main_mailer_type** &mdash; Type of mailer [Default: *Satellite system*]
* **relayhost** &mdash; Email relay host DNS name [Default: *NoRelayHost*]

#### Examples

* `--plugin postfix:"maincf=/path/to/my-postfix-main.cf"` &mdash; Uses a fully-configured main.cf, and postfix will be ready to go.
* `--plugin postfix:"relayhost=smtp.someserver.com|mailname=mydomain.com|rootmail=myemail@somedomain.com"` &mdash; Set some of the postfix parameters, but more configuration will be required to make it operational. A good reference will be cited here at some point.

### quietness

The quietness plugin controls the quiet and splash settings in /boot/firmware/cmdline.txt

#### Arguments

* **consoleblank** &mdash; Set a console blanking timeout (Default: 300 seconds)
* **quiet** &mdash; Enables 'quiet' in /boot/firmware/cmdline.txt
* **noquiet** &mdash; Disable 'quiet' in /boot/firmware/cmdline.txt. If `noquiet=keep` is NOT specified, sdm will re-enable 'quiet' in cmdline.txt after the First Boot.
* **splash** &mdash; Enables 'splash' in /boot/firmware/cmdline.txt
* **nosplash** &mdash; Disable 'splash' in /boot/firmware/cmdline.txt. If `nosplash=keep` is NOT specified, sdm will re-enable 'splash' in cmdline.txt after the First Boot.
* **plymouth** &mdash; Enables Plymouth in /boot/firmware/cmdline.txt. Not Yet Implemented
* **noplymouth** &mdash; Disables the Plymouth graphical splash screen for the First Boot (only). It is re-enabled at the end of First Boot.

#### Examples

* `--plugin quietness:"consoleblank|noquiet=keep|nosplash=keep"` &mdash; Remove 'quiet' and 'splash' from cmdline.txt and do not re-enable them. Console blanking timeout set to 300 seconds (5 minutes)
* `--plugin quietness:"consoleblank=600|noquiet|nosplash|noplymouth"` &mdash; Remove 'quiet' and 'splash' from cmdline.txt, and disable plymouth. All will be re-enabled after the First Boot. Console blanking timeout set to 600 seconds (10 minutes).

### raspiconfig

the `raspiconfig` plugin is used to modify settings supported by `raspi-config`. This is not necessarily the complete list (done quickly), and one or two of these may not be supportable. There's more work to do on this one!

See <a href="https://www.raspberrypi.com/documentation/computers/configuration.html">RaspberryPi Documentation for raspi-config</a> for details.

#### Arguments

* **audio**
* **audioconf**
* **blanking**
* **boot_behaviour, boot_behavior**
* **boot_order**
* **boot_splash**
* **boot_wait**
* **camera**
* **composite**
* **glamor**
* **gldriver**
* **i2c**
* **leds**
* **legacy**
* **memory_split**
* **net_names**
* **onewire**
* **overclock**
* **overlayfs** &mdash; Enables the readonly file system. Optional value specifies whether bootfs should be 'ro' (default) or 'rw'
* **overscan**
* **pi4video**
* **pixdub**
* **powerled**
* **proxy**
* **rgpio**
* **serial** &mdash; Deprecated. See the <a href="Plugins.md#serial">serial plugin</a>
* **spi**
* **xcompmgr**

#### Examples

* `--plugin raspiconfig:"net_names=1|boot_splash=1"`
* `--plugin raspiconfig:overlayfs=ro` &mdash; Enable the rootfs readonly file system with a read-only bootfs also
* `--plugin raspiconfig:overlayfs` &mdash; Enable the rootfs readonly file system with a read-only bootfs also
* `--plugin raspiconfig:overlayfs=rw` &mdash; Enable the rootfs readonly file system with a read/write bootfs

#### Notes

The 'overlayfs' setting enables the read-only file system. The file system is not made read-only until sdm FirstBoot has completed and the system restarts. If you need a swapfile, you'll need to configure it on another disk or partition, since the boot disk isn't writeable. At the moment sdm doesn't provide any support for swapfile management with overlayfs.

### runatboot

The `runatboot` plugin provides a way to run an arbitrary script during the First Boot of the system. The script is run as root or `user` if specified, with no other provisions or control made by sdm. Behavior, output, logging content, etc is all the responsibility of the script.

#### Arguments

* **script** &mdash; /full/path/to/the/script that should be run
* **args*** &mdash; The arguments to provide to the script
* **user** &mdash; If provided use sudo to run script as the specified user. User must exist at time of First Boot
* **sudoswitches** &mdash; If `user` provided, include these sudo switches
* **output** &mdash; Where to set stdout. Default is /dev/null. The directory must already exist, and the user (root or `user` if specified) must be able to write the output file in that directory
* **error** &mdash; Where to set stderr. Default is the same as stdout (`2>&1`)

#### Example

* `--plugin runatboot:"script=/path/to/script|args=arg1 arg2 arg3"` &mdash; Run the specified script with the 3 provided arguments
* `--plugin runatboot:"user=me|sudoswitches=-H|script=/path/to/script|args=arg1 arg2 arg3"` &mdash; Run the specified script with the 3 provided arguments as the specified user and include `-H` on the sudo command
* `--plugin runatboot:"script=/path/to/script2|args=arg1 arg2 arg3|output=/var/log/myscript.log"` &mdash; Run the specified script with the 3 provided arguments with output and error going to /var/log/myscript.log

### runscript

The `runscript` plugin runs a script during customization.

#### Arguments

* **dir** &mdash; Optional directory in which to run the script (as the default directory). The directory will be created if it doesn't exist. Use a /full/path/to/dir
* **runphase** &mdash; Specifies the phase (`1` or `post-install`) in which to run the script. Default is `1`
* **script** &mdash; /full/path/to/script on the host to run. The script will be copied into the IMG
* **user** &mdash; The user under which to run the script. The user must exist by the time the script is run in Phase 1 or post-install. If not specified the script is run as `root`
* **stdout** &mdash; Specifies stdout for the script output. /full/path/to/stdout must be specified (but not checked by sdm)
* **stderr** &mdash; Specifies stderr for the script output. /full/path/to/stderr must be specified (but not checked by sdm)

The script is called with one argument: the current Phase (either `1` or `post-install`).

The default for `stdout` and `stderr` if not specified are `$(basename $script).out` and `$(basename $script).error`. If `dir` is specified the files will be written to `dir`. If not, the files will be written to `/etc/sdm/assets/runscript`. 

Each script (unique filename) can be run on behalf of multiple users, by using multiple invocations of the `runscript` plugin with different users, but each script can ONLY be run ONCE PER USER. A second `runscript` call with the same script name and user will elicit an error. This plugin treats the same script name in different directories as the same script, so qualify them further for uniqueness if needed.

#### Examples

* `--plugin runscript:"dir=/home/work|script=/path/to/my/script|user=bls"` &mdash; The directory /home/work is created and owned by user bls. The script specified is run during Phase 1, and the ouptut and error files are saved in /home/work
* `--plugin runscript:"/path/to/my/script"` &mdash; The script is run as root during Phase 1. Output and error are saved in /etc/sdm/assets/runscript/sdm-runscript-$script.out and .error
* `--plugin runscript:"stdout=/dev/stdout|stderr=/dev/stderr|script=/path/to/my/script"` &mdash; redirect the output of the script to the console instead of a file in the image
#### Example runscript

This simple demo script prints out some environmental information including the username, group ids, and current working directory. Save the file somewhere with execute permission and use `--plugin runscript:"script=myrunscript.sh|stdout=/dev/stdout|stderr=/dev/stderr"`

```
#!/bin/bash

echo "In the runscript"
echo "* whoami: $(whoami)"
echo "* ids: $(id)"
echo "* pwd: $(pwd)"
```

### rxapp

**rxapp** is a handy tool to securely and remotely start X11 apps via SSH without a password. You can read about it [here](https://github.com/gitbls/rxapp).

rxapp is included because it is generally useful, but also as a demonstration of how to copy a file from the network (GitHub in this case) into the IMG in a plugin.

#### Arguments

There are no `--plugin` arguments for rxapp

### samba

#### Arguments

* **smbconf** &mdash; Full */path/to/smb.conf* for an already-configured /etc/samba/smb.conf. If provided it is placed into /etc/samba after samba has been installed.
* **shares** &mdash; Full */path/to/shares.conf* for a file containing only the samba share definitions. If provided it is appended to /etc/samba/smb.conf after samba has been installed.
* **dhcp** &mdash; TBH not sure what this does. If you figure it out, let me know ;)
* **do_debconf** &mdash; TBH not sure what this does. If you figure it out, let me know ;)
* **workgroup** &mdash; Workgroup name to replace WORKGROUP in the default /etc/samba/smb.conf. If *smbconf* is specified, the workgroup is NOT modified.

#### Examples

* `--plugin samba:smbconf=/home/bls/mylan-smb.conf` &mdash; Use the provided fully-configured file for /etc/samba/smb.conf
* `--plugin samba:"shares=/home/bls/mysmbshares.conf"` &mdash; Append the provided share definitions to the end of the default /etc/samba/smb.conf
* `--plugin samba:"workgroup=myworkgroup|shares=/home/bls/mysmbshares.conf"` &mdash; Use the default /etc/samba/smb.conf, set the workgroup name to *myworkgroup* and append the provided share definitions to /etc/samba/smb.conf

### serial

The `serial` plugin is used to configure the serial port. Although the `serial` setting on the `raspiconfig` plugin still works, as of 2023-12-28 it prompts, which is obviously annoying when you're in the middle of an sdm customize.

There's a second issue in that the serial setting for the Pi5 is different than for other Pis, and raspi-config checks the system on which it is running, which can likely be incorrect when doing an sdm customize.

The `serial` plugin addresses these issues. You can use it during a customize if you know the target hardware. Otherwise, when you burn the disk for a target system, you can run the plugin then to set it correctly for the target hardware.

#### Arguments

* **disableshell** &mdash; Explicitly disables the shell on the console serial port
* **enableshell** &mdash; If set, enable a shell on the console serial port. Also enables the uart
* **enableuart** &mdash; Enable the console serial port uart without enabling the shell
* **pi5** &mdash; If set, configure the serial port for a Pi5
* **pi5debug** &mdash; If set, configure the debug serial port for a Pi5

#### Examples

* `--plugin serial` &mdash; Configure the serial port for a Pi other than a Pi5 and disable the login shell on it
* `--plugin serial:pi5` &mdash; Configure the serial port for a Pi5 and disable the login shell on it
* `--plugin serial:disableshell` &mdash; Another way to disable the login shell on the console serial port
* `--plugin serial:enableshell` &mdash; Configure the serial port for a Pi other than a Pi5 and enable a login shell on it
* `--plugin serial:pi5|enableshell` &mdash; Configure the serial port for a Pi5 and enable a login shell on it
* `--plugin serial:pi5debug` &mdash; Configure the debug serial port for a Pi5

### speedtest

The `speedtest` plugin creates a service that remains running and regularly runs speedtest, with a mechanism for reporting out-of-bounds results for `ping`, `download speed` and `upload speed`.

#### Arguments
* **alertping** &mdash; Call `alertscript` if a speedtest ping result is greater than `alertping`
* **alertdown** &mdash; Call `alertscript` if a speedtest download speed result is less than `alertdown`
* **alertup** &mdash; Call `alertscript` if a speedtest upload speed result is less than `alertup`
* **alertscript** &mdash; /path/to/alertscript. See below for an example alertscript
* **interval** &mdash; Run the speedtest every `interval` seconds. Note that running too frequently will likely elicit errors from speedtest. Default is 3600 seconds (1 hour)
* **log** &mdash; /path/to/logfile for speedtest logging. Default is /var/log/sdm-speedtest-monitor.log
* **rawlog** &mdash; /path/to/rawlog for raw speedtest result logging, which captures the output from the speedtest commands. This is optional and not logged if not provided.

#### Examples

* `--plugin speedtest:"alertping=8|alertdown=600000000|alertup=600000000|alertscript=/usr/local/bin/alertscript"` &mdash; Calls specified alert script if ping is greater than 8ms, or download or upload speed is less than 600mb. Logs to /var/log/sdm-speedtest-monitor.log 

Example alertscript:
```
#!/bin/bash

if [ -f /etc/default/sdm-speedtest ]
then
    source /etc/default/sdm-speedtest
else
    logger "sdm-speedtest alertscript: ? /etc/default/sdm-speedtest not found"
    exit 1
fi
ping=$2
download=$3
upload=$4
case "$1" in
    alert)
        [ $ping -gt $alertping ] && logger "sdm-speedtest alert: Ping $ping gt $alertping"
        [ $download  -lt $alertdown ] && logger "sdm-speedtest alert: Download $download lt $alertdown"
        [ $upload  -lt $alertup ] && logger "sdm-speedtest alert: Upload $upload lt $alertup"
        ;;
    error)
        logger "sdm-speedtest alertscript error: |$2|"
        ;;
esac
```
### sshd

The `sshd` plugin configures:
* The SSH service to be enabled or disabled. This service is enabled by default, even if the `sshd` plugin is not used. Use the `sshd` service to disable the SSH service if needed
* Various SSH service configuration items

### Arguments

These configuration items affect the SSH service.

* **enablesvc** &mdash; Enable or disable the service. [Default: enabled]. Values supported: `yes`, `no`, or `socket`

* Arguments that modify /etc/sshd_config
    * **listen-address** &mdash; IP address on which to listen [Default: 0.0.0.0] (all IP addresses on the server)
    * **password-authentication** &mdash; Enable/disable password authentication. [Default: `yes`]. Disable this (`no`) to restrict logins to public key only
    * **port** &mdash; Port number SSH service should listen on [Default: 22]

#### Examples

* `--plugin sshd:"enablesvc=no" &mdash; Disable the SSH service
* `--plugin sshd:"port=22222|listen-address=192.168.16.16" &mdash; Enable the SSH service, which will listen on port 2222 and only on the IP address 192.168.16.16 (which must be an IP address on the target system)
* `--plugin sshd:"password-authentication=no" &mdash; Disable password authentication

### sshhostkey

The `sshhostkey` plugin allows the generation new or import of existing SSH host keys.
Importing SSH host keys is useful to generate images with deterministic keys.
Generating SSH host keys during an sdm customize or burn can be beneficial because the entropy during Pi's first boot is very limited, whereas sdm can access the entropy pool of the host OS.

Note, however, that unless you fully understand the ramifications of multiple hosts sharing SSH host keys, if the customized IMG is to be used by multiple host systems, you should only use the `sshhostkey` plugin during burn so that each host has unique SSH host keys.

One nice use of this plugin in Trixie is to use it at burn time, along with the `--expand-at-boot` command line switch.

#### Arguments

* **generate-keys** &mdash; Create a new set of keys in phase 1.
* **import-keys** &mdash; Copy files from the given host directory to /etc/ssh.

#### Examples

* `--plugin sshhostkey:"generate-keys"` &mdash; Generate a new set of host keys.
* `--plugin sshhostkey:"import-keys=/path/to/hostkeys"` &mdash; Copy `ssh_host_*_key` and `ssh_host_*_key.pub` files from the specified host directory to the Pi's /etc/ssh/ directory
* `--plugin sshhostkey:"generate-keys|import-keys=/path/to/hostkeys"` &mdash; Useful to import a subset (e.g. RSA only) keys, and re-create the rest. 

### sshkey

The `sshkey` plugin creates an SSH key or imports an SSH key for a user. In either case, you can optionally create a Putty private key for it.

### Arguments

* **sshuser** &mdash; The user for whom the SSH key is targeted. The user must already exist
* **authkey** &mdash; Add the created SSH public key to `sshuser`'s ~/.ssh/authorized_keys
* **import-key** &mdash; Instead of creating an SSH key, import the specified SSH key from the provided file in the host OS
* **import-pubkey** &mdash; Import the provided SSH public key and add it to `sshuser`'s ~/.ssh/authorized_keys. The key is not checked in any way
* **keyname** &mdash; Name the key that is to be created
* **keytype** &mdash; Type of key to create. Accepted values: `ecdsa`, `ecdsa-sk`, `ed25519`, `ed25519-sk`, `rsa`. [Default: `ecdsa`]
* **passphrase** &mdash; Passphrase to secure the SSH key. The same passphrase is used when creating a putty key
* **putty-keyname** &mdash; If specified, create a putty key in ~/.ssh with the provided key name

#### Examples

* `--plugin sshkey:"sshuser=bls|keyname=mykey|keytype=ed25519|passphrase=itsasecret|putty-keyname=myputtykey"` &mdash; Create a new SSH key for user `bls`, with the parameters as specified. Additionally, the Putty key `myputtykey.ppk` is created using the same passphrase
* `--plugin sshkey:"sshuser=bls|import-key=/home/bls/.ssh/myotherkey|putty-keyname=otherputty|passphrase=anothersecret"` &mdash; Import the specified private key from the host system. Use the provided passphrase to access the imported key and create a Putty key using the same passphrase.

### swap

The `swap` plugin configures `rpi-swap`.

#### Arguments

* `config` &mdash; Provides a configured swap.conf. Start with /rpi/etc/swap.conf and edit as desired. The provided file is placed in /etc/rpi/swap.conf.d
* `filesize` &mdash; Specifies the size for the swap file. Modifications are stored in /etc/rpi/swap.conf.d
* `zramsize` &mdash; Specifies the size for the zram device. Modifications are stored in /etc/rpi/swap.conf.d

#### Examples

* `--plugin swap:"config=/path/to/myswap.conf"` &mdash; Copies the configured swap config file to /etc/rpi/swap.conf.d
* `--plugin swap:"filesize=2048|zramsize=1024"` &mdash; Configure a 2GB swapfile and a 1GB zram device

### syncthing

The `syncthing` plugin installs <a href="">syncthing </a> and configures it for the user specified by `runasuser`.

#### Arguments

* **connect-address** &mdash; Address or host name to use when attempting to connect to this device. Must be fully specified. For example: tcp://0.0.0.0:22001. See <a href="https://docs.syncthing.net/users/config.html#listen-addresses">listen-addresses</a> for specfication details.
* **enablesvc** &mdash; Enable the syncthing service during sdm FirstBoot
* **gui-address** &mdash; GUI listen address. Default is 127.0.0.1:8384 For example: 0.0.0.0:8384 or http://0.0.0.0:8384
* **gui-password** &mdash; GUI authentication password used in conjunction with the `gui-user`
* **gui-user** &mdash; GUI authentication username
* **homedir** &mdash; Home directory to use. Default: `runasuser` home directory
* **nolinger** &mdash; Do not start syncthing for user until user logs in. Default: syncthing started for user at system boot once enabled by `enablesvc` or manually via `systemctl enable --user syncthing` from the user account
    * Can be controlled manually after system up and running. If modifying other than current user specify `username` and use `sudo`
        * Enable linger:  `loginctl enable-linger [username]` 
        * Disable linger: `loginctl disable-linger [username]`
* **release** &mdash; syncthing release to install. Default: `stable`
* **runasuser** &mdash; Username to be used to run the syncthing service. Default: First user created with the `user` plugin
* **sendstats** &mdash; Send statistics setting (-1: Never, 0: Ask, 1: Always). Default: Always
* **synchost** &mdash; Hostname that will eventually be used for this host. (Sorry that you need to specify this here)

#### Examples

* `--plugin syncthing` &mdash; Install syncthing. GUI username/password will not be set. GUI will only be accessible from browsers running on the same host as syncthing. syncthing will run as the first user created with the `user` plugin. Hostname will be set to `sdm`, which can be edited in config.xml
* `--plugin syncthing:"enablesvc|gui-address=0.0.0.0:8384|gui-password=asecret|gui-user=syncuser"` &mdash; Install syncthing. GUI username/password will be set. GUI will be accessible from browsers running on any LAN host. syncthing will run as the first user created with the `user` plugin. The syncthing listenAddress will be set to the default (`tcp://0.0.0.0:22000`)
* `--plugin syncthing:"enablesvc|gui-address=0.0.0.0:8384|gui-password=asecret|gui-user=syncuser" --plugin syncthing:"runasuser=syncuser2|enablesvc|gui-address=0.0.0.0:8385|gui-password=asecret|gui-user=syncuser2|connect-address=tcp://0.0.0.0:22001" `
    * Install and configure syncthing for the first user created with the `user` plugin as in the previous example
    * A second user, `syncuser2` will also be configured. The user `syncuser2` must be created using the `user` plugin before referencing it in the `syncthing` plugin. syncthing will listen on `tcp://0.0.0.0:22001` for the second user
    * Each user must have a unique listenAddress

#### Notes

Final syncthing configuration is done during sdm FirstBoot. The script that will be run is in /etc/sdm/0piboot/098-enable-syncthing-`runasuser`.sh

For a user's syncthing service to be started at boot `enablesvc` must be set and `nolinger` must NOT be set.


### system

The `system` plugin is a collection of system-related configuration settings. You are responsible for using correct file types expected by each function (e.g., .conf, .rules, etc). The plugin does no checking/modification of file types.

If the system plugin is invoked more than once in an IMG, either on customize or burn, you must include the `name=somename` argument for correct operation.

#### Arguments

* Cron control arguments
  * **cron-d** &mdash; Comma-separated list of files to copy to /etc/cron.d
  * **cron-daily** &mdash; Comma-separated list of files to copy to /etc/cron.daily
  * **cron-hourly** &mdash; Comma-separated list of files to copy to /etc/cron.hourly
  * **cron-weekly** &mdash; Comma-separated list of files to copy to /etc/cron.weekly
  * **cron-monthly** &mdash; Comma-separated list of files to copy to /etc/cron.monthly
  * **cron-systemd** &mdash; Takes no value. Switches from using cron to systemd-based cron timers
* **eeprom** &mdash; Supported values are ***critical***, ***stable***, and ***beta***
* **exports** &mdash; Comma-separated list of files to append to /etc/exports
* **fstab** &mdash; Comma-separated list of files to append to /etc/fstab
* **journal** &mdash; Configure systemd journal. Supported values are ***persistent***, ***volatile***, and ***none***. By default Bullseye uses rsyslog and `journal=volatile` while Bookworm uses `journal=persistent`. NB RasPiOS changed again. It's best to use this configuration setting if you care.
    * `persistent`: Makes a permanent journal in /var/log
    * `volatile`: The journal is in memory and not retained across system restarts
    * `none`: There is no system journal
* **ledheartbeat** &mdash; Enable LED heartbeat flash on Pi systems that have /sys/class/leds/PWR/trigger, such as the Pi4 and Pi5.
* **modprobe** &mdash; Comma-separated list of files to copy to /etc/modprobe.d
* **motd** &mdash; Single /path/to/file to use for /etc/motd. /dev/null results in an empty motd
* **name** &mdash; Name of this invocation. This **must** be included if the `system` plugin is invoked more than once in an IMG, including between customize and burn. Best practice to avoid problems is to give each and every invocation a name.
* **rclocal** &mdash; Comma-separated list of ordered commands to add to /etc/rc.local. An item starting with '@' is interpeted as a file whose contents will be included.
* Service control arguments
  * **service-disable** &mdash; Comma-separated list of services to disable
  * **service-enable** &mdash; Comma-separated list of services to enable
  * **service-mask** &mdash; Comma-separated list of services to mask
* **swap** &mdash; **disable** or integer swapsize in MB to set
* **sysctl** &mdash; Comma-separated list of files to copy to /etc/sysctl.d
* **systemd-config** &mdash; Comma-separated list of `type:/path/to/file.conf`, where type is one of *login*, *network*, *resolve*, *system*, *timesync*, or *user*. Copies the provided file to /etc/systemd/*type*.conf.d NOTE: file must be specified as a full /path/to/file.conf and the file type MUST be `.conf`
* **udev** &mdash; Comma-separated list of files to copy to /etc/udev/rules.d

#### Examples

* `--plugin system:"cron-d=/path/to/crondscript|exports=/path/to/e1,/path/to/e2"`
* `--plugin system:"systemd-config=timesync=/path/to/timesync.conf,user=/path/to/user.conf|service-disable=svc1,svc2"`
* `--plugin system:"name=s1|cron-d=/path/to/crondscript|exports=/path/to/e1,/path/to/e2" --plugin system:"name=s2|fstab=myfstab"`

#### Notes

If you're having issues with settings in your `systemd-config` files, here are some handy infobits:
* The command `sudo systemd-analyze cat-config systemd/service.conf` (where *service* is one of journald, logind, networkd, pstore, sleep, system, timesyncd, or user) will display the settings in precedence order. This is very handy in sorting out what config file is providing which setting.
* The files in /lib/systemd/*service*.conf.d and /etc/systemd/*service*.conf.d appear to have their files unified and processed in ascending alphabetical order. For instance,with /lib/systemd/journal.conf.d/70-xx.conf and /etc/systemd/journal.conf.d/030-xx.conf, 030-xx.conf is processed *first*, so any settings in 70-xx.conf will override settings in 030-xx.conf. 
* The `swap` argument controls whichever of `rpi-swap` or `dphys-swapfile` is installed. `swap=0` disables swap. Also see the `swap` plugin for fine-grained configuration of `rpi-swap`.

### trim-enable

trim-enable will enable <a href="https://en.wikipedia.org/wiki/Trim_(computing)">SSD Trim</a> on all or only selected devices. Trim is not actually enabled on the devices until the system first boots.

This plugin can be run manually on a running sdm-customized system by
```
sdm --runonly plugins --plugin trim-enable:"disks=/dev/sda,/dev/sdb"
```
The optional switch `--oklive` can be used to avoid the Prompt "Do you really want to run plugins live on the running host?"

#### Arguments

* **disks** &mdash; Specifies the disks on which to enable trim. `disks=all` will enable trim on all drives. Multiple disk names can be specified by, for example, `disks=/dev/sda,/dev/sdb`. If no disks are specified, `disks=all` is the default.

Additional information on SSD Trim for RasPiOS and Linux can be found <a href="https://forums.raspberrypi.com/viewtopic.php?t=351443">here</a>, <a href="https://lemariva.com/blog/2020/08/raspberry-pi-4-ssd-booting-enabled-trim">here</a>, and <a href="https://www.jeffgeerling.com/blog/2020/enabling-trim-on-external-ssd-on-raspberry-pi">here</a>.

### ufw

Install and configure the ufw firewall

#### Arguments
* **`ufwscript`** &mdash; a list of one or more /path/to/script containing a she-bang (`#!/bin/bash`) and series of one or more ufw commands to configure the firewall. The traditional `sudo` is not required, since the script is run as root. Multiple scripts, if provided, are run in lexical order.
* **`savescriptdir`** &mdash; Specifies a directory where the ufw plugin will save the provided `ufwscript` scripts. If not provided, the scripts will be saved in `/usr/local/bin`.

#### Examples

* `--plugin ufw:"/ufwscript=/path/to/script1,/path/to/script2"` &mdash; Install ufw and configure it with the two provided script files. Save the script files in the IMG in /usr/local/bin
* `--plugin ufw` &mdash; Install ufw, do not configure any rules. ufw documentation says that all inbound network accesses are denied by default

### update-alternatives

Use the `update-alternatives` plugin to manipulate the Debian alternatives system.

#### Arguments

* **get-selections** &mdash; Output the current alternatives list to the console and /etc/sdm/history
* **query-alternative** &mdash; Provide a listing of the specified alternatives in a human-readable format
* **set-one** &mdash; Set one alternative. `set-one` provides the name to set (e.g., `editor`) and `path` provides the value
* **setpath** &mdash; The path to a registered alternative for selection `set-one`
* **set-many** &mdash; Set a series of alternatives. See below
* **install-alternative** &mdash; Install an alternative in the system with the name provided as the `install-alternative` value. Requires `link`, `installpath`, and `priority` arguments. See Examples
* **link** &mdash; The generic name for the master link (e.g., /usr/bin/something)
* **installpath** &mdash; The path to an alternative for `install-alternative`
* **priority** &mdash; Sets the priority for the alternative. When a link group is in automatic mode, the alternatives pointed to will be those which have the highest priority.

#### Examples

* `--plugin update-alternatives:get-selections` &mdash; Print the list of alternatives
* `--plugin update-alternatives:"query-alternative=editor,pager"` &mdash; Print the configuration of the specified alternatives
* `--plugin update-alternatives:"set-one=x-terminal-emulator|setpath=/usr/bin/xterm"` &mdash; Set the selection `x-terminal-emulator` to alternative `/usr/bin/xterm`
* `--plugin update-alternatives:"set-many=/path/to/list"` &mdash; Set many alternatives at once.
* `--plugin update-alternatives:"install-alternative=x-www-browser|link=/usr/bin/x-www-browser|installpath=/usr/bin/netsurf|priority=40"` Install a new alternative group

#### Example series of alternatives for `set-many`

Each line in the file for `set-many` consists of three fields: *selection-name* `manual` `/path/to/alternative`
The specified alternative must already be registered in the Debian alternatives system, typically when the package is installed
```
editor manual /bin/ed
pager manual /bin/more
```

These two paragraphs from the `update-alternatives` man page are helpful in understanding whether to use `auto` or `manual`. Hint: Use `manual` if you want the alternative setting to actually change.

Each link group is, at any given time, in one of two modes: automatic or manual.  When a group is in automatic mode, the alternatives system will automatically decide, as packages are installed and removed, whether and how to update the links.  In manual mode, the alternatives system will retain the choice of the administrator and avoid changing the links (except when something is broken).

Link groups are in automatic mode when they are first introduced to the system.  If the system administrator makes changes to the system's automatic settings, this will be noticed the next time update-alternatives is run on the changed link's group, and the group will automatically be switched to manual mode.


### user

Use the `user` plugin to delete, create, or set passwords for users

#### Arguments

* **userlist** &mdash; Value is a /path/to/file with a list of "commands". See the discussion below
  * Syntax: userlist=/path/to/file
* **log** &mdash; Value is a /path/to/file on the **host** system where the log is to be created. NOTE: The log is written in Phase 0, while the actual user management is done in Phase 1, except for setting Samba passwords, which is done in the post-install phase.
  * Syntax: log=/path/on/host/to/logfile
* **adduser** &mdash; Add the specified user
  * Syntax: `adduser=username`
* **deluser** &mdash; Delete the specified user
  * Syntax: `deluser=username`
* **setpassword** &mdash; Set the password for the specified user. The user must already exist
  * Syntax: `setpassword=username|password=newpassword`
* **addgroup** &mdash; Add a new group
  * Syntax: `addgroup=groupname,gid`
* **homedir** &mdash; Specify the home directory for a new user. Default is /home/username.  A home directory will not be created if `nohomedir` is specified
  * Syntax: `homedir=/home/not-the-usual-place`
* **uid** &mdash; Force the new user's ID to be the given number Default is the next uid to be assigned
  * Syntax: `uid=name-or-number`
* **password** &mdash; Specify the password for `adduser` and `setpassword`
  * Syntax: `password=topsecretpassword`
* **password-hash** &mdash; Specify a hashed password for `adduser`. Create the hashed password with `mkpasswd --method=SHA=512 --rounds=4096 password`
* **password-plain** &mdash; Synonym for the `password` argument
* **nohomedir** &mdash; Do not create a home directory for this user
  * Syntax: `nohomedir`
* **noskel** &mdash; Do not copy /etc/skel files to the newly-created login directory
  * Syntax: `noskel`
* **nochown** &mdash; Do not set the home directory file ownership. Useful for home directories that need to be secured from their users
  * Syntax: `nochown`
* **Group** &mdash; Set the initial login group
  * Syntax: `Group=primary-group-name`
* **groupadd** &mdash; Augment the user's groups (see `groups` argument) with these. See discussion below
  * Syntax: `groupadd=groups,to,add`
* **groups** &mdash; Set the list of groups for a user. If not specified, `--groups` is used, with the default:
```
users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo
```
* **prompt** &mdash; Prompt for the user's password
  * Syntax: `prompt`
* **rootpwd** &mdash; Set the root account password to this user's password
  * Syntax: `rootpwd`
* **redact** &mdash; At the end of `user` plugin processing, redact all passwords
  * Syntax: `redact`
* **nosudo** &mdash; Do not enable this account for password-less `sudo`. If you want to remove sudo capability completely for a user, use the command `gpasswd --delete user sudo` in an easily-created personal plugin.
  * Syntax: `nosudo`
* **linger** &mdash; Enable service lingering for this user
  * Syntax: `linger`
* **samba** &mdash; Set a Samba username and password for this user
  * Syntax: `samba`
* **smbpasswd** &mdash; Use the provided password for the Samba password instead of the user's password
  * Syntax: `smbpasswd=smbpasswdforuser`
* **shell** &mdash; Set the user's shell
  * Syntax: `shell=/sbin/nologin`

#### Overview and handling multiple accounts

Conceptually, each invocation of the `user` plugin, or each line in a `userlist` file, consists of a *verb* or *directive* and some arguments. Verbs are:
* `adduser` &mdash; Adds the user as described by the rest of the arguments
* `deluser` &mdash; Deletes the specified user
* `setpassword` &mdash; Set the user's password
* `addgroup` &mdash; Add a new group

So, some example lines in a `userlist` (or each set of arguments for several `--plugin user` command line switches) are:
```
deluser=pi
addgroup=myhomegroup,7654
addgroup=demousers
adduser=bls|uid=4321|password=mypassword|groupadd=myhomegroup|Group=users
adduser=demo1|prompt|nohomedir|groups=demousers|nosudo
adduser=demo2|nohomedir|groups=demousers|nosudo|prompt
adduser=demo3|nosudo
setpassword=demo3|password=thenewpassword

```
In the above
* The pi account will be deleted, if it exists
* The two groups will be added. `myhomegroup` will have gid 7654.
* The user `bls` account will be created with the specified `Group`, and a default login group of `users`. The group `myhomegroup` will be added to the default set of groups (`--groups` or the plugin `group` argument).
* The user `demo1` will be created with no home directory. The group `demousers` will be added to the default set of groups for this user. sdm will prompt for the password.
* The user `demo2` will be created, sdm will prompt for the password
* The user `demo3` will be created and a home directory /home/demo3 will be created
* sdm will set the password for demo3 as a separate step (this is not necessary, btw; one could use the `password=` argument on the demo3 line)

  The plugin will prompt for the user's password

The above userlist can be equivalently placed on the command line:
```
--plugin user:"deluser=pi" \
--plugin user:"addgroup=myhomegroup,7654" \
--plugin user:"addgroup=demousers" \
--plugin user:"adduser=bls|uid=4321|password=mypassword|groupadd=myhomegroup|Group=users" \
--plugin user:"adduser=demo1|prompt|nohomedir|groups=demousers" \
--plugin user:"adduser=demo2|nohomedir|groups=demousers|nosudo|prompt" \
--plugin user:"adduser=demo3|nosudo" \
--plugin user:"setpassword=demo3|password=thenewpassword"
```
Plugins are run in the order they are specified on the command line. I recommend that the `user` plugin be as close to the first plugin run as possible, so that the first created user ($myuser) is available to other plugins.

#### Notes

* If you add any users and/or add a password for the user `pi` you probably don't want the RasPiOS services to run at first system boot that help you configure a user. That is exactly what this plugin does, so you can and **should** disable the RasPiOS services with `--plugin disables:piwiz`.
* If you want to set a username or password that contains the dollar sign (`$`) special treatment is required:
  * If using `--plugin` on the command line, the dollar sign characters must be quoted using a backslash (`\$`)
  * Alternatively, use a `userlist` file as described <a href="#overview-and-handling-multiple-accounts">here</a>, or use `--plugin @/path/to/pluglist` as described <a href="#invoking-a-plugin-on-the-sdm-command-line">here.</a>

### venv

 Use the `venv` plugin to do perform one or two python virtual environment (venv) functions:
* Optionally create and populate the venv. If you want to create the venv use one of `create` or `createif`. The venv will be crated and populated.
* Optionally pip install one or more packages via `install`, `requirements`, or both

#### Arguments

`path` is required. All other arguments are optional.

* **chown** &mdash; Set the `owner:group` of all files in the created venv as specified by the `chown` value
* **create** &mdash; Create the venv at the provided path. Fail if it already exists.
* **createif** &mdash; Create the venv at the provided path if it doesn't exist. Fail if it already exists and is not a venv ($path/pyenv.cfg doesn't exist)
* **createoptions** &mdash; Switches to add to the `python -m venv` command (e.g., `--system-site-packages`; see <a href="https://docs.python.org/3/library/venv.html"> Creating virtual environments</a>)
* **install** &mdash; Comma-separated list of pip modules to install
* **installoptions** &mdash; Switches to add to the `pip install` command (see `sudo pip install --help | less`)
* **list** &mdash; After the venv has created, list the installed modules with `pip list` to the console and /etc/sdm/history
* **path** &mdash; Path to venv directory specifies the path to the venv
* **requirements** &mdash; /path/to/requirements-file. See <a href="https://pip.pypa.io/en/stable/reference/requirements-file-format/">Requirements file format</a>
* **runphase** &mdash; Specify the phase when the venv should be created. Values are `phase1` or `post-install` [D:phase1]
* **pyver** &mdash; Specify the python version. Not currently used, and set to "3"
* **name** &mdash; Name to use for the venv asset storage. Default is the *filename* of the `path`. Must be used if, for instance two venv invocations create venvs with the same directory name in the same IMG customization

**NOTES:**
* The venv is always created by root. Use the `chown` argument to set different file ownership
* `--requirement` and `--constraint` are not supported in requirements.txt files. Use `-r` and/or `-c`
* If provided, a requirements file may use `-r` and/or `-c`. Those files, however, may NOT have any further nesting.

#### Examples

* `--plugin venv:"path=/usr/local/bin/myvenv|create|install=urllib3,requests"` &mdash; Installs modules `urllib3` and `requests` 
* `--plugin venv:"path=/home/bls/myvenv|create|list|chown=bls:users|install=urllib3,requests|requirements=/ssdy/work/myrqs.txt"` &mdash; Installs modules `urllib3`, `requests` and any modules listed in the requirements.txt file.

### vnc

Install and configure either or both of Virtual VNC and RealVNC.

#### Arguments

* **vncbase=port** &mdash; Starting port for VNC Servers (default: 5900)
* **realvnc=resolution** &mdash; Install RealVNC server with the specified resolution on the console. The resolution is optional.
* **tigervnc=res1,res2,...resn** &mdash; Install tigervnc server with virtual VNC servers for the specified resolutions
* **tightvnc=res1,res2,...resn** &mdash; Install tightvnc server with virtual VNC servers for the specified resolutions
* **wayvnc[=res]** &mdash; Enable wayvnc server. If resolution is specified, set it has the Wayland headless resolution

Only one of tigervnc or tightvnc can be installed and configured on a system by sdm.

#### Examples

* `--plugin vnc:"realvnc|tigervnc=1280x1024,1600x1200"` &mdash; Install RealVNC server for the console and tigervnc virtual desktop servers for the specified resolutions.
* `--plugin vnc:"realvnc=1600x1200"` &mdash; Install RealVNC server and configure the console for 1600x1200, just as raspi-config VNC configuration does.
* `--plugin vnc:"tigervnc=1024x768,1600x1200,1280x1024"` &mdash; Install tigervnc virtual desktop servers for the specified resolutions. Only configure RealVNC if it is already installed (e.g., RasPiOS with Desktop IMG).

#### Additional details

By default Virtual VNC desktops are configured with ports 5901, 5902, ... This can be modified with the `--vncbase` *base* switch. For instance, `--vncbase 6400` would place the VNC virtual desktops at ports 6401, 6402, ... Setting `--vncbase` does not change the RealVNC server port.

For RasPiOS Desktop, RealVNC Server will be enabled automatically. Well, actually, it will be disabled for the first boot of the system as will the graphical desktop, and the sdm FirstBoot service will-reenable both for subsequent use.

For RasPiOS Lite, if the `nodmconsole` keyword is specified to the graphics plugin AND the Display Manager is xdm or wdm, the Display Manager will not be started on the console, and neither will RealVNC Server. It can be started later, if desired, with `sudo systemctl enable --now vncserver-x11-serviced`. Note, however, that you must enable the Display Manager as well for it to really be enabled. To enable the Display Manager:

* **xdm:**&nbsp;`sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/xdm/Xservers`
* **wdm:** `sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/wdm/Xservers`

### wificonfig

wificonfig is used to enable the sdm Captive Portal to delay WiFi SSID/Password configuration until the first system boot.

#### Arguments

* **apssid=APSSID** &mdash;SSID for the Access Point. Default: *sdm*
* **apip=ap.ip.ad.dr** &mdash;IP Address for the Access Point. Default: *10.1.1.1*
* **country=cc** &mdash;Two-letter WiFi country code. The codes are found in /usr/share/zoneinfo/iso3166.tab
* **defaults=/path/to/defaults** &mdash;Path to defaults file. See <a href="Captive-Portal.md#defaults-file">Defaults file</a> for details
* **facility=facname** &mdash;Facility name. Default: *sdm*
* **retries=n** &mdash;Maximum number of retries for the user to set the SSID/Password. Default: *5*
* **timeout=n** &mdash;Captive Portal timeout (interval between network packets from the connecting device). Default: *900 seconds* (15 minutes)
* **wifilog=/path/to/wifilog** &mdash;Log file for the Captive Portal. Default: */etc/sdm/wifi-config.log*

### wireguard

The `wireguard` plugin simplifies and scripts the configuration of Wireguard endpoints. The plugin design is oriented around easily configuring a two-node Wireguard VPN but it can be used for general wireguard host configuration as well.

#### Arguments

* **address** &mdash; Specifies the IP address for this end of the tunnel. In the form x.x.x.x/24, e.g., 10.1.10.1/24
* **allowed-ips** &mdash; Specifies the remote IP addresses that can access the tunnel. Typically this will include the remote host's tunnel IP address (e.g., 10.1.10.2/24) and the remote host's LAN IP address (192.168.44.10/24)
* **addpeer** &mdash; Add a Peer section to an existing interface configuration. Settings supported: `allowed-ips`, `endpoint`, `remote-public-key`, `generate-remote-keys`, `preshared-key`, `persistent-keepalive`
* **dns** &mdash; Specify the DNS server for the tunnel peer(s). Typically a DNS server on the host's LAN or a public DNS server (1.1.1.1, 8.8.8.8, etc)
* **endpoint** &mdash; Specify the remote endpoint DNS name or IP address, and port in the form dns-or-name:port (e.g., myhost.domain.com:51820 or 44.44.44.44:51820)
* **generate-host-keys** &mdash; Generate host public and private keys for this interface. Conflicts with `import-public-key` and `import-private-key`
* **generate-remote-keys** &mdash; Generate remote keys for this `addpeer`. Conflicts with `import-public-key` on an `addpeer` peer configuration
* **import-private-key** &mdash; Import a host's private key specified by /path/to/private-key. Conflicts with `generate-host-keys` on an interface definition
* **import-public-key** &mdash; Import a host's public key specified by /path/to/public-key. Conflicts with `generate-host-keys` on an interface definition
* **ipforward** &mdash; Enable IP forwarding on this host onto the LAN (See below for details)
* **listen-port** &mdash; Port on which wireguard should listen [D:51820]
* **persistent-keepalive** &mdash; See the section <a href="https://www.wireguard.com/quickstart/">NAT and Firewall Traversal Persistence</a> for details on `persistent-keepalive`
* **preshared-key** &mdash; Specify a pre-shared key for a peer. Both peers must share the same key
* **preup** &mdash; Command to run immediately prior to a connection starting
* **predown** &mdash; Command to run immediately prior to a connection terminating
* **postup** &mdash; Command to run immediately after a connection is started
* **postdown** &mdash; Command to run immediately after a connection is terminated
* **remote-public-key** &mdash; Provide the public key for a remote host in the form /path/to/remote.public-key
* **svcenable** &mdash; Enable the connection
* **wghostname** &mdash; Provide a hostname to use for the host keys instead of the connection name [D:copied from `wgname`]
* **wgname** &mdash; Specify the connection name [D:wg0]

#### Notes

Use `ipforward` on a host if you want the remote host to have access to other hosts on this host's LAN.
  * `ipforward=nftables`, `ipforward=y` or simply `ipforward` &mdash; Enable IP forwarding with `nftables` and enable `net.ipv4.ip_forward=1`
  * `ipforward=iptables` &mdash; Use iptables rules instead of nftables

In each of the above cases, `postup` and `postdown` settings are configured for nftables or iptables as appropriate.

The default preup/postup/predown/postdown settings can be overridden by specifying any one of them. In that case, all that should be set must be specified.

In all the above cases, `net.ipv4.ip_forward` is set, and the system will route wireguard packets for this wireguard interface to the LAN

#### Examples

Creating a fully-configured Wireguard interface requires two unique invocations of the `wireguard` plugin. The first time defines the interface (e.g., wg0), and the second (and others, if desired) defines the Wireguard peer using the `addpeer` argument.

See this <a href="Cool-Things-You-Can-Do-wireguard.md">detailed guide</a> for information on the 3 different strategies for configuring wireguard keys, and fully-functional examples.

### wsdd

wsdd is the Web Service Discovery host daemon. It's very useful in Windows/Samba environments. You can read about it at https://github.com/christgau/wsdd

Note that wsdd is available in Bookworm via apt, so this plugin is not needed on Bookworm (Debian 12) or later, although it can still be used if you prefer.

#### Arguments

* **wsddswitches=switchlist** &mdash; List of switches to write into /etc/default/wsdd
* **localsrc=/path/to/files** &mdash; Local directory with cached copy of wsdd (files: wsdd.py wsdd.8 wsdd.defaults wsdd.service)

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
