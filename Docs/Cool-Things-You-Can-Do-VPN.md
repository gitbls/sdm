# Cool and Useful Things: VPN

Configure two Pis in a site-to-site or host-to-host configuration quickly, easily, reliably, and repeatably. 

In a properly configured network, when both are booted, the site-to-site VPN will automatically start.

Optionally, add a client/server VPN capability to one end that can be used by Android, Linux, iOS, MacOS, and Windows client systems.

This example also shows how you can

* Create customized host configurations from a single IMG
* Extract host-specific files (e.g., Certs) from an IMG or burned disk in this case
* Configure a host with a static IP address

See <a href="Cool-Things-You-Can-Do-wireguard.md">Cool and Useful Things: wireguard</a> to see how sdm can simplify fully configuring a Wireguard VPN for you.

## Introduction

You can use sdm to create two systems to be Host-to-Host or Site-to-Site endpoints very easily. The two endpoints have identical RasPiOS software configurations, since they will be built from a single customized IMG. You can, of course, use different base customized IMGs, but not recommended for reasons of preserving sanity.

Host-specific configuration is done when the disks for each host are burned.

Creating the customized IMG  is conveniently excluded from this discussion. Refer to <a href="Example-Commands.md">Example Commands</a> for some example getting started with customization scripts.

Example scripts to build the VPN server(s) follow the description.

## Overview

Here's an outline of the steps that will be done. These are detailed in following sections.

* Customize the <i>base image</i> that is used by both endpoints. This is simply the standard typically-headless server install with all your customizations in it. While you can use a RasPiOS edition that has a desktop, it's generally not recommended for 24x7 systems
* Burn one VPN endpoint's disk using the already-customized IMG
  * Use the `pistrong` plugin to install and configure the Tunnel (see Examples below)
  * Optionally use the `pistrong` plugin to install and configure a client/server VPN on this endpoint
  * Use the postburn plugin `runscript` to run a script to generate certs for client/server VPN users (if using a client/server VPN as well)
  * Use the postburn plugin `runscript` to run a script that extracts the Cert Packs onto the host system for use on the other end of the Tunnel
* Burn the second endpoint's disk using the same customized disk
  * Use the `pistrong` plugin `certpack` argument to import the extracted Cert Pack and configure this host's end of the Tunnel

When the first host completes the FirstBoot process and restarts its VPN will be running and ready to accept connections.

When the second host completes the FirstBoot process and restarts the vpnmon service will start. vpnmon starts the VPN connection and keeps the VPN up and running.

These same scripts (but obviously with a different network configuration) built a real-life VPN between two geographically distant sites in Seattle and Colorado, and the VPN started as expected.

## Network configuration

My test configuration uses two interconnected routers.

In order to properly configure the site-to-site VPN detailed network information for both endpoints is required and is captured in the file `left/makeTunnel.conf`.

NOTES:
* Although the example uses IP addresses for the external network, I strongly recommend you use a DNS name to protect against IP address changes. That is, instead of using the addresses 2.2.2.2, use a DNS name (e.g., using a dynamic DNS service). This insulates your configuration from changes to your external IP address.
* Be sure to review the VPN configuration tool `pistrong` <a href="https://github.com/gitbls/pistrong/blob/master/README.md">documentation</a> as there are network configuration guidelines that you need to be aware of and follow including: DNS configuration, port forwarding, and an IP subnet numbering restriction.

```
Domain Name: mydomain.com

+--------------+    +-----------------+
| 192.168.16.2 |____| Router          |
|  left        |    | I: 192.168.16.1 |____+
+--------------+    | O: 2.2.2.2      |    |
                    +-----------------+    |
                                           |
+--------------+    +-----------------+    |
| 192.168.32.2 |____| Router          |----+
|  right       |    | I: 192.168.32.1 |
+--------------+    | O: 2.2.2.3      |
                    +-----------------+
```

I found that it was VERY handy to have a reliable time source in the configuration, so I added another Pi with 2 ethernet adapters running an apppropriately configured chrony time server. The Pi was connected to both my home LAN (192.168.92) and the test network internet (2.2.2.x).
```
+-----------------+
| TimeSrv         |
| I: 192.168.92.8 |
| O: 2.2.2.4      |
+-----------------+
```
Additionally, since this Pi was on my home LAN I could use it as an SSH gateway into the test network.

## Example scripts and configuration files

No script is provided for the customization, as there's nothing that is specific to this scenario in the fully customized system, but there are examples <a href="Example-Commands.md">here</a> and all plugins are documented with examples <a href="Plugins.md">here</a>.

The two ends of the VPN in this example are named `left` and `right`, with `left` configured with the VPN certificate authority and is an inbound site-to-site VPN server. `left` can also be configured as a client/server VPN supporting connections from Android, iOS, Linux, MacOS, and Windows. 

`right` is also configured to accept inbound site-to-site VPN connections from `left`, but not from any other VPN endpoints. This can be easily added, but is beyond the scope of this example.

* Create a new empty directory and `cd` into it
* Create sub-directories `left`and `right`
* Copy the script `doburn` from below into this directory
* Copy the scripts for `left` (below) to directory `left`
  * **Edit** left/makeTunnel.conf to configure the site-to-site VPN for your network
  * **Edit** left/makemyca.conf to configure the client/server VPN for your network (if desired)
