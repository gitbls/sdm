# Overview

This document collects together everything you need to know about first boot scripts and configuration files

## Statically-built boot scripts

Scripts placed in `/usr/local/sdm/1piboot/0*-*.sh` will be run automatically at system First Boot if `--bootscripts` is specified. These scripts are static in that they are copied from the host system into the IMG during customization, and sdm provides no way to update the file once it's customized into an IMG. It does, however, provide one way to implement your customization functionality.

Another way to run scripts at First system boot is via executable scripts placed in `/etc/sdm/0piboot/0*-*.sh` These scripts are run regardless of the `--bootscripts` state. These are typically used by Plugins and Custom Phase Scripts to delay running something until First system boot, rather than during customization. See <a href="Programming-Plugins-and-Custom-Phase-Scripts.md#handling-plugin-deferred-actions">Handling plugin deferred actions</a> for an example.


## Configuration files

sdm uses a couple of different configuration files to transmit configuration information from customization to the First Boot service.

## Statically-built configuration file

As above, this file is copied from the host system's `/usr/local/sdm/1piboot/1piboot.conf` into the IMG during customization, and processed at First system boot if there are any non-comment, non-blank lines in the file. See 1piboot/1piboot.conf on this GitHub or /usr/local/sdm/1piboot/1piboot.conf on your host system.

## Dynamically-built configuration file

The file `/etc/sdm/auto-1piboot.conf` is populated by sdm as needed during customization and processed at First system boot.

There are several plugins that implement some of their functionality by writing to auto-1piboot.conf. These include:

* `graphics` plugin &mdash; delayed_boot_behavior
* `raspiconfig` plugin &mdash; All settings
* `system` plugin &mdash; `fstab`, `service-enable` and `service-disable` functions

In addition, sdm will write the `delayed_boot_behavior` setting to auto-1piboot.conf if the IMG being customized has a known Display Manager (lightdm, xdm, or wdm) or Window Manager (LXDE). sdm will set the boot behavior for the First system boot to `console no login`, and during the First system boot then sets the boot behavior as specified in `delayed_boot_behavior` for subsequent system boots.
 <br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
