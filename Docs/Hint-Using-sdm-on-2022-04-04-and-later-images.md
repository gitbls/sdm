# Hint: Using sdm on 2022-04-04 and Later IMGs

sdm works fine on RasPiOS 2022-04-04 images (and presumably later). Key considerations for using sdm on these images:
* Add `--plugin disables:piwiz` to the sdm command line if you have fully configured the image with sdm using:
  * Use the `user` plugin to add, delete, or modify users as appropriate
  * Use the `L10n` plugin to configure the system keymap, locale, and timezone

You can use `--plugin disables:piwiz` on both Lite and Desktop versions and on either the `--customize` command or the `--burn` command .

On Lite sdm disables the userconfig service. On Desktop versions, sdm also prevents the piwiz desktop app from starting.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
