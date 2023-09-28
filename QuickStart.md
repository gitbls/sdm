# sdm Quick Start

## Customize a RasPiOS IMG file and burn it to an SSD or SD Card in three commands.

It's assumed that there is a freshly downloaded copy of a RasPiOS IMG file (e.g., 2023-05-03-raspios-bullseye-armhf.img or 2023-05-03-raspios-bullseye-armhf-lite.img) in the current directory, and that there is an SD Card in /dev/sde.

### Install sdm and required system software

`curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash`

This command will:
* Download sdm from GitHub to /usr/local/sdm
* Create a link for /usr/local/sdm/sdm in /usr/local/bin/sdm for ease of use
* Install required system software using apt: systemd-container qemu-user-static binfmt-support file parted

### Customize the image

`sudo sdm --customize 2023-05-03-raspios-bullseye-armhf.img --plugin user:"adduser=myuser|prompt" --plugin disables:piwiz --plugin L10n:host --plugin network:"wpa=/path/to/wpa_supplicant.conf" --restart`

sdm will make the following customizations to your IMG file:
* Copy your Localization settings (Keymap, Locale, Timezone, and WiFi Country) from the system on which it's running
* Copy the wpa_supplicant.conf you specified into the IMG file at /etc/wpa_supplicant/wpa_supplicant.conf
* Configure the system in the IMG file to have SSH enabled
* Prompt for a new password for user `myuser` (the user 'pi' will remain on the system without a password)
* Perform an `apt update` and `apt upgrade`

After your first run with sdm it's best practice to look at the console output in detail. One common error is running out of disk space in the IMG file. sdm will flag that in the console output. You can extend it one time by using `sudo sdm --extend 2023-05-03-raspios-bullseye-armhf.img --xmb 2048`  and then redoing the customization command.

### Burn the image onto the SSD/SD Card

`sudo sdm --burn /dev/sde --hostname mypi1 --expand-root --regen-ssh-host-keys 2023-05-03-raspios-bullseye-armhf.img`

*OR* you can use your favorite SD burning tool such as Raspberry Pi Imager or Win32DiskImager. If you use a tool besides sdm you'll need to set the hostname with raspi-config after the system has booted.

### Boot the newly-created SSD/SD Card

Load the SD card into a Pi and power it up. The system will come up (almost) as it always does:
* RasPiOS will NOT:
  * Resize the root file system and immediately reboot because that's already been done by sdm
  * Ask for keyboard configuration because that's already been done
  * Ask for anything about users, because that's already benn done 
* Toward the end of the first boot process an sdm systemd service (sdm-firstboot) runs once and takes care of several config settings that must be done on the running system
* When the system first boot is fully complete the system automatically restarts again because of the `--restart` command switch

Then, when the system comes back up your Pi is all happy, ready to go, and configured with:
* The latest RasPiOS updates installed for installed packages
* User `myuser` is configured and ready for you to login
* Hostname set to mypi1, or whatever you choose for the hostname
* Keymap, Locale, and Timezone configured the same as the system on which you are running sdm. No need to spend time remembering how to do this in raspi-config!
* Wifi configured and operational
* SSH enabled

If you want to build a disk for another Pi, you only need redo the `sdm --burn` command, specifying the new host. 

### See sdm in action!

Watch a short video discussing sdm with video segments showing it in action [here](https://youtu.be/CpntmXK2wpA)
