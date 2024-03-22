# Disks and Partitions

This is a collection of disk and partition-related information relative to sdm.

sdm doesn't have any specific issues with various disk drives and formats.

sdm does need to know about partition numbers, and it can correctly handle the partition names on mmcblk\* and nvme0n\* disks as well as /dev/sd\*

sdm supports RasPiOS disks with two partitions: a FAT32 bootfs (partition 1) and an ext4 rootfs (partition 2), that is, the standard RasPiOS IMG files up through Bookworm.

By default sdm `--burn` will do an image copy of the IMG file to the burn disk with `dd`, so the burned disk is MBR format with a FAT32 bootfs and an ext4 rootfs. When the system boots, RasPiOS will expand the rootfs partition to fill the disk. In other words, a standard RasPiOS bootable disk.

There are a few switches that change the burn function with respect to disks and partitions.

* `--gpt` &mdash; Convert the burned disk to GPT partition format
* `--burn-plugin parted` &mdash; Use the `parted` burn plugin to do disk partitioning functions after the burn has completed. See <a href="Plugins.md">Plugins</a>
* `--convert-root` fmt &mdash; Convert the rootfs to a different file system, rather than ext4. See the next section
* `--expand-root` &mdash; sdm will expand the rootfs to the whole disk after burning
* `--no-expand-root` &mdash; sdm will not expand rootfs and will disable automatic RasPiOS rootfs expansion

## rootfs conversion

The `--convert-root` switch is used to specify a different rootfs file system format. Supported formats:
* `btrfs`
* `ext4`
* `lvm`

rootfs conversion requires that the files are copied via the file system (using rsync) rather than a block mode copy, which is inherently faster.

Using `--convert-root lvm` causes `--gpt` to be set.

## Example commands

* `sdm --burn /dev/sdc --convert-root btrfs --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; Burn the IMG to /dev/sdc with a `btrfs` file system for rootfs
* `sdm --burn /dev/sdc --gpt --expand-root /path/to/2023-12-05-raspios-bookworm-arm64.img` &mdash; Burn the IMG to /dev/sdc with a GPT partition table

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
