# fstab

sdm does not touch the lines in /etc/fstab created by RasPiOS. You may want to append one or more lines to /etc/fstab to set up other mounts, such as SMB, NFS, etc, and smb provides a couple of different ways to handle importing and appending your custom /etc/fstab into your image.

One way to do this is via a Custom Phase Script. In your Custom Phase Script, your Phase 0 code copies the fstab extension file into the IMG somewhere. Then, your Phase 1 code appends the copied fstab extension to the etc/fstab.

One drawback with this approach is that your fstab additions will be processed during the system FirstBoot. Network timeouts, etc could be an issue. This can be solved by using a Custom bootscript to append your custom fstab file to /etc/fstab.

That's exactly what `--fstab` does for you, and eliminates the need to use a Custom bootscript to update fstab.

sdm copies the file you provide to /etc/sdm/assets in the IMG, and then processes that during the system FirstBoot, by appending it to /etc/fstab.

**NOTE:** No matter which mechanism you use, you'll need to create the mount point directories in the image during Phase 1 using a Custom Phase Script.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
