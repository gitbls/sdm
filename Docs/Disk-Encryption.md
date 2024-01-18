# rootfs Disk Encryption

One tool that can be used to increase system security is encryption. This article discusses using sdm to configure encryption for the rootfs partition on a Raspberry Pi system disk. This makes the loss of a disk far less of a problem, since the content cannot be read, nor can the disk be booted,  without knowing the rootfs password.

Although encryption does increase security, it is not a panacea. For instance, consider the following:

* The rootfs password must be typed *every* time the Pi reboots
* rootfs encryption does not make the running system more secure
* This tool does not provide any way to undo disk encryption if you decide you don't want it
  * You'll have to rebuild the system disk. **Good news:** if you're using sdm, rebuilding your disk is much less of an issue

With those caveats, if rootfs encryption is useful for you, sdm makes it extremely simple to configure an encrypted rootfs.

**NOTE:** This tool is only supported on RasPiOS Bookworm and later.

## Overview

There are many articles about rootfs disk encryption on the Internet. If you're interested in learning more about it, your favorite search engine will reveal a bazillion articles on the subject.

Additionally, <a href="https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup">this Wikipedia article</a> discusses LUKS encryption, which is utilized to encrypt your rootfs.

sdm supports rootfs encryption configuration two ways:

* sdm-integrated, using the `cryptroot` plugin
* Standalone on RasPiOS without needing sdm itself

These two methods are discussed in the following sections.

## sdm-integrated rootfs encryption configuration

When customizing an IMG or burning an IMG to an SSD/SD Card, you can start the encryption configuration process by using the `cryptroot` plugin. This plugin performs several steps:

* Installs the required crypto software: `cryptsetup`, `cryptsetup-initramfs`, and `cryptsetup-bin`
* Configures sdm to create and run the `sdm-auto-encrypt` service after the system has fully completed the first boot process
* Provides an overview of what steps will be taken to encrypt your system's rootfs

The `sdm-auto-encrypt` service runs the script `sdm-cryptconfig` with arguments indicating that it should operate in sdm-integrated mode. See below for details on sdm-cryptconfig.

sdm-integrated rootfs encryption is nearly fully automatic if you use the sdm switch `--restart`. From the time you first boot your newly-burned disk you'll only need to type 2 commands, both when running in initramfs:
* A command to encrypt rootfs (see below)
* `exit`, to exit the initramfs and continue the system boot on a newly-encrypted rootfs

All other steps are done automatically.

## Standalone rootfs encryption configuration

If your system was not built with sdm (why not?), you can still use a single sdm script to encrypt your rootfs: `sdm-cryptconfig`.

When your system is running, simply download and run sdm-cryptconfig:
```
sudo curl --fail --silent --show-error -L https://github.com/gitbls/sdm/raw/master/sdm-cryptconfig -o /usr/local/bin/sdm-cryptconfig
sudo chmod 755 /usr/local/bin/sdm-cryptconfig
sudo sdm-cryptconfig
```

## The sdm-cryptconfig script

sdm-cryptconfig performs all necessary configuration before the rootfs can be encrypted:

* Downloads the script `sdmcryptfs` from Github to /bin if it's not present on the system (sdm-enhanced systems will have it)
* If not an sdm-enhanced system, installs the required disk crypto software: `cryptsetup`, `cryptsetup-initramfs`, and `cryptsetup-bin`
* Updates the initramfs configuration to enable encrypting rootfs (primarily `bash` and `sdmcryptfs`)
* Builds the updated initramfs with encryption support
* Updates /boot/firmware/cmdline.txt, /etc/crypttab, and /etc/fstab for an encrypted rootfs
* If sdm-cryptconfig was run via the cryptroot sdm plugin, it will automatically reboot the system
  * If not, reboot the system manually when you are ready to proceed
  
## initramfs

initramfs is one of the first programs run during a RasPiOS system boot. Since the system has been configured to use an encrypted rootfs, initramfs will try to boot using that configuration, and it will fail.

But not for lack of trying! initramfs will try to open the encrypted disk 30 (!) times before it gives up, reports an error, and prompts with:
```
(initramfs)
```
At this point, you need to know two important details:
* The name of your system disk, which will most likely be `/dev/mmcblk0` (integrated SD reader) or `/dev/sda` (a USB-connected device)
* The name of the scratch disk, which must be larger than the *used* space on your rootfs. sdm-cryptconfig will tell you what size this must be

It's best to not plug in the scratch disk until you are at the (initramfs) prompt, because log messages will tell you the name of the disk you just plugged in.

With this information, you'll enter the command (for example):
```
(initramfs) sdmcryptfs /dev/mmcblk0 /dev/sda
```
This will cause sdmcryptfs to encrypt the rootfs on /dev/mmcblk0, using /dev/sda as a scratch disk.

sdmcryptfs will then:

* Print the size of the rootfs
* Save the contents of the rootfs to the scratch disk
* Enable encryption on the rootfs
  * You will be prompted to enter YES (all in upper case) to continue
  * You will then be prompted to provide the passphrase for $rootfs
  *  **Be sure that your CapsLock is set correctly (in case you changed it to type YES)!!!**
* After a short pause you'll be prompted for the passphrase again to unlock the now-encrypted rootfs
* The saved rootfs content will be restored from /dev/sdX to the encrypted rootfs
* When the restore finishes sdmcryptfs will exit and drop you to the (initramfs) prompt
* Type `exit` to continue the boot sequence
* Once the system boot has completed the sdm-cryptfs-cleanup service will run which:
  * Removes some content that is no longer needed (`bash` and `sdmcryptfs`) and rebuilds initramfs 
  * Reboots the system one last time
* As the system reboots you'll once again be prompted for the rootfs passphrase
  * NOTE: Without the 30 tries!
* The system will now ask for the rootfs passphrase like this every time the system boots

**Do not lose or forget the rootfs password. It is not possible to unlock the encrypted rootfs.**

This work is based on https://rr-developer.github.io/LUKS-on-Raspberry-Pi, which predates Bookworm, but was *extremely* helpful in puzzling out the initramfs configuration.

## Known issues

If you're using sdm to configure a graphical (X11) system, sdm normally delays starting the graphical environment until the 2nd reboot. When setting up encryption it still does this.

Unfortunately, the encryption process is still active, so you may be surprised to have the system reboot out from under your graphical environment if you jump on the keyboard quickly like I do.
