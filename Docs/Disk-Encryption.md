# rootfs Disk Encryption

One tool that can be used to increase system security is encryption. This article discusses using sdm to configure encryption for the rootfs partition on a Raspberry Pi system disk. This makes the loss of a disk far less of a problem, since the content cannot be read, nor can the disk be booted,  without knowing how to decrypt the partition either with a passphrase, Yubikey, or a USB Keyfile Disk.

Although encryption does increase security, there are some challenges, such as:

* The rootfs passphrase must be typed **on the console** *every* time the Pi reboots, but you can also use a Yubikey or a USB Keyfile Disk, or enter the passphrase remotely via SSH. sdm fully supports both methods. Details below.
* rootfs encryption does not make the running system any more secure
* This tool does not provide any way to undo disk encryption if you decide you don't want it
  * You'll have to rebuild the system disk
  * ***Good news:*** If you're using sdm to create your customized IMG, rebuilding your disk is much less of an issue

With those caveats, if rootfs encryption is useful for you, sdm makes it quite simple to configure and use an encrypted rootfs.

**NOTES**

* This tool only supports sdm-integrated encryption configuration using the `cryptroot` plugin on RasPiOS Bookworm and later. `sdm-cryptconfig` can be used on already-running RasPiOS systems as well as on Debian Bookworm (arm and X86_64) and derivatives.

* Your system MUST be fully updated with apt before starting the encryption process documented here (`sudo apt update ; sudo apt full-upgrade`)

* Since the encryption process is not reversible you are encouraged to try the process on a COPY of your system disk or a freshly burned/updated disk to ensure you fully understand the process

## Overview

There are many articles about rootfs disk encryption on the Internet. If you're interested in learning more about it, your favorite search engine will reveal a bazillion articles on the subject.

Additionally, <a href="https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup">this Wikipedia article</a> discusses LUKS encryption, which is utilized to encrypt your rootfs.

sdm supports enabling rootfs encryption configuration in two different ways:

* sdm-integrated, using the `cryptroot` plugin
* Standalone on RasPiOS and Debian Bookworm and later without needing all of sdm by using `sdm-cryptconfig` on your running system

These two methods are discussed in the following sections.

This tool supports multiple methods of unlocking the encrypted rootfs. These include:
* **Passphrase** &mdash; When the system boots the passphrase must be provided to the prompt on the console. The passphrase can also be provided if <a href="Disk-Encryption.md#ssh-and-initramfs">SSH was configured into the initramfs</a>
* **Keyfile** &mdash; A <a href="Disk-Encryption.md#unlocking-rootfs-with-a-usb-keyfile-disk">keyfile</a> on a USB disk can unlock the rootfs
* **Yubikey** &mdash; A <a href="Disk-Encryption.md#unlocking-rootfs-with-a-yubikey"> Yubikey </a> can unlock the rootfs

Passphrase on the console is the default and madatory method. Keyfile and Yubikey are optional, but only one of Keyfile or Yubikey can be enabled. Specifically, enabling the Yubikey will render any configured keyfile ignored.

SSH unlock can be used in any configuration.

## sdm-Integrated rootfs Encryption Configuration

### Terse Description
The system reboots a couple of times, performing steps during each reboot:

* **First system boot:** At the end, the `sdm-firstboot` service runs, which completes sdm system configuration and reboots
  * An sdm FirstBoot script, `/etc/sdm/0piboot/099-enable-auto-encrypt.sh` runs and configures the service `sdm-auto-encrypt` to run on reboot
* **Second boot:** At the end of system startup, the `sdm-auto-encrypt` service runs which reconfigures the system for encryption and reboots
  * The `sdm-auto-encrypt` service runs `sdm-cryptconfig` to configure the system for encryption and configures the `sdm-cryptfs-cleanup` service
* **Third boot:** System startup drops into initramfs to perform the encryption process
  * In initramfs you use the `sdmcryptfs` command to encrypt rootfs
  * Upon initramfs exit, system continues booting
  * At end of system startup the `sdm-cryptfs-cleanup` service tidies sdm-related services on the running system, removes sdmcryptfs-related bits from the initramfs, and then reboots

    **NOTE:** You MUST wait for this stage to automatically reboot or the encryption will fail
* **Final reboot:** System is now running on an encrypted rootfs
  * All system boots now require the rootfs unlock passphrase, Yubikey, or USB Keyfile Disk to continue

