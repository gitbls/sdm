# sdm
Raspberry Pi SD Card Image Manager

## Description

sdm is a command-line management tool to make simplify expedite building new ready-to-go SD cards for the Raspberry Pi, especially if you have multiple Raspberry Pi systems, or want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed.

By using sdm you'll spend a lot less time rebuilding SD cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

sdm only runs on Raspbian, and requires a USB SD Card reader when writing a new SD Card.

## Installing sdm

## Details

It's easiest to think about sdm as a phased set of steps for managing the SD Card image, and writing an SD card for booting. These phases are:

* **Phase 0:** *Copying files into the Raspbian IMG file.* sdm takes care of Phase 0 for you. You provide the Phase 0 script (sdm-phase0.sh by default). See below for an overview of this script.
* **Phase 1:** *Operating inside the IMG file and in the context of that system (via nspawn)*. When operating in the context of that system, all changes made affect the SD Card IMG, not the Raspbian system on which sdm is running. Most, but not all commands can be used. For instance, `systemctl` doesn't work (except for enable and disable) because systemd is not running in the nspawn'ed image. But, new users can be added, passwords can be changed, etc.
* **Phase 2:** *Writing the SD Card*. The IMG is dd'd onto the new physical SD card, and the new system name is written to the SD card afterwards. This enables a single IMG file to be the source for all of your Pi systems.
* **Phase 3:** *Booting the newly-created SD card on a Pi*. When the new system boots the first time, the systemd service rpi-firstboot sets the system name and WiFi country *(?? can this be done in nspawn??)*, and disables itself so that it doesn't run on subsequent system boots.

## What's here

sdm consists of a primary script `sdm` and several supporting scripts:

* **sdm-phase0.sh -** Skeleton script file run by sdm before nspawn-ing into the IMG file. sdm-phase0.sh has access to the running Pi system and the file system within the IMG file. You can customize this as desired. The default file performs several steps:
    * Sets up ssh and wpa_supplicant in the IMG boot partition
    * Sets up the rpi-firstboot (1piboot) service
    * Copies desired scripts into the IMG
    * Optionally desired login files for an additional user into the IMG
    * Easily extended to do other customizations you want to have in each of your systems
* **rpi0-early-config -** Changes the password for the pi user. Optionally, creates your personal account and sets its password.
* **rpi1-early-install -** Installs packages you want installed in every system.
* **rpi2-X-install -** Installs a minimal X windows system.
* **rpix-apt-cacher -** Configures and installs apt-cacher-ng. Optional, but highly recommended. See below.
* **rpi-firstboot.sh -** Service run on first boot to set the hostname and WiFi country. It's also used during Phase 1 (as 0piboot) to set the locale, keymap, and timezone for your system.
* 1piboot/* - Configuration file and sample scripts. You'll need to edit the configuration file (1piboot.conf) to set the locale, keymap, timezone, and WiFi country.

## sdm commands

## 1piboot

## apt-cacher-ng

## Cleaning up dangling mounts

## Loop device notes

