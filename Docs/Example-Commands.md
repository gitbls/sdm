# Example: Commands

* `sudo sdm --customize --plugin apps:"apps=@/path/to/myapps" 2024-03-15-raspios-bookworm-arm64.img`

    Installs the apps from the list in the file myapps (one app per line) into the image.

* `sudo sdm --burn /dev/sdc --host sky --expand-root --regen-ssh-host-keys 2024-03-15-raspios-bookworm-arm64.img`

    sdm burns the image to the SD Card in /dev/sdc and sets the hostname to 'sky'. `--expand-root` expands the rootfs to fill the remainder of the disk, and `--regen-ssh-host-keys` has sdm's First Boot take care of these, and disables the RasPiOS firstboot service that then not needed.

    **NOTE:** While sdm does check that the device is a block device and is not mounted, it is still a good idea to double check that you're writing to the device you think you are before pressing ENTER.

* `sudo sdm --burn /dev/sdc --host sky --plugin cryptroot:"authkeys=/home/bls/.ssh/authorized_keys|crypto=aes|ssh" 2024-03-15-raspios-bookworm-arm64.img --expand-root --regen-ssh-host-keys`

    As above, burn the IMG to the disk. After the burn completes, run the `cryptroot` plugin to prepare to encrypt the rootfs. See <a href="Docs/Disk-Encryption.md">Disk Encryption</a> for complete details on this plugin. Running `cryptroot` at burn time facilitates easily building Pi systems with or without rootfs encryption.

* `sudo sdm --explore 2024-03-15-raspios-bookworm-arm64.img`

    sdm enters the nspawn container for the IMG so you can work on it. For example, you might want to do an *apt update* and *apt upgrade*, install additional packages, or make other configuration or customization changes, before you burn a new SD Card. Use the `exit` command to leave the container.

* `sudo sdm --runonly plugins --plugin piapps 2024-03-15-raspios-bookworm-arm64.img`

    Run the plugin `piapps` in the specified IMG. This runs all 3 phases of the plugin, so it's exactly like running the plugin during an install.

# Official Getting Started with sdm script

This script is a great way to get started sdm. It makes use of a list of plugins which is easier to manage for some.

This example can be copied and used, or of course create your own 'list of plugins' file and sdm command script. This file is also available here: <a href="../ezsdm">ezsdm</a>

```sh
#!/bin/bash
#
# Simple script to use sdm with plugins
# Edit the text inside the EOF/EOF as appropriate for your configuration
# ** Suggestion: Copy this file to somewhere in your path and edit your copy
#    (~/bin is a good location)


function errexit() {
    echo -e "$1"
    exit 1
}

[ $EUID -eq 0 ] && sudo="" || sudo="sudo"

img="$1"
[ "$img" == "" ] && errexit "? No IMG specified"

[ "$(type -t sdm)" == "" ] && errexit "? sdm is not installed"

#[ "$sudo" != "" ] && assets="." || assets="/etc/sdm/local-assets"
assets="."
rm -f $assets/my.plugins.1
[ -f $assets/my.plugins ] &&  mv $assets/my.plugins $assets/my.plugins.1

(cat <<EOF
# Plugin List generated $(date +"%Y-%m-%d %H:%M:%S")
EOF
    ) | bash -c "cat >|$assets/my.plugins"

(cat <<'EOF'

# Delete user pi if it exists
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#user
user:deluser=pi

# Add a new user ** change 'myuser' and 'mypassword' **
user:adduser=myuser|password=mypassword

# Install btwifiset (Control Pi's WiFi from your phone)
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#btwifiset
btwifiset:country=US|timeout=30

# Install apps
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#apps
apps:name=mybrowsers|apps=firefox,chromium-browser
apps:name=mytools|apps=keychain,lsof,iperf3,dnsutils

# Configure network ** change 'myssid' and 'mywifipassword' **
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#network
network:ifname=wlan0|wifissid=myssid|wifipassword=mywifipassword|wificountry=US

# This configuration eliminates the need for piwiz so disable it
disables:piwiz

# Uncomment to enable trim on all disks
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#trim-enable
#trim-enable

# Configure localization settings to the same as this system
# https://github.com/gitbls/sdm/blob/master/Docs/Plugins.md#l10n
L10n:host
EOF
    ) | bash -c "cat >>$assets/my.plugins"

$sudo sdm --customize --plugin @$assets/my.plugins --extend --xmb 2048 --restart --regen-ssh-host-keys $img
```

# Specifying plugins on the command line

Here is another example that can be copied and used. It uses the `--plugin` switch on the command line, as opposed to the previous example of using a list of plugins file.

Any/all these plugin invocations can be used in the above script if desired, without the `--plugin`. An annotated version follows with some explanations. 

```sh

#!/bin/bash

sudo sdm \
     --customize $1 \
     --poptions noupdate,noupgrade,noautoremove \
     --logwidth 132 \
     --extend --xmb 2048 \
     --plugin user:"deluser=pi" \
     --plugin user:"adduser=bls|password=mypassword|uid=3300" \
# Use one of the next two. netman=nm not needed on Bookworm or later
#     --plugin network:"netman=nm|wifcountry=US|nmconn=/ssd/work/mywifi.nmconnection" \
#     --plugin network:"netman=nm|ifname=wlan0|wificountry=US|wifissid=mySSID|wifipassword=myWifiPassword" \
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

Annotated version of above script
```sh

sudo sdm \
     --customize $1 \                                                               # Pass the IMG filename as the parameter
     --logwidth 132 \                                                               # Break long log lines at 132 characters
     --extend --xmb 2048 \                                                          # Extend the IMG by 2GB
     --plugin user:"deluser=pi" \                                                   # Delete user pi
     --plugin user:"adduser=bls|password=mypassword|uid=3300" \                     # Create a new user with a password using a specific UID
#     --plugin network:"netman=nm|wificountry=US|nmconn=/ssd/work/mywifi.nmconnection" \ # Use Network Manager and set up a connection
#     --plugin network:"netman=nm|ifname=wlan0|wificountry=US|wifissid=mySSID|wifipassword=myWifiPassword" \ # Set WiFi country, wifi SSID, and password for wlan0
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
