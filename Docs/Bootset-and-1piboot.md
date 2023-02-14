# Bootset and 1piboot
## raspi-config control using 1piboot.conf and the --bootset command switch

1piboot/1piboot.conf is a configuration file that describes RasPiOS-related configuration settings to be made in your image. Configuration settings are made when the system first boots. All of these settings use raspi-config to make the actual changes to the system. sdm does not syntax check the settings.

The settings in 1piboot.conf can be controlled by editing the config file, or via the `--bootset` command switch. For instance, you can set `serial=0` in 1piboot.conf or you can use the `--bootset serial=0` command switch. In addition, you can use `--bootset` when you customize the image and override the setting when you `--burn` the SD Card or `--burnfile` a new IMG file. To set multiple values, separate them with a comma: `--bootset serial=0,boot_behaviour=B4,camera=0`

## First Boot configuration settings

The following can only be set in the context of a running system, so are set during the first boot of the operating system. Details on each of these settings are available in the `sudo raspi-config` command. Unless otherwise specified, you enable the setting by uncommenting the corresponding line in 1piboot.conf and setting it to 0 (enabled) or other value as noted (e.g., *audio*, *pi4video*, *boot_behaviour*, and *boot_order*).

* **boot_splash** &mdash; Enable a splash screen at boot time
* **boot_wait** &mdash; Wait for a network connection to be established
* **camera** &mdash; Enable the camera
* **i2c** &mdash; Enable the ARM I2C interface
* **net_names** &mdash; Enable predictable device names
* **onewire** &mdash; Enable the one-wire interface
* **rgpio** &mdash; Enable the network-accessible GPIO server
* **serial** &mdash; Enable the serial port
* **spi** &mdash; Enable the SPI interface
* **blanking** &mdash; Enable screen blanking
* **overscan** &mdash; Enable compensation for displays with overscan.
* **pixdub** &mdash; Enable pixel doubling
* **powerled** &mdash; **0**:Enable disk activity flashing on Power LED, **1**:Power LED always on (Pi Zero and Pi400 only)
* **audio** &mdash; Set the audio setting. Valid settings are: **0**:Auto, **1**:Force 3.5mm jack, **2**:Force HDMI
* **pi4video** &mdash; Set the Pi4 video mode. Valid settings are: **V1**:4Kp60, **V2**:Analog TV out, **V3**:Disable both 4Kp60 and Analog
* **boot_behaviour** &mdash; Set the boot behavior. Valid settings are: **B1**:Text console no autologin, **B2**:Text console with autologin, **B3**:Graphical Desktop no autologin, and **B4**:Graphical Desktop with autologin.

  **NOTE:** If `--user` was specified, autologin will be set for that user. If not, user "pi" is enabled.

* **boot_order** &mdash; Set the boot order. Valid settings are: **B1**:Boot from SD Card if available else boot from USB, **B2**:Boot from USB USB if available else boot from SD Card, **B3**: Network boot if SD Card boot fails. See the "Boot Order" section below.
* **overclock** &mdash; Enable overclocking. Valid settings are: **None**, **Modest**, **Medium**, **High**, **Turbo**. This setting is for Pi 1 and 2 only and will silently fail on all other Pi models.

**NOTE:** Not all of the above settings have been thoroughy tested and verified. They simply call `raspi-config`, so *should just work*. If you run into a problem, please open an issue on this github.

## Boot Order

The *boot_order* configuration setting is different than other settings, in that in modifies the Raspberry Pi eeprom so that boot from USB disk or boot from Network are enabled. If your Pi already has a current system on it, you can use the command `sudo raspi-config do_boot_order XX` to set the boot_order to B1 (Boot from SD Card if available else USB device), B2 (Boot from USB if available else SD Card) or B3 (Boot from Network if SD Card boot fails).

If the target system doesn't have a current system on it, you can update the eeprom with sdm by setting up a separate image that is enabled with boot_order, and has all updates installed. Burn that image to an SD card and boot up the target Pi hardware. The system will use raspi-config to change the boot_order setting, and the restart again.

At that point, you can remove the SD card and move ahead with setting up your SSD or Network boot as desired.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
