# sdm
Raspberry Pi SD Card Image Manager

## Description

`sdm` provides a quick and easy way to build consistent, ready-to-go SD cards for the Raspberry Pi. This command line management tool is especially useful if you:

* have multiple Raspberry Pi systems and you want them all to start from an identical and consistent set of installed software packages, configuration scripts and settings, etc.

* want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed. Every time.

* want to do the above repeatedly and a LOT more quickly.

What does *ready-to-go* mean? It means that every one of your systems is fully configured with Keyboard mapping, Locale, Timezone, and WiFi set up as you want, all of your personal customizations and all desired RasPiOS packages and updates installed.

In other words, all ready to work on your next project.

With sdm you'll spend a lot less time rebuilding SD cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

Someone in the RaspberryPi.org forums said *"Generally I get by by reflashing an SD card and reinstalling everything from the notes I made previously. That is not such a long winded process."*

While better than not having ANY notes, this approach requires relatively complete notes, and careful attention to detail each and every time you need to reflash a card.

`sdm` lets you keep your notes in simple working bash code and comments, and makes a "not such a long winded process" into a single command that you run whenever you need to create a new SD card. And the card is built with ALL of your favorite apps installed and all your favorite customizations.

***As a bonus***, sdm includes an *optional* script to install and configure `apt-cacher-ng`. `apt-cacher-ng` is a RasPiOS package that lets you update all your Pis quickly by caching downloaded packages locally on your LAN. This can greatly reduce install and update time, as well as internet network consumption.

sdm is for RasPiOS, and runs on RasPiOS Buster. sdm requires a USB SD Card reader to write a new SD Card. You cannot use sdm to rewrite the running system's SD Card.

## Usage overview

### sdm Quick Start

Here's how to quickly and easily to create and customize an IMG file and burn it to an SD Card. It's assumed that there is a freshly downloaded copy of RasPiOS 2020-08-20-raspios-buster-armhf-full.img or 2020-08-20-raspios-buster-armhf-lite.img in the current directory, and that there is an SD Card in /dev/sde.

* **Install sdm:** `sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash`

* **Customize the image:** `sudo /usr/local/sdm/sdm 2020-08-20-raspios-buster-armhf-full.img --wpa /path/to/working/wpa_supplicant.conf --noextend --L10n --restart`

    sdm will copy your Localizaton settings (Keymap, Locale, Timezone, and WiFi Country) from the system on which it's running, and prompt for a new password for user 'pi'. No additional packages will be installed in this example, but 'apt update' and 'apt upgrade' will be done.

* **Burn the image onto the SD Card:** `sudo /usr/local/sdm/sdm --burn /dev/sde --hostname mypi1 2020-08-20-raspios-buster-armhf-full.img`

Now, load the SD card into a Pi and power it up. The system will come up as it always does:

* Resizes the root file system and restarts automatically
* After the system restarts it goes through a complete system startup, just as it always does on a fresh SD Card
* Toward the end of the boot process an sdm systemd service script runs once and sets the WiFi country, unblocking WiFi
* When the system boot is fully complete (it can take a while on a large SD card!), the system automatically restarts again

When the system comes back up your Pi is all happy, ready to go, and configured with:  [Link text](URL)

* **The latest RasPiOS updates installed** for all installed packages
* **Password set** for user 'pi'
* **Hostname** set to *mypi1*, or whatever you choose to use as the hostname
* **Keymap**, **Locale**, and **Timezone** configured the same as the system on which you are running sdm (easily changeable, of course)
* **Wifi** configured and operational
* **SSH** enabled

What else can sdm do? Here are a few examples:

