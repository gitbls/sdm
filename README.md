# sdm
Raspberry Pi SD Card Image Manager

## Description

`sdm` is a command-line management tool to simplify and expedite building consistent, ready-to-go SD cards for the Raspberry Pi. This is especially useful if you:

* have multiple Raspberry Pi systems and you want them all to start from a consistent set of installed software packages, configuration scripts and settings, etc.

* want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed.

* want to do any or all of the above a LOT more quickly.

What does 'ready-to-go' mean? It means that your system has all your personal customizations installed and all Raspbian packages and updates installed at first system boot.

With sdm you'll spend a lot less time rebuilding SD cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

As a bonus, sdm includes a configuration script for apt-cacher-ng. apt-cacher-ng enables you to update all your Pis quickly by caching local packages. This reduces install and update time, and can greatly reduce network consumption.

sdm only runs on Raspbian, and requires a USB SD Card reader for writing a new SD Card. And, no, you cannot use sdm to rewrite the running system's SD Card.

## Installing sdm

Installation is fairly simple. sdm uses the path /usr/local/sdm within images that it manages, so for consistency you should do the same on your system. **The simplest download is to use EZsdmInstaller**, which performs the commands listed below:

    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

**or download the Installer script to examine it before running:**

    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller -o ./EZsdmInstaller
    ./EZsdmInstaller

