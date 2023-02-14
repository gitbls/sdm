# Captive Portal

If `--loadlocal wifi` is specified on the command line during image customization, a Captive Portal is started during the system First Boot. The Captive Portal starts an Access Point named 'sdm' (can be changed with --apssid) and the IP Address 10.1.1.1 (can be changed with --apip). When you connect to http://10.1.1.1 a web page will be displayed that has two links on it.

Clicking on the first link brings up a web form where the user can enter the SSID and Password for the WiFi network that the Pi should be connected to, as well as optionally specifying the Keymap, Locale, and Timezone appropriate for the user and location. There are two checkboxes, both checked, that the user can unselect: 

* **Validate WiFi Configuration by Connecting** &mdash; If this is checked, the user-provided WiFi SSID and Password will be used to validate that the Pi can connect to WiFi. If it is not checked, the SSID and Password are written to wpa_supplicant.conf and no validation is done.
* **Check Internet Connectivity after WiFi Connected** &mdash; If checked, the captive portal will also test whether the Internet (1.1.1.1) is accessible.

The Captive Portal will complete and the boot process will continue if the WiFi connection test is successful, or if no WiFi validation is done. If there is a problem connecting to WiFi, the Portal will be re-enabled for another try.

If the Pi has only a single WiFi on it (that is, no second WiFi via a USB adapter), the Captive Portal WiFi will be dropped when the WiFi validation is done. The user must reconnect to the Captive Portal WiFi before checking the result of the validation test.

However, if the Pi has a second WiFi available (wlan1), the Captive Portal will use wlan1 for the Captive Portal, and use wlan0 for WiFi validation. In this case, the Captive Portal WiFi does not drop during this process.

The Captive Portal (sdm-cportal) is built in such a way that it is usable outside of sdm. If you try to use it outside of sdm and run into problems, please open an issue on this github.

NOTE: At the current time, the text displayed by the Captive Portal is only available in English. If you would like to contribute translations to other languages, open an issue on this github.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
