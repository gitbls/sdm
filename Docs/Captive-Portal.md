# Captive Portal

The Captive Portal can be used to delay configuring the WiFi SSID/Password until the system first boots. See <a href="#portal-principles-of-operation">Portal Principles of Operation</a> below for complete details on how the Captive Portal works.

The primary target use for the Captive Portal is during the first boot of the system where there is no other way to configure the WiFi credentials. However, there's nothing precluding it from being used on running systems. For instance, you could wire up a GPIO to trigger the Portal to run. The Portal itself does not reboot the system, but it is generally suggested that you reboot the system once the Portal completes.

## Using the Captive Portal with sdm

There are two ways to use the Captive Portal in sdm: Via a plugin or the sdm command line. Both provide identical operation, but the plugin provides finer-grain control over the configuration as well as scope (e.g., all systems built from an IMG or only specific systems/SSD/SD Cards).

### Using the Captive Portal plugin

The plugin is discussed in detail <a href="Plugins.md#wificonfig">here</a>. The plugin can be used with `--customize`, burning an IMG to an SSD/SD device, or as a standalone update to an IMG or an already-burned but not yet booted sdm-customized SSD/SD.

At one end, using the plugin during customization would cause the Portal to run on all SSD/SD cards burned from that IMG.

Conversely, if you are burning SD Cards for a set of Pis, but some of the devices are on different WiFi networks, you can customize the SD Cards for them by running the plugin on only those SD Cards, while burning the rest with a wpa_supplicant.conf for systems on the known network.

The Captive Portal (sdm-cportal) can also be used independently of sdm. See <a href="#detailed-captive-portal-documentation">Detailed Captive Portal Documentation</a> for more information.

#### Examples

Installing the Captive Portal into an IMG:
```
sdm --customize --nowpa --plugin wificonfig:"country=us" [...other switches...] 2023-05-03-raspios-bullseye.img
```
Installing the Captive Portal when burning an SSD/SD Card:
```
sdm --burn /dev/sdc --plugin wificonfig:"country=us" [...other switches...] 2023-05-03-raspios-bullseye.img
```
Installing the Captive Portal on a specific SSD/SD Card after it's burned:
```
sdm --runonly plugins --plugin wificonfig:"country=us" [...other switches...] /dev/sdc
```

### Using the sdm command line

Another way to activate the Captive Portal is using the command switch `--loadlocal wifi` on the sdm customization command line.

For instance:

```
sudo sdm --customize --loadlocal wifi --nowpa --restart --user myuser --password-user somepassword 2023-05-03-raspios-bullseye-arm64.img
```

The `--nowpa` switch tells sdm to ignore an omitted `--wpa` switch. `--user myuser --pasword-user mypassword` sets a username and password. These are not required; there are other ways to handle user accounts in sdm. See the documentation.

`--restart` tells sdm to restart the Pi automatically after the First Boot completes, so that the system has clean booted after the First Boot process completes. See <a href="Command-Details.md">Command Details.</a>

## Detailed Captive Portal Documentation

The Captive Portal can work with or without the rest of sdm.  The Portal uses a very minimal web server that you connect to with your device (typically a phone) to:

* Provide the WiFi SSID and password for the local WiFi
* optionally provide Localization (L10N) settings
* Test the provided SSID/password
* Obtain the test result

Captive Portal is typically started during the system First Boot. The Captive Portal starts an Access Point named 'sdm' and the IP Address 10.1.1.1 (both can be changed with command line switches). When you connect to http://10.1.1.1 an introduction page is displayed.

Clicking on the *Start WiFi Configuration* link brings up a web form where the user can enter the SSID and Password for the WiFi network that the Pi should be connected to, as well as optionally specifying the Localization settings for Keymap, Locale, and Timezone that are appropriate for the user and location. There are three checkboxes, all checked, that the user can unselect: 

* **Validate WiFi Configuration by Connecting** &mdash; If this is checked, the user-provided WiFi SSID and Password will be used to validate that the Pi can connect to WiFi. If it is not checked, the SSID and Password are written to wpa_supplicant.conf and no validation is done.
* **Check Internet Connectivity after WiFi Connected** &mdash; If checked, the captive portal will also test whether the Internet (1.1.1.1) is accessible.
* **Enable WiFi power management** &mdash; If checked, power management will be enabled for the WiFi device. Some networks seem to work better with this set one way or the other so this checkbox provides that choice. Note that this only changes the power management setting for the Captive Portal operation. Implementing a permanent change on the system must be done separately.

The Captive Portal will complete and the boot process will continue if the WiFi connection test is successful, or if no WiFi validation is done. If there is a problem connecting to WiFi, the Portal will be re-enabled for another try.

Some devices may drop the WiFi connection to the Captive Portal during validation. Wait until the Raspberry Pi ACT light flashes **....** or **---.** then reconnect to the Captive Portal AP and click on the *Check Results* link.

### Command Line Description

The Captive Portal (file `sdm-cportal`) is a Linux command-line program that has the following switches:

* `--apssid` &mdash; Specifies the name for the access point. The complete SSID is `<hostname>-<apssid>` (e.g., *myhost-sdm*) to acommodate configuring multiiple systems in close proximity. The default is **sdm**
* `--apip` &mdash; Set the IP Address for the access point. Default is **10.1.1.1**
* `--country` &mdash; Set the WiFi country to use in case user doesn't specify. Default is **US**
* `--defaults` &mdash; Provides a file with defaults for the Captive Portal. See below for details
* `--reset` &mdash;See below
* `--l10nhandler` &mdash; Provides a script to be run when the localization settings are know. See below
* `--retries` &mdash; Retry the Portal data entry up to this many times. Default is **5** retries
* `--sdm` &mdash; sdm-cportal was invoked by sdm. A couple of things are done differently
* `--timeout` &mdash; Specifies the timeout (in seconds) for the Portal. Default is **15*60 seconds**
* `--wlan` &mdash; Specify the WiFi device to use. Default is **wlan0**

