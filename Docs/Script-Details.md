# sdm Script Details

sdm consists of a primary script sdm and several supporting scripts:

* **sdm** &mdash; The sdm main program. Collects the command line details and starts the customization process. Also directly handles some commands such as `--burn`, `--shrink`, and `--ppart`.

* **sdm-phase0** &mdash; Script run by sdm before nspawn-ing into the IMG file. sdm-phase0 has access to the running Pi system as well as the file system within the IMG file. sdm-phase0 performs several steps:

     *  Copy files from the running system into the IMG, as specified by command line switches, for use in Phase 1.
     
     * If `--user` is specified, creates the user's home directory so that your Custom Phase script can copy files into it during Phase 0. The user is also enabled to use `sudo` like the user *pi*.

    * Calls selected Plugins and/or Custom Phase Scripts for Phase 0 if specified.

    You can extend what's done in Phase 0 by using a <a href="Plugin.md">Plugin</a> or <a href="Custom-Phase-Script.md">Custom Phase Script</a>. 

* **sdm-phase1** &mdash; Asks for and changes the password for the *pi* user. Optionally, if you used the sdm `--user` switch, creates your personal account, sets its password, directory and protections, etc. If `--aptcache` was specified, the IMG is enabled as an apt-cacher-ng client. See <a href="apt-Cacher-NG.md">apt Cacher NG</a> for details on apt-cacher-ng.

    sdm-phase1 installs the apps that you've specified. You control which applications are installed by using the `--apps` switch. The value for the `--apps` switch can either be a quoted, space-separated list ("pkg1 pkg2 pgk3"), or @somefile, where somefile has a list of applications to install, one per line. Comments are indicated by a pound sign (#) and are ignored, so you can document your app list if desired. If the specified file is not found, sdm will look in the sdm directory (/usr/local/sdm). 

    sdm-phase1 also installs the 'X' apps that you've specified. You control which applications are installed by using the `--xapps` switch. The value for the `--xapps` switch is treated the same as for the `--apps` switch above. This is probably more interesting if you're using RasPiOS Lite, which does not include the X Windows software in the image. The example file `sdm-xapps-example` provides one example of installing a minimal X Windows system, but since there are a multitude of ways to install X11, display managers, window managers, and X11-based applications, you'll undoubtedly want to build your own xapps list.

    * There is no restriction that the *xapps* list actually contains X Windows apps; it can be used as a set of secondary apps if desired.

    * App installation is enabled by providing the *apps* and/or *xapps* values to the `--poptions` command switch. ***In other words,*** to have sdm install apps you need to specify the set of apps using `--apps` (or `--xapps`) **AND** `--poptions apps` (and/or xapps).

    * sdm does not *require* that you separate your app list into "apps" and "X apps". This is done solely to provide you with more fine-grained control over app selection. For instance, you might not want to install the X apps into a server image, but want both sets installed on a Desktop configuration.

* **sdm-apt** &mdash; sdm-apt is an optional script that you can use to issue apt commands when in Phase 1 or via `sdm --explore`. It logs the apt output in $SDMPT/etc/sdm/apt.log along with all the other apt operations done in by sdm in customizing your image. Refer to the script for details.

* **sdm-firstboot** &mdash; sdm-firstboot is a systemd service run on first system boot to set the WiFi country, enables Pi-specific devices if configured, and optionally run any Custom FirstBoot scripts.

* **1piboot/*** &mdash;  Configuration file and sample scripts. You may edit the configuration file (1piboot.conf) if you wish, or you can use the --bootset command switch to control all the settings. See <a href="Bootset-and-1piboot.md">Bootset and 1piboot</a> for details. This directory will also be installed onto the SD Card in /usr/local/sdm/1piboot.
    If enabled, the custom scripts in 1piboot/0*-*.sh are run when the system first boots, and can perform system tuning improvements. The custom scripts are enabled by the switch `--bootscripts` on either the command line that builds the IMG, or on the `sdm --burn` command when burning a new SD card. The scripts can do anything you want, of course, although having several small focused scripts is probably preferable for your sanity over the long term.

* **sdm-cparse** &mdash; Helper script that defines some sdm-internal bash functions.

* **sdm-cportal** &mdash; Implements the Captive Portal for `--loadlocal wifi`

* **sdm-cmdsubs** &mdash; Implements functions used by sdm to process `--burn`, `--shrink`, and `--ppart` commands

* **sdm-logmsg** &mdash; Helper script for the Captive Portal.

* **sdm-customphase** &mdash; Custom Phase Script skeleton. Use this as a starting point to build your <a href="Custom-Phase-Script.md">Custom Phase Script</a>

* **sdm-readparams** &mdash; Helper script that reads the sdm configuration file creating bash variables, and sources sdm-cparse to make its functions available. sdm-readparams is copied to /etc/sdm in an IMG being customized, and is called as needed by sdm, Plugins, and Custom Phase Scripts.

* **sdm-apt-cacher** &mdash; Configures and installs apt-cacher-ng. This is optional, but highly recommended, especially with slower internet connections. sdm will use this with the `--aptcache` command switch. <a href="apt-Cacher-NG.md">apt Cacher NG</a> for details.

* **plugins/sdm-plugin-template** &mdash; Plugin skeleton. Use this as a starting point to build your <a href="Plugins.md">Plugin</a>.

* **plugins/*all other files*** &mdash; <a href="Plugins.md">Plugins</a> that can be used with the `--plugin` switch.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
