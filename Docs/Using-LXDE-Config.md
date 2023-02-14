# Using --lxde-config to customize LXDE

The `--lxde-config` switch directs sdm to load the specified app LXDE configuration files into the image in the /home/*user*/.config directory tree. *user* will be pi by default, or the user specified by `--user`.

The `--lxde-config` switch takes a comma-separated argument. The complete switch specification is:

    --lxde-config pcmanfm:/path/to/pcmanfm.conf,libfm:/path/to/libfm.conf,lxterminal:/path/to/lxterminal.conf

You do not need to specify all the config files. If you only want to customize lxterminal, you only need specify that. If you are customizing pcmanfm, you'll need to specify config files for both pcmanfm AND libfm (I have no idea why pcmanfm uses two config files!)

Here's how to establish your custom configuration files:

* Boot a RasPiOS Desktop system with LXDE
* Customize lxterminal and/or pcmanfm preferences in the apps as desired
* Copy the configuration files from your Pi to a shared directory, so that they are available on the Pi that you'll be using for sdm. They don't really need to be in a *shared directory* per se, just a directory available to sdm. The config files can be found at
    * **libfm:** /home/*user*/.config/libfm.conf
    * **pcmanfm:** /home/*user*/.config/LXDE-pi/pcmanfm.conf
    * **lxterminal:** /home/*user*/.config/lxterminal/lxterminal.conf
* Add the --lxde-config switch with the appropriate arguments to your sdm command line
* The specified files will be copied into the IMG during Phase 0, when both the host and IMG are acessible
* The files will be moved to the correct directory locations in /home/*user*/.config during Phase 1
* When you boot your newly-created customized image, your settings will be in place

If the target IMG does not have LXDE installed no changes will be made, although the files will be copied to /etc/sdm/assets.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
