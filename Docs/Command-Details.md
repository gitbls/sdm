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

    Uses systemd-nspawn to *go into* the IMG file (first example) or SD Card (second example) to explore and/or make manual changes to the image. When using `--explore` there is no access to the files in the running system.

* `sudo sdm --extend [--xmb nnn] raspios-image.img`

    Extends the image by the specified size and exits. The `--extend [--xmb nnn]` switch can also be used in conjunction with `--customize`. The IMG is extended before starting customization.

* `sudo sdm --shrink raspios-image.img`

    Shrinks the image to be as small as possible and exits.

* `sudo sdm --ppart raspios-image.img`

    Prints the partition tables in the IMG file.

* `sudo sdm --mount raspios-image.img`

    ***OR***

    `sudo sdm --mount /dev/sdX`

    Mounts the IMG file (first example) or SD Card (second example) onto the running system. This enables you to manually and easily copy files from the running RasPiOS system into the IMG.

    **NOTE: BE VERY CAREFUL!** When you use the `--mount` command you're running as root with access to everything! If you copy or delete a file and neglect to prefix the file directory reference with **/mnt/sdm** you will modify your running system.

* `sudo sdm --info` *what* &mdash; Display one of the databases that specify timezones, locale, keymaps, and wifi-country. The *what* argument can be one of `time`, `locale`, `keymap`, or `wifi`. The requested database is displayed with the `less` command. `--info help` will display the list of options.

## Command switches

sdm has a broad set of command switches. These can be specified in any case (UPPER, lower, or MiXeD).

