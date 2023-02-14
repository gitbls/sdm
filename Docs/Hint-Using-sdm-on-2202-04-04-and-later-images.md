# Hint: Using sdm on 2202-04-04 and Later IMGs

sdm works fine on RasPiOS 2022-04-04 images (and presumably later). Key considerations for using sdm on these images:
* Add `--disable piwiz` to the sdm command line if you have fully configured the image using sdm using:
  * `--user`, `--password-user`, `--L10n` (or equivalently `--keymap`, `--locale`, `--timezone`, and `--wifi-country`)
  * `--wpa` to configure WiFi if needed
  * Have NOT used `--poptions noupdate,noupgrade`. That is, the IMG is fully up-to-date.

You can use `--disable piwiz` on both Lite and Desktop versions and on either the `--customize` command or the `--burn` command .

On Lite sdm disables the userconfig service. On Desktop versions, sdm also prevents the piwiz desktop app from starting.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