* **Install applications**  &mdash; Editors (emacs, vim, etc), and any other packages you always install in a new system. sdm has two built-in package install lists, creatively named *apps* and *xapps*. You can select which of the two lists to include when you build an image, so you can build images with no additional apps, *apps* only, *xapps* only, or both.
* **Personal customizations** &mdash; Have every system come up running with your own customizations such as your favorite .bashrc and any other files that you always want on your system
* **Append Custom fstab file to /etc/fstab** &mdash; Automatically append your site-specific fstab entries to /etc/fstab
* **systemd service configuration and management** &mdash; If there are services that you always enable or disable, you can easily configure them with sdm
* **Enable Pi-specific devices** &mdash; Easily enable camera, i2c, etc, via raspi-config automation
* **Other customizations** &mdash; Done through a simple batch script. The file sdm-customphase is a skeleton Custom Phase Script that you can copy, modify, and use. **Full disclosure: **You'll need to use a Custom Phase Script to copy your .bashrc or /etc/fstab, or perform systemd service management, etc. See the section Custom Phase Script below for details, and see the section below on /etc/fstab as well.
* **Burn SD Card Image for network distribution** &mdash; You can build a customized SD Card Image to distribute via a mechanism other than an actual SD Card, such as the Internet. The recipient can burn the SD Card using any one of a number of tools on Linux ([Installing Operating System Images](https://www.raspberrypi.org/documentation/installation/installing-images/)), Windows ([Installing Operating System Images Using Windows](https://www.raspberrypi.org/documentation/installation/installing-images/windows.md)), or MacOS ([Installing Operating System Images Using MacOS](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)).

## Detailed Installation and Usage Guide

Installation is simple. sdm must be installed in and uses the path `/usr/local/sdm` both on your running system and within images that it manages. **The simplest way to install sdm is to use EZsdmInstaller**, which performs the commands listed in *the really long way*:

    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

**Or, download the Installer script to examine it before running:**

    curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller -o ./EZsdmInstaller
    chmod 755 ./EZsdmInstaller
    # Inspect the EZsdmInstaller script if desired
    sudo ./EZsdmInstaller

**Or, download it the really long way:**

    sudo mkdir -p /usr/local/sdm /usr/local/sdm/1piboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm -o /usr/local/sdm/sdm
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase0 -o /usr/local/sdm/sdm-phase0
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase1 -o /usr/local/sdm/sdm-phase1
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-cparse -o /usr/local/sdm/sdm-cparse
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-firstboot -o /usr/local/sdm/sdm-firstboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-apt-cacher -o /usr/local/sdm/sdm-apt-cacher
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-customphase -o /usr/local/sdm/sdm-customphase
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/1piboot.conf -o /usr/local/sdm/1piboot/1piboot.conf
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/010-disable-triggerhappy.sh -o /usr/local/sdm/1piboot/010-disable-triggerhappy.sh
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/030-disable-rsyslog.sh -o /usr/local/sdm/1piboot/030-disable-rsyslog.sh
    sudo chmod -R 755 /usr/local/sdm/* /usr/local/sdm/1piboot/*.sh
    sudo chmod 644 /usr/local/sdm/{sdm-apps-example,sdm-xapps-example} /usr/local/sdm/1piboot/1piboot.conf

## sdm Operation Details

sdm operates on the SD Card image in distinct phases:

* **Phase 0:** *Operating in the logical context of your physical RasPiOS system, copying files into the RasPiOS IMG file.* sdm takes care of Phase 0 for you. The Phase 0 script `sdm-phase0` performs the Phase 0 copying. It will also optionally call a Custom Phase script provided by you to perform customized personal steps. See *Custom Phase Script *below for details.

* **Phase 1:** *Operating inside the IMG file and in the context of that system (via systemd-nspawn)*. When operating in this context, all changes made only affect the SD Card IMG, not the physical RasPiOS system on which sdm is running

    Most, but not all commands can be used in Phase 1. For instance, most `systemctl` commands don't work because systemd is not running in the nspawn'ed image. However, `systemctl disable` and `systemctl enable` do work. 

    Other functions you might want to do in Phase 1 include: add new users, set or change passwords, install packages, etc. In other words, you can do almost everything you want to configure a system for repeated SD card burns.

    Once sdm has started the nspawn container, it will automatically run `/usr/local/sdm/sdm-phase1` to perform Phase 1 customization. As with Phase 0, your optional Custom Phase Script will be called. After Phase 1 completes, sdm will provide a command prompt inside the container unless you specified `--batch`, in which case sdm will exit the container. **NOTE:** When sdm provides a command prompt, either with Phase 1 customization or with `--mount`, the terminal colors are changed to remind you that the IMG is mounted. See the section on Terminal Colors below.

* **Phase 2:** *Write the SD Card*. Using the `sdm --burn` command, the IMG is written to the new physical SD card using ***dd***, and the new system name is written to the SD card. *This enables a single IMG file to be the source for as many Pi systems as you'd like.* Of course, you can burn the SD Card using a different tool if you'd prefer, although you'll need to set the hostname with another mechanism.

* **Phase 3:** *Boot the newly-created SD card on a Pi*. When the new system boots the first time, the systemd service sdm-firstboot.service sets WiFi Country, and any device-specific settings you've enabled (see below), and then disables itself so it doesn't run on subsequent system boots.

## Usage Examples

* `sudo /usr/local/sdm/sdm --poptions apps --apps @myapps --user bls --uid 1600 --hdmigroup 2 --hdmimode 82 2020-08-20-raspios-buster-armhf-full.img`

    Installs the apps from the list in the file myapps into the image, creates user bls with the specified UID, and sets the HDMI settings in /boot/config.txt needed for my monitor.

* `sudo /usr/local/sdm/sdm --poptions apps --apps "iperf3 zip nmap" --user bls --uid 1600 --bootconfig hdmigroup:2,hdmimode:82 2020-08-20-raspios-buster-armhf-full.img`

    This is similar to the above, showing how config.txt settings can be specified individually and apps can be listed on the command line instead of an @file.

* `sudo /usr/local/sdm/sdm --burn /dev/sdc --host sky 2020-08-20-raspios-buster-armhf-full.img`

    sdm burns the image to the SD Card in /dev/sdc and sets the hostname to 'sky'.

    **NOTE:** While sdm does check that the device is a block device and is not mounted, it is still a good idea to double check that you're writing to the device you think you are before pressing ENTER.

* `sudo /usr/local/sdm/sdm --explore 2020-08-20-raspios-buster-armhf-full.img`

    sdm enters nspawn on the image for you to work on it. For example, you might want to do an *apt update* and *apt upgrade*, install additional packages, or make other configuration or customization changes, before you burn a new SD Card.

## sdm Script Details

sdm consists of a primary script `sdm` and several supporting scripts:

* **sdm-phase0**  &mdash; Script run by sdm before nspawn-ing into the IMG file. sdm-phase0 has access to the running Pi system as well as the file system within the IMG file. You can customize what's done in Phase 0 by using a Custom Phase Script (see below). sdm-phase0 performs several steps:

     * If `--user` is specified, creates the user's home directory so that your Custom Phase script can copy files into it during Phase 0. The user is also enabled to use `sudo` like the user *pi*.

    * Miscellaneous requested configuration changes: Setting hdmigroup and hdmimode, any other boot config settings, and the eeprom directory.

    * Calls the Custom Phase Script for Phase 0 if specified. See Custom Phase Script below.

* **sdm-phase1**  &mdash; Asks for and changes the password for the *pi* user. Optionally, if you used the sdm `--user` switch, creates your personal account, sets its password, directory and protections, etc. If `--aptcache` was specified, the IMG is enabled as an apt-cacher-ng client. See below for details on apt-cacher-ng.

    sdm-phase1 installs the apps that you've specified. You control which applications are installed by using the `--apps` switch. The value for the `--apps` switch can either be a quoted, space-separated list ("pkg1 pkg2 pgk3"), or @somefile, where somefile has a list of applications to install, one per line. Comments are indicated by a pound sign (#) and are ignored, so you can document your app list if desired. If the specified file is not found, sdm will look in the sdm directory (/usr/local/sdm). 

    sdm-phase1 also installs the 'X' apps that you've specified. You control which applications are installed by using the `--xapps` switch. The value for the `--xapps` switch is treated the same as for the `--apps` switch above. This is probably more interesting if you're using RasPiOS Lite, which does not include the X Windows software in the image. The example file `sdm-xapps-example` provides one example of installing a minimal X Windows system, but since there are a multitude of ways to install X11, display managers, window managers, and X11-based applications, you'll undoubtedly want to build your own xapps list.

    * There is no restriction that the *xapps* list actually contains X Windows apps; it can be used as a set of secondary apps if desired.

    * App installation is enabled by providing the *apps* and/or *xapps* values to the `--poptions` command switch.

    * sdm does not *require* that you separate your app list into "apps" and "X apps". This is done solely to provide you with more fine-grained control over app selection. For instance, you might not want to install the X apps into a server image, but want both sets installed on a Desktop configuration.

* **sdm-apt**  &mdash; sdm-apt is an optional script that you can use to issue apt commands when in Phase 1 or via `sdm --explore`. It logs the apt output in /etc/sdm/apt.log along with all the other apt operations done in by sdm in customizing your image. Refer to the script for details.
* **sdm-firstboot**  &mdash; sdm-firstboot is a systemd service run on first system boot to set the WiFi country, enables Pi-specific devices if configured, and optionally run any Custom FirstBoot scripts.

* **1piboot/* **&mdash;  Configuration file and sample scripts. You may need to edit the configuration file (1piboot.conf). See the next section for details. This directory will also be installed onto the SD Card in /usr/local/sdm/1piboot. 

    If enabled, the custom scripts in 1piboot/0*-*.sh are run when the system first boots, and provide system tuning improvements. You can, of course, disable any of these by renaming them with a leading period, or changing the file type (from ".sh" to ".sh-disabled", for example). The custom scripts are enabled by the switch `--bootscripts` on either the command line that builds the IMG, or on the `sdm --burn` command when burning a new SD card. Two example scripts are provided. You can use either, both, or none of these, as you desire.

    * **010-disable-triggerhappy.sh**  &mdash; Disables the TriggerHappy service, which you may not be using. (Does anyone actually use TriggerHappy? Asking for a friend)
    * **030-disable-syslog.sh**  &mdash; Switches the system log from using rsyslog, writing several text-based log files in /var/log (daemon.log, syslog, auth.log, kern.log, and messages) to using journalctl and writing a log in /var/log/journal. The `sudo journalctl` command can be used to view the log (in either scenario).

* **sdm-cparse**  &mdash; Helper script that defines some sdm-internal bash functions.

* **sdm-customphase**  &mdash; Custom Phase Script skeleton. Use this as a starting point to build your own Custom Phase Script. See Custom Phase Script below.

* **sdm-apt-cacher**  &mdash; Configures and installs apt-cacher-ng. This is optional, but highly recommended, especially with slower internet connections. sdm will use this with the `--aptcache` command switch. See the section on apt-cacher-ng below for details.

## 1piboot.conf

1piboot/1piboot.conf is a configuration file that describes RasPiOS-related configuration settings to be made in your image. Configuration settings are made when the system first boots. All of these settings use raspi-config to make the actual changes to the system. sdm does not syntax check the settings.

### First Boot configuration settings

The following can only be set in the context of a running system, so are set during the first boot of the operating system. Details on each of these settings are available in the `sudo raspi-config` command. Unless otherwise specified, you enable the setting by uncommenting the corresponding line in 1piboot.conf and setting it to 0 (enabled) or other value as noted (e.g., *audio*, *pi4video*, *boot_behaviour*, and *boot_order*).

* **boot_splash** &mdash; Enable a splash screen at boot time
* **boot_wait** &mdash; Wait for a network connection to be established
* **camera** &mdash; Enable the camera
* **i2c** &mdash; Enable the ARM I2C interface
* **net_names** &mdash; Enable predictable device names
* **onewire** &mdash; Enable the one-wire interface
* **rgpio** &mdash; Enable the network-accessible GPIO server
* **serial** &mdash; Enable the serial port
* **spi** &mdash; Enable the SPI interface
* **blanking** &mdash; Enable screen blanking
* **overscan** &mdash; Enable compensation for displays with overscan.
* **pixdub** &mdash; Enable pixel doubling
* **audio** &mdash; Set the audio setting. Valid settings are: **0:**Auto, **1:**Force 3.5mm jack, **2:**Force HDMI
* **pi4video** &mdash; Set the Pi4 video mode. Valid settings are: **V1:**4Kp60, **V2:**Analog TV out, **V3:**Disable both 4Kp60 and Analog
* **boot_behaviour** &mdash; Set the boot behavior. Valid settings are: **B1:**Text console no autologin, **B2:**Text console with autologin, **B3:**Graphical Desktop no autologin, and **B4:**Graphical Desktop with autologin
* **boot_order** &mdash; Set the boot order. Valid settings are: **B1:**Boot from USB device if SD Card boot fails, **B2:**Network boot if SD Card boot fails
* **overclock** &mdash; Enable overclocking. Valid settings are: **None**, **Modest**, **Medium**, **High**, **Turbo**. This setting is for Pi 1 and 2 only and will silently fail on all other Pi models.

**NOTE:** Not all of the above settings have been thoroughy tested and verified. They simply call `raspi-config`, so *should just work*. If you run into a problem, please open an issue on this github.

#### First Boot Automatic System Restart
One last First Boot setting controls whether the system automatically restarts at the completion of the First Boot processing. This is controlled with the `--restart` switch (or equivalently `--reboot`). The automatic system restart will wait until the system boot process has fully completed before restarting.

First Boot Automatic System Restart is useful for a couple reasons:

* if access to the system requires a configuration setting modified during the First Boot. A reboot ensures that all configuration settings are fully enabled.

    For example, if the only access to the Pi will be over the serial port, the system must be restarted before the serial port will be active. In this case you would enable `serial=0` in 1piboot.conf and use the `--restart` command switch so the Pi automatically restarts.

* You want it to reboot to make it easier to ensure that your configuration and services are as desired
* You want the system to be fully operational so you can get started!

**NOTE:** If `--restart` is specified on **RasPiOS Full with Desktop** sdm changes the boot_behaviour to **B1** (Text console with no autologin) so that the sdm FirstBoot messages are visible. In this case the boot_behaviour is reset to **B4** (Graphical Desktop with autologin) for all subsequent reboots, unless 1piboot.conf has been modified and a different value for boot_behaviour is set.

## Complete sdm Command List

`sdm` commands consist of:

* `sudo /usr/local/sdm/sdm raspios-image.img`

    Perform Phase 0 configuration, and drops you in a shell inside the image for Phase 1 customization

* `sudo /usr/local/sdm/sdm --burn /dev/sdX --host hostname raspios-image.img`

    Burns the IMG file onto the specified SD card and sets the hostname on the card.

* `sudo /usr/local/sdm/sdm --burnfile customized-for-myhostname.img --host myhostname raspios-image.img`

    Burns the IMG file to the specified SD Card Image and sets the hostname. The customized IMG file must be burned to an SD Card to be used.

* `sudo /usr/local/sdm/sdm --explore raspios-image.img`

    Uses systemd-nspawn to "go into" the IMG file to explore and/or make manual changes to the image. `--explore` disables automatic image extension. When using `--explore` there is no access to the files in the running system.

* `sudo /usr/local/sdm/sdm --extend [--xmb nnn] raspios-image.img`

    Extends the image by the specified size and exits. Use --noextend if you need to re-enter sdm to prevent further unwanted extensions.

* `sudo /usr/local/sdm/sdm --mount raspios-image.img`

    Mounts the IMG file onto the running system. This enables you to manually and easily copy files from the running RasPiOS system into the IMG.

 **NOTE: BE VERY CAREFUL!** When you use the `--mount` command you're running as root with access to everything! If you copy or delete a file and neglect to prefix the file directory reference with **/mnt/sdm ** you will modify your running system.

sdm has a broad set of command switches. These can be specified in any case (UPPER, lower, or MiXeD).

* `--1piboot` *conffile* &mdash; Specify a 1piboot.conf file to use instead of the one in /usr/local/sdm/1piboot/1piboot.conf
* `--apps` *applist* &mdash; Specifies a list of apps to install. This can be either a quoted list of space-separate apps ("zip iperf3 nmap") or a pointer to a file (@file), which has one package name per line. Comments are preceded by a pound sign ('#') and are ignored. You must specify `--poptions apps` in order for sdm to process the *apps* list.
* `--aptcache` *IPaddr* &mdash; Use APT caching. The argument is the IP address of the apt-cacher-ng server
* `--aptconfirm` &mdash; Prompt for confirmation before APT installs and updates are done in sdm Phase 1
* `--batch` &mdash; Do not provide an interactive command prompt inside the nspawn container
* `--bootadd` *key:value,key:value,...* &mdash; Add new keys/values to /boot/config.txt
* `--bootconfig` *key:value,key:value,...* &mdash; Update existing, commented keys in /boot/config.txt
* `--bootscripts` &mdash; Directs sdm-firstboot to run the boot scripts in 1piboot/*.sh. If `--bootscripts` is specified when creating the sdm-enhanced IMG, every SD Card burned will run the boot scripts on First Boot. If not specified on IMG creation, it can be also be specified when burning the SD Card to run the boot scripts on that SD Card.
* `--cscript` *scriptname* &mdash; Specifies the path to your Custom Phase Script, which will be run as described in the Custom Phase Script section below.
* `--csrc` */path/to/csrcdir* &mdash; A source directory string that can be used in your Custom Phase Script. One use for this is to have a directory tree where all your customizations are kept, and pass in the directory tree to sdm with `--csrc`. 
* `--custom[1-4]` &mdash; 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize your Custom Phase Script.
* `--datefmt "fmt"` &mdash; Use the specified date format instead of the default "%Y-%m-%d %H:%M:%S". See `man date` for format string details.
* `--ddsw` *"switches"* &mdash; Provide switches for the `dd` command used with `--burn`. The default is "bs=16M oflag=direct". If `--ddsw` is specified, the default value is replaced.
* `--eeprom` *value* &mdash; Change the eeprom value in /etc/default/rpi-eeprom-update. The RasPiOS default is 'critical', which is fine for most users. Change only if you know what you're doing.
* `--fstab` *file* &mdash; Append the contents of the specified file to /etc/fstab in the Customized Image. This is useful if you want the same /etc/fstab entries on your RasPiOS systems.
* `--hdmigroup` *num* &mdash; hdmigroup setting in /boot/config.txt
* `--hdmimode` *num* &mdash; hdmimode setting in /boot/config.txt
* `--host` *hostname* or `--hostname` *hostname* &mdash; Specifies the name of the host to set onto the SD Card when burning it.
* `--keymap` *keymapname* &mdash; Specifies the keymap to set into the image, or burn onto the SD Card. `--keymap` can be specified when customizing the image and/or when burning the SD card. Specifying `--keymap` with `--burn` overrides whatever is in the image. Also see `--l10n`. See the *layout* section in /usr/share/doc/keyboard-configuration/xorg.list for a complete list of keymaps.
* `--l10n` &mdash; Build the image with the Keymap, Locale, Timezone, and WiFi Country of the system on which sdm is running. Note that the switch name is lowercase *L10N*, which is shorthand for "localization", just like I18N is shorthand for "internationalization"
* `--locale` *localename* &mdash; The locale is specified just as you'd set it in raspi-config. For example, in the USA, one might use en_US.UTF-8, and in the UK en_UK.UTF-8. See /usr/share/local/i18n/SUPPORTED for a complete locale list.
* `--noextend` &mdash; Do not extend the IMG file at all
* `--norestart` or `--noreboot` &mdash; Do not restart the system after the First Boot. This is useful if you set `--restart` when you build the image, but want to disable the automatic restart for a particular SD Card when you burn it.
* `--nspawnsw` *"switches"* &mdash; Provide additional switches for the systemd-nspawn command. See `man systemd-nspawn`.
* `--poptions` *value* &mdash; Controls which functions will be performed by sdm-phase1. Possible values include:
    *  **apps** &mdash; install the *apps*
    * **noupdate** &mdash; do not do an `apt update`
    * **noupgrade** &mdash; do not do an `apt upgrade`
    * **samba** &mdash; streamlined, promptless Samba install
    * **xapps** &mdash; install the *xapps*

    Enter multiple values as a single string separated by commas. For example `--poptions apps,xapps` or `--poptions noupdate,noupgrade`

* `--restart` or `--reboot` &mdash; Restart the system at the end of the First Boot. The `--restart` switch can be used on the command when customizing the IMG (will apply to all SD Cards) or on the `--burn` command (will apply only to SD cards burned with `--restart` set. The system will not restart until the boot process has fully completed.
* `--showapt` &mdash; Show the output from apt (Package Manager) on the terminal in Phase 1. By default, the output is not displayed on the terminal. All apt output is captured in /etc/sdm/apt.log in the IMG.
* `--ssh` *SSHoption* &mdash; Control how SSH is enabled in the image. By default, if `--ssh` is not specified, SSH will be enabled in the image using the SSH service, just like RasPiOS. if `--ssh none` is specified SSH will not be enabled. If `--ssh socket` is specified SSH will be enabled using SSH sockets via systemd instead of having the SSH service hanging around all the time.
* `--timezone` *tzname* &mdash; Set the timezone for the system.  See `sudo timedatectl list-timezones | less` for a complete list of timezones.
* `--user` *username* &mdash; Specify a username to be created in the IMG. 
* `--uid` *uid* &mdash; Use the specified uid rather than the next assignable uid for the new user, if created.
* `--wifi-country` *countryname* &mdash; Specify the name of the country to use for the WiFi Country setting. See /usr/share/zoneinfo/iso3166.tab for a complete list. Also see `--l10n` which will extract the current WiFi Country setting from /etc/wpa_supplicant/wpa_supplicant.conf or /etc/wpa_supplicant/wpa_supplicant-wlan0.conf on the system on which sdm is running.
* `--wpa` *conffile* &mdash; Specify the wpa_supplicant.conf file to use. You can either specify your wpa_supplicant.conf on the command line, or copy it into your image in your sdm-customphase script. See the sample sdm-customphase for an example. `--wpa` can also be specified when burning the SD Card.
* `--nowpa` &mdash; Use this to tell sdm that you really meant to not provide a wpa_supplicant.conf file. You must either specify `--wpa` or `--nowpa` when customizing an IMG. This is useful if you want to build SD Cards for different networks. You can use `--nowpa` when you customize the IMG, and then specify `--wpa` *conffile* when burning the SD Card.
* `--xapps` *xapplist* &mdash; Like `--apps`, but specifies the list of apps to install when `--poptions xapps` is specified.
* `--xmb` *n*` &mdash; Specify the number of MB to extend the image. The default is 2048 (MB), which is 2GB. You may need to increase this depending on the number of packages you choose to install in Phase 1. If the image isn't large enough, package installations will fail. If the image is too large, it will consume more disk space, and burning the image to an SD Card will take longer.

## sdm-firstboot

sdm-firstboot is a script executed by the service created in the IMG that runs when the system boots the first time. sdm-firstboot sets the WiFi Country, other infrequently used device settings, and optionally executes custom scripts in /usr/local/sdm/thispi/1piboot/0*-*.sh See the examples on this github. sdm Phase 0 copies these files from /usr/local/sdm/1piboot on the running system.

## Custom Phase Script

A Custom Phase Script is a script provided by you. It is called 3 times: Once for Phase 0, once for Phase 1, and once after Phase 1 has completed. The first argument indicates the current phase ("0", "1", or "post-install"). The Custom Phase Script needs to be aware of the phase, as there are contextual differences:

* In Phase 0, the host file system is fully available. The IMG file is mounted on /mnt/sdm, so all references to the IMG file system must be appropriately referenced by prefacing the directory string with /mnt/sdm. This enables the Custom Phase script to copy files from the host file system into the IMG file.

* In Phase 1 and post-install (both inside nspawn) the host file system is not available at all. Thus, if a file is needed in Phase 1, Phase 0 must copy it into the IMG. References to /mnt/sdm will fail in Phase 1.

The best way to build a Custom Phase Script is to start with the example Custom Phase Script `sdm-customphase`, and extend it as desired.

## /etc/fstab

sdm does not touch the lines in /etc/fstab created by RasPiOS. You may want to append one or more lines to /etc/fstab to set up other mounts, such as SMB, NFS, etc, and smb provides a couple of different ways to handle importing and appending your custom /etc/fstab into your image.

One way to do this is via a Custom Phase Script. In your Custom Phase Script, your Phase 0 code copies the fstab extension file into the IMG somewhere. Then, your Phase 1 code appends the copied fstab extension to the etc/fstab.

One drawback with this approach is that your fstab additions will be processed during the system FirstBoot. Network timeouts, etc could be an issue. This can be solved by using a Custom bootscript to append your custom fstab file to /etc/fstab.

That's exactly what `--fstab` does. It copies the file you provide to /etc/sdm/assets in the IMG, and then processes that during the system FirstBoot.

No matter which mechanism you use, you'll need to create the mount point directories in the image during Phase 1.

## Installing Samba into your IMG

Installing Samba is super-simple! Add *samba* as one of the values in the comma-separated `--poptions` list. Samba will be installed silently with no prompts.

In addition to the basic install, you can of course do also do other configuration such as creating shares, creating accounts and setting up Samba passwords, by adding the appropriate commands to your Custom Phase script in the post-install section.

## Terminal Colors

sdm changes the terminal colors when providing a command prompt in Phase 1, or when using the `--mount` command, to remind you that things are not quite "normal".

The colors are controlled by the `--ecolors` command switch, which takes an argument specified as 3 colors. The default is `--ecolors blue:gray:red` which sets the foreground (text) blue, the background gray, and the cursor red. 

## apt-cacher-ng

apt-cacher-ng is a great RasPiOS package, and nearly essential if you have more than a couple of Pi systems. The savings in download MB and installation wait time is really quite impressive.

apt-cacher-ng requires a system running the apt-cacher server. For your sanity and the best and most reliable results, run this on a "production", always available Pi.

Once you have configured the server system, copy sdm-apt-cacher to the server and execute the command `sudo /path/to/sdm-apt-cacher server`. This will install apt-cacher-ng on the server and configure it for use. If the server firewall blocks port 3142 you'll need to add a rule to allow it.

Once you have the apt-cacher server configured you can use the `--aptcache` *IPaddr* sdm command switch to configure the IMG system to use the APT cacher.

If you have other existing, running Pis that you want to convert to using your apt-cacher server, copy sdm-apt-cacher to each one and execute the command 'sudo /path/to/sdm-apt-cacher client`.

## Bread crumbs

sdm leaves a couple of files in /etc/sdm in the IMG that are used to control its operation and log status.

* *apt.log* contains all the apt command output (package installs) done during the SD Card creation

* *cparams* are the parameters with which sdm was initially run on the image

* *history* has the log written by sdm

* *1piboot.conf* is the configuration file used when the IMG was customized

* *auto-1piboot* is used by sdm. At the current time, it is only used to reset the *boot_behaviour* on RasPios Full with Desktop.

* *custom.ized* tells sdm that the image has been customized. If this exists, sdm will not rerun Phase 0. If you really want to rerun Phase 0 on an already-customized image, use `sdm --explore` to nspawn into the image and `rm -f /etc/sdm/custom.ized`.

## Cleaning up dangling mounts

If something is not working right, make sure that there are no dangling mounts in the running RasPiOS system. You can end up with a dangling mount if sdm terminates abnormally, either with an error (please report!) or via an operator-induced termination. If sdm is not running, you should see no "/mnt/sdm" mounts (identified with `sudo df'). 

You can unmount them by manually using `sudo umount -v /mnt/sdm/{boot,}`. This will umount /mnt/sdm/boot and then /mnt/sdm. You'll need to delete the dangling loop device also.

## Loop devices

A couple of quick notes on loop devices, which are used to mount the IMG file into the running system.

* `losetup -a` lists all in-use loop devices

* `losetup -d /dev/loopX` deletes the loop device /dev/loopX (e.g., /dev/loop0). You may need to do this to finish cleaning up from dangling mounts (which you do first, before deleting the loop device).

* If your system doesn't have enough loop devices, you can increase the number by adding max_loop=n on end of /boot/cmdline.txt and reboot.