### Details

When customizing an IMG or burning an IMG to an SSD/SD Card, you can start the encryption configuration process by using the `cryptroot` plugin. See <a href="Plugins.md#cryptroot">cryptroot plugin documentation</a> for details on the `cryptroot` plugin. This plugin performs several steps:

* Installs the required crypto software: `cryptsetup`, `cryptsetup-initramfs`, and `cryptsetup-bin`
* Configures sdm to create and run the `sdm-auto-encrypt` service after the system has fully completed the sdm FirstBoot process
* Provides an overview of what steps will be taken to encrypt your system's rootfs

The `sdm-auto-encrypt` service runs the script `sdm-cryptconfig` with arguments indicating that it should operate in sdm-integrated mode. See below for details on sdm-cryptconfig.

sdm-integrated rootfs encryption is nearly fully automatic if you use the sdm switch `--restart`. From the time you first boot your newly-burned disk you'll only need to type 2 commands, both when running in initramfs:
* A command to encrypt rootfs (see below)
* `exit`, to exit the initramfs and continue the system boot on a newly-encrypted rootfs

All other steps are done automatically.

## Standalone rootfs Encryption Configuration

If your RasPiOS system was not built with sdm *(why not?)*, or if your distro is Debian Bookworm-based (or later) you can still use a single sdm script to encrypt your rootfs: `sdm-cryptconfig`.

When your system is running, simply download and run sdm-cryptconfig:
```
# sdm-make-luks-usb-key and sdm-add-luks-key are only needed if you want to use a USB Keyfile Disk
sudo curl --fail --silent --show-error -L https://github.com/gitbls/sdm/raw/master/sdm-make-luks-usb-key -o /usr/local/bin/sdm-make-luks-usb-key
sudo curl --fail --silent --show-error -L https://github.com/gitbls/sdm/raw/master/sdm-add-luks-key -o /usr/local/bin/sdm-add-luks-key
sudo chmod 755 /usr/local/bin/sdm-add-luks-key /usr/local/bin/sdm-make-luks-usb-key

# sdm-cryptconfig is required for rootfs encryption
sudo curl --fail --silent --show-error -L https://github.com/gitbls/sdm/raw/master/sdm-cryptconfig -o /usr/local/bin/sdm-cryptconfig
sudo chmod 755 /usr/local/bin/sdm-cryptconfig
sudo sdm-cryptconfig [optional switches; see below]
```

## The sdm-cryptconfig Script

`sdm-cryptconfig` performs all necessary configuration before the rootfs can be encrypted:

* Downloads the script `sdmcryptfs` from Github to /usr/local/bin if it's not present on the system (sdm-enhanced systems will already have it)
* Ensures the required disk crypto software is installed: `cryptsetup`, `cryptsetup-initramfs`, and `cryptsetup-bin`
* If SSH access to initramfs was requested, `dropbear-initramfs` and `dropbear-bin` are also installed
* Updates the initramfs configuration to enable encrypting rootfs (primarily `bash` and `sdmcryptfs`)
* Builds the updated initramfs with encryption support
* Updates /boot/firmware/cmdline.txt, /etc/crypttab, and /etc/fstab for an encrypted rootfs
* If sdm-cryptconfig was run via the cryptroot sdm plugin or if `--reboot` specified, the system will automatically reboot
  * If not, reboot the system manually when you are ready to proceed

### sdm-cryptconfig Switches

sdm-cryptconfig has several switches. When using sdm-integrated rootfs encryption the `cryproot` plugin takes care of setting the appropriate switches, based on the arguments to the plugin. All switches are optional.

Switches to sdm-cryptconfig include:

