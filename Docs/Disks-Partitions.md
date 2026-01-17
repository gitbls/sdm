# Disks and Partitions

This is a collection of disk and partition-related information relative to sdm.

sdm doesn't have any specific issues with various disk drives and formats.

sdm does need to know about partition numbers, and it can correctly handle the partition names on mmcblk\* and nvme0n\* disks as well as /dev/sd\*

sdm supports RasPiOS disks with two partitions: a FAT32 bootfs (partition 1) and an ext4 rootfs (partition 2), that is, the standard RasPiOS IMG files up through Bookworm.

By default sdm `--burn` will do an image copy of the IMG file to the burn disk with `dd`, so the burned disk is MBR format with a FAT32 bootfs and an ext4 rootfs. When the system boots, RasPiOS will expand the rootfs partition to fill the disk. In other words, a standard RasPiOS bootable disk.

There are a few switches that change the burn function with respect to disks and partitions.

* `--gpt` &mdash; Convert the burned disk to GPT partition format
* `--burn-plugin parted` &mdash; Use the `parted` burn plugin to do disk partitioning functions after the burn has completed. See <a href="Plugins.md">Plugins</a>
* `--convert-root` fmt[,[+]size] &mdash; Convert the rootfs to a different file system, rather than ext4. See the next section
* `--expand-root` &mdash; sdm will expand the rootfs to the whole disk after burning
* `--no-expand-root` &mdash; sdm will not expand rootfs and will disable automatic RasPiOS rootfs expansion

## rootfs conversion

The `--convert-root` switch is used to specify a different rootfs file system format. Supported formats:
* `btrfs`
* `ext4`
* `lvm`

rootfs conversion requires that the files are copied via the file system (using rsync) rather than a block mode copy, which is inherently faster.

However, GPT partition tables are more extensible and are the partition type for the future. Using `--gpt` without `--convert-root` is equivalent to adding `--convert-root ext4`.

Using `--convert-root lvm` causes `--gpt` to be set.

Perhaps someday the RasPiOS team will switch to using GPT partition format for their IMGs.

The `--convert-root` switch takes an optional argument `size`, which specifies the new size for the rootfs (if used with only the size) or the size by which to increase the rootfs size (if used with `+`).

## Example commands

* `sdm --burn /dev/sdc --convert-root btrfs --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; Burn the IMG to /dev/sdc with a `btrfs` file system for rootfs
* `sdm --burn /dev/sdc --convert-root btrfs,8192 --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; As above, but make rootfs 8192MB (8GB)
* `sdm --burn /dev/sdc --convert-root btrfs,+8192 --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; As above, but increase the size of rootfs by 8192MB
* `sdm --burn /dev/sdc --gpt --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; Burn the IMG to /dev/sdc with a GPT partition table

## Device names

In Linux *old-style* device names were more like **/dev/sda** or **/dev/sdb**, and partitions were a number added to the end of the disk (e.g., **/dev/sda1**). Newer devices, such as **/dev/mmcblk0** and **/dev/nvme0** have added a controller number to the device name. For instance **/dev/nvme0** is the first NVMe disk and **/dev/nvme1** is the second NVMe disk.

sdm needs to know about *special* device names such as `mmcblk` and `nvme` in order to refer to partitions correctly. It has built-in knowledge of these two disk type names. If you need to add an additional disk type name (e.g., `nbd`), follow these steps:
* On the **host** system where you run sdm, sudo edit /etc/sdm/cparams and add a new parameter at the end:
```
xspdev:"nbd"
```
This directs sdm to treat `nbd` as a special device name so you can refer to **/dev/nbd0** for the first `nbd` device, **/dev/nbd1** for the second device, etc. Partitions on this device will be named **/dev/nbd0p1**, that is, treated exactly like `mmcblk` and `nvme`.

You can enable multiple such names with:
```
xspdev:"nbd xyz"
```

## rootfs expansion

sdm provides control over the rootfs expansion, whereas rpi-imager always expands the rootfs during an early first boot of the OS.

Supported scenarios include:

* **Expand rootfs after burning the disk.** Use `--expand-root`. The system will boot with the rootfs fully-expanded.
* **Do not expand rootfs after burning the disk.** Use `--no-expand-root`. You can perform further partition manipulation using the `parted` plugin on the burn command such as: resize rootfs, add additional partitions, etc.
* **Expand rootfs the same way that rpi-imager does.** Do not add any rootfs expansion-related switches to the command line. The system will boot and immediately expand the rootfs, regenerate SSH keys, and reboot. You must define at least one user with the `user` plugin and include `--plugin disables:piwiz` on either the customize or burn command.
* **Expand rootfs at first system boot.** (Trixie and later). You must also either use `--regen-ssh-host-keys` or `--plugin sshhostkey:generate-keys`.

In the first two cases, you should include `--regen-ssh-host-keys` on either the customize or burn command or use the `sshhoskey` plugin to ensure that the SSH host keys are generated. If you do either of these in the third case (rpi-imager model) the SSH host keys will always be generated during the first (zeroth in sdm terms) system boot.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
