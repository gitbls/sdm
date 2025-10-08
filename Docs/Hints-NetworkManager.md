# Overview

Although NetworkManager (nm) has been around for a while, not many people have used it on RasPiOS because dhcpcd was the default prior to Bookworm.

RasPiOS Bookworm now uses nm by default.

This page discusses nm sdm-fu and overall more depth on the `network` plugin.

## What happens by default and how do I control?

On Bullseye and earlier systems, the `network` plugin by default uses dhcpcd for `netman`, as it is on an uncustomized RasPiOS. The `network` plugin accepts a file via the `dhcpcdappend` argument that is appended to /etc/dhcpcd.conf. The `wpa` argument file will be copied to /etc/wpa_supplicant/wpa_supplicant.conf. Alternatively, if the arguments `wifissid`, `wifipassword`, and `wificountry` are all set, wpa_supplicant.conf will be written with this configuration.

On Bookworm and later, nm is used by default for network management. You can also select nm on Bullseye with the `netman=nm` argument to the `network` plugin. Likewise, if you want to use dhcpcd on Bookworm, use `netman=dhcpcd`.

When configuring nm, a WiFi connection can be configured with the arguments `wifissid`, `wifipassword`, and `wificountry`. If all 3 are provided to the network plugin an nm connection file will be created using the `wifissid` as the connection name. If these arguments are not provided, the plugin will get the values from a provided `wpa` argument file. If neither of these are provided, no WiFi connection will be configured unless one is provided with an `nmconn` argument.

In addition to several <a href="Plugins.md#network">arguments</a> there are two nm-specific arguments: `nmconf`, and `nmconn`. Using these provides you with the best nm control in sdm.

## Generating `nmconf` and `nmconn` files

As with other plugins, the best sdm-fu results from building static configuration files, and copying them into the IMG. With this approach the system can be fully configured from the first system boot.

`nmconf` files are nm configuration files. The `nmconf` argument can provide a comma-separated list of files on the host system. nm expects these files to be named something.conf

Similarly, `nmconn` files are nm connection keyfiles. These are also text-based. Network manager expects these to be named something.nmconnection. Each WiFi network requires a .nmconnection file.

One way to generate a .nmconnection is to use nmcli. This technique requires use of the nmcli `--offline` switch, which is supported only in Bookworm and later. This example on Bookworm is one long command line. See <a href="#wifi-autoconnect">a note about WiFi autoconnect here.</a>
```sh
nmcli --offline c add type wifi con-name your-name ifname wlan0 ssid your-ssid | \
nmcli --offline c modify wifi-sec.key-mgmt wpa-psk wifi-sec.psk your-password autoconnect false > your-connfile.nmconnection
```
The above command would create your-connfile.nmconnection:
```
[connection]
id=your-name
uuid=d45eba01-916c-4b77-8f0e-01071f955727
type=wifi
autoconnect=false
interface-name=wlan0

[wifi]
mode=infrastructure
ssid=your-ssid

[wifi-security]
key-mgmt=wpa-psk
psk=your-password

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
```

In order to generate a .nmconnection file using Bullseye or earlier, you must use nm running on a booted system. Once that system is configured with nm and available you can:

    nmcli c add type wifi con-name your-name ifname wlan0 ssid your-ssid
    nmcli c modify your-name wifi-sec.key-mgmt wpa-psk wifi-sec.psk your-password

### Other useful nmcli commands

Disable IPV6 on a WiFi connection

    nmcli c modify your-name ipv6.method disabled

Disable IPV6 on the default eth0 connection

    nmcli c modify Wired\ connection\ 1 ipv6.method disabled

## One last note on NetworkManager

Although nm uses wpa_supplicant, it does not specifically use the wpa_supplicant.conf file except as described above (by the `network` plugin).

Instead, nm communicates WiFi configuration information to wpa_supplicant over dbus. This enables a key feature of nm, the ability to easily switch WiFi connections.

## WiFi Autoconnect

By default, a new WiFi connection is created with `autoconnect true`. Perfect if you only have one WiFi connection. But, when you add a second one, which one is the one to connect by default?

For secondary, non-autoconnect connections, specify `autconnect false` so that they are actually not autoconnected.

## NetworkManager information and documentation

* `man nm-settings-keyfile` &mdash; Connection keyfile
* `man nm-settings` &mdash; More Connection settings (Advanced)
* `man NetworkManager.conf` &mdash; Overview of Network Manager configuration (Advanced)
*  <a href="https://networkmanager.dev/docs/api/latest/"> Complete NetworkManager documentation</a>
