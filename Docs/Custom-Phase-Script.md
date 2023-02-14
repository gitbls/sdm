# Custom Phase Script

## Overview

A Custom Phase Script is a script provided by you. You put all the commands in the Custom Phase Script that you want to have done to the IMG.

Historically, sdm supported Custom Phase Scripts first. <a href="Plugins.md">Plugins</a>, which were added in V7.0, are logically the same as Custom Phase Scripts, but can also be used at burn time. sdm will continue to support Custom Phase Scripts, but <a href="Plugins.md">Plugins</a> are the recommended approach for extending sdm capabilities or doing personal customizations.

The Custom Phase Script is called 3 times: Once for Phase 0, once for Phase 1, and once after Phase 1 has completed. The first argument indicates the current phase ("0", "1", or "post-install"). The Custom Phase Script needs to be aware of the phase, as there are contextual differences:

* In Phase 0, the host file system is fully available. The IMG file is typically mounted on /mnt/sdm (although it may be mounted on /mnt/sdm.xxxx if /mnt/sdm is busy), so all references to the IMG file system must be appropriately referenced by prefacing the directory string with $SDMPT, which is always correct. This enables the Custom Phase script to copy files from the host file system into the IMG file.

* In Phase 1 and post-install (both inside nspawn) the script runs in the context of the IMG. This is where you install and configure any additional or apps with special install requirements. In both Phase 1 and post-install, the host file system is not available at all. Thus, if a file is needed in Phase 1, Phase 0 must copy it into the IMG. References to /mnt/sdm will fail in Phase 1. If preferred, you can use $SDMPT in Phase 1 and the post-install phase also, as sdm defines it as "".

If a Custom Phase Script wants to run a script at boot time, even if `--bootscripts` is not specified, the Custom Phase script should put the script in the IMG in /etc/sdm/0piboot and named 0*-*.sh (e.g., 010-customize-something.sh). These scripts are always run by FirstBoot.

The best way to build a Custom Phase Script is to start with a copy of the example Custom Phase Script `sdm-customphase`, and extend it as desired.

## Command line switches

* `--cscript` *scriptname* &mdash; Specifies the path to your Custom Phase Script, which will be run as described in the Custom Phase Script section below.
* `--csrc` */path/to/csrcdir* &mdash; A source directory string that can be used in your Custom Phase Script. One use for this is to have a directory tree where all your customizations are kept, and pass in the directory tree to sdm with `--csrc`. 
* `--custom[1-4]` &mdash; 4 variables (custom1, custom2, custom3, and custom4) that can be used to further customize your Custom Phase Script.
<br>
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