* Copy the scripts for `right` (below) to directory `right`
* Copy your already-customized IMG into this directory
* Change protection on executable scripts to 755: `chmod 755 doburn left/postburn*`
* Load a blank disk for `left` into /dev/sdX
* Burn disk for `left` in /dev/sdX using already-customized IMG: `sudo ./doburn left imgname.img /dev/sdX`
* Load a blank disk for `right` into /dev/sdX
* Burn disk for `right` in /dev/sdX using already-customized IMG: `sudo ./doburn right imgname.img /dev/sdX`
* Boot `left`
* Boot `right`
* Once the systems have completed FirstBoot and rebooted, the VPN will be up and running assuming all the network elements are fully and properly configured.
### doburn
```sh
#!/bin/bash

hn=$1
img=$2
dev=$3

[[ "$hn" == "" ]] || [[ "$img" == "" ]] || [[ "$dev" == "" ]] && echo "? Usage: $0 hostname img /dev/sdX" && exit 1

srcdir="$(pwd)"
mydir="$srcdir/$hn"
case "$hn" in
    left)
        rm -rf $srcdir/certs/*
        mkdir -p $srcdir/certs
	# Calling postburn-make-user-certs is only needed for client/server VPN configurations. Remove if only using site-to-site or host-to-host
        sdm --burn $dev --hostname $hn --plugin @$mydir/pluglist \
            --burn-plugin postburn:"runscript=$mydir/postburn-make-user-certs|runphase=phase1|where=host" \
            --burn-plugin postburn:"runscript=$mydir/postburn-get-certs|runphase=phase0|where=host" \
            $img
        ;;
    right)
        sdm --burn $dev --hostname $hn --plugin @$mydir/pluglist \
            $img
        ;;
    *)
        echo "? Unrecognized hostname '$hn'"
        exit
        ;;
esac
```

### left/makeTunnel.conf

Modify as appropriate for your network configuration. This is only used in a site-to-site or host-to-host VPN, not used for client/server VPN.

```
#Type of tunnel: Host-to-Host or Site-to-Site
ttype:Site-to-Site

#Name for tunnel (used in filenames, cert names, etc)
tunnelname:tun

#Host name for this end of tunnel (use current hostname if it's for this host)
thishost:left

#Remote VPN Server name
rmhost:right

#LAN IP for host 'thishost'
mylanip:192.168.16.2

#LAN IP for host 'rmhost'
rmlanip:192.168.32.2

#Public DNS name/IP address for 'thishost'
myip:2.2.2.2

#Public DNS name/IP address for 'rmhost'
#Leave blank if the remote host should not accept inbound connections for this tunnel
rmip:2.2.2.3
```

### left/makemyca.conf

This is only needed if you want to enable a client/server VPN as well. Modify as appropriate for your network configuration.

```
#Host name
thishost:left

#Domain name
thisdomain:mydomain.com

#External DNS name or IP address for the VPN
vpnaddr:2.2.2.2

#Device name for incoming VPN connections
vpndev:eth0

#Device name for LAN (can be same as vpndev, or different)
landev:eth0

#ip addr of landev
myipaddr:192.168.16.2

#ip addr of vpndev device if vpndev!=landev
#emyipaddr:192.168.16.2

#subnet used inside the tunnel
vpnsubnet:10.1.10.0/24

#dns server IP for clients using the tunnel
vpndns:192.168.16.1

#Web url used in mail with certs
weburl:http://myhost.mydomain.com

#Web directory for the system
webdir:/var/www/html/vpn

#Additional secondary VPN SAN keys if needed
#san2:

#CN Suffix used only as a name in certs (username-device-$thishost@cnsuffix)
cnsuffix:myvpn.net
```

#### left/pluglist

Modify the static IP and gateway as appropriate for your network configuration.

```
network:ifname=eth0|ipv4-static-ip=192.168.16.2|ipv4-static-gateway=192.168.16.1|noipv6|autoconnect=true
pistrong:maketunnel=left/makeTunnel.conf|calife=7300|uclife=7300
# Uncomment next line to enable client/server VPN
#pistrong:makemyca=left/makemyca.conf|calife=7300|uclife=7300
pistrong:iptables|ipforward=y|enablesvc
sshd:enablesvc=yes
```

### left/postburn-get-certs

This script copies all the Cert packs generated during the burn to the host system for your convenience. 

```sh
#!/bin/bash

mydir="$(pwd)"
echo "> Copy pistrong Certs to host system '$mydir/certs'"
cp $SDMPT/etc/swanctl/pistrong/server-assets/*.zip $mydir/certs
```

### left/postburn-make-user-certs
```sh
This is needed only for client/server VPN connections. Modify as appropriate for your VPN client cert naming conventions

#!/bin/bash

mydir="$(pwd)"
echo "> Create user Certs"
echo ""
# Modify the name (home or away) and device name to be as you wish
#
pistrong add home --device rpi1 --linux --remoteid linux.myvpn.net
pistrong add home --device windows3 --windows --remoteid windows.myvpn.net
pistrong add away --device iosj --ios --remoteid ios.myvpn.net
pistrong add away --device and0 --android --remoteid android.myvpn.net
pistrong list > $mydir/certs/vpn-users.txt
```

### right/pluglist

Modify the static IP, gateway, and `vpnmonping` as appropriate for your network configuration.

```
network:ifname=eth0|ipv4-static-ip=192.168.32.2|ipv4-static-gateway=192.168.32.1|noipv6|autoconnect=true
pistrong:iptables|ipforward=y|certpack=certs/Tunnel-tun-right.zip|enablesvc=y|vpnmon=left|vpnmonping=192.168.16.2
sshd:enablesvc=yes
```

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
