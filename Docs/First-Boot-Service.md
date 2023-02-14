# First Boot Service

sdm adds the sdm-firstboot service to each image during Customization. The FirstBoot service implements settings that must be delayed until the target system has actually booted.

The FirstBoot service looks at these settings and implements them as needed:

* Enables and/or disables services as specified with the `--svc-enable` and `--svc-disable` switches
* Processes `--bootset` settings 
* Appends the file specified by `--dhcpcd` to /etc/dhcpcd.conf
* Appends the file specified by `--fstab` to /etc/fstab
* Resets the system console boot behaviour (See NOTE below).
* Sets keyboard, timezone, and locale if specified on the `--burn` command line
* Sets the WiFi Country
* Optionally executes custom scripts in /usr/local/sdm/thispi/1piboot/0*-*.sh. sdm Phase 0 copies these files from /usr/local/sdm/1piboot on the running system.

After all First System Boot processing has been done, FirstBoot waits until the system boot process has fully completed. If `--restart` or `--reboot` were specified, FirstBoot will then restart the system.

First Boot Automatic System Restart is useful for a couple reasons:

* if access to the system requires a configuration setting modified during the First Boot. A restart ensures that all configuration settings are fully enabled.

    For example, if the only access to the Pi will be over the serial port, the system must be restarted before the serial port will be active. In this situation the `--bootset serial:0 --restart` command switches enable the serial port and automatically restart the Pi. After the restart, the serial port is active.

* You want it to reboot to make it easier to ensure that your configuration and services are as desired
* You want the system to be fully operational so you can get started!

**NOTE:** If `--restart` is specified on **RasPiOS Full with Desktop** sdm changes the boot_behaviour to **B1** (Text console with no autologin) so that the sdm FirstBoot messages are visible. In this case the boot_behaviour is reset to **B4** (Graphical Desktop with autologin) for all subsequent reboots, unless the command line included `--bootset boot_behaviour:xx` command switch was specified.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