* `--authorized-keys authkeyfile` &mdash; Specifies an SSH *authorized_keys* file to use in the initramfs. Required with `--ssh`
* `--crypto crypt-type` &mdash; Specifies the encryption to use. `aes` used by default, which uses `aes-xts-plain64`. Use `xchacha` on Pi4 and earlier for best performance. See Encryption/Decryption performance comparison below.
* `--dns dnsaddr` &mdash; Set IP Address of DNS server
* `--gateway gatewayaddr` &mdash; Set IP address of gateway
* `--hostname hostname` &mdash; Set hostname
* `--ipaddr ipaddr` &mdash; set IP address to use in initramfs
* `--keyfile /path/to/keyfile` &mdash; A keyfile used for passphrase-less booting. See <a href="Disk-Encryption.md#unlocking-rootfs-with-a-usb-keyfile-disk">Unlocking rootfs with a USB Keyfile Disk</a> for details
* `--mapper cryptmapname` &mdash; Set cryptroot mapper name [Default: cryptroot]
* `--mask netmask` &mdash; Set network mask for initramfs
* `--no-expand-root` &mdash; Do not expand the rootfs at the end of sdmcryptfs
* `--no-last-reboot` &mdash; Don't do final reboot after sdm-cryptfs-cleanup
* `--nopwd` &mdash; Do not configure passphrase unlock; a keyfile is required
* `--quiet` &mdash; Keep graphical desktop startup quiet (see 'known issues' below)
* `--reboot` &mdash; Reboot the system (into initramfs) when sdm-cryptconfig is complete
* `--ssh` &mdash; Enable SSH in initramfs. Requires `--authorized-keys` to provide an authorized keys file for SSH security
* `--sshbash` &mdash; Leave bash enabled in the SSH session rather than switching to the captive `cryptroot-unlock` (DEBUG only!)
* `--sshport portnum` &mdash; Use the specified port rather than the Default 22
* `--sshtimeout secs` &mdash; Use the specified timeout rather than the Default 3600 seconds
* `--sdm` &mdash; sdm `cryptroot` plugin sets this. Not for manual use
* `--tries n` &mdash; Set the number of retries to decrypt rootfs before giving up [Default: 0 (infinite)]
* `--unique-ssh` &mdash; Use a different SSH host key in initramfs than the host OS SSH key
* `--wifi-password` &mdash; Specify WiFi password for the WiFi connection
* `--wifi-ssid` &mdash; Enable WiFi in initramfs and specify the connection's SSID (Requires: `--ssh`, `--authorized-keys`, and `--wifi-password`)
* `--wifi-use-psk` &mdash; Convert WiFi password to a WPA hased PSK in wpa_supplicant.conf. The WiFi password is not recorded anywhere.

The network configuration switches (`dns`, `gateway`, `hostname`, `ipaddr`, and `mask`) are only needed and should only be used if you know that the system is unable to get an IP address and network configuration information from the network (e.g., via DHCP). These settings are ONLY used in the initramfs if SSH is enabled and are not automatically removed.

WiFi in initramfs only uses DHCP so the network configuration switches are ignored for an initramfs  WiFi connection.

A fully-booted RasPiOS system uses a different mechanism to configure a static network, such as Network Manager, systemd-networkd, or other network configuration tools.
  
## initramfs

initramfs is one of the first programs run during a RasPiOS system boot. Since the system has been configured to use an encrypted rootfs, initramfs will try to boot using that configuration, and it will fail.

But not for lack of trying! initramfs will try to open the encrypted disk 30 (!) times before it gives up, reports an error, and prompts with:
```
(initramfs)
```
At this point, you need to know two important details:
* The name of your system disk, which will most likely be `/dev/mmcblk0` (integrated SD reader), `/dev/sda` (a USB-connected disk), or `/dev/nvme0n1` for an NVME disk
* The name of the scratch disk, which must be larger than the *used* space on your rootfs. sdm-cryptconfig will tell you what size this must be

If using a USB-connected scratch disk, it's best to not plug it in until you are at the (initramfs) prompt, because log messages will tell you the name of the disk you just plugged in.

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
  * You will then be prompted to provide the passphrase for $rootfs unless `nopwd` was specified
  *  **Be sure that your CapsLock is set correctly (in case you changed it to type YES)!!!**
* After a short pause you'll be prompted for the passphrase again to unlock the now-encrypted rootfs unless `nopwd` was specified
* If you provided an encryption keyfile to `sdm-cryptconfig` or the `cryptroot` plugin it will be installed into the encrypted rootfs
* The saved rootfs content will be restored from /dev/sdX to the encrypted rootfs
* When the restore finishes sdmcryptfs will exit and drop you to the (initramfs) prompt
* Type `exit` to continue the boot sequence
* Once the system boot has completed the sdm-cryptfs-cleanup service will run which:
  * Removes some content that is no longer needed (`bash` and `sdmcryptfs`) and rebuilds initramfs
  * **NOTE:** You MUST wait for this stage to automatically reboot or the encryption will fail
  * Automatically reboots the system one last time
