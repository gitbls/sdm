# Using the `labwc` plugin to customize Labwc

The `labwc` plugin enables you to load specified labwc configuration files into the image in the /home/*user*/.config directory tree.

The `labwc` plugin accepts several arguments. The easiest way to configure labwc is to use the argument `all-config` which takes a directory path. The complete argument specification is:
```sh
--plugin labwc:"all-config=/path/to/labwc-config-dir"
```
Here's how to establish your custom configuration files:

* Boot a RasPiOS Desktop system with labwc
* Customize lxterminal and/or pcmanfm preferences in the apps as desired
* Customize labwc settings using the GUI configuration mechanisms
* Save the customized configuration using the script `sdm-collect-labwc-config`
* Copy the directory of saved configurations as needed for use in sdm customizations
* Add the `labwc` plugin with the `all-config` argument and directory with the collected config files to your sdm command line
* The specified files will be copied into the IMG during Phase 0, when both the host and IMG are acessible
* The files will be moved to the correct directory locations in /home/*user*/.config during Phase 1
* When you boot your newly-created customized image, your settings will be in place

If the target IMG does not have Labwc installed no changes will be made, although the files will be copied to /etc/sdm/assets/labwc

NOTE: the `labwc` plugin takes other arguments as well. See <a href="Plugins.md#labwc">labwc plugin documentation</a> for complete details.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
