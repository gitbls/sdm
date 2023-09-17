# Passwords

Starting with sdm V9.0, user account passwords are set using the `user` plugin.

See <a href="Plugins.md#user">the user plugin documentation</a> for full details.

If you forget any of the passwords, you can use sdm to reset a password by using `sdm --explore` into the IMG or SD Card, and then changing the password for the desired account(s) with the `passwd` command.

You can use the `--redact` switch with `--customize` or `--burn` or the `user` plugin `redact` argument. sdm will replace all occurrences of the matching strings in /etc/sdm/history with the string **REDACTED**. The redaction is a simple string replacement.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
