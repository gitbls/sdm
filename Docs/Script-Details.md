# sdm Script Details

sdm consists of a primary script sdm and several supporting scripts:

* **sdm** &mdash; The sdm main program. Collects the command line details and starts the customization process. Also directly handles some commands such as `--burn`, `--shrink`, and `--ppart`.

* **sdm-phase0** &mdash; Script run by sdm before nspawn-ing into the IMG file. sdm-phase0 has access to the running Pi system as well as the file system within the IMG file. sdm-phase0 performs several steps:

     *  Copy files from the running system into the IMG, as specified by command line switches, for use in Phase 1.
     
    * Calls selected Plugins and/or Custom Phase Scripts for Phase 0 if specified.

    You can extend what's done in Phase 0 by using a <a href="Plugin.md">Plugin (preferred)</a> or <a href="Custom-Phase-Script.md">Custom Phase Script</a>. 

* **sdm-phase1** &mdash; If `--aptcache` was specified, the IMG is enabled as an apt-cacher-ng client. See <a href="apt-Cacher-NG.md">apt Cacher NG</a> for details on apt-cacher-ng.

    * App installation is accomplished using the <a href="Docs/Plugins.md#apps>`apps` plugin</a>. The `apps` plugin installs the requested apps when it is run in Phase 1.

    * Similarly, other plugins can be used, and are called by sdm-phase1 at the appropriate time.

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