**Or, download it the really long way:**

    sudo mkdir -p /usr/local/sdm /usr/local/sdm/sdm-1piboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm -o /usr/local/sdm/sdm
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase0 -o /usr/local/sdm/sdm-phase0
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase1 -o /usr/local/sdm/sdm-phase1
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-cparse -o /usr/local/sdm/sdm-cparse
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-logit -o /usr/local/sdm/sdm-logit
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-firstboot -o /usr/local/sdm/sdm-firstboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-apt-cacher -o /usr/local/sdm/sdm-apt-cacher
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-customphase -o /usr/local/sdm/sdm-customphase
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-base-installs -o /usr/local/sdm/sdm-base-installs
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-X-installs -o /usr/local/sdm/sdm-X-installs
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/1piboot.conf -o /usr/local/sdm/sdm-1piboot/1piboot.conf
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/010-disable-triggerhappy.sh -o /usr/local/sdm/sdm-1piboot/010-disable-triggerhappy.sh
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/020-ssh-switch.sh -o /usr/local/sdm/sdm-1piboot/020-ssh-switch.sh
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/030-disable-rsyslog.sh -o /usr/local/sdm/sdm-1piboot/030-disable-rsyslog.sh
    sudo chmod -R 755 /usr/local/sdm/*

## Details

sdm manages the SD Card image in Phases:

* **Phase 0:** *Operating in the context of your physical Raspbian system, copying files into the Raspbian IMG file.* sdm takes care of Phase 0 for you. The Phase 0 script `sdm-phase0` performs the Phase 0 copying. It will also optionally call a Custom Phase script provided by you to perform customized personal steps. See *Custom Phase script *below for details.

* **Phase 1:** *Operating inside the IMG file and in the context of that system (via nspawn)*. When operating in this context, all changes made only affect the SD Card IMG, not the physical Raspbian system on which sdm is running

    Most, but not all commands can be used in Phase 1. For instance, `systemctl` doesn't work because systemd is not running in the nspawn'ed image. But, new users can be added, passwords can be changed, packages can be installed, etc. In other words, you can do almost everything you want to configure a system for repeated SD card burns.

    Once sdm has started the nspawn container, it will automatically run /usr/local/sdm/sdm-phase1 to perform Phase 1 customization. As with Phase 0, your personal customization script will be called. After Phase 1 has completed, sdm will provide a command prompt inside the container unless you specified `--batch`, in which case sdm will exit the container.

* **Phase 2:** *Writing the SD Card*. The IMG is written to the new physical SD card using ***dd***, and the new system name is written to the SD card. This enables a single IMG file to be the source for as many Pi systems as you'd like.

* **Phase 3:** *Booting the newly-created SD card on a Pi*. When the new system boots the first time, the systemd service sdm-firstboot sets the system name and WiFi country and disables itself so that it doesn't run on subsequent system boots.

## Usage Examples

* `sudo /usr/local/sdm/sdm --poptions firstboot 2020-02-13-raspbian-buster-lite.img`

    Performs basic customization. Only sets up the sdm-firstboot service. No additional applications are installed.

* `sudo /usr/local/sdm/sdm --poptions firstboot:base --user bls --uid 1600 --hdmigroup 2 --hdmimode 82 --cscript /path/to/my-phase-script --csrc /rpi 2020-02-13-raspbian-buster-lite.img`

    *or* `sudo /usr/local/sdm/sdm --poptions firstboot:base --user bls --uid 1600 --bootconfig hdmigroup:2,hdmimode:82 --cscript /path/to/my-phase-script --csrc /rpi 2020-02-13-raspbian-buster-lite.img`

    Installs the sdm-firstboot service, and whatever base applications you have set up in sdm-base-installs. The Custom Phase script is called where your own customizations can be done. The user *bls* is created with a UID of 1600. The config.txt settings for hdmigroup and hdmimode are set in both examples.

* `sudo /usr/local/sdm/sdm --burn /dev/sdc --host sky 2020-02-13-raspbian-buster-lite.img`

    sdm burns the image to the SD Card in /dev/sdc.

    **NOTE:** while sdm does check that the device is not mounted, it is still a good idea to double check before pressing ENTER. 

* `sudo /usr/local/sdm/sdm --explore 2020-02-13-raspbian-buster-lite.img`

    sdm enters nspawn on the image for you to work on. You might want to do an apt update and apt upgrade, for instance, before you burn an SD Card for a new Pi.

## What's here

sdm consists of a primary script `sdm` and several supporting scripts:

* **sdm-phase0 -** Script run by sdm before nspawn-ing into the IMG file. sdm-phase0 has access to the running Pi system as well as the file system within the IMG file. You can customize what's done in Phase 0 by using a Custom Phase script (see below). sdm-phase0 performs several steps:

    * Sets up ssh in the IMG boot partition. wpa_supplicant needs to be set in a Custom Phase script since it's original source can be anywhere.

    * If --user is specified, creates the user's home directory so that your Custom Phase script can copy files into it during Phase 0. The user is also enabled to use `sudo` like the user *pi*.

    * Installs and configures the sdm-firstboot service

    * Miscellaneous requested configuration changes: Setting hdmigroup and hdmimode, and eeprom directory.

    * Calls the Custom Phase script for Phase 0

* **sdm-phase1 -** Asks for and changes the password for the *pi* user. Optionally, if you used the sdm --user switch, creates your personal account, sets its password, protections, etc. If `--aptcache` was specified, the system is enabled as an apt-cacher-ng client. See below for details on apt-cacher-ng.

* **sdm-base-installs -** Installs your favorite applications. Edit as desired.

* **sdm-X-installs -** Installs a minimal X windows system onto Raspbian Lite. This is more of an example than anything, since there are a multitude of ways to install X11, display managers, window managers, and X11-based applications. Edit as desired.

* **sdm-firstboot -** Systemd service run on first system boot to set the hostname and WiFi country. It's also used during Phase 1 to set the locale, keymap, and timezone for your system.

* **sdm-1piboot/* -** Configuration file and sample scripts. **You'll need to edit the configuration file (1piboot.conf)** before using sdm to set the locale, keymap, timezone, and WiFi country. Do not change the hostname from 'xxxxx'. sdm will change it automatically when you burn the SD card.

* **sdm-cparse -** Helper script that loads sdm parameters for use by the scripts.

* **sdm-logit -** Helper script to write log entries into /etc/sdm/history

* **sdm-customphase -** Sample Custom Phase script. Use this as a starting point to build your own image customizations.

* **sdm-apt-cacher -** Configures and installs apt-cacher-ng. This is optional, but highly recommended. See section on apt-cacher-ng below for details.

## sdm commands

`sdm` commands consist of:

* `sdm raspbian-image.img` - Perform Phase 0 configuration, and drops you in a shell inside the image for Phase 1 customization. Switches include:
    * `--cscript *scriptname*` - Full file path of your Custom Phase script. See the example for details.
    * `--xmb *nnnn*` - Extend the IMG file by nnnn MB (default is 2048MB/2GB). You may need to increase this depending on the number of packages you choose to install in Phase 1. If the image isn't large enough, installations will fail. If the image is too large, it will consume a larger amount of disk space, and burning the image to an SD Card will take longer.
    * `--noextend` - Do not extend the IMG file. 
    * `--csrc /path/to/csrcdir` - Source tree root that is passed into the Phase 0 script (sdm-phase0.sh or equivalent). You can use this to inform your Custom Phase script. See the example.
    * `--user username` - If provided, the specified user will be created.
* `sdm --burn /dev/sdX --host hostname raspbian-image.img` - Burns the IMG file onto the specified SD card and sets the hostname on the card. (Phase 2)
* `sdm --extend [--xmb nnn] raspbian-image.img` - Extends the image by the specified size and exits. Use --noextend if you need to re-enter sdm to prevent further extensions.
* `sdm --explore raspian-image.img` - Uses systemd-nspawn to "go into" the IMG file to explore and/or make manual changes to the image. --explore disables extending the image
* `sdm --mount raspbian-image.img` - Mounts the IMG file onto the running system. This enables you to manually and easily copy files from the running Raspbian system into the IMG. BE CAREFUL, as you're running as root with access to everything.

Additional sdm command switches include:

* `--aptcache IPaddr` - Use APT caching. The argument is the IP address of the apt-cacher-ng server
* `--aptconfirm` - Prompt for confirmation before APT installs and updates are done in sdm Phase 1.
* `--batch` - Do not provide an interactive command prompt inside the nspawn container.
* `--bootconfig key:value,key:value,...` - Update existing, commented keys in /boot/config.txt
* `--bootadd key:value,key:value,...` - Add new keys/values to /boot/config.txt
* `--csrc /path/to/csrcdir` - A source directory string that can be used in your Custom Phase script. One use for this is to have a directory tree where all your customizations are kept, and pass in the directory tree to sdm with `--csrc`.
* `--custom[1-4]` - 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize scripts that sdm uses. See sdm-X-installs for an example
* `--ddsw "switches" - Provide switches for the --burn `dd` command. Default is "bs=16M"
* `--eeprom value` - Change the eeprom value in /etc/default/rpi-eeprom-update. The Raspbian default is 'critical', which is fine for most users. Change only if you know what you're doing.
* `--hdmigroup num` - hdmigroup setting in config.txt
* `--hdmimode num` - hdmimode setting in config.txt
* `--nspawnsw "switches" - Provide additional switches for the systemd-nspawn command
* `--poptions value` - Controls which scripts will be called by sdm-phase1. Possible options include: firstboot, base, and xwindows. Enter multiple values as a single string separated by a colon or comma. For example `--poptions firstboot:base` or `--poptions firstboot,base,xwindows`
* `--uid uid` - Use the specified uid rather than the next assignable uid for the new user, if created.

## sdm-firstboot

sdm-firstboot is a service created in the IMG that runs when the system boots the first time. sdm-firstboot sets the host name, enables WiFi, and executes any custom scripts in /boot/sdm-1piboot/0*-*.sh See the examples on this github.

## Custom Phase script

A Custom Phase script is provided by you. It is called in both Phase 0 and Phase 1, with the first argument indicating the current phase ("0" or "1"). The Custom Phase script needs to be aware of the phase, as there are contextual differences:

* In Phase 0, the host file system is fully available. The IMG file is mounted on /mnt/sdm, so all references to the IMG file system must be appropriately referenced by prefacing the directory string with /mnt/sdm. This enables the Custom Phase script to copy files from the host file system into the IMG file.

* In Phase 1 (inside nspawn) the host file system is not available at all. Thus, if a file is needed in Phase 1 to do something, Phase 0 must copy it into the IMG. References to /mnt/sdm will fail in Phase 1.

See the example Custom Phase script `sdm-customphase`.

## apt-cacher-ng

apt-cacher-ng is a great Raspbian package, and nearly essential if you have more than a couple of Pi systems. The savings in download MB and installation wait time can be quite impressive.

apt-cacher-ng requires a system running the apt-cacher server. Typically you'll run this on a "production", always available Pi.

Once you have configured the server system, copy sdm-apt-cacher to the server and execute the command `sudo sdm-apt-cacher server`. This will install apt-cacher-ng on the server and configure it for use. If the server firewall blocks port 3142 you'll need to add a rule to allow it.

Once you have the apt-cacher server configured you can use the `--aptcache IPaddr` sdm switch to configure the IMG system to use the APT cacher.

If you have other Pis that you want to convert to using your apt-cacher server, copy sdm-apt-cacher to each one and execute the command 'sudo sdm-apt-cacher client`.

## Bread crumbs

sdm leaves a couple of files in /etc/sdm that are used to control its operation and log status.

* *history *has log entries written by Phase 0 and Phase 1 scripts

* *cparams* are the parameters with which sdm was initially run on the image

* *custom.ized* tells sdm that the image has been customized. If this exists, sdm will not rerun Phase 0. If you really want to rerun Phase 0 on an already-customized image, use sdm --explore to nspawn into the image and `rm -f /etc/sdm/custom.ized`.

## Cleaning up dangling mounts

If something is not working right, make sure that there are no dangling mounts in the running Raspbian system. You can end up with a dangling mount if sdm terminates abnormally, either with an error (please report!) or via an operator-induced termination. If sdm is not running, you should see no "/mnt/sdm" mounts (identified with `sudo df'). 

You can unmount them by manually using `sudo umount -v /mnt/sdm/{boot,}`. This will umount /mnt/sdm/boot and then /mnt/sdm. You'll also need to ensure that the loop device was deleted.

## Cleaning up loop devices

* `losetup -a` will list all loop devices

* `losetup -d /dev/loopX` will delete the loop device /dev/loopX (e.g., /dev/loop0). You may need to do this to finish cleaning up from dangling mounts (which you'll do first, before deleting the loop device).

