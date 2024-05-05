# Example: Commands

* `sudo sdm --customize --plugin apps:"apps=@myapps" 2020-08-20-raspios-buster-armhf-full.img`

    Installs the apps from the list in the file myapps (one line per app) into the image.

* `sudo sdm --burn /dev/sdc --host sky 2020-08-20-raspios-buster-armhf-full.img`

    sdm burns the image to the SD Card in /dev/sdc and sets the hostname to 'sky'.

    **NOTE:** While sdm does check that the device is a block device and is not mounted, it is still a good idea to double check that you're writing to the device you think you are before pressing ENTER.

* `sudo sdm --explore 2020-08-20-raspios-buster-armhf-full.img`

    sdm enters the nspawn container for the IMG so you can work on it. For example, you might want to do an *apt update* and *apt upgrade*, install additional packages, or make other configuration or customization changes, before you burn a new SD Card.

This is an example that can be copied and used. Following that is an annotated version with some explanations.

```sh

#!/bin/bash

sudo sdm \
     --customize $1 \
     --poptions noupdate,noupgrade,noautoremove \
     --logwidth 132 \
     --extend --xmb 2048 \
     --plugin user:"deluser=pi" \
     --plugin user:"adduser=bls|password=mypassword|uid=3300" \
# Use one of the next two
#     --plugin network:"ssh|netman=nm|wificountry=US|nmconn=/ssd/work/mywifi.nmconnection" \
#     --plugin network:"ssh|netman=nm|wificountry=US|wifissid=mySSID|wifipassword=myWifiPassword" \
     --plugin system:"systemd-config=timesync=/rpi/systemd/timesyncd.conf" \
     --plugin system:"service-disable=apt-daily.timer,apt-daily-upgrade.timer|eeprom:stable|fstab=/rpi/etc/fstab.lan" \
     --plugin disables:"piwiz|triggerhappy" \
     --plugin lxde:lhmouse \
     --plugin L10n:host \
     --plugin bootconfig:"hdmi_force_hotplug=1|hdmi_ignore_edid|dtparam=sd_poll_once" \
     --plugin apps:"apps=@/rpi/myapps|name=myapps" \
     --plugin apps:"apps=@/rpi/myxapps|name=myxapps" \
     --aptcache 192.168.42.4 \
     --reboot 20                                              

```

Annotated version
```sh

sudo sdm \
     --customize $1 \                                                               # Pass the IMG filename as the parameter
     --logwidth 132 \                                                               # Break long log lines at 132 characters
     --extend --xmb 2048 \                                                          # Extend the IMG by 2GB
     --plugin user:"deluser=pi" \                                                   # Delete user pi
     --plugin user:"adduser=bls|password=mypassword|uid=3300" \                     # Create a new user with a password using a specific UID
#     --plugin network:"netman=nm|wificountry=US|nmconn=/ssd/work/mywifi.nmconnection" \ # Use Network Manager and set up a connection
                                                                                         # and enable SSH, which is the default
#     --plugin network:"ssh|netman=nm|wificountry=US|wifissid=mySSID|wifipassword=myWifiPassword" \ # Set WiFi country, wifi SSID, and password (and SSH enabled)
     --plugin system:"systemd-config=timesync=/rpi/systemd/timesyncd.conf" \        # Configure systemd-timesyncd
     --plugin system:"service-disable=apt-daily.timer,apt-daily-upgrade.timer|eeprom:stable|fstab=/rpi/etc/fstab.lan" \ # Other system settings
     --plugin disables:"piwiz|triggerhappy" \                                       # Disable piwiz and triggerhappy
     --plugin lxde:lhmouse \                                                        # If done against a desktop version, enable left-handed mouse
     --plugin L10n:host \                                                           # Get localization settings from the host
     --plugin bootconfig:"hdmi_force_hotplug=1|hdmi_ignore_edid|dtparam=sd_poll_once" \ # Add some settings to bootconfig
     --plugin apps:"apps=@/rpi/myapps|name=myapps" \                                     # Install apps from a list
     --plugin apps:"apps=@/rpi/myapps1|name=myapps2" \                                   # Install more apps
     --aptcache 192.168.42.4 \
     --reboot 20                                              

```

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
