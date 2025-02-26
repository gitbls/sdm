# Cool and Useful Things You Can Do: Hotspot

Your Pi can be used as a hotspot, providing network connectivity to other devices connected to it via WiFi or USB. The `hotspot` plugin enables you to easily configure either one.

## Configure Pi as a WiFi Hotspot

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

## Configure Pi as a USB Hotspot (Tether Host)

Similarly, your Pi can provide a hotspot via usb0 (tether host) with traffic forwarded to the internet via wlan0 or another device of your choice (e.g., eth0).

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

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