* As the system reboots you'll once again be prompted for the rootfs passphrase
  * **NOTE:** Without the 30 tries!
  * If using a Yubikey or USB Keyfile Disk, plug it in at any time
* The system will now ask for the rootfs passphrase like this (or use the Yubikey or USB Keyfile Disk) every time the system boots

**Do not lose or forget the rootfs passphrase. It is not possible to unlock the encrypted rootfs without a configured Yubikey, USB Keyfile Disk or rootfs passphrase**

### Sample initramfs/sdmcryptfs Console Interaction
Lines not preceded by `> yyyy-mm-dd hh:mm:ss` are the output of programs (dd, cryptsetup, resize2fs) that are run by sdmcryptfs. The date/time may be incorrect if the system doesn not have a battery backed up clock.

```
(initramfs) sdmcryptfs /dev/sda /dev/sdb
> 1970-01-01 00:00:59 Shrink partition /dev/sda2 and get its size
> 1970-01-01 00:01:17 Device ‘/dev/sda’ rootfs size 743448 4K blocks (3.0GB; 2.86GiB)
> 1970-01-01 00:01:17 Save rootfs '/dev/sda2' to /dev/sdb
> 1970-01-01 00:01:17 rootfs Save should take less than 3 minutes
743448+0 records in
743448+0 records out
> 1970-01-01 00:02:04 Enable luks2 encryption on '/dev/sda2'
> 1970-01-01 00:02:04 OK to ignore superblock signature warning
> 1970-01-01 00:02:04 Enabling encryption could take up to a minute or two
WARNING: Device /dev/sda2 already contains a 'ext4' superblock signature.
WARNING!
=========
This will overwrite data on /dev/sda2 irrevocably.

Are you sure? (Type ‘yes’ in capital letters): YES
Enter passphrase for /dev/sda2:
Verify passphrase:
Ignoring bogus optimal-io size for data device (33553920 bytes).
> 1970-01-01 00:03:31 Unlock encrypted partition ‘/dev/sda2’
> 1970-01-01 00:03:31 Unlock will take several seconds
Enter passphrase for /dev/sda2:
> 1970-01-01 00:03:41 Restore ‘/dev/sda2’ from /dev/sdb
> 1970-01-01 00:03:41 rootfs Restore should take about the same time as the rootfs Save
743448+0 records in
743448+0 records out
> 1970-01-01 00:04:53 Restore complete; Expand rootfs…
Resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/mapper/cryptroot to 117076694 (4k) blocks.
The file system on /dev/mapper/cryptroot is now 117076694 (4k) blocks long.

> 1970-01-01 00:04:56 rootfs partition size: 479546138624 Bytes (479.5GB, 446.6GiB)

Enter the 'exit' command to resume the system boot

(initramfs) exit
```

## SSH and initramfs