* `--1piboot` *conffile* &mdash; Specify a 1piboot.conf file to use instead of the one in /usr/local/sdm/1piboot/1piboot.conf. Note that this is less preferable than using the `--bootset` command switch.
* `--apps` *applist* &mdash; Specifies a list of apps to install. This can be either a quoted list of space-separate apps ("zip iperf3 nmap") or a pointer to a file (@file), which has one package name per line. Comments are preceded by a pound sign ('#') and are ignored. You must specify `--poptions apps` in order for sdm to process the *apps* list.
* `--apssid` *SSID* &mdash; Use the specified SSID for the Captive Portal instead of the default 'sdm'. See <a href="Captive-Portal.md">Captive Portal</a> for details.
* `--apip` *IPaddr* &mdash; use the specified IP Address instead of the default 10.1.1.1. See <a href="Captive-Portal.md">Captive Portal</a> for details.
* `--aptcache` *IPaddr* &mdash; Use APT caching. The argument is the IP address of the apt-cacher-ng server
* `--apt-dist-upgrade` &mdash; Some RasPiOS Bullseye images have a strange software configuration, which causes `apt-get upgrade` to fail. This switch forces sdm to use `apt-get --dist-upgrade` which updates correctly. [In the 2021-10-30 set of images, the "with Desktop" versions have a set of problematic VLC modules installed.]
* `--autologin` &mdash; Cause the user to autologin when the system restarts
* `--b0script` *script* &mdash; Call the function `do_b0script` in *script* when burning. *script* will be called after the output has been burned, and operates in effectively a *Phase 0* environment. See <a href="Burn-Scripts.md">Burn Scripts</a>
* `--b1script` *script* &mdash; Like `--b0script`, but is called in an nspawn container. See <a href="Burn-Scripts.md">Burn Scripts</a>
* `--batch` &mdash; Do not provide an interactive command prompt inside the nspawn container
* `--bootadd` *key:value,key:value,...* &mdash; Add new keys/values to /boot/config.txt
* `--bootconfig` *key:value,key:value,...* &mdash; Update existing, commented keys in /boot/config.txt
* `--bootset`  *key:value,key:value,...* &mdash; Change system configuration settings. See <a href="Bootset-and-1piboot.md">Bootset and 1piboot</a>. Note that `key=value` can also be used.
* `--bootscripts` &mdash; Directs sdm-firstboot to run the boot scripts in 1piboot/*.sh. If `--bootscripts` is specified when creating the sdm-enhanced IMG, every SD Card burned will run the boot scripts on First Boot. If not specified on IMG creation, it can be also be specified when burning the SD Card to run the boot scripts on that SD Card.
* `--bupdate` *item* &mdash; Used only on `--burn` command. *item* can be **plugin**: Check and update plugins
    * Best to not include it always unless you know what you're doing
    * `--bupdate` is only honored on a burn command, and is not inspected during a customize command
    * This is very handy when you're in the process of developing a new plugin or updating an existing plugin
* `--cron-d` *file* &mdash; Copy the cron file to /etc/cron.d. `--cron-d` can be specified multiple times to copy multiple files.
* `--cron-hourly` *file* &mdash; Copy the cron file to /etc/cron.hourly. `--cron-hourly` can be specified multiple times to copy multiple files.
* `--cron-daily` *file* &mdash; Copy the cron file to /etc/cron.daily. `--cron-daily` can be specified multiple times to copy multiple files.
* `--cron-weekly` *file* &mdash; Copy the cron file to /etc/cron.weekly. `--cron-weekly` can be specified multiple times to copy multiple files.
* `--cron-monthly` *file* &mdash; Copy the cron file to /etc/cron.monthly. `--cron-monthly` can be specified multiple times to copy multiple files.
* `--cron-systemd` &mdash; Disable the cron service and enable cron via systemd sockets instead. One less process in the system, but some cron features are not supported, such as user-level crontabs.
* `--cscript` *scriptname* &mdash; Specifies the path to your Custom Phase Script, which will be run as described in the Custom Phase Script section below.
* `--csrc` */path/to/csrcdir* &mdash; A source directory string that can be used in your Custom Phase Script. One use for this is to have a directory tree where all your customizations are kept, and pass in the directory tree to sdm with `--csrc`. 
* `--custom[1-4]` &mdash; 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize your Custom Phase Script.
* `--datefmt "fmt"` &mdash; Use the specified date format instead of the default "%Y-%m-%d %H:%M:%S". See `man date` for format string details.
* `--ddsw` *"switches"* &mdash; Provide switches for the `dd` command used with `--burn`. The default is "bs=16M iflag=direct". If `--ddsw` is specified, the default value is replaced.
* `--dhcpcdwait` &mdash; Enable 'wait for network' (raspi-config System option S6).
* `--dhcpcd` *file* &mdash; Append the contents of the specified file to /etc/dhcpcd.conf in the Customized Image.
* `--disable` *option* &mdash; Disable specified options in the comma-separated list. Supported options: `bluetooth`, `piwiz`, `swap`, `triggerhappy`, `wifi`.
    * `bluetooth` &mdash; Block bluetooth via /etc/modprobe.d/blacklist-sdm-bluetooth.conf and disable the hciuart service
    * `piwiz` &mdash; Don't run piwiz during first system boot if LXDE is installed. All the settings in piwiz can be accomplished in sdm.
    * `swap` &mdash; Disables the dphys-swapfile service. No service, no swap file.
    * `triggerhappy` &mdash; Disable the Triggerhappy service, which most people don't use. This also disables the udev rule that creates boot-time log spew.
    * `wifi` &mdash; Disable wifi via /etc/modprobe.d/blacklist-sdm-wifi.conf, which disables the onboard WiFi adapter.
