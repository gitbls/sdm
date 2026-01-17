# Command Details

sdm commands include:

* `sudo sdm --customize raspios-image.img`

    Perform Phase 0 configuration, and drops you in a shell inside the image for Phase 1 customization

* `sudo sdm --burn /dev/sdX --host hostname raspios-image.img`

    Burns the IMG file onto the specified SD card and sets the hostname on the card.

* `sudo sdm --burnfile customized-for-myhostname.img --host myhostname raspios-image.img`

    Burns the IMG file to the specified SD Card Image and sets the hostname. The customized IMG file must be burned to an SD Card to be used.

* `sudo sdm --explore raspios-image.img`

    ***OR***

    `sudo sdm --explore /dev/sdX`

    Uses systemd-nspawn to enter the IMG file (first example) or SD Card (second example) container to explore and/or make manual changes to the image. When using `--explore` there is no access to the files in the host system.

* `sudo sdm --extend [--xmb nnn] raspios-image.img`

    Extends the image by the specified size and exits. The `--extend [--xmb nnn]` switch can also be used in conjunction with `--customize`. The IMG is extended before starting customization.

* `sudo sdm --shrink raspios-image.img`

    Shrinks the image to be as small as possible and exits.

* `sudo sdm --ppart raspios-image.img`

    Prints the partition tables in the IMG file.

* `sudo sdm --mount raspios-image.img`

    ***OR***

    `sudo sdm --mount /dev/sdX`

    Mounts the IMG file (first example) or SD Card (second example) onto the running host system. This enables you to manually and easily copy files from the running host system into the IMG.

    **NOTE: BE VERY CAREFUL!** When you use the `--mount` command you're running as root with access to everything! If you copy or delete a file and neglect to prefix the file directory reference with **/mnt/sdm** you will modify your running system.

* `sudo sdm --info` *what* &mdash; Display one of the databases that specify timezones, locale, keymaps, and wifi-country. The *what* argument can be one of `time`, `locale`, `keymap`, or `wifi`. The requested database is displayed with the `less` command. `--info help` will display the list of options.

## Command switches

sdm has a broad set of command switches. These can be specified in any case (UPPER, lower, or MiXeD).

All files that you provide to sdm, whether on the command line or in arguments to a plugin, must use full paths. For instance, to use a file in your home directory, don't use `file` or `~/file`, use `/home/<mylogin>/file`. Relative file paths may not work because the current directory in which any sdm function is running may change.

* `--1piboot` *conffile* &mdash; Specify a 1piboot.conf file to use instead of the one in /usr/local/sdm/1piboot/1piboot.conf.
* `--aptcache` *IPaddr* &mdash; Use APT caching. The argument is the IP address of the apt-cacher-ng server
* `--apt-dist-upgrade` &mdash; Some RasPiOS Bullseye images have a strange software configuration, which causes `apt-get upgrade` to fail. This switch forces sdm to use `apt-get --dist-upgrade` which updates correctly. [In the 2021-10-30 set of images, the "with Desktop" versions have a set of problematic VLC modules installed.]
* `--apt-options` *value* &mdash; Controls which functions will be performed by sdm-phase1. `--apt-options` and `--poptions` are synonyms. Possible values include:
    * **noautoremove** &mdash; do not do an `apt autoremove`
    * **nologdates** &mdash; do not include date/times in apt.log
    * **noupdate** &mdash; do not do an `apt update`
    * **noupgrade** &mdash; do not do an `apt upgrade`
    * **none** &mdash; set noupdate,noupgrade,noautoremove
 specified

    Enter multiple values as a single string separated by commas. For example `--poptions noupdate,noupgrade`

