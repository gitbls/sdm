# Using the `lxde` plugin to customize LXDE

The `lxde` plugin enables you to load specified app LXDE configuration files into the image in the /home/*user*/.config directory tree.

The `lxde` plugin accepts the argument `lxde-config` which takes a comma-separated argument. The complete argument specification is:
```sh
--plugin lxde:"lxde-config pcmanfm:/path/to/pcmanfm.conf,libfm:/path/to/libfm.conf,lxterminal:/path/to/lxterminal.conf"
```
You only need to specify the config files you want to provide. If you are customizing pcmanfm, you'll need to specify config files for both pcmanfm AND libfm (I have no idea why pcmanfm uses two config files!)

Here's how to establish your custom configuration files:

* Boot a RasPiOS Desktop system with LXDE
* Customize lxterminal and/or pcmanfm preferences in the apps as desired
* Copy the configuration files from your Pi to a shared directory, so that they are available on the Pi that you'll be using for sdm. They don't really need to be in a *shared directory* per se, just a directory available to sdm. The config files can be found at
    * **libfm:** /home/*user*/.config/libfm.conf
    * **pcmanfm:** /home/*user*/.config/pcmanfm/LXDE-pi/pcmanfm.conf
    * **lxterminal:** /home/*user*/.config/lxterminal/lxterminal.conf
* Add the `lxde` plugin with the `lxde-config` argument and values to your sdm command line
* The specified files will be copied into the IMG during Phase 0, when both the host and IMG are acessible
* The files will be moved to the correct directory locations in /home/*user*/.config during Phase 1
* When you boot your newly-created customized image, your settings will be in place

If the target IMG does not have LXDE installed no changes will be made, although the files will be copied to /etc/sdm/assets/lxde.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