* `--dtoverlay` *string* &mdash; Add a dtoverlay to /boot/config.txt with the specified string, one dtoverlay per switch. Multiple `--dtoverlay` switches can be specified. They will all be added to config.txt
* `--dtparam` *string* &mdash; Add a dtparam to /boot/config.txt with the specified string, one dtparam per switch. Multiple --dtparam switches can be specified. They will all be added to config.txt
* `--eeprom` *value* &mdash; Change the eeprom value in /etc/default/rpi-eeprom-update. The RasPiOS default is 'critical', which is fine for most users. Change only if you know what you're doing.
* `--expand-root` &mdash; Used with `--burn`. Expands the root partition on the SSD/SD Card after burning, and disables the default (quick) first boot that does this, since sdm has already expanded the partition
* `--exports` *file* &mdash; Copy the specified file into the image as /etc/exports
* `--fstab` *file* &mdash; Append the contents of the specified file to /etc/fstab in the Customized Image. This is useful if you want the same /etc/fstab entries on all of your RasPiOS systems.
* `--gadget-mode` &mdash; Configure the image to be a USB gadget.
* `--groups` *grouplist* &mdash; Specify the groups to be added to new user created with `--user`. The default list is: `dialout,cdrom,floppy,audio,video,plugdev,users,adm,sudo,users,input,netdev,spi,i2c,gpio`
* `--hdmi-force-hotplug` &mdash; Enable the hdmi_force_hotplug setting in /boot/config.txt
* `--hdmigroup` *num* &mdash; hdmigroup setting in /boot/config.txt
* `--hdmimode` *num* &mdash; hdmimode setting in /boot/config.txt
* `--host` *hostname* or `--hostname` *hostname* &mdash; Specifies the name of the host to set onto the SD Card when burning it.
* `--hotspot` See <a href="Hotspot.md">Hotspot</a>
* `--journal` *type* &mdash; *type* specifies how to configure the system log. The default is `syslog`, which is "as configured" in RasPiOS. For the other values, the rsyslog service is disabled and logging configured:
    * `persistent`: Makes a permanent journal in /var/log
    * `volatile`: The journal is in memory and not retained across system restarts
    * `none`: There is no system journal
* `--keymap` *keymapname* &mdash; Specifies the keymap to set into the image, or burn onto the SD Card. `--keymap` can be specified when customizing the image and/or when burning the SD card. Specifying `--keymap` with `--burn` overrides whatever is in the image. Also see `--l10n`. See `sudo sdm --info keymap` or the *layout* section in /usr/share/doc/keyboard-configuration/xorg.list for a complete list of keymaps.
* `--l10n` &mdash; Build the image with the Keymap, Locale, Timezone, and WiFi Country of the system on which sdm is running. Note that the switch name is (lowercase) *L10N*, which is shorthand for "localization", just like *I18N* is shorthand for "internationalization". Both `--l10n` and `--L10n` are accepted.
* `--loadlocal USB` &mdash; WiFi Credentials are read from a USB device. The switch keyword value USB is required. The Credentials must be in the file `local-settings.txt` in the root directory of the USB device. `local-settings.txt` has three text lines in it, specifying the WiFi Country, WiFi SSID and password in the format:

        country=2 letter country code
        ssid=yourSSIDname
        password=yourWiFiPassword

    `local-settings.txt` can include 3 additional lines for setting `keymap`, `locale`, and `timezone`. These take the same values as the `--keymap`, `--locale`, and `--timezone` command switches.

    The First Boot process will wait for and use the first non-mounted USB device that is found. If the file `local-settings.txt` is not found on that USB device, First Boot will print a message on the console, and the wait process will be restarted, so the remote user can update their USB device as needed. See /usr/share/zoneinfo/iso3166.tab for the complete WiFi Country code list. If `--loadlocal` is used, `--wifi-country` and the WiFi Country setting obtained from `--l10n` are ignored.

    In addition to the switch value USB, the `--loadlocal` switch also accepts the values `flashled` and `internet`. The `flashled` value causes the First Boot process to flash the green Pi LED with progress indicators. See <a href="LED-Flashing.md">LED Flashing</a> for details. The `internet` value causes First Boot to check that the Pi has Internet access. If there is no internet access, First Boot will restart the load from USB process.

