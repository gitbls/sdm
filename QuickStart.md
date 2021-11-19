# sdm Quick Start

## Customize a RasPiOS IMG file and burn it to an SD Card in three commands.

It's assumed that there is a freshly downloaded copy of a RasPiOS IMG file (e.g., 2021-05-07-raspios-buster-armhf-full.img or 2021-05-07-raspios-buster-armhf-lite.img) in the current directory, and that there is an SD Card in /dev/sde.

### Install sdm and systemd-container
`sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash`

### Customize the image
`sudo /usr/local/sdm/sdm --customize 2021-05-07-raspios-buster-armhf-full.img --wpa /path/to/working/wpa_supplicant.conf --L10n --restart `

sdm will make the following changes to your IMG file:
* Copy your Localization settings (Keymap, Locale, Timezone, and WiFi Country) from the system on which it's running
* Copy the wpa_supplicant.conf you specified into the IMG file at /etc/wpa_supplicant/wpa_supplicant.conf
* Configure the system in the IMG file to have SSH enabled
* Prompt for a new password for user pi
* Do an  `apt update` and `apt upgrade`

After the first run it's best practice to look at the console output in detail. One common error is running out of disk space in the IMG file. You can extend it one time by using `sudo /usr/local/sdm/sdm --extend thefile.img`  and then redoing the customization command.

### Burn the image onto the SD Card
`sudo /usr/local/sdm/sdm --burn /dev/sde --hostname mypi1 2021-05-07-raspios-buster-armhf-full.img`

OR use your favorite SD burning tool such as Raspberry PI Imager or Win32DiskImager. If you use a tool besides sdm you'll need to set the hostname with raspi-config after the system has booted.

### Boot the newly-created SD Card
Load the SD card into a Pi and power it up. The system will come up as it always does:
* Resize the root file system and restarts automatically 
* After the system restarts it goes through a complete system startup, just as it always does on a fresh SD Card
* Toward the end of the boot process an sdm systemd service (sdm-firstboot) runs once and sets the WiFi country, unblocking WiFi
* When the system boot is fully complete the system automatically restarts again because of the --restart command switch

When the system comes back up your Pi is all happy, ready to go, and configured with:
* The latest RasPiOS updates installed for installed packages
* Password set for user pi
* Hostname set to mypi1, or whatever you choose for the hostname
* Keymap, Locale, and Timezone configured the same as the system on which you are running sdm. No need to spend time remembering how to do this in raspi-config!
* Wifi configured and operational
* SSH enabled

If you want to build an SD Card for another Pi, you only need redo the `sdm --burn` command, specifying the new host. 

### See sdm in action!

Watch a short video discussing sdm with video segments showing it in action [here](https://youtu.be/CpntmXK2wpA)