### Defaults file

The defaults file is typically used during Captive Portal testing and eval. It is not intended for regular deployment use, although it is not precluded. The file format is:

```
formsubmit?ssid=yourssid&password=yourwifipassword&wificountry=US&keymap=us&locale=en_US.UTF-8&timezone=America/Los_Angeles&dhcpwait=60&validate=on&ckinternet=on&wifipower=on
```
Simply delete the whole &keyword=value for any values you don't want. For testing, I recommend setting all values. This really makes testing
MUCH easier.

By default the values from the defaults file are applied only if no value was provided in the Captive Portal web form. If the key *override* (value is not important) is found in the defaults file, provided defaults override the web form inputs.

### Reset command

Typically one would run sdm-cportal as part of configuring a system online via WiFi at some location. You shouldn't need to use the reset command in that scenario. If you are testing sdm-cportal interactively and abort the test, you will probably need to reset the network configuration on your system using the `--reset` switch or reboot the system to ensure that the network configuration has consistent state.

### L10Nhandler

If you are using sdm-cportal as part of a configuration system, you may want to capture the localization settings that the user provided in the Captive Portal form. The `--l10nhandler` switch takes a filename value which is a script that is called when the localization settings are known.

Here is a sample script template you can start with for this. This sample simply uses raspi-config to set the values passed to it. Each set value is logged to the system log with the `logger` command.
```sh
#!/bin/bash
#
# $1: keymap
# $2: locale
# $3: timezone

keymap="$1"
locale="$2"
timezone="$3"

# Sample code to save localization settings

#logger "l10nhandler: inputs: keymap='$keymap' local='$locale' timezone='$timezone'"
if [ "$keymap" != "" ]
then
    logger "l10nhandler: Configure keyboard"
    raspi-config nonint do_configure_keyboard "$keymap" < /dev/console > /dev/console
fi
if [ "$locale" != "" ]
then
    logger "l10nhandler: Configure locale"
    raspi-config nonint do_change_locale "$locale"
fi
if [ "$timezone" != "" ]
then
    logger "l10nhandler: Configure timezone"
    raspi-config nonint do_change_timezone "$timezone"
fi
#logger "l10nhandler: localization settings updated"
```

### ACT LED Signaling

The Captive Portal signals state via the ACT LED on the Pi (the green light). The signals include:
```
NAME                  ACT LED pattern
APoff:                ----
  The access point has not yet started
APon:                  -.--
  The access point is ready to accept a connection
Testing in progress:   --.-
  Testing the provided SSID/password
Good Result Available: ....
  Reconnect to the access point and click the link to get the Pi's IP address
Bad Result Available:  ---.
  Reconnect to the access point and click the link 
Doing Cleanup:         ...-
  Housekeeping and exit

```

### WiFi Connection Information

If you're having problems with the connection dropping, it's best to hit the WiFi settings app on your device, toggle WiFi off/on, and then reconnect to the Captive Portal. 

I found this wifi toggle/reconnect necessary primarily after the *Testing host WiFi Configuration* web page. Wait for the ACT
LED to flash Results Available and then toggle/reconnect your device's WiFi before clicking on the Check WiFi
Connection Status link.

### Portal Principles of Operation

The Captive Portal uses a Virtual Access Point on the WiFi adapter. This effectively enables the WiFi to have two different functions: An Access Point for devices to connect to, and a "standard" WiFi that is used for testing the provided SSID/Password.

From a software perspective, the Captive Portal uses systemd-networkd to control the WiFi adapter. In order to make this work correctly, dhcpcd and Network Manager services are stopped as the Captive Portal starts up. Upon completion the Portal restarts whichever of those two was previously running.

The Captive Portal uses two separately controlled wpa_supplicant services. One WPA supplicant is used for wlan0, and the other for controlling the Captive Portal Access Point.

The Captive Portal Operating steps are:
* Cleanly stop network services (dhcpcd, Network Manager, and systemd-networkd)
* Create and configure the Captive Portal
* Start systemd-networkd, which starts the Captive Portal network interface
* Listen for and process incoming HTTP requests
* When an SSID/Password have been provided, configure the "normal" WiFi to use those
* Start the WiFi WPA supplicant to test the SSID/Password (the network test runs in a separate thread)
* When the test succeeds (IP address obtained) the result is made available to the user, ACT LED flashes four short flashes (**....**). If the test fails (too many tries without success) the ACT LED flashes **---.**.
* After the user retrieves the test result, the Portal either loops back for another try (on failure) or the Captive Portal prepares to exit
* The Captive Portal updates wpa_supplicant.conf if the test succeeds or if no Internet test is done
* Upon exit the Captive Portal removes the temporary network configuration and restarts either dhcpcd or Network Manager, as appropriate. If systemd-networkd was previously running, it's also restarted.
* If the timeout (15*60 seconds by default) fires, the Captive Portal will be cleanly shutdown without having performed any permanent WiFi configuration changes. However, if the timeout occurs after testing of the SSID/Password has successfully completed, wpa_supplicant.conf will in fact be updated.

## Final Notes

* The text displayed by the Captive Portal is only available in English.
* The Captive Portal does not automatically pop a web page; you will need to manually connect.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
