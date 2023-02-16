# Changelog

## V7.9.1

* Make `--user` handling independent of `--nopassword`.

## V7.9

* Wiki documentation updated and completely moved to this github Docs/ directory. Wiki will be removed soon
* Add --nopassword to fully disable password processing during customize
* Add `--rename-pi newuser` to rename the 'pi' user during customization
* New plugins
  * **btwifiset**: Set WiFi SSID/password via Bluetooth
  * **imon**: Install internet up/down, External IP, and Failover monitor
  * **pistrong**: Install strongSwan IPSEC VPN and pistrong Cert Manager
* General code improvements

## V7.8

* Correct V7.7.1 chroot fix
* Ensure pre-phase0 and burn logging contain all messages
* Don't try to process `--user` in burn if it's already added

## V7.7.1

* unset/restore SDMPT around chroot

## V7.7

* If created user doesn't have .bashrc, .profile, or .bash_logout copy them from /etc/skel
* Re-jigger password getting/setting. `--user` now defaults to pi if not specified 
* Enable `--disable`, `--svc-disable', `--svc-enable', and `--autologin` switches with `--burn`
* Improve first boot graphical desktop switching
* Improve apt error detecting/reporting
* Code improvements

## V7.6

* Improve compressed file check
* Improve 'already mounted' check

## V7.5

* Report the occurrence of apt failures in the sdm history

## V7.4

* plugin names can be a full path spec now, and will be copied into local-plugins if needed
* Some generated new disk IDs will now be odd numbers

## V7.3

* Add `--redact` which redacts passwords from /etc/sdm/cparam and /etc/sdm/history. Best to only use on burn command, but also honored on customize
* Ensure that `--bootset` `boot_behaviour` setting is honored

## V7.2

* Use systemctl to get systemd version rather than systemd
* Redo wsl support to autodetect chroot required
  * Detects sdm running on WSL, x86/64
  * Also enables 32-bit RasPiOS to customize 64-bit RasPiOS (slow b/c of qemu but it works!)
* Enable `--user` on the `--burn` command
  * User will be created with specified uid (if `--uid`) or useradd choice of next uid, and home directory created
  * sdm will prompt for password if `--user` specified without `--password-user`
  * User directory can be populated by using a personalized plugin or b0script/b1script
* Correct usermod command in sdm-gburn to append, not replace, groups

## V7.1

* Plugins should do installs in Phase 1 so that Custom Phase Script post-installs can count on them being there. All provided plugins corrected.

## V7.0

* Plugins are here! Like Custom Phase Scripts, Plugins enable sdm functionality to be extended in a modular way. Plugins can be used during `--customize` and `--burn`. See https://github.com/gitbls/sdm/wiki/sdm-Plugins for details.
* Initial plugin set: apt-cacher-ng, apt-file, postfix, rxapp, samba, vnc. See above link for complete details.
* As a result of the new plugins, the following sdm switches have been removed: `--vnc` and `--poptions samba`, which are now available as plugins.
* If sdm installed into /usr/local/sdm, add a link to it in /usr/local/bin, eliminating the need for an alias. Thanks @arpj-rebola for the `realpath` hint
* Code cleanups. Replace most use of `readarray` with `read -a` and fix potential IFS breakage. Cleaner code, less cruft, less oopsie opportunity.

## V6.13

* Add `--debug apt` which installs packges from apps and xapps one at a time instead of all at once. This is useful, for instance, in tracking down which specific package has install problems.
* Streamline exit handling
* Handle down-rev sfdisk that does not have the --disk-id switch by falling back to fdisk
* Redo new disk ID generation for efficiency and simplicity 

## V6.12

* sdm works in Windows WSL! Well, for everything but burning to SSDs/SD Cards. See https://github.com/gitbls/sdm/wiki/Using-sdm-on-Windows-WSL for details.
* Add --nowait-timesync which skips waiting for date/time synchronization in sdm-firstboot. Useful if no network
* Remove /etc/ssh/sshd_config.d/rename_user.conf at the end of first boot; part of /usr/bin/cancel-rename

## V6.11

* Per-system wpa config option in sdm-gburn and allow comment lines and blank lines
* Improve delayed display manager handling for both Lite and Desktop editions

## V6.10

