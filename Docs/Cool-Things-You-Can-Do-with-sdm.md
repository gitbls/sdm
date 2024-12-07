# Cool and Handy Things You Can Do With sdm

Here are some examples of some cool things that you can easily implement with sdm.

## Configure Pi as a Hotspot

Your Pi can be used as a hotspot, providing connectivity to other devices connected to it via WiFi or USB. The `hotspot` plugin enables you to easily configure either one.

### Configure Pi as a WiFi Hotspot

This example uses a hotspot served via WiFi wlan0 with traffic forwarded to the internet via eth0. The config file contents are described <a href="Plugins.md#hotspot">here</a>.

```
device=wlan0
hsenable=y
hsname=myhotspot
ipforward=eth0
type=routed
wifipassword=SecretPassword
wifissid=myhotspot
```

Invoke the hotspot plugin with `--plugin hotspot:config=/path/to/hotspot-config.txt`

<a href="Plugins.md#hotspot">`hotspot` plugin documentation</a>

### Configure Pi as a USB Hotspot (Tether Host)

Similarly, your Pi can provide a hotspot via usb0 (tether host) with traffic forwarded to the internet via wlan0 (or another device of your choice).

When a device such as a Pi configured for tether (client) is plugged into a USB port, the usb0 hotspot will be activated. The `wifissid` and `wifipassword` arguments aren't used with USB hotspots.

```
device=usb0
hsenable=y
hsname=myhotspot
ipforward=wlan0
type=routed
wifipassword=SecretPassword
wifissid=myhotspot
```

Change the ipforward device to be the device that is connected to the network you want to route to.

The USB hotspot plugin is configured the same way as a WiFi hotspot: `--plugin hotspot:config=/path/to/usb-hotspot-config.txt`

<a href="Plugins.md#hotspot">`hotspot` plugin documentation</a>

## Configure Pi as a USB Tether Client

Configure a Pi with the `gadgetmode` plugin and plug this tether client via USB to a Pi with a USB hotspot plugin (above), or an appropriately configured MacOS or Windows system.

Invoke the `gadgetmode` plugin `--plugin gadgetmode:static-mac`

<a href="Plugins.md#gadgetmode">`gadgetmode` plugin documentation</a>

## Generate SSH Key for User During `--burn` and Retrieve For Use Elsewhere

Use the `sshkey` plugin to create an SSH key for a specific user/disk. Use the `postburn` plugin to run a script that extracts certs from the burned disk to a host-based directory.
```
--plugin sshkey:"sshuser=myuser|keyname=mykeyname|passphrase=mypassphrase"
--burn-plugin postburn:"runscript=$mydir/postburn-get-certs|runphase=phase0|where=host"
```

with the script post-burn-get-certs:

```
#!/bin/bash

mydir="/path/to/my/dir"
echo "> Copy certs to save location on the host"
# This will require your customization. Use $SDMPT to reference files and directories on the burned disk
# 
#cp $SDMPT/path/cert-file /path/on/host/dir
#
# For example
#
cp $SDMPT/home/myuser/.ssh/mykeyname /path/on/host/dir
```

<a href="Plugins.md#sshkey">`sshkey` plugin documentation</a><br>
<a href="Plugins.md#postburn">`postburn` plugin documentation</a>

## Easily Configure a Two-Host IPSEC VPN that <b><i>just runs</i></b>

You can use sdm to create two systems to be Host-to-Host or Site-to-Site endpoints using only three commands:
* Customize the <i>base image</i> that is used by both endpoints
* Burn one endpoint's disk
  * Include `--plugin pistrong` to install and configure the Tunnel
  * Use the `postburn` plugin to extract the Cert Pack for the other end of the Tunnel
* Burn the second endpoint
  * Use the `pistrong` plugin `certpack` argument to import the Cert Pack and configure this host's end of the Tunnel

In its fully-configured usage the first host will complete the FirstBoot process. When it restarts, it's VPN will be running.

When the second host completes the FirstBoot process, it will start a service that attempts to always keep the VPN up and running.

<b>Are you interested in trying this VPN?</b> Please post an issue on the sdm GitHub and inspire me to complete the documentation ;)

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
