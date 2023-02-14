# Example: Commands

* `sudo sdm --customize --poptions apps --apps @myapps --hdmigroup 2 --hdmimode 82 2020-08-20-raspios-buster-armhf-full.img`

    Installs the apps from the list in the file myapps (one line per app) into the image and sets the HDMI settings in /boot/config.txt needed for my monitor.

* `sudo sdm --burn /dev/sdc --host sky 2020-08-20-raspios-buster-armhf-full.img`

    sdm burns the image to the SD Card in /dev/sdc and sets the hostname to 'sky'.

    **NOTE:** While sdm does check that the device is a block device and is not mounted, it is still a good idea to double check that you're writing to the device you think you are before pressing ENTER.

* `sudo sdm --explore 2020-08-20-raspios-buster-armhf-full.img`

    sdm enters the nspawn container for the IMG so you can work on it. For example, you might want to do an *apt update* and *apt upgrade*, install additional packages, or make other configuration or customization changes, before you burn a new SD Card.


* This is a more complex example with explanations of the switches:

```
sdm $1 \
     --customize \                                            # Customize command
     --logwidth 132 \                                         # Break long log lines at 132 characters
     --l10n \                                                 # Get Localization settings from system sdm is on
     --plugin vnc:"realvnc=default|tigervnc=2540x1350,1880x1100" \ # Enable RealVNC on the console and virtual desktops with the given geometries
     --wpa /rpi/etc/wpa_supplicant/wpa_supplicant.conf \      # Copy my wpa_supplicant into the image
     --ssh service \                                          # Enable sshd service (This is the default if --ssh not specified)
     --systemd-config timesyncd:/rpi/systemd/timesyncd.conf \ # Load a local timesyncd.conf that sets the IP address of the LAN's timeserver
     --disable piwiz,swap,triggerhappy \                      # Disable these things because I don't need them (everything piwiz does sdm will have done)
     --svcdisable apt-daily.timer,apt-daily-upgrade.timer \   # Disable some services
     --eeprom stable \                                        # Use eeprom = stable
     --poptions apps,xapps \                                  # Install both apps and xapps
     --apps @myapps \                                         # @myapps has a list, one package per line
     --xapps @myxapps \                                       # @myxapps    " " "
     --apt-dist-upgrade \                                     # May be needed on Bullseye systems
     --aptcache 192.168.42.4 \                                # Use this for an apt caching server
     --dtparam sd_poll_once \                                 #
     --hdmi-force-hotplug \                                   #
     --hdmi-ignore-edid \                                     #
     --hdmigroup 2 \                                          #
     --hdmimode 82 \                                          # These settings work for my 1920x1080 monitor
     --reboot 20 \                                            # ...
     --cscript bls-sdm-customize \                            # Here's my Custom Phase Script that does configuration beyond what sdm does
     --user bls \                                             # Add a user with the username 'bls'
     --uid 3300 \                                             # Make the uid for 'bls' 3300. This will be the same on every pi to make NFS easier
     --password-pi mysecretpassword \                         # Set the password for user 'pi'
     --password-user anotherpassword \                        # Set the password for user 'bls'
     --dhcpcdwait \                                           # Cause dhcpcd to wait until the network is up
     --fstab /rpi/etc/fstab.lan \                             # Add my local network shares to the end of /etc/fstab
     --mouse left                                             # I'm a leftie, so make the mouse left-handed in LXDE

```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