If the Pi is *headless* (no keyboard/video/mouse) it is quite difficult (OK, it's impossible or close to it) to unlock the rootfs partition. There are two solutions that you can use with sdm's encrypted rootfs support. You can:

* Use a Yubikey or USB Keyfile Disk (described in following sections).
* Enable SSH in the initramfs. When the system boots you can SSH into the initramfs and you'll be prompted for the rootfs unlock passphrase. After you enter it correctly, the system boot will proceed.

SSH can also be used during the initial rootfs encryption process, discussed in the next section. Everything works exactly the same as if you are sitting on the console, with the exception that log entries (e.g. plugging in a disk) do not show up in the SSH session.

You can use `parted -l` in the initramfs to determine which disks are plugged in to decide, for example, what scratch disk to use with `sdmcryptfs`.

Note that once you've enabled SSH in the initramfs, sdm does not provide an easy way to disable it. That said, it is typically not active for very long, and once encryption has been configured, by default the SSH port is locked down to only prompting for the unlock passphrase.

`sdm-cryptconfig` switches relevant for SSH are:

* `--authorized-keys keyfile` &mdash; Specifies an SSH authorized_keys file to use in the initramfs. This is required with SSH, since there is no password authentication in initramfs
* `--sshbash` &mdash; Leave bash enabled in the SSH session rather than switching to the captive `cryptroot-unlock`. This is a security hole, so use for DEBUG ONLY.
* `--sshport portnum` &mdash; Use the specified port rather than the Default 22
* `--sshtimeout secs` &mdash; Use the specified timeout rather than the Default 300 seconds
* `--unique-ssh` &mdash; Use a different SSH host key in the initramfs. The default is to use the host OS SSH key
* Network configuration settings &mdash; You may need to use some or all of these depending on your network configuration

Note that if SSH is enabled in initramfs, you can also SSH into the initramfs to perform the initial configuration (sdmcryptfs). As part of the post-encryption cleanup, this capability is removed in favor of only being able to enter the decryption passphrase.

### Add SSH to an already-encrypted system

If you encrypted your rootfs but didn't add SSH and now wish you did, you can! On your running, rootfs encrypted system:
```
sudo /usr/local/sdm/sdm-ssh-initramfs --authorized-keys /path/to/ssh/authorized_keys
```
sdm-ssh-initramfs will install and configure dropbear, and then rerun `update-initramfs -u`. After it completes, reboot the system, and the SSH server will be active, and you'll be able to unlock the encrypted rootfs over the network using SSH with a key that is accepted in the authorized_keys file.

sdm-ssh-initramfs has a few other configuration switches. They are documented above at <a href="#sdm-cryptconfig-switches">sdm-cryptconfig switches</a>. sdm-ssh-initramfs supports the `--authorized-keys`, `--dns`, `--gateway`, `--hostname`, `--ipaddr`, `--mask`, and `--unique-ssh` switches.


### SSH and initramfs notes

Things to know when using SSH as documented here:

* You must specify the username `root`. This is ***important***, as that's how SSH is configured in the initramfs
* You can use `ssh root@hostname` if DNS (not MDNS) on your network is set up correctly for resolving local host names.
* You will not be able to SSH using ".local" names when initramfs SSH is running; avahi is not running in the initramfs so the system is unknown to MDNS (that's the protocol that is used for ".local")
* If your local network does not have a properly-configured DNS server (<a href="https://github.com/gitbls/ndm">example</a>), you'll need to use `ssh root@ip.ad.dd.rs`
* WiFi is not supported for the SSH initramfs connection

## Unlocking rootfs with a Yubikey

The Yubikey is a cryptographic USB device that can be used to unlock the rootfs.

The yubikey can unlock the encrypted rootfs automatically if present. If this is not desired, specify the `--noautounlock` switch to `sdm-yubi-config` and the initramfs code will prompt for the Yubikey passphrase.

### Enabling the rootfs for Yubikey unlock

First, fully configure encryption on the system using `sdm-cryptconfig` as documented above. Once that has completed and the system is fully operational, you can add Yubikey unlock as a second method to unlock rootfs.

The sdm script `sdm-yubi-config` will configure your encrypted rootfs to be unlockable with a Yubikey. Like sdm-cryptconfig, sdm-yubi-config does not require sdm to be installed.

sdm-yubi-config switches include:

* `--initialize` &mdash; Initialize the Yubikey slot. If not specified the slot must be previously configured
* `--luks-phrase` &mdash; Specifies the configured Luks unlock phrase
* `--luks-slot` &mdash; Specifies the Luks slot to use [Default:2]
* `--mapper` &mdash; Specifies the cryptroot mapper name [Default:cryptroot]
* `--noautounlock` &mdash; Do not automatically unlock rootfs; prompt for Yubikey passphrase [Default:autounlock]
* `--yubi-phrase` &mdash; Specifies the Yubikey passphrase
* `--yubi-slot` &mdash; Specifies the Yubikey slot to use [Default:2]

All switches are optional. sdm-yubi-config will prompt for the Luks passphrase and the Yubikey passphrase if not provided on the command line.

You must reboot the system after sdm-yubi-config completes.

NOTE: Yubikey unlock and USB Keyfile unlock are mutually exclusive. Only one can be configured.

### Using the Yubikey

When the system with a Yubikey-enabled encrypted rootfs boots, there are a few different possible scenarios. In all scenarios the Yubikey can be removed after the encrypted rootfs is unlocked.

* Autounlock enabled and Yubikey inserted
  * Non-stop boot &mdash; The system will use the autounlock-enabled Yubikey passphrase to unlock the rootfs
* Autounlock and yubikey not inserted
  * A prompt will ask if you want to use the yubikey
    * If **Y** (default), waits until the Yubikey is inserted then proceeds to unlock the encrypted rootfs
    * If **N**, the system will prompt for the Luks passphrase (the passphrase used when the rootfs was initially encrypted)
* No autounlock and Yubikey inserted
  * A prompt will request the Yubikey passphrase
* No autounlock and Yubikey not inserted
  * A prompt will ask if you want to use the yubikey
    * If **Y** (default), a prompt will request the Yubikey passphrase, then waits until the Yubikey is inserted, and then unlocks the encrypted rootfs
    * If **N**, the system will prompt for the Luks passphrase (the passphrase used when the rootfs was initially encrypted)

In all the above scenarios, passphrases that are typed are not echoed on the console. If a passphrase is mistyped, power-cycle the system and try again. Since no disks are mounted, there is no possibility of disk corruption.

## Unlocking rootfs with a USB Keyfile Disk

Instead of typing the rootfs passphrase every boot you can use a USB Keyfile Disk to unlock the rootfs.

### Creating a USB Keyfile Disk

Use `sudo /usr/local/sdm/sdm-make-luks-usb-key` on a host system to create a USB keyfile disk and key. `sdm-make-luks-usb-key` takes one argument, the name of an unmounted disk where the keyfile will be written. The disk will be re-partitioned with a small FAT32 partition.

Use `--init` for the first key you create and save to the USB Keyfile Disk. If you add additional keys to the disk (for the same or other systems), only use `--init` if you intend to delete ALL keys already on the disk.

Switches include:

* `--ext4` &mdash; Also create a small second partition, formatted as ext4
* `--hidden` &mdash; Create a GPT formatted disk and tag the partition as EFI. It will not be readable on Windows. Requires `--init`
* `--hostname hname` &mdash; Add this key to the file `hostkeys.txt` on the USB Keyfile Disk. This is handy if you have multiple keys on the disk.
* `--init` &mdash; Re-initialize the USB disk and re-create the FAT32 partition
* `--keyfile /path/to/keyfile` &mdash; Add an existing keyfile to the USB Keyfile disk rather than creating a new one

### Using the USB Keyfile Disk

The `sdmluksunlock` initramfs script continuously scans the available USB drives for the required USB Keyfile disk, so you can insert the disk at any point. It may take a few seconds for the disk to be recognized and scanned, and then it will take several more seconds to unlock the rootfs and continue the system boot.

### USB Keyfile Disk Usage Notes

* In addition to writing the USB Keyfile Disk, `sdm-make-luks-usb-key` also places a copy of the newly-created encryption key file in `/root/big-long-uid.lek`.

  You may find it handy for use during customization runs, but once a USB Keyfile Disk has been successfully created, you can `sudo rm -f /root/big-long-uid.lek`, or `*.lek` to delete them all.

### Adding a USB Keyfile to an Already-Encrypted rootfs

If your rootfs is already encrypted with a passphrase, but no keyfile, you can easily add a keyfile to it:
* Create the USB keyfile disk
  * This can be done on any host and writes the keyfile to a USB disk. See above <a href="Disk-Encryption.md#creating-a-usb-keyfile-disk">Creating a USB Keyfile Disk</a>
* Add the USB keyfile on the host with the encrypted rootfs (on the system running with an encrypted rootfs):
```
sudo mount /dev/sdX /mnt
sudo /usr/local/sdm/sdm-add-luks-key /mnt/big-long-uuid.lek
sudo umount /mnt
```
* Reboot

## Exploring and Mounting Encrypted Disks

Encrypted disks can be explored or mounted with the `--encrypted` switch.

If a keyfile has been added to the encrypted disk you can use `--keyfile /path/to/keyfile.lek` to unlock the rootfs with a keyfile. `--keyfile` implies `--encrypted`.

sdm does not support using Yubikey to unlock an encrypted disk with the explore (`--explore`) or mount (`--mount`) commands.

## Encryption Performance

As mentioned above, it's best to use `aes` encryption on the Pi5, which has built-in crypto instructions. All other Pis lack these instructions, so `xchacha` is recommended for them.

### Encryption/Decryption Performance Comparison

Here's a performance comparison on a Pi5, first showing `xchacha`, then `aes`. As you can see, `aes` encryption is more than twice as fast as `xchacha`, and more than 4 times as fast on decryption.
```
pw/ssdy/work$ sudo cryptsetup benchmark -c xchacha20,aes-adiantum-plain64
# Tests are approximate using memory only (no storage IO).
#            Algorithm |       Key |      Encryption |      Decryption
xchacha20,aes-adiantum        256b       394.4 MiB/s       421.6 MiB/s

pw/ssdy/work$ sudo cryptsetup benchmark -c aes-xts-plain64
# Tests are approximate using memory only (no storage IO).
# Algorithm |       Key |      Encryption |      Decryption
    aes-xts        256b      1774.5 MiB/s      1836.1 MiB/s

pw/ssdy/work$ sudo cryptsetup benchmark -c aes-cbc-essiv:sha256 
# Tests are approximate using memory only (no storage IO).
# Algorithm |       Key |      Encryption |      Decryption
    aes-cbc        256b       923.4 MiB/s      1895.6 MiB/s
```

On a Pi4, the results are quite different. Using `xchacha` is more than twice as fast as `aes` on both encryption and decryption.
```
p84~$ sudo cryptsetup benchmark -c xchacha20,aes-adiantum-plain64
# Tests are approximate using memory only (no storage IO).
#            Algorithm |       Key |      Encryption |      Decryption
xchacha20,aes-adiantum        256b       170.9 MiB/s       180.0 MiB/s

p84~$ sudo cryptsetup benchmark -c aes-xts-plain64 
# Tests are approximate using memory only (no storage IO).
# Algorithm |       Key |      Encryption |      Decryption
    aes-xts        256b        87.5 MiB/s       108.4 MiB/s

p84~$ sudo cryptsetup benchmark -c aes-cbc-essiv:sha256 
# Tests are approximate using memory only (no storage IO).
# Algorithm |       Key |      Encryption |      Decryption
    aes-cbc        256b        68.8 MiB/s        81.3 MiB/s
```

## btrfs rootfs notes

sdm can be used to create an encrypted rootfs with the btrfs file system.

* Use the `--convert-root btrfs` when burning the disk.
* If you want the rootfs to fill the remainder of the disk, add `--expand-root` to the burn command.
* If you prefer more precise control on the size of the rootfs:
  * Use `--convert-root btrfs,8192` to request an 8GB btrfs rootfs
  * Use `--convert-root btrfs,+8192` to request an additional 8GB be added to the btrfs rootfs
  * With either of the above, if you want to utilize the space beyond the rootfs, be sure to add `--no-expand-root` to the burn command
  * In cases where the encrypted rootfs is not expanded to fill the disk sdmcryptfs will increase the rootfs partition size to accomodate the LUKS overhead
* When used in conjunction with `--plugin cryptroot` on the burn command, rootfs expansion is deferred until after the rootfs has been encrypted.

  This is useful so all those empty blocks in the btrfs expanded rootfs don't need to be copied. This is not an issue for ext4 filesystems since the file system data can be shrunk before copying.

## Known Issues

* To use disk encryption on disks other than rootfs that you have manually encrypted, remove `luks.crypttab=no` from /boot/firmware/cmdline.txt

* When running RasPiOS with Desktop (both X11 and Wayland) sdm-cryptconfig will unconditionally make these adjustments to your system:
  * Remove 'quiet' and 'splash' from /boot/firmware/cmdline.txt, making the system boot far less quiet
  * Disable the plymouth splash screen
  * Configure the system so that the boot following the disk encryption boots to the CLI
    * The systemd service `sdm-cryptfs-cleanup` restores the boot to graphical desktop

  The above changes are made to ensure that you have full visibility into what's happening in the boot process. You can override these changes with the sdm-cryptconfig `--quiet` switch.

  After the system has fully completed the encryption process, if you want you can `sudoedit /boot/firmware/cmdline.txt` and add `quiet`. Do NOT add `splash` to cmdline.txt or the prompt for the unlock passphrase will not display. Also, if you want to re-enable plymouth, do the following once you're logged in:
```sh
for svc in plymouth-start plymouth-read-write plymouth-quit plymouth-quit-wait plymouth-reboot
do
    sudo systemctl unmask $svc
done
```

## Acknowledgement

Encryption configuration is based on https://rr-developer.github.io/LUKS-on-Raspberry-Pi. As of 2024-01-01 it predates Bookworm, but was very helpful in working out the initramfs configuration.


<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