* `--autologin` &mdash; Cause the user to autologin when the system restarts
* `--b0script` *script* &mdash; Call the function `do_b0script` in *script* when burning. *script* will be called after the output has been burned, and operates in effectively a *Phase 0* environment. See <a href="Burn-Scripts.md">Burn Scripts</a>
* `--b1script` *script* &mdash; Like `--b0script`, but is called in an nspawn container. See <a href="Burn-Scripts.md">Burn Scripts</a>
* `--batch` &mdash; When customization completes do not drop to an interactive command prompt inside the nspawn container; instead, just exit
* `--bootscripts` &mdash; Directs sdm-firstboot to run the boot scripts in /usr/local/sdm/1piboot/0*-*.sh. If `--bootscripts` is specified when creating the sdm-enhanced IMG, every SD Card burned will run the boot scripts on First Boot. If not specified on IMG creation, it can be also be specified when burning the SD Card to run the boot scripts on that SD Card. See <a href="First-Boot-Scripts-and-Configurations.md">First Boot Scripts and Congfigurations</a> for further details.
* `--bupdate` *item* &mdash; Used only on `--burn` command. *item* can be **plugin**: Check and update plugins
    * Best to not include it always unless you know what you're doing
    * `--bupdate` is only honored on a burn command, and is not inspected during a customize command
    * This is very handy when you're in the process of developing a new plugin or updating an existing plugin