* `--loadlocal wifi` &mdash; Starts a WiFi Captive Portal to obtain and test the WiFi Credentials during the First Boot. See <a href="Captive-Portal.md">Captive Portal</a> for details. The *flashled* and *internet* options are not supported with `--loadlocal wifi`.
* `--locale` *localename* &mdash; The locale is specified just as you'd set it in raspi-config. For example, in the USA, one might use en_US.UTF-8, and in the UK en_UK.UTF-8. See `sudo sdm --info locale` or /usr/share/i18n/SUPPORTED for a complete locale list.
* `--logwidth` *N* &mdash; Set the maximum log line width before lines are split. Default is 96 characters.
* `--lxde-config` *args* &mdash; Copy the specified LXDE app configuration files into the image. See <a href="Using-LXDE-Config.md">Using LXDE Config</a>
* `--modprobe` *file* &mdash; Copy the modprobe file to /etc/modprobe.d. `--modprobe` can be specified multiple times to copy multiple files.
* `--motd` *file* &mdash; Copy the specified file to /etc/motd. The original /etc/motd is renamed to /etc/motd.orig. You can easily create a null message of the day by using `--motd /dev/null`
* `--mouse left` &mdash; If LXDE is installed, set the Mouse to be left-handed (for those that are in their right mind).
* `--norestart` or `--noreboot` &mdash; Do not restart the system after the First Boot. This is useful if you set `--restart` when you build the image, but want to disable the automatic restart for a particular SD Card when you burn it.
* `--nopassword` &mdash; Do not require a password during customization. If no password is applied when the IMG is subsequently burned, it will be rather difficult to login to the system.
* `--nouser` &mdash; Enable customizing an IMG with no user configured. This is useful if you want to late-create the user, either with `sdm --burn` or sdm-gburn.
* `--nowait-timesync` &mdash; Don't wait for the system time to sync in sdm FirstBoot
* `--nspawnsw` *"switches"* &mdash; Provide additional switches for the systemd-nspawn command. See `man systemd-nspawn`.
* `--password-pi` *password* &mdash; Specify the password for the "pi" user. See <a href="Passwords.md">Passwords</a> for details
* `--password-root` *password* &mdash; Specify the password for root. See <a href="Passwords.md">Passwords</a> for details
* `--password-same` *arg* &mdash; Specify whether all accounts should have the same password. *arg* can be **yes** or **no**. *All accounts* includes *pi*, the user specified by `--user`, and root, if `--rootpwd` is specified.
* `--password-user` *password* &mdash; Specify the password for the `--user` user. See <a href="Passwords.md">Passwords</a> for details
* `--plugin plugin-name:"arguments"` &mdash; Include the named plugin with its arguments. See <a href="Plugins.md">Plugins</a> for complete plugin details
* `--plugin-debug` &mdash; Enable additional debug printout in plugins (useful for plugin development)
* `--poptions` *value* &mdash; Controls which functions will be performed by sdm-phase1. Possible values include:
    * **apps** &mdash; install the *apps*
    * **noautoremove** &mdash; do not do an `apt autoremove`
    * **noupdate** &mdash; do not do an `apt update`
    * **nodmconsole** &mdash; do not enable Display Manager on console (xdm or wdm only)
    * **noupgrade** &mdash; do not do an `apt upgrade`
    * **xapps** &mdash; install the *xapps*

    Enter multiple values as a single string separated by commas. For example `--poptions apps,xapps` or `--poptions noupdate,noupgrade`

