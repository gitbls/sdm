# sdm
Raspberry Pi SD Card Image Manager

## Description

`sdm` is a command-line management tool to simplify and expedite building consistent, ready-to-go SD cards for the Raspberry Pi. This is especially useful if you have multiple Raspberry Pi systems, or want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed.

With sdm you'll spend a lot less time rebuilding SD cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

sdm only runs on Raspbian, and requires a USB SD Card reader when writing a new SD Card.

## Installing sdm

## Details

sdm is structured as a phased set of steps for managing the SD Card image, and writing an SD card for booting. These phases are:

* **Phase 0:** *Copying files into the Raspbian IMG file.* sdm takes care of Phase 0 for you. The Phase 0 script `sdm-phase0` performs the Phase 0 copying. It will also call a custom script provided by you to perform customized personal steps. See below for details. 
* **Phase 1:** *Operating inside the IMG file and in the context of that system (via nspawn)*. When operating in the context of that system, all changes made affect the SD Card IMG, not the Raspbian system on which sdm is running. Most, but not all commands can be used. For instance, `systemctl` doesn't work because systemd is not running in the nspawn'ed image. But, new users can be added, passwords can be changed, packages can be installed, etc. Once you get a command prompt, you'll enter `/usr/local/sdm/sdm-phase1` to perform Phase 1 customization. As with Phase 0, your personal customization script will be called.
* **Phase 2:** *Writing the SD Card*. The IMG is dd'd onto the new physical SD card, and the new system name is written to the SD card afterwards. This enables a single IMG file to be the source for all of your Pi systems.
* **Phase 3:** *Booting the newly-created SD card on a Pi*. When the new system boots the first time, the systemd service sdm-firstboot sets the system name and WiFi country and disables itself so that it doesn't run on subsequent system boots.

## What's here

sdm consists of a primary script `sdm` and several supporting scripts:

* **sdm-phase0 -** Skeleton script file run by sdm before nspawn-ing into the IMG file. sdm-phase0 has access to the running Pi system and the file system within the IMG file. You can customize this as desired by using a Custom Phase script. The base file file performs several steps:
    * Sets up ssh and wpa_supplicant in the IMG boot partition
    * Sets up the sdm-firstboot service
    * Copies sdm scripts into the IMG
    Your custom script can do other tasks in Phase 0 such as:
    * Copying desired login files for the pi user and/or an additional user into the IMG
* **sdm-phase1 -** Changes the password for the pi user. Optionally, creates your personal account and sets its password. If requested, enables the system as an apt-cacher-ng client. See below for details on apt-cacher-ng.
* **sdm-base-installs -** Installs your favorite applications. Edit as desired
* **sdm-X-installs -** Installs a minimal X windows system.
* **sdm-firstboot -** Service run on first system boot to set the hostname and WiFi country. It's also used during Phase 1 to set the locale, keymap, and timezone for your system.
* **sdm-1piboot/* -** Configuration file and sample scripts. You'll need to edit the configuration file (1piboot.conf) to set the locale, keymap, timezone, and WiFi country. Do not change the hostname from 'xxxxx'. sdm will change it automatically when you burn the SD card.
* **sdm-apt-cacher -** Configures and installs apt-cacher-ng. This is optional, but highly recommended. See section on apt-cacher-ng below for details.
## sdm commands

`sdm` commands consist of:

* `sdm raspbian-image.img` - Perform Phase 0 configuration, and drops you in a shell inside the image for Phase 1 customization. Switches include:
    * --cscript *scriptname* - Full file path of your Custom Phase script. See the example for details.
    * --xmb nnnn - Extend the IMG file by nnnn MB (default is 2048MB/2GB). May be necessary depending on the number of packages you choose to install in Phase 1. If the image isn't large enough, installations will fail. If the image is too large, it will consume a larger amount of disk space, and burning the image will take longer.
    * --noextend - Do not extend the IMG file. 
    * --src /path/to/src - Source tree root that is passed into the Phase 0 script (sdm-phase0.sh or equivalent)
    * --user username - If provided, the specified user will be created.
* `sdm --burn /dev/sdX --host hostname raspbian-image.img` - Burns the IMG file onto the specified SD card and sets the hostname on the card. (Phase 2)
* `sdm --extend [--xmb nnn] raspbian-image.img` - Extends the image by the specified size and exits. Use --noextend to prevent sdm from extending it again.
* `sdm --explore raspian-image.img` - Uses systemd-nspawn to "go into" the IMG file to explore and/or make manual changes to the image.
* `sdm --mount raspbian-image.img` - Mounts the IMG file onto the running system. This enables you to manually and easily copy files from the running Raspbian system into the IMG. BE CAREFUL, as you're running as root with access to everything.

Additional sdm command switches include:

* `--aptcache IPaddr` - Use APT caching. The argument is the IP address of the apt-cacher-ng server
* `--aptconfirm` - Prompt for confirmation before APT installs and updates are done in sdm.
* `--csrc srcdir` - A source directory string that can be used in your Custom Phase script
* `--eeprom value` - Change the eeprom value in /etc/default/rpi-eeprom-update. The Raspbian default is 'critical', which is fine for most users. Change only if you know what you're doing.
* `--hdmigroup num` - hdmigroup setting in config.txt
* `--hdmimode num` - hdmimode setting in confirm.txt
* `--rootpwd` - Also set the root password in Phase 1
* `--uid uid` - Use the specified uid rather than the next assignable uid for the new user, if created.
* `--custom[1-4]` - 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize scripts that sdm uses. See sdm-X-installs for an example

## sdm-firstboot

sdm-firstboot is a service created in the IMG that runs when the system boots the first time. It sets the host name, enables WiFi, and executes any custom scripts in /boot/sdm-1piboot/0*-*.sh See the examples on this github.

## Custom Phase script

A Custom Phase script is provided by you. It is called in both Phase 0 and Phase 1, with the first argument indicating the current phase. The Custom Phase script needs to be aware of the phase, as there are contextual differences:

* In Phase 0, the host file system is fully available. The IMG file is mounted on /mnt/sdm, so all references to the IMG file system must be appropriately referenced. This enables the Custom Phase script to copy files from the host file system into the IMG file.

* In Phase 1 (inside nspawn) the host file system is not available at all. Thus, if a file is needed in Phase 1 to do something, Phase 0 must copy it into the IMG.

See the example Custom Phase script `sdm-customphase`.

## apt-cacher-ng

apt-cacher-ng is a great package in Raspbian, and nearly essential if you have more than a couple of Pi systems. The savings in download MB and wait time can be quite impressive.

apt-cacher-ng requires a system to be running the apt-cacher server. Once you have configured the server system, copy sdm-apt-cacher to the server and execute the command `sudo sdm-apt-cacher server`. This will install apt-cacher-ng on the server and configure it for use.

Once you have the apt-cacher server configured you can use the `--aptcache IPaddr` sdm switch to configure the IMG system to use the APT cacher.

If you have other Pis that you want to convert to using your apt-cacher server, copy sdm-apt-cacher to each one and execute the command 'sudo sdm-apt-cacher client`.

## Cleaning up dangling mounts

## Loop device notes

\\ Don't forget to document --src root format. Also include some tips/tricks
