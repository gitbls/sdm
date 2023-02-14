# Troubleshooting

sdm places important files in the IMG in `/etc/sdm` that are used to control its operation and log status.

* *apt.log* contains all the apt command output (package installs) done during the SD Card creation

* *cparams* contains the parameters with which sdm was initially run on the image

* *history* is the log written by sdm

* *1piboot.conf* is the configuration file used when the IMG was customized

* *auto-1piboot* is used by sdm to implement settings that must be delayed until the FirstBoot service runs. See <a href="First-Boot-Service.md">First Boot Service</a>

* *custom.ized* tells sdm that the image has been customized. If this exists, sdm will not rerun Phase 0 unless you answer Y to the query at the start of customization. You can avoid the prompt by including the `--redo-customize` switch on the command line.

## Cleaning up dangling mounts and loop devices

sdm tries very hard to clean up after itself. If sdm runs to completion or is able to complete its cleanup handling, there will be no dangling mounts or dangling loop devices.

But, sometimes *stuff happens* and sdm is prevented from cleaning up.

### Dangling Mounts

If something is not working correctly, make sure that there are no dangling mounts in the running RasPiOS system. You can end up with a dangling mount if sdm terminates abnormally, either with an error (please report!) or via an operator-induced termination. If sdm is not running, you should see no "/mnt/sdm" mounts (identified with `sudo df'). 

You can unmount them by manually using `sudo umount -v /mnt/sdm/{boot,}`. This will umount /mnt/sdm/boot and then /mnt/sdm. You'll need to delete the dangling loop device also.

### Dangling Loop devices

A couple of quick notes on loop devices, which are used to mount the IMG file into the running system.

* `losetup -a` lists all in-use loop devices

* `losetup -d /dev/loopX` deletes the loop device /dev/loopX (e.g., /dev/loop0). You may need to do this to finish cleaning up from dangling mounts (which you do first, before deleting the loop device).

* If your system doesn't have enough loop devices, you can increase the number by adding max_loop=n on end of /boot/cmdline.txt and reboot.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