* `--rclocal` *command* &mdash; Add the specified command to /etc/rc.local. Multiple `--rclocal` switches can be specified, and the commands are added in the order specified on the command line.
* `--reboot n` &mdash; Restart the system at the end of the First Boot after waiting an additional *n* seconds. The `-reboot` switch can be used on the command when customizing the IMG (will apply to all SD Cards) or on the `--burn` command (will apply only to SD cards burned with `--restart` set. The system will not restart until the boot process has fully completed. Waiting an additional time may be useful if your system has services that take longer to start up on the first boot. sdm waits until *n* seconds (n=20 for `--restart) after the graphical or multi-user target is reached.
* `--redact` &mdash; See <a href="Passwords.md">Passwords</a> for details.
* `--redo-customize` &mdash; Directs sdm to not prompt for confirmation to redo the customization on a target found to already be customized.
* `--regenerate-ssh-host-keys` &mdash; The sdm FirstBoot process will regenerate the SSH host keys on the first system boot once the system time has been synchronized. The system will move ahead and regenerate the keys if the time has not been synchronized within 60 seconds.
* ``--rename-pi newuser` &mdash; Instead of creating a new user, rename the `pi` user to the specified new username, and properly configure the home directory, etc.a
* `--restart` &mdash; Restart the system at the end of the First Boot. The `--restart` switch and `--reboot` are synonomous except that you cannot specify an additional restart wait with the `--restart` switch.
* `--showapt` &mdash; Show the output from apt (Package Manager) on the terminal in Phase 1. By default, the output is not displayed on the terminal. All apt output is captured in /etc/sdm/apt.log in the IMG.
* `--sdmdir` */path/to* &mdash; sdm normally is in /usr/local/sdm. If you want it to be put somewhere else when you customize an image, use this switch to specify the location. To install sdm itself into a different directory, specify it as the parameter to EZsdmInstall when you first install sdm
* `--showpwd` &mdash; Show the passwords set on accounts in /etc/sdm/history
* `--ssh` *SSHoption* &mdash; Control how SSH is enabled in the image. If `--ssh` is not specified or if  *SSHoption* is `service`, SSH will be enabled in the image using the SSH service, just like RasPiOS. if `--ssh none` is specified SSH will not be enabled at all. If `--ssh socket` is specified SSH will be enabled using SSH sockets via systemd instead of having the SSH service hanging around all the time.
* `--svcdisable` and `--svcenable` &mdash; Enable or disable named services, specified as comma-separate list, as part of the first system boot processing. 
* `--swap` *n* &mdash; Set the swap size to *n*MB. This overrides `--disable swap`
* `--sysctl` *file* &mdash; Copy the specified file into the image in /etc/sysctl.d. `--sysctl` can be speicified multiple times to copy multiple files.
* `--systemd-config` *item*:*file* &mdash; Specify config files for the various systemd functions. *item* is one of: 	    `login`, `network`, `resolve`, `system`, `timesync`, `user`. The specified file is put into the directory /etc/systemd/*item*.conf.d, and the filename must be terminated with ".conf" in order for systemd to process them during systemd initialization. See the corresponding man page for details: `man logind.conf`, `man networkd.conf`, `man resolved.conf`, `man systemd-system.conf`, `man timesyncd.conf`, and `man systemd-user.conf`. The most useful of these is probably 'timesync', which lets you easily set a time server address.
* `--timezone` *tzname* &mdash; Set the timezone for the system.  See `sudo sdm --info time` or `sudo timedatectl list-timezones | less` for a complete list of timezones.
* `--udev` *file* &mdash; Copy the udev rule file to /etc/udev/rules.d. `--udev` can be specified multiple times to copy multiple files.
* `--user` *username* &mdash; Specify a username to be created in the IMG. 
* `--uid` *uid* &mdash; Use the specified uid rather than the next assignable uid for the new user, if created.
* `--update-plugins` &mdash; Typically for sdm development use only. When plugins are used during an sdm burn, they are run from the copy in the source IMG. This switch causes sdm to look for newer updates on the host system, and update the burn target before running the plugins.
* `--vncbase` *base* &mdash; Set the base port for VNC virtual desktops; RealVNC Console service is not changed.
* `--wifi-country` *countryname* &mdash; Specify the name of the country to use for the WiFi Country setting. See /usr/share/zoneinfo/iso3166.tab for the complete WiFi Country code list. Also see the `--l10n` command switch which will extract the current WiFi Country setting from /etc/wpa_supplicant/wpa_supplicant.conf or /etc/wpa_supplicant/wpa_supplicant-wlan0.conf on the system on which sdm is running.
* `--wpa` *conffile* &mdash; Specify the wpa_supplicant.conf file to use. You can either specify your wpa_supplicant.conf on the command line, or copy it into your image in your sdm-customphase script. See the sample sdm-customphase for an example. `--wpa` can also be specified when burning the SD Card.
* `--nowpa` &mdash; Use this to tell sdm that you really meant to not provide a wpa_supplicant.conf file. You must either specify `--wpa` or `--nowpa` when customizing an IMG. This is useful if you want to build SD Cards for different networks. You can use `--nowpa` when you customize the IMG, and then specify `--wpa` *conffile* when burning the SD Card.
* `--xapps` *xapplist* &mdash; Like `--apps`, but specifies the list of apps to install when `--poptions xapps` is specified.
* `--xmb` *n* &mdash; Specify the number of MB to extend the image. The default is 2048 (MB), which is 2GB. You may need to increase this depending on the number of packages you choose to install in Phase 1. If the image isn't large enough, package installations will fail. If the image is too large, it will consume more disk space, and burning the image to an SD Card will take longer.

## Customization switches that can be used with --burn

For a list of switches can be used with `--burn`, see <a href="Burn-Scripts.md">Burn Scripts</a>. When used with `--burn`, they affect only the output SSD/SD Card, and not the IMG file.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
