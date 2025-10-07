# Trixie Hints

This collection of notes discusses sdm features relative to Trixie that you might want to utilize

## cloudinit and netplan

RasPiOS Trixie includes by default cloud-init and netplan
* **cloud-init** &mdash; If you're using sdm you don't need it
* **netplan** &mdash; netplan integrates with cloud-init AND network-manager to muck up our network connections
  * .nmconnection files end up in /run/NetworkManager/system-connections instead of /etc/NetworkManager/system-connections
  * Some .nmconnection files don't even have indicative filenames, making things even more exciting


The `disables` plugin argument `cloudinit` will
* Remove cloud-init
* Replace NetworkManager with the stock Debian NetworkManager that does not have the netplan integration

  This works great and all your .nmconnection files end up where they should. There is a lingering question around what happens if/when Debian updates it's NetworkManager, because the plugin marks NetworkManager as held. At the moment manual steps are required to update it should there be a newer version from Debian.

Relative to the above, in addition to `disables:cloudinit` consider adding
```
network:cname=lo|ifname=lo|ctype=loopback|ipv4-static-ip=127.0.0.1/8|autoconnect=no
```
to your pluglist or using the
```
--plugin network:"cname=lo|ifname=lo|ctype=loopback|ipv4-static-ip=127.0.0.1/8|autoconnect=no"
```
switch on the command line. This will relocate lo.nmconnection to /etc/NetworkManager/system-connections

Alternatively you can use `copyfile` or your own mechanism to copy a prebuilt lo.nmconnection to /etc/NetworkManager/system-connections

## labwc

The script `sdm-collect-labwc-config` can be run on either Bookworm or Trixie to gather your changes to the labwc config files into a single directory.

When customizing your Trixie system, use `--plugin labwc:labwc-config=/path/to/dir` and the `labwc` plugin will place them properly on your Trixie system.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
