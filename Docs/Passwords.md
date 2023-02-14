# Passwords

## Behavior of --password-same Switch
If `--password-same y` is specified, then all accounts will be given the same password. *All accounts* includes *pi*, the user specified by `--user`, and root, if `--rootpwd` is specified. The password used is selected as follows:

* `--password-pi` password if specified
* `--password-user` password if specified
* `--password-root` password if specified
* Password entered in response to the password prompt

## --nopassword switch

The `--nopassword` switch directs sdm to not prompt for any passwords during IMG customization. It is assumed that at least one password will be set during the burn process, but it is not enforced. In other words, if `--nopassword` is used during customization no passwords are set during the burn process, and no Custom Phase Script or plugin has set any passwords, it will not be possible to login to the system.

## Password logging in the IMG or SSD/SD Card
If `--showpwd` is used, passwords will knowingly be logged in /etc/sdm/history.

**However**, if **any** of the password switches (`--password-pi`, `--password-user`, or `--password-root`) are used on the command line, passwords **will** be logged in /etc/sdm/history because the complete sdm command line is logged there. They will also be retained in /etc/sdm/cparams.

**To remove all logged passwords from an sdm-customized IMG or SD card** (and NOT change any passwords on the IMG or SD Card), simply remove the files /etc/sdm/history and /etc/sdm/cparams. You may want to save them for later use or information unless you have recorded the passwords elsewhere.

Note that if you forget any of the passwords, you can use sdm to reset them by using `sdm --explore` into the IMG or SD Card, and then changing the password for the desired account(s) with the `passwd` command.

You can use the `--redact` switch with `--customize` or `--burn`. sdm will replace all occurrences of the passwords for pi, user, and root (as described above) with the string **REDACTED**. The redaction is a simple string replacement. If any of those passwords are words found in /etc/sdm/history or /etc/sdm/cparams, those non-password instances will be redacted as well.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
