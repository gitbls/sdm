# LED Flashing

Using the `--loadlocal usb,flashled` will cause the First Boot process to flash the Green Pi LED with progress/problem indicators. This is very useful if the Pi doesn't have a monitor attached. The flash codes are ("." is a short flash, and "-" is a long flash):

* `..- ..- ..-`  &mdash; First Boot is waiting for an unmounted USB device to appear with the file `local-settings.txt` on it.
* `... --- ...`  &mdash; An error was found in `local-settings.txt`. Errors can include:
    * ssid or password are not specified, or are the null string
    * An invalid WiFi Country was specified
    * An invalid Keymap, Locale, or Timezone was specified
* `-- -- -- --`  &mdash; WiFi did not connect
* `..... ..... .....`  &mdash; WiFi connected
* `.-.-.- .-.-.- .-.-.- .-.-.-`  &mdash; Internet is accessible
* `-.-.-. -.-.-. -.-.-. -.-.-.`  &mdash; Internet is not accessible
* `..-. ..-. ..-.` &mdash; Waiting for a DHCP-assigned IP address
<br>
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
