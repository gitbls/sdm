# Hotspot

The --hotspot switch is used to install a hotspot into the image

Hotspot configuration is done with the `--hotspot` switch.

* `--hotspot` *config-file* &mdash; Install and Configure a hotspot (Access Point). This is done in accordance with the guides on the Raspberry Pi website:
    * <a href="https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-routed-wireless-access-point">Routed Access Point Configuration</a>
    * <a href="https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-bridged-wireless-access-point">Bridged Access Point Configuration</a>
    
    When `--hotspot` is used, the hotspot is installed and configured at the end of Phase 1. The system is set to automatically restart at the completion of FirstBoot to help ensure that the hotspot is correctly configured. **Check the logs!**

    The hotspot configuration is specified in *config-file*, which contains a set of directives, one per line. The settings shown here are the defaults:

```
# Type of hotspot
#  local: Clients can only access the hotspot IP itself
#  routed: Clients can access the hotspot IP; non-local traffic is routed to the Pi's eth0 network
#  bridged: The Client network is bridged onto the Pi's eth0 network
config="local"
# Channel to use
channel="36"
# WiFi mode: "g" for 2.4Ghz, "a" for 5Ghz
# See https://en.wikipedia.org/wiki/List_of_WLAN_channels for legal channels/modes per country
hwmode="a"
# Country: defaults to --wifi-country setting but can be changed here
country="us"
# Network device to use. Default is "wlan0"
dev="wlan0"
# IP address for the hotspot WiFi network device
wlanip="192.168.4.1"
# Range of IP addresses and netmask to use for DHCP server on the hotspot network
dhcprange="192.168.4.2,192.168.4.32,255.255.255.0"
# Lease time for IP addresses leased on the hotspot network
leasetime="24h"
# SSID for the hotspot network
ssid="MyPiNet"
# Passphrase for the hotspot network
passphrase="password"
# Domain name for the hotspot network
domain="wlan.net"
# If enable=true, the hotspot will be enabled at system boot
enable="true"
# If non-null, specifies a file that is concatenated onto /etc/hostapd/hostapd.conf
include=""
```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
