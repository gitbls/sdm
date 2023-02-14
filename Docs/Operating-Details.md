# Operating Details

sdm operates on the SD Card image in distinct phases:

* **Phase 0:** *Operating in the logical context of your host system, copying files into the RasPiOS IMG file.* sdm takes care of Phase 0 for you. The Phase 0 script `sdm-phase0` performs the Phase 0 copying. It will also optionally call a <a href="Custom-Phase-Script.md">Custom Phase Script</a> provided by you to perform customized personal steps. In addition, all <a href="Plugins.md">plugins</a> specified will be called for Phase 0.

* **Phase 1:** *Operating inside the IMG file container and in the context of that system (via systemd-nspawn or chroot)*. When operating in this context, all changes made only affect the SD Card IMG, not the host system on which sdm is running

    Most, but not all commands can be used in Phase 1. For instance, most `systemctl` commands don't work because systemd is not running in the nspawn'ed image. Importantly, however, `systemctl disable` and `systemctl enable` ***do*** work.

    Other functions you might want to do in Phase 1 include: add new users, set or change passwords, install packages, update configuration files, etc. In other words, you can do almost everything you want to configure a system for repeated SD card burns.

    Once sdm has started the nspawn container, it will automatically run `/usr/local/sdm/sdm-phase1` to perform Phase 1 customization. As with Phase 0, your optional Custom Phase Script will be called, as will selected plugins. After Phase 1 completes, sdm will provide a command prompt inside the container unless you specified `--batch`, in which case sdm will exit the container. **NOTE:** When sdm provides a command prompt, either with Phase 1 customization or with `--mount`, the terminal colors are changed (if your terminal supports it) to remind you that the IMG is mounted. See <a href="Terminal-Colors.md">Terminal Colors</a>.

* **Post-Install:** The post-install phase runs after Phase 1. In the post-install phase, custom phase scripts and selected plugins, which are both called, can count on all packages being installed, so that packages can be configured, etc.

* **Phase 3:** *Write the SD Card*. Using the `sdm --burn` command, the IMG is written to the new physical SD card using ***dd***, and the new system name is written to the SD card. *This enables a single IMG file to be the source for as many Pi systems as you'd like.* Of course, you can burn the SD Card using a different tool if you'd prefer, although you'll need to set the hostname with another mechanism.

    <a href="Plugins.md">Plugins</a> can be included on the burn command line, which will cause them to run Phase 0, phase 1, and post-install phase on the SD card.

* **Phase 4:** *Boot the newly-created SD card on a Pi*. When the new system boots the first time, the systemd service sdm-firstboot.service sets WiFi Country, and any device-specific settings you've enabled (see below), and then disables itself so it doesn't run on subsequent system boots.

Once the IMG is completed (Phase 0, Phase 1, and post-install), **Phase 3** and **Phase 4** can be repeated as often as needed to create fresh bootable devices for one or more of your Pi fleet, configured exactly as you want them to be.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