* systemd didn't get '--console` switch until V242, so don't use it on earlier versions

## V6.9

* Basic network manager configuration via `--netman dhcpcd|nm` switch. Preliminary and may change.
* Implement non-interactive sdm usage (--explore, --customize, --mount)

## V6.8

* Properly cleanup/exit when CTRL/C caught. This can obviously leave IMG/SSD/SD in indeterminate state, but mounts and loop devices cleaned up
* If both --expand-root (on burn command) and --regen-ssh-host-keys (on --burn or --customize command) are enabled, disable the unneeded RasPiOS firstboot script when burning
* Burn to (IMG) file improvements
* Always change Disk ID when burning
* Correct wrong parameter order bug identified by @StefanTischler
* Enable sdm-gburn to not add a user if needed for use case (e.g., users created in --customize)
* In addition to disabling userconfig service, also mask it, just in case.

## V6.7

* Correct re-enabling display manager after first boot
* Correct a couple of backwards stderr redirects

## V6.6

* Vast improvements to sdm-gburn. See https://github.com/gitbls/sdm/wiki/Batch-burn-SSD-SDs-with-sdm-gburn
* Reimagined and reimplemented autologin and firstboot autoreboot handling; it's MUCH better
* Add `--nouser` to disable user creation enforcement; Useful with sdm-gburn to burn a large number of SSD/SDs at one sitting
* Add `--autologin` to explicitly enable autologin, on Lite and with Desktop
* Change `--disable piwiz` to properly disable piwiz on Desktop version and userconfig service on both Desktop and Lite
* Set hostname on burn even if IMG is not sdm-enhanced
* Code cleanups

## V6.5

* Improve --expand-root processing, and enable it for non-customized images. Use sfdisk to extend the root partition and set the disk ID. Thanks @rpdom.

## V6.4

* Enable getty@tty1 if using `--svc-disable userconfig`. Since sdm can do effectively what the userconfig service does (add a new user with a password) it needs to complete the system configuration that the userconfig service does. /usr/lib/userconf-pi/userconf calls /usr/bin/cancel-rename, which enables getty@tty1.

## V6.3

* Check for parted installed if `--extend`

## V6.2

* Add sdm-gburn script, which burns a group of per-recipient customized SD Cards from a single IMG. Useful for classrooms or commercial distribution, for instance.
* Correct comments for in quote-stripping code

## V6.1

* Mask or unmask services when enabling/disabling them via --svc-enable/--svc-disable, as appropiate. Hat tip to RonR.

## V6.0

* Test and verify that sdm works correctly with RasPiOS 2022-04-07. See https://github.com/gitbls/sdm/wiki/Hint:-Using-sdm-on-2022-04-04-and-later-RasPiOS-images for details.
  * If using sdm on pre-2022-04-04 images, the user 'pi' password is changed by default (password of your choice, of course!)
  * If using sdm on 2022-04-04 or later images, the user 'pi' password is only changed if you specify `--user pi` on the command line
* `--user` is now **required** on customizations. For pre-2022-04-04 you can specify `--user pi` if you don't want a new user created. For 2022-04-04 or later images, use this to create your favorite username, or use `--user pi` if desired
* Remove requirement than sdm must reside in /usr/local/sdm. It can now be anywhere in the file system
  * To install sdm into a directory other than /usr/local/sdm on your running system, provide the directory name as the first argument to `EZsdmInstaller`. You must download and run EZsdmInstaller locally with `sudo /path/to/EZsdmInstaller` */path/to/install-sdm* to use this capability
  * Use `--sdmdir` */path/to/dir* when customizing to change where sdm places itself in the customized image
  * **IMPORTANT: This creates a (slightly) incompatible change in Custom Phase scripts.** See the 'loadparams' function in sdm-customphase and update your Custom Phase script accordingly
* Improved error checking in EZsdmInstaller
* Enable command line switch `--L10N` and `--L10n` in addition to `--l10n`

## V5.5

* Correct check for any partitions on the burn target device being mounted and provide a useful message if so.

## V5.4

* WARNING: In order to bring consistency between the burn phase and the customization phase, switch `--b1script` has been renamed to `--b0script` and `--b2script` has been renamed to `--b1script`. Apologies for any inconvenience this causes. See https://github.com/gitbls/sdm/wiki/Burn-Scripts for details.

## V5.3a

* Buglet fix: Incorrect check for /mnt/sdm existence

## V5.3

* Improve status message readability at --shrink completion
* When burning, don't set hostname to an fqdn if --domain specified, leaving that to the user. However, fqdn IS added to /etc/hosts entry 127.0.0.1
* Fix edge case in --shrink that threw an incorrect message

## V5.2

* Add --expand-root. When used with --burn, expands the root partition on the SSD/SD Card after burning. This eliminates the need for the resize/reboot when first booting the system, which, by the way, is automatically disabled when you use --expand-root.

## V5.1

* sdm now creates, but doesn't use, /etc/sdm/local-assets in the IMG, for your use in Custom Phase Scripts
* Don't try to flush the burn log if /etc/sdm doesn't exist in the burn target
* Multiple copies of sdm can be simultaneously active on the same system, removing a prior restriction. sdm uses /mnt/sdm if it's available. If not, it uses /mnt/sdm.$BASHPID. NOTE: If you are using a Custom Phase script and want to use multiple active sdm instances, you must edit your Custom Phase script and change all instances of /mnt/sdm to $SDMPT. See the updated example Custom Phase script
* Processing of svc-disable, svc-enable, and bootset switches are no longer deferred to FirstBoot, except in the case of using the switches on the --burn command. In this case they are processed during FirstBoot
* Tidy up VNC handling. sdm can install RealVNC for graphically accelerated console VNC. RealVNC Virtual Desktops require an Enterprise License, so you can use one of TigerVNC or TightVNC for virtual desktops.
* Fix cosmetic race condition on RasPiOS with Desktop where autologin was prematurely re-enabled by FirstBoot. 
* General code cleanups

## V5.0

* Rearrange documentation into a Wiki
* Add --shrink to shrink an IMG file
* Add --ppart to display the partitions in an IMG file or SSD/SD Card
* Add --svc-disable and --svc-enable for switch naming consistency
* Enable --rclocal on burn command
* Don't disable wpa_supplicant service and raspberrypi-net-mods. If you want them disabled, use either --svc-disable or a custom phase script
* Correct dhcpcd wait logic to accommodate buster/bullseye image location difference
* Move processing of several switches from Phase 0 to Phase 1, since they don't need access to local system storage: --bootadd, --bootconfig, --dtoverlay, --dtparam, --hdmi-force-hotplug, --hdmi-ignore-edid, --hdmigroup, --hdmimode, --rclocal

## V4.20

* Copy 1piboot.conf to /usr/local/sdm/1piboot on target in sdm as well as to /etc/sdm

## V4.19

* Add --gadget-mode to configure the image for USB Gadget Mode
* Add --swap n to set swap size to nMB
* Add --regenerate-ssh-host-keys to regenerate SSH host keys after system time is synced (or 60 seconds elapse)
* Enable --rclocal to be used on the burn command. (Each target burn can have a different set of rc.local commands if desired)
* Copy 1piboot.conf to /usr/local/sdm/1piboot as well as to /etc/sdm

## V4.18

* Add --disable options,in,a,list. Valid options are bluetooth, piwiz, swap, triggerhappy, and wifi
* Add --systemd-config item:filename to augment systemd config files for: login,network,resolve,system,timesync,user. See README for details
* Remove --noswap and --nopiwiz in favor of --disable
* Reorder and group processing "similar" Phase 0 and Phase 1 customizations together (sdm, networks, user, system)

## V4.17

* Add --journal to control the system journal configuration (syslog, journal|persistent, volatile, none)

## V4.16

* Add --noswap to disable dphys-swapfile and hence no swapfile created or used
* Suppress "Reading database" messages from apt/dpkg that were spewed into /etc/sdm/apt.log
* Correct xvnc*@.service definitions for Bullseye systemd: Remove User=nobody, set StandardError to journal
* 1piboot script 030-disble-rsyslog now writes the config change to a file in /etc/systemd/journald.conf.d/

## V4.15

* Add --password-pi, --password-user, and --password-root to set account passwords from the command line. See README for details, especially the important note about Password retention in the image. These switches can also be used to apply unique passwords when burning an SSD/SD Card.
* Add --password-same y|n, which avoids the "Use same password?" question during customization
* Add --redo-customize, which skips the "Image is already customized, Redo?" prompt
* add -q to systemd-nspawn command to eliminate some extraneous message spew
* Correct mis-handling of --info help command
* General message improvements
* General code improvements

## V4.14

* Add --lxde-config, which enables you to correctly load config files for lxterminal and pcmanfm. See the README for details. If there are other apps that you'd like to see included, please open an issue on this github. (Side note: The bash construct `${!symbol}` is so cool!)
* Add --logwidth N, which sets the maximum log line width before splitting. Default is 96 characters.

## V4.13

* Improve disk space used logging

## V4.12

* Always disable sdm-firstboot service at end of FirstBoot processing
* Improve check for "is package installed"

## V4.11

* Fix sdm-phase0 creating $myuser home directory on running system rather than in /mnt/sdm
* Fix erroneous redirects in sdm-phase1 (and checked others!)
* Have you ever mistakenly pointed sdm to a ZIP file instead of the IMG contained within it? I did today. Never again though!

## V4.10

* Add missing hyphens to hdmi-ignore-edid in switch table

## V4.09

* Add --hdmi-ignore-edid which sets hdmi_ignore_edid=0xa5000080 in /boot/config.txt
* Correct some references to logit function
* Correct dd switches for improved performance
* Enable sdm-hotspot to install hotspot without using sdm (see source)

## V4.08

* Improve and simplify Phase 0 vs 1 identification to reduce code complexity
* Improve --b2script handling

## V4.07

* Add --hotspot to install and configure a hotspot, either as 'local', 'routed', or 'bridged'
* Add --b1script to run a script after the SSD/SD Card has been burned. See README
* Add --b2script to run a script, like --b1script, but in the context of the newly-burned SD Card (nspawn)

## V4.06

* Add --mouse left to enable left-handed mouse in LXDE (for those that are in their right mind)
* Add --nopiwiz to disable piwiz from running on LXDE desktop systems (no effect if no LXDE)
* Remove --aptconfirm, a holdover from very early releases (didn't work, and could hang apt waiting for input)

## V4.05

* Log apt maintenance steps
* Add --cron-systemd to disable the cron service and use systemd timers instead.

## V4.04

* Have you been burned by running of of space in an IMG during customization and not noticing it? This fix is for you (and me!) Print number of free blocks at start of customization, start of Phase 1, and at the end of Phase 1. Also, if IMG appears full at end of Phase 1, log a very visible message.

## V4.03

* Set --eeprom value during FirstBoot so an upgrade during Phase 1 doesn't risk a deadlock if apt asks for resolution on the modified /etc/default/rpi-eeprom-update
* Disable --poptions 'nofirstboot' poption. It's still accepted in case anyone was using it, but it is ignored.
* Polished Display Manager configuration in Phase 1
* Add --poption 'noautoremove' to skip the apt autoremove in Phase 1
* Add --poption 'novnc' to skip processing --vnc. Useful for scripting.
* Add --showpwd to log passwords created in /etc/sdm/history. Explicitly set protection of /etc/sdm to 700.
* If --wpa is used to provide a wpa_supplicant.conf, disable raspberrypi-net-mods to speed up boot time by an infintesimally small amount.

## V4.02

* Add --vnc switch to configure tigervnc or tightvnc virtual servers, and/or the RealVNC graphical console server. You can easily install the RealVNC server attached to the graphical console (Lite), and several Virtual VNC servers (Desktop and Lite), each with their own preconfigured geometry (handy if you connect to a host from different systems with varied screen sizes)
* If xdm or wdm is installed, enable it on console after FirstBoot unless --poptions 'nodmconsole' (lightdm is not configurable for this AFAICT)
* Add --groups to control which groups are added to user created with --user

## V4.01

* EZinstaller update to make LAN-based testing easier
* Improve some help text
* Only copy "known" 1piboot/*.sh files when copying sdm into an image. If you have other scripts you want in the image, copy them using a Custom Phase Script.

## V4.00

* Rework readparams, logit, and logtoboth. If you are using a Custom Phase Script, you'll need to edit it and remove the first argument to logit and logtoboth. They now only take one argument, the string to be output. If you don't do this, you'll see blank lines, or lines with "/mnt/sdm".
* Add --domain domainname. This is not used by sdm, but is available for use in your Custom Phase Script
* Write hostname to cparams when burning

## V3.26

* Correct block device check so sdm doesn't try to mount a non-existent IMG file

## V3.25

* Enable sdm to operate on an OS directory tree with --directory
* Code cleanliness: Add missing 'local' declarations in functions
* Correct --motd handling, and enable --motd /dev/null to create a null /etc/motd

## V3.24

* Add --modprobe to add /etc/modprobe.d config files into image
* Add --motd to replace /etc/motd with a different message
* --sysctl can be specified multiple times

## V3.23

* Add --udev to add udev files into image

## V3.22

* Correct --noreboot operation
* Document switches supported on --burn command
* Make EZsdmInstaller OS-aware and install additional packages as appropriate
* Disable apt config file modification checking during apt upgrade
	

## V3.21

* Handle partitions on /dev/mmcblk0 correctly, named "p1" and "p2", not "1" and "2"

## V3.20

* Minor correction in handling of --dtparam --dtoverlay strings
* Add --rclocal to add command lines to /etc/rc.local
* Add --cron-{d,hourly,daily,weekly,monthly} to copy a crontab file to the corresponding /etc/cron.{d,hourly,daily,weekly,monthly} directory

## V3.19

* Implement --dtparam and --dtoverlay. Multiple of each can be specified
* Improve --help command code so it isn't so ugly

## V3.18

* --extend should not require --nowpa
* Redo --extend handling. --extend will extend an image by --xmb N MB. --extend with --customize extends image and then customizes, if used without --customize, just extends and then exits. --noextend is no longer needed.
* --customize is now required to customize an image.
* Basic testing on Stretch images, which work fine. Functions added to raspi-config in Buster will obviously not work on Stretch, but still handy to have Localization, WiFi, SSH, and app installations working if you need to go back to Stretch for any reason.

## V3.17

* Correct --apps and --xapps switch value handling

## V3.16

* Add --bootset powerled:n for Pi Zero and Pi400 (currently). n=0 to flash LED on disk activity, n=1 on constantly

## V3.15

* Complete logging of --exports, --sysctl, and --dhcpcd on burn command
* Improve --burn messages consistency

## V3.14

* Add --exports file which copies the specified file into the image as /etc/exports
* Add --sysctl file which copies the specified file into the image in /etc/sysctl.d The filename must end with '.conf'
* Change --dhcpcd behavior to append to /etc/dhcpcd.conf in the image during Phase 0, so that it is in place for the first system boot.
* Support --exports, --sysctl, and --dhcpcd on the burn command as well.

## V3.13

* Improve help if image has already been customized
* Add --aptmaint update,upgrade,autoremove for "batch" mode IMG maintenance

## V3.12

* Improve DHCP wait logic in sdm-firstboot
* Correct file naming local-1piboot(.conf) in sdm-firstboot
* Add --hdmi-force-hotplug 1 to easily enable the setting in config.txt
* Add --loadlocal wifi to get WiFi credentials via a Captive Portal WiFi hotspot. FlashLED doesn't work with this. Yet.
* Add --dhcpcdwait to enable 'wait for internet'. Equivalent to raspi-config System Option S6.
* Add --dhcpcd file to append the contents of 'file' to /etc/dhcpcd.conf

## V3.11

* --loadlocal accepts additional values 'flashled' signal status with the Green LED) and 'internet' (check for Internet connectivity)
    
## V3.10

* Add --loadlocal to load WiFi and Localization details from a USB device on First Boot. Handy if sending an image or SD Card to
someone who doesn't want to disclose their WiFi credentials.
* Add --info command to 'less' the databases used for checking Time Zones, Locales, Keymaps, and WiFi Country. See `sdm --info help` for details
* Check switch value errors for Locale, Keymap, Timezone, and WiFi Country

## V3.9

* Correct numeric test check

## V3.8

* Check that switches with numeric values are as they should be

## V3.7

* FirstBoot message cleanups
* Always run firstboot scripts created in /etc/sdm/0piboot (e.g., from Custom Phase Scripts)

## V3.6

* Minor logging updates in sdm-firstboot
* Remove gratuitous "Done" in sdm-cparse
* --reboot now takes a value for number of seconds to wait after system has reached default target before restarting. --restart does NOT take a value, and has a wait time of 20 seconds.

## V3.5

Updates:

* Redo FirstBoot handling for improved efficiency

## V3.4

New features:

* SSD tested and works
* Add --bootset command switch. Now all 1piboot settings can be done from the command line
* Strip carriage returns when importing wpa_supplicant.conf just in case
* Document enabling boot from USB disk (SSD)

## V3.3

New features:

* Strip carriage returns when importing wpa_supplicant.conf just in case
* --mount and --explore now operate on block devices, such as SD Cards, as well as IMG files

## V3.2

This is a major overhaul from prior versions. Error and message handling has been cleaned up and improved. 

New features:

* **Automatic reboot** after the system First Boot &mdash; Get to a fully-configured system more quickly. Super-useful if you're using the Serial Port to connect to your Pi.
* **RasPiOS Desktop **integration &mdash; Automatic reboot shows in the console window during the system First Boot, and reboots to the full Graphical Desktop
* **rasPiOS device support **(serial, i2c, spi, camera, etc...) &mdash; Any device capabilities that can be set with raspi-config, can be set with sdm.
* **Burn to an IMG file** in addition to burn to an SD card. Very useful if you want to send an SD Card Image to someone so that they can burn their own SD Card
* **/etc/fstab extension** &mdash; Easily add site-specific mounts to add to /etc/fstab
*  Simplified Localization&mdash; `--L10n` gathers the localization settings from the system on which sdm is running, or easily specify on the command line using `--keymap`, `--locale`, `--timezone`, and `--wifi-country
* **Integrated wpa_supplicant.conf handling** &mdash; Specify your wpa_supplicant.conf on the command line
* **Integrated SSH handling** &mdash; SSH is enabled by default. Use `--ssh none` to disable SSH, or `--ssh socket` to use systemd socket-based SSH to remove one process from the running system.