* `--chroot` &mdash; By default sdm uses `systemd-nspawn` to enter the container in Phase 1/post-install phases. Some (likely older) host OSes may have issues with that. If `systemd-nspawn` fails with an `execve` error, retry the command and add `--chroot`.
* `--convert-root fstype[,[+]size]` &mdash; Use with `--burn` to create disks with either `btrfs` or `lvm` rootfs. See <a href="Disks-Partitions.md#rootfs-conversion">Disks and Partitions</a>
* `--cscript` *scriptname* &mdash; Specifies the path to your Custom Phase Script, which will be run as described in the Custom Phase Script section below.
* `--csrc` */path/to/csrcdir* &mdash; A source directory string that can be used in your Custom Phase Script. One use for this is to have a directory tree where all your customizations are kept, and pass in the directory tree to sdm with `--csrc`. 
* `--custom[1-4]` &mdash; 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize your Custom Phase Script.
* `--datefmt "fmt"` &mdash; Use the specified date format instead of the default "%Y-%m-%d %H:%M:%S". See `man date` for format string details.
* `--ddsw` *"switches"* &mdash; Provide switches for the `dd` command used with `--burn`. The default is "bs=16M iflag=direct". If `--ddsw` is specified, it replaces the default value.
* `--encrypted` &mdash; Use with the `--explore` and `--mount` commands to access encrypted disks. See <a href="Disk-Encryption.md">Disk Encryption.</a>
* `--expand-at-boot` &mdash; The rootfs will be expanded when the system first boots. You must either use `--regen-ssh-host-keys` or `--plugin sshhostkey:generate-keys`. This switch is only supported with Trixie and later IMGs; however, the version is not checked.
* `--expand-root` &mdash; Used with `--burn`. Expands the root partition on the SSD/SD Card after burning, and disables the default (quick) first boot that does this, since sdm has already expanded the partition
* `--extend` &mdash; Used in conjunction with the `--xmb` switch to extend an image. If used without `--customize` the IMG is extended but no other action is taken. If used with `--customize` the IMG is extended before the IMG is customized.
* `--extract-log` */path/to/dir* &mdash; Extract the log files /etc/sdm/apt.log and /etc/sdm/history from the device or IMG and save them in the specified directory
* `--extract-script` */path/to/script* &mdash; Run the provided script when extracting log information. Can be used for correctness checking, etc.
* `--gpt` &mdash; Directs the `--burn` command to set the burned disk to GPT partitions
* `--groups` *grouplist* &mdash; Specify the groups to be added to new users created with the `user` plugin. The default list is: `users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo`
* `--host` *hostname* or `--hostname` *hostname* &mdash; Specifies the name of the host to set onto the SD Card when burning it.
* `--loadlocal wifi` &mdash; Starts a WiFi Captive Portal to obtain and test the WiFi Credentials during the First Boot. See <a href="Captive-Portal.md">Captive Portal</a> for details. The *flashled* and *internet* options are not supported with `--loadlocal wifi`.
* `--logwidth` *N* &mdash; Set the maximum log line width before lines are split. Default is 96 characters.
* `--norestart` or `--noreboot` &mdash; Do not restart the system after the First Boot. This is useful if you set `--restart` when you build the image, but want to disable the automatic restart for a particular SD Card when you burn it.
* `--nowait-timesync` &mdash; Don't wait for the system time to sync in sdm FirstBoot
* `--nspawnsw` *"switches"* &mdash; Provide additional switches for the systemd-nspawn command. See `man systemd-nspawn`.
* `--plugin plugin-name:"arguments"` &mdash; Include the named plugin with its arguments. sdm interprets a plugin name that starts with **"@"** as a file containing a list of plugins to include See <a href="Plugins.md">Plugins</a> for complete plugin details
* `--plugin-debug` &mdash; Enable additional debug printout in plugins (useful for plugin development)
* `--poptions` *value* &mdash; See `--apt-options` above for details. `--apt-options` and `--poptions` are synonyms.
* `--reboot n` &mdash; Restart the system at the end of the First Boot after waiting an additional *n* seconds. The `-reboot` switch can be used on the command when customizing the IMG (will apply to all SD Cards) or on the `--burn` command (will apply only to SD cards burned with `--restart` set. The system will not restart until the boot process has fully completed. Waiting an additional time may be useful if your system has services that take longer to start up on the first boot. sdm waits until *n* seconds (n=20 for `--restart) after the graphical or multi-user target is reached.
* `--redact` &mdash; See <a href="Passwords.md">Passwords</a> for details.
* `--redo-customize` &mdash; Directs sdm to not prompt for confirmation to redo the customization on a target found to already be customized.
* `--regen-ssh-host-keys` &mdash; The sdm FirstBoot process will regenerate the SSH host keys on the first system boot once the system time has been synchronized. This is useful so that the date/times on /etc/ssh-host* host keys are actual, eliminating potential future confusion. However, the system will move ahead and regenerate the keys if the time has not been synchronized within 60 seconds or if `--nowait-timesync`.
* `--restart` &mdash; Restart the system at the end of the First Boot. The `--restart` switch and `--reboot` are synonomous except that you cannot specify an additional restart wait with the `--restart` switch.
* `--runonly plugins` &mdash; Only run plugins. If no device or directory specified, sdm defaults to directory '/' on the running system.
* `--showapt` &mdash; Show the output from apt (Package Manager) on the terminal in Phase 1. By default, the output is not displayed on the terminal. All apt output is captured in /etc/sdm/apt.log in the IMG.
* `--sdmdir` */path/to* &mdash; sdm normally is in /usr/local/sdm. If you want it to be put somewhere else when you customize an image, use this switch to specify the location. To install sdm itself into a different directory, specify it as the parameter to `install-sdm` when you first install sdm
* `--update-plugins` &mdash; Typically for sdm development use only. When plugins are used during an sdm burn, they are run from the copy in the source IMG. This switch causes sdm to look for newer updates on the host system, and update the burn target before running the plugins.
* `--vncbase` *base* &mdash; Set the base port for VNC virtual desktops; RealVNC Console service is not changed.
* `--wifi-country` *countryname* &mdash; Specify the name of the country to use for the WiFi Country setting. See /usr/share/zoneinfo/iso3166.tab for the complete WiFi Country code list. Also see the `--l10n` command switch which will extract the current WiFi Country setting from /etc/wpa_supplicant/wpa_supplicant.conf or /etc/wpa_supplicant/wpa_supplicant-wlan0.conf on the system on which sdm is running.
* `--xmb` *n* &mdash; Specify the number of MB to extend the image. The default is 2048 (MB), which is 2GB. You may need to increase this depending on the number of packages you choose to install in Phase 1. If the image isn't large enough, package installations will fail. If the image is too large, it will consume more disk space, and burning the image to an SD Card will take longer.

## Customization switches that can be used with --burn

For a list of switches can be used with `--burn`, see <a href="Burn-Scripts.md">Burn Scripts</a>. When used with `--burn`, they affect only the output SSD/SD Card, and not the IMG file.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
