# Captive Portal

The Captive Portal can be used to delay configuring the WiFi SSID/Password until the system first boots. See <a href="#portal-principles-of-operation">Portal Principles of Operation</a> below for complete details on how the Captive Portal works.

## Using the Captive Portal with sdm

When used with sdm, the Captive Portal is enabled by using the command switch `--loadlocal wifi` on the sdm customization command line.

For instance:

```
sudo sdm --customize --loadlocal wifi --nowpa --restart --user myuser --password-user somepassword 2023-05-03-raspios-bullseye-arm64.img
```

The `--nowpa` switch tells sdm to ignore an omitted `--wpa` switch. `--user myuser --pasword-user mypassword` sets a username and password. These are not required; there are other ways to handle user accounts in sdm. See the documentation.

`--restart` tells sdm to restart the Pi automatically after the First Boot completes, so that the system has clean booted after the First Boot process completes. See <a href="Command-Details.md">Command Details.</a>

One use of the Captive Portal would be: If you're distributing a customized RasPiOS IMG, you can provide these IMGs to people without needing to know their WiFi credentials by using `--loadlocal wifi` when you customize the IMG. Doing the same thing without sdm can of course be done, if you have a capability similar to sdm First Boot to properly run the Captive Portal. 

The Captive Portal (sdm-cportal) can also be used independently of sdm. See the next section for details.

## Detailed Captive Portal Documentation

The Captive Portal can work with or without the rest of sdm.  The Portal uses a very minimal web server that you connect to with your device (typically a phone) to:

* Provide the WiFi SSID and password for the local WiFi
* optionally provide Localization settings
* Test the provided SSID/password
* Obtain the test result

Captive Portal is typically started during the system First Boot. The Captive Portal starts an Access Point named 'sdm' and the IP Address 10.1.1.1 (both can be changed with command line switches). When you connect to http://10.1.1.1 an introduction page is displayed.

Clicking on the *Start WiFi Configuration* link brings up a web form where the user can enter the SSID and Password for the WiFi network that the Pi should be connected to, as well as optionally specifying the Localization settings for Keymap, Locale, and Timezone that are appropriate for the user and location. There are three checkboxes, all checked, that the user can unselect: 

* **Validate WiFi Configuration by Connecting** &mdash; If this is checked, the user-provided WiFi SSID and Password will be used to validate that the Pi can connect to WiFi. If it is not checked, the SSID and Password are written to wpa_supplicant.conf and no validation is done.
* **Check Internet Connectivity after WiFi Connected** &mdash; If checked, the captive portal will also test whether the Internet (1.1.1.1) is accessible.
* **Enable WiFi power management** &mdash; If checked power management will be enabled for the WiFi device. Some networks seem to work better with this set one way or the other so this checkbox provides that choice. Note that this only changes the power management setting for the Captive Portal operation. Implementing a permanent change on the system must be done separately.

The Captive Portal will complete and the boot process will continue if the WiFi connection test is successful, or if no WiFi validation is done. If there is a problem connecting to WiFi, the Portal will be re-enabled for another try.

Some devices may drop the WiFi connection to the Captive Portal during validation. Wait until the Raspberry Pi ACT light flashes **....** then reconnect to the Captive Portal AP and click on the *Check Results* link.

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
* `--wlan` &mdash; Specify the WiFi device to use. Default is **wlan0**

### Defaults file

The defaults file is typically used during Captive Portal testing and eval. It is not intended for regular deployment use, although it is not precluded. The file format is:

```
formsubmit?ssid=yourssid&password=yourwifipassword&wificountry=US&keymap=us&locale=en_US.UTF-8&timezone=America/Los_Angeles&dhcpwait=60&validate=on&ckinternet=on&wifipower=on
```
Simply delete the whole &keyword=value for any values you don't want. For testing, I recommend setting all values. This really makes testing
MUCH easier.

### Reset command

Typically one would run sdm-cportal as part of configuring a system online via WiFi at some location. You shouldn't need to use the reset command in that scenario. If you are testing sdm-cportal interactively and abort the test, you will probably need to reset the network configuration on your system using the `--reset` switch or reboot the system to ensure that the network stack has consistent state.

**NOTE:** I have had the WiFi get completely confused when using the portal multiple times sequentially on the same system boot instance. I can't say for sure whether it's caused by something the Captive Portal is doing or if it's a bug in the WiFi driver stack, but there have been times when only a reboot would un-screw the WiFi. I have not seen this happen as a result of *normal* usage.

### L10Nhandler

If you are using sdm-cportal as part of a configuration system, you may want to capture the localization settings that the user provided in the Captive Portal form. The `--l10nhandler` switch takes a filename value which is a script that is called when the localization settings are known.

Here is a sample script template you can start with for this. This sample simply uses raspi-config to set the values passed to it. Each set value is logged to the system log with the `logger` command.
```
#!/bin/bash

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
APon:                 -.--
  The access point is ready to accept a connection
Testing in progress:  --.-
  Testing the provided SSID/password
Results Available:    ....
  Reconnect to the access point and click the link 
Doing Cleanup:        ...-
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
* When the test succeeds (IP address obtained) or fails (too many tries without success) the result is made available to the user, LEDs flash four short flashes (**....**)
* After the user retrieves the test result, the Portal either loops back for another try (on failure) or the Captive Portal prepares to exit
* Upon exit the Captive Portal removes the temporary network configuration and restarts either dhcpcd or Network Manager, as appropriate. If systemd-networkd was previously running, it's also restarted.

## Final Notes

* The Captive Portal version does not have a timeout. It will continue running until it has successfully connected to a WiFi network or has failed to do so `--retries` times.
* The text displayed by the Captive Portal is only available in English.
* The Captive Portal does not automatically pop a web page; you will need to manually connect.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
