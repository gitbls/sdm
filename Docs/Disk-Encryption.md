# At-rest Disk Encryption

One tool that can be used to increase system security is encryption. This article discusses using sdm to configure encryption for a partition on a Raspberry Pi system disk. This makes the loss or theft of a disk far less of a problem, since the content cannot be read without knowing how to decrypt the partition(s) either with a passphrase, Yubikey, USB Keyfile Disk, or Network Bound Disk Encryption (NBDE).

sdm supports any combination of an encrypted rootfs and/or encrypted data partitions.

sdm configures encrypted partitions using <a href="https://gitlab.com/cryptsetup/cryptsetup">cryptsetup LUKS disk encryption</a>, a core component of RasPiOS and Debian. cryptsetup is fully-documented and well-supported.

Although encryption does increase security, there are some challenges, such as:

* The rootfs passphrase must be typed **on the console** *every* time the Pi reboots. If you don't want to type a passphrase, you can use a Yubikey, a USB Keyfile Disk, or Network Bound Disk Encryption (NBDE) unlock.
* If you want to use a passphrase on a headless Pi, you can use SSH to enter the passphrase remotely. Details below
* At-rest encryption does not make the running system any more secure
* This tool does not provide any way to undo disk encryption if you decide you don't want it
  * You'll have to rebuild the system disk
  * ***Good news:*** If you're using sdm to create your customized IMG, rebuilding your disk is much less of an issue

With those caveats, if encryption is useful for you, sdm makes it quite simple to configure and use an encrypted rootfs and optionally one or more data partitions.

**NOTES**

* This tool only supports sdm-integrated encryption configuration using the `cryptroot` plugin on RasPiOS Bookworm and later. `sdm-cryptconfig` can be used on already-running RasPiOS systems as well as on Debian Bookworm (arm and X86_64) and derivatives.

* There is currently no standalone way to use the `cryptpart` plugin. It must be run via sdm (contrast with `sdm-cryptconfig` that does not require sdm installed). That said, sdm is quite easy to install and has a very small footprint.

* Yubikey unlock is only supported for the rootfs. Data partitions can be unlocked using a keydisk or a passphrase

* Network Bound Disk Encryption (NBDE) unlock is only supported for the rootfs.

* Your system MUST be fully updated with apt before starting the encryption process documented here (`sudo apt update ; sudo apt full-upgrade`)

* Since the encryption process is not reversible you are encouraged to try the process on a COPY of your system disk or a freshly burned/updated disk to ensure you fully understand the process

## Overview

There are many articles about rootfs disk encryption on the Internet. If you're interested in learning more about it, your favorite search engine will reveal a **bazillion articles** on the subject.

*"It's unbelievably hard to successfully encrypt your SD card using those articles. Don't even think about it. Use `sdm` instead."* &mdash; Actual sdm user

Additionally, <a href="https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup">this Wikipedia article</a> discusses LUKS encryption, which is utilized to encrypt your rootfs.

sdm supports enabling rootfs encryption configuration in two different ways:

* sdm-integrated, using the `cryptroot` plugin
* Standalone on RasPiOS and Debian Bookworm and later without needing all of sdm by using `sdm-cryptconfig` on your running system

These two methods are discussed in the following sections.

This tool supports multiple methods of unlocking the encrypted rootfs. These include:
* **Passphrase** &mdash; When the system boots the passphrase must be provided to the prompt on the console. The passphrase can also be provided if <a href="Disk-Encryption.md#ssh-and-initramfs">SSH was configured into the initramfs</a>
* **Keyfile** &mdash; A <a href="Disk-Encryption.md#unlocking-rootfs-with-a-usb-keyfile-disk">keyfile</a> on a USB disk can unlock the rootfs
* **Yubikey** &mdash; A <a href="Disk-Encryption.md#unlocking-rootfs-with-a-yubikey"> Yubikey </a> can unlock the rootfs
* **Network Bound Disk Encryption (NBDE)** &mdash; NBDE contacts a small NBDE server (tangd) to facilitate the unlock. See <a href="Disk-Encryption.md#nbde">Network Bound Disk Encryption</a>

Passphrase on the console is the default unlock method. Keyfile, Yubikey, and NBDE are optional. Only one of Keyfile or Yubikey can be enabled. Specifically, enabling the Yubikey will render any configured keyfile ignored. If a keyfile or Yubikey is configured, the passphrase is not required. NBDE and Yubikey are mutually exclusive as well.

SSH unlock can be used in any configuration.

NBDE is discussed in detail <a href="Disk-Encryption.md#nbde">here.</a>

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

* `--auto-encrypt devname` &mdash; Perform the sdmcryptfs encryption process automatically. `devnam` is the device name (e.g., `/dev/sdc`) of the scratch disk on the system where the encryption will be done. Requires `--nopwd` and `--keyfile`
* `--authorized-keys authkeyfile` &mdash; Specifies an SSH *authorized_keys* file to use in the initramfs. Required with `--ssh`
* `--crypto crypt-type` &mdash; Specifies the encryption to use. `aes` used by default, which uses `aes-xts-plain64`. Use `xchacha` on Pi4 and earlier for best performance. See Encryption/Decryption performance comparison below.
* `--dns dnsaddr` &mdash; Set IP Address of DNS server
* `--gateway gatewayaddr` &mdash; Set IP address of gateway
* `--hostname hostname` &mdash; Set hostname
* `--ipaddr ipaddr` &mdash; set IP address to use in initramfs
* `--keyfile /path/to/keyfile` &mdash; A keyfile used for passphrase-less booting. See <a href="Disk-Encryption.md#unlocking-rootfs-with-a-usb-keyfile-disk">Unlocking rootfs with a USB Keyfile Disk</a> for details
* `--mapper cryptmapname` &mdash; Set cryptroot mapper name [Default: cryptroot]
* `--mask netmask` &mdash; Set network mask for initramfs
* `--nbde-server` &mdash; Specify the NBDE server URL. See <a href=#nbde>here for details</a>
* `--no-expand-root` &mdash; Do not expand the rootfs at the end of sdmcryptfs
* `--no-last-reboot` &mdash; Don't do final reboot after sdm-cryptfs-cleanup
* `--nopwd` &mdash; Do not configure passphrase unlock; a keyfile is required
* `--quiet` &mdash; Keep graphical desktop startup quiet (see 'known issues' below)
* `--reboot` &mdash; Reboot the system (into initramfs) when sdm-cryptconfig is complete
* `--sdm` &mdash; sdm `cryptroot` plugin sets this. Not for manual use
* `--ssh` &mdash; Enable SSH in initramfs. Requires `--authorized-keys` to provide an authorized keys file for SSH security
* `--sshbash` &mdash; Leave bash enabled in the SSH session rather than switching to the captive `cryptroot-unlock` (DEBUG only!)
* `--sshport portnum` &mdash; Use the specified port rather than the Default 22
* `--sshtimeout secs` &mdash; Use the specified timeout rather than the Default 3600 seconds
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

**Do not lose or forget the rootfs passphrase. It is *impossible* to unlock the encrypted rootfs without a configured Yubikey, USB Keyfile Disk or rootfs passphrase**

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
* If your local network does not have a properly-configured DNS server to resolve local LAN DNS names(<a href="https://github.com/gitbls/ndm">example</a>), you'll need to use `ssh root@ip.ad.dd.rs`

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

Use `sudo /usr/local/sdm/sdm-make-luks-usb-key` on a host system to create a USB keyfile disk and key. `sdm-make-luks-usb-key` takes one argument, the name of an unmounted disk where the keyfile will be written. If desired, sdm-make-luks-usb-key can also initialize the disk.

Use `--init` for the first key you create and save to the USB Keyfile Disk. If you add additional keys to the disk (for the same or other systems), only use `--init` if you intend to delete ALL keys already on the disk.

Switches include:

* `--fat` &mdash; Create a FAT filesystem for the first partition. If not specified, the partition will be created as `ext4`
* `--force` &mdash; Implies `--init`. Initialize the keydisk without any safety checking
* `--hidden` &mdash; Makes the keydisk partition invisible to Windows by tagging it as EFI
* `--hostname` &mdash; If specified, writes a file on the keydisk with the hostname and keyname
* `--init` &mdash; Initialize the keydisk
* `--keyfile` &mdash; If specified, add the keyfile to the keydisk. A new file will be generated if not specified.
* `--label` &mdash; Specify the partition label for the keydisk. This can be used with the `cryptpart` plugin `keydisk-id` argument so the keydisk can be automatically found at system boot.
* `--mbr` &mdash; Format the disk with an MBR partition table instead of a GPT partition table.
* `--nodisk` &mdash; Just generate a keyfile but do not write the keyfile to the keydisk
* `--noretain` &mdash; Do not retain the keyfile in /root.

#### Examples

* `sdm-make-luks-usb-key /dev/sdb --init --label MYKEYDISK` &mdash; Generate a new key, initialize the specified disk and copy the keyfile to it. The disk will be labled MYKEYDISK, so it can be located by the `cryptpart` plugin using the `keydisk-id=LABEL=MYKEYDISK` argument.
* `sdm-make-luks-usb-key /dev/sdb` &mdash; Generate a new key, copy it to the already-initialized keydisk

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

## NBDE

Network Bound Disk Encryption (NBDE) is an alternate unlock method for encrypted partitions (rootfs only at the current time).

### NBDE Server Configuration

NBDE requires an NBDE server, `tangd`, on the local network. If the server on which you choose to run `tangd` is customized with sdm you can use the sdm plugin `nbde-server-install` to install tangd. If not, it's a very simple install. The tangd server listens on port 80 by default, but this can be changed. `nbde-server-install` accomodates this as an option, or you can find configuration details <a href="#nbde-further-reading">here.</a>

### How does NBDE work?

Here's a brief overview of how tang works, from the `man tang` man page.

The Tang project arose as a tool to help the automation of decryption.  Existing mechanisms predominantly use key escrow systems
where a client encrypts some data with a symmetric key and stores the symmetric key in a remote server for later retrieval. The
desired goal of this setup is that the client can automatically decrypt the data when it is able to contact the escrow server and
fetch the key.

However, escrow servers have many additional requirements, including authentication (so that clients can't get keys they aren't
supposed to have) and transport encryption (so that attackers listening on the network can't eavesdrop on the keys in transit).

Tang avoids this complexity. Instead of storing a symmetric key remotely, the client performs an asymmetric key exchange with the
Tang server. Since the Tang server doesn't store or transport symmetric keys, neither authentication nor encryption are
required. Thus, Tang is completely stateless and zero-configuration. Further, clients can be completely anonymous.

### Using NBDE to unlock an encrypted rootfs

When encrypting a rootfs, sdm-cryptconfig accepts the switch `--nbde-server`. Likewise, the `cryptroot` plugin accepts the argument `nbde-server`. In either case, you must provide the URL of the NBDE server in the form `http://fqdn.domain.xyz[:port]` (e.g., http://myserver.mydomain.com).

If your network does not have a local DNS server with local hosts configured, you can use an IP address instead (e.g., `http://ip.ad.dr.es[:port]`, `http://192.168.1.62`), but be aware that the NBDE server must ALWAYS be at that IP address.

On the other hand, if you use a full DNS domain, the server can easily be moved. In either case, the `[:port]` specifies the port number to use (e.g., `:7500`), and if not specified, both the NBDE server and client will use port `80`.

Lastly, note that the URL is `http://` and ***NOT*** `https://`.

### Configuring a LUKS unlock with NBDE

There are two methods for configuring rootfs encryption, likewise there are two methods for configuring NBDE.

* **cryptroot plugin** &mdash; Use the `cryptroot` plugin argument `nbde-server` to enable NBDE unlock

    `--plugin cryptoot:"...|nbde-server=http://mysrv.mydom.com|nopwd|keyfile=/path/to/keyfile.lek|..."`

* **sdm-cryptconfig** &mdash;  Use the command line argument `--nbde-server` to enable NBDE rootfs unlock

    `sudo /usr/local/sdm/sdm-cryptconfig ... --nbde-server http://mysrv.mydom.com --nopwd --keyfile /path/to/keyfile.lek ...`

#### sdm NBDE implementation behind-the-scenes

The `cryptroot` plugin creates a systemd service to run sdm-cryptconfig at the end of the sdm FirstBoot, so this description focuses on sdm-cryptconfig.

sdm-cryptconfig creates a systemd service (sdm-cryptfs-cleanup) to tidy up the system after a rootfs encryption. When NBDE is enabled this service also configures NBDE in the newly-encrypted rootfs.

When the system reboots at the end of sdm-cryptfs-cleanup, the system boots normally with the exception that NBDE is active. In this case, the network is started (eth0 only) and the NBDE client program (`clevis`) attempts to contact the `tangd` server to obtain the public key matter which is used to create the encryption material.

If tangd responds successfully and provides valid data, clevis unlocks the rootfs and the system boot continues. If there is no response or it is otherwise unsuccessful, the system will use the other mechanisms you configured: passphrase, keydisk, or Yubikey.

#### NBDE Further Reading

<a href="https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/security_hardening/configuring-automated-unlocking-of-encrypted-volumes-using-policy-based-decryption_security-hardening"> This page describes NBDE</a> and the clevis/tang implementation. sdm automates the configuration described in this document.

sdm does not provide any assistance for rotating tang server keys, which is described on the above linked page or `man tang` on the system where tang is installed.

## Encrypting other partitions

You may want to create a data partition on the system disk that is also encrypted (e.g., for an encrypted /home partition). This section demonstrates how to accomplish this. The end result is a system disk with an encrypted rootfs and an encrypted data partition.

A video of this entire process <a href="https://youtu.be/RLbxXzZo2Lk">can be viewed here.</a>

**NOTE:** As this page explains, sdm-cryptconfig can be used to encrypt the rootfs without installing sdm. However, encrypting other partitions is highly dependent on a couple of sdm plugins. So, if you want to encrypt other (data) partitions, sdm is required to (at least minimally) customize the system as well as burning the system disk.

This example demonstrates:
* Using the `cryptroot` plugin to automatically encrypt the rootfs after the disk has burned and booted
* Using the `parted` plugin to expand rootfs on the burned disk and add a data partition
* Copying the already-generated keyfile from the host into the disk as part of the burn process
* Running the `cryptpart` plugin very late in the multi-step FirstBoot process to encrypt and create the file system on the partition created with the `parted` plugin

### cryptpart partname NOTE

The `partname` argument to the `cryptpart` plugin is the physical partition name that it will have when the system is running on the new disk.

Typically, disk names for RasPiOS boot disks will be: `/dev/mmcblk0` (Integrated MicroSD card reader), `/dev/sda` (a USB disk), or `/dev/nvme0n1` (an NVMe disk).

This example creates partition 3, so the partname would be either `/dev/mmcblk0p3`, `/dev/sda3`, or `/dev/nvme0n1p1` as appropriate for the system configuration it is booted on, and it is only used during encryption configuration.

The parted command is useful for getting the partition numbers as well. 
```
sudo parted -ms /dev/sda unit mb print
BYT;
/dev/sda:480104MB:scsi:512:512:gpt:ASMT ASM105x:;
1:8.39MB:545MB:537MB:fat32::msftdata;
2:545MB:12683MB:12138MB:::;
3:12683MB:480104MB:467421MB::primary:;
```

Format of the above:
```
#   https://alioth-lists.debian.net/pipermail/parted-devel/2006-December/000573.html
    # $l1: BYT;  ** error if not BYT 
    # $l2: filespec:bytesB:file:512:512:msdos::;
    # $l3: partnum:startB:endB:sizeB:fstype:::;
    # $l4: partnum:startB:endB:sizeB:fstype:::;
```

This is the sample script that is discussed in the following sections to burn the disk and create a system with an encrypted rootfs and an encrypted data partition. The rootfs will use the btrfs file system, as will the data partition. ext4 file systems are also supported.
```sh
#!/bin/bash

dev=$1            # Burn device target (e.g., /dev/sda)
img=$2            # /path/to/IMG.img
host=$3           # host name to burn for
part3=$4          # Name of the 3rd partition on the booted system boot disk (see above)
 
sdm --burn $dev --hostname $host $img \
    --plugin cryptroot:"crypto=aes|nopwd|keyfile=/root/521f4471-8fa2-4ac3-ab96-6e5f00f67291.lek" \
    --burn-plugin parted:"rootexpand=8192|addpartition=0,none" --regen-ssh-host-keys --gpt --convert-root btrfs \
    --plugin copyfile:"from=/root/3449424f-1348-489d-9cdc-d4a2e1b6beef.lek|to=/root" \
    --plugin defer-plugin:"cryptpart:nonint|nopwd|cryptname=datapart|fstype=btrfs|keyfile=/root/3449424f-1348-489d-9cdc-d4a2e1b6beef.lek|mountpoint=/data|partname=$part3|keyfile-location=usb|keydisk-id=LABEL=MYLABEL"
```

The `cryptroot` plugin indicates that the rootfs partition will be encrypted with no passphrase but will instead use only a keyfile. *Pro Tip: A passphrase is an excellent idea when trying this for the first time*

The `parted` plugin is a *burn plugin*. Burn plugins are run after the disk has been burned. The parted plugin will expand rootfs by 8GB and add a partition following the rootfs with no filesystem that is expanded to consume the rest of the disk.

The `copyfile` plugin copies the keyfile for the data partition from the host system into the burned disk for use by `cryptpart`

The `cryptpart` plugin is run *deferred*, which means that it does not run during sdm FirstBoot or the rootfs encryption process. Instead, it is delayed until both of these activities complete. See <a href="Plugins.md#defer-plugin">defer-plugin plugin documentation</a> for details on deferred plugins.

That's the high level summary. Here are the detailed steps, including the use of a keyfile disk.

* **Customize the IMG file** &mdash; This is not discussed here, but if you've made it this far, you know what this step is! Use sdm to configure the system just like you want it to be. Then, when you want to create a disk with an encrypted rootfs, follow on here.
* **Make an sdm LUKS keydisk** &mdash; See <a href="Disk-Encryption.md#creating-a-usb-keyfile-disk"> here</a> for details. Use that keyname in your version of the above script.
  * **How many keyfiles?** Each partition can have its own keyfile on the same disk, or they can use the same keyfile. There is no default.
  * *Pro tip: sdm-make-luks-usb-key leaves a copy of the generated keyfile in /root.* You can, of course, move it. sdm doesn't care. But keyfiles are the keys to your system, and must be protected. If you have no valid copies of the keyfile and you did not add a passphrase unlock during the rootfs encryption process, you will have no way to access any of the data on that disk. This applies to the data partition as well.
* **Burn disk** &mdash; sdm burns the IMG to a disk. Once the disk is created sdm performs additional steps before the burn is complete:
  * The `cryptroot` plugin runs after the disk has been burned, in the context of the freshly-burned disk. `cryptroot` prepares the system for the encryption process.
    * Install required packages
    * Configure the system to run sdm-cryptconfig at the end of the next system boot
    * Defer setting RasPiOS boot behavior (B1-B4) until encryption has completed
  * The `copyfile` plugin copies the keyfile from the host to /root on the burned disk 
* **The burn plugin `parted`** runs after the disk burn completes
  * `parted` expands the root partition by 8192MB (8GB).
    * In practice, the space is left reserved, but unused. The root partition expansion is done during the encryption process in initramfs. This avoids the need to copy empty blocks during the encryption conversion.
  * `parted` creates the data partition, expanding it to fill the rest of the disk. The partition is create with no filesystem.
* **Configure the `cryptpart` plugin** to run once the system has achieved FirstBoot process complete via `defer-plugin`.
* **sdm-firstboot reboots** the system at the completion of the first system boot
  * Still part of a normal, unencrypted boot process
* **sdm-cryptconfig runs** at the completion of the system startup, as configured by the `cryptroot` plugin
  * sdm-cryptconfig configures the system for rootfs encryption
  * ***There is no undo*** once sdm-cryptconfig starts
  * Configures sdm-cryptfs-cleanup service
* **The system reboots into initramfs**
  * See <a href=Disk-Encryption.md#initramfs>here</a> for details of the `sdmcryptfs` command
* **Manually Run sdmcryptfs** at the `(initramfs)` prompt
  * sdmcryptfs performs the encryption
    * Read the configuration details passed from sdm-cryptconfig
    * Save the rootfs to RAM or another disk
      * To use RAM the entire rootfs must be less than approximately 80% of physical memory
    * Encrypt the partition
    * Unlock the now-encrypted partition
    * Expand the partition
    * Restore the rootfs
    * Expand the rootfs file system
    * Exit to the initramfs prompt
* **Continue the boot process** by typing *exit*
* sdm-cryptfs-cleanup runs at the end of this boot
  * sdm-cryptfs-cleanup was configured by sdm-cryptconfig
  * Reconfigure initramfs for normal operation
  * Set the deferred RasPiOS boot behavior (B1-B4)
  * Clear encryption-in-progress flag
* **System reboots automatically** for a normal system boot
* Boot process in initramfs unlocks the rootfs
  * There is a prompt if passphrase is enabled
  * The system will look for the keyfile (if enabled) on an attached USB disk device. It can be plugged in at any time
* After startup completes deferred plugins will run because the encryption-in-progress flag is clear
* One of the deferred plugins is `cryptpart`, which
  * Encrypt the new partition that the `parted` burn plugin created
    * Using either a keyfile or a passphrase
  * Enable non-rootfs encrypted partition mounting
  * Create the file system (ext4 or btrfs)
  * Keyfile can be provided from a USB stick or /root
  * Configure a systemd mount if the keyfile will be on a USB stick
* There is **no notification** that the deferred plugins have completed nor is there an automatic reboot option. The system is fully functional except a reboot is required to verify that automatic unlock and mount (if enabled) are correctly configured.
  * Results from running the deferred plugins can be viewed in the system journal (`journalctl`)
  * You can add your own notification using `defer-plugin:defer-command`.
* When this is complete, you will need to **manually reboot** or use `defer-plugin:defer-reboot`.
  * You can check `journalctl -b | grep 'Complete Run Defer Pluglists'` to see if the deferred service has completed.
  * **Don't reboot the system until this has completed, of course**
  * **Debug hint**
    * `journalctl | grep sdm-run-defer-pluglists` and look for errors
* After a reboot the system has a **fully encrypted rootfs and data partition**

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

sdm can be used to create an encrypted rootfs that uses the btrfs file system.

* Use the `--convert-root btrfs` when burning the disk.
* If you want the rootfs to fill the remainder of the disk, add `--expand-root` to the burn command.
* If you prefer more precise control on the size of the rootfs:
  * Use `--convert-root btrfs,8192` to request an 8GB btrfs rootfs
  * Use `--convert-root btrfs,+8192` to request an additional 8GB be added to the btrfs rootfs
  * With either of the above, if you want to utilize the space beyond the rootfs, be sure to add `--no-expand-root` to the burn command
  * In cases where the encrypted rootfs is not expanded to fill the disk sdmcryptfs will increase the rootfs partition size to accomodate the LUKS overhead
* When used in conjunction with `--plugin cryptroot` on the burn command, rootfs expansion is deferred until after the rootfs has been encrypted.

  This is useful so all those empty blocks in the btrfs expanded rootfs don't need to be copied. This is not an issue for ext4 filesystems since the file system data can be shrunk before copying.

### btrfs rootfs and rootfs expansion

By default the rootfs (btrfs or ext4) will be expanded to fill all available space.

If you use the `parted` plugin to add additional partitions after the rootfs partition in conjunction with the `cryptroot` plugin (on the IMG customize or burn), the `parted` plugin will leave space between the rootfs partition and the next partition. If `--plugin parted:"rootexpand=nnnn"` is used, the space left will be as specified by `rootexpand`.

If `rootexpand` is not specified, the `parted` plugin will leave a small amount of free space between a btrfs rootfs and the next partition to accomodate the LUKS header along with the btrfs partition. This is not required for an ext4 rootfs.

In either case, the rootfs expansion is done in `sdmcryptfs`. If you don't want the rootfs expansion to occur, use `--plugin cryptroot:no-expand-root`, but be aware that even in this case a btrfs rootfs will be expanded by the "small amount of free space" mentioned above in order to ensure that the partition is large enough to accomodate the LUKS header in addition to the filesystem data.

Deferring the rootfs expansion to `sdmcryptfs` minimizes the size of the rootfs that is copied.

## Known Issues

* To use disk encryption on disks other than rootfs that you have manually encrypted, remove `luks.crypttab=no` from /boot/firmware/cmdline.txt. The `cryptpart` plugin takes care of this.

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
## Common Difficulties

* If you intend to use a YubiKey or a USB key, but sdmcryptfs asks you for a passphrase, something is wrong. Stop and figure out how to correct it.

* If you use `--plugin cryptpart`:
  * If you're using a USB keydisk, remember to use `--label` when you create the keydisk or the disk will not automount to unlock an encrypted data partition.
  * Similarly, Be sure to provide that label to the `cryptpart` plugin argument `keydisk-id` as `LABEL=<mylabel>`. `LABEL` must be capitalized exactly as shown.
  * Use `journalctl` to watch for log entries generated by cryptpart. If all goes well, there'll be a log entry saying you should reboot. When you do, you'll see the newly-created partition.
  * Be patient. It can take several minutes for cryptpart to complete. Don't reboot until it's done.
  * cryptpart won't run unless a copy of your key is available immediately after you boot your newly-burned SD card. As shown in the example above, one way to make that happen is to use `--plugin copyfile:from=/root/some-big-uuid.lek|to=/root|mkdirif` to put a copy of the key on the SD card, and specify `keyfile=/root/some-big-uuid.lek` to cryptpart.
  * Specify a filesystem type of `none` to parted, and specify the filesystem type you want to use to `cryptpart`.
  * If you unlock a partition using a USB key, sdm doesn't automatically unmount that USB key. It's mounted read-only so it's safe to just unplug it without unmounting it first.
* You must have a network connection when you run `sdm --customize`, and you must also have a network connection during "Second Boot" because sdm-cryptconfig may need to install additional packages.
* You will not see any error messages that sdm-cryptconfig might produce at second-boot time, although they are in the system journal, so this can be difficult to debug. This is not true, however, if sdm-cryptconfig is run interactively.

* Be careful when you use the parted burn-plugin with `no-expand-root=y`. The latter will override any value you may have specified with `rootexpand=nnnn`.

* If you need to erase an SD card, use `parted /dev/sdX mklabel msdos`. Some versions of `rpi-imager` are known to create an invalid MBR partition block.

* If you're using Btrfs, consider adding `kernel=kernel8.img` to your config.txt file. Btrfs support for the -2712 kernel is marked as experimental.

* When you're running a customize or a burn, you'll gradually learn which error messages indicate a problem, and which ones can be ignored. These can generally be ignored.
  * During `--customize` and `--burn`
    * `update-initramfs` will say "Couldn't identify type of root file system"
    * `cryptsetup` will say "Couldn't resolve device"
    * Something will say "invoke-rc.d: could not determine current run level"
    * `parted` will say "You may need to update /etc/fstab"
  * When you see the `(initramfs)` prompt
    * "Magic mismatch"
    * "Can't find valid F2FS filesystem in superblock"

 ## Acknowledgements

Encryption configuration is based on https://rr-developer.github.io/LUKS-on-Raspberry-Pi. As of 2024-01-01 it predates Bookworm, but was very helpful in working out the initramfs configuration.

Thanks to:
* https://gitlab.com/cryptsetup for the great encryption technology
* The RasPiOS and Debian teams for a great OS
* Moses for the WiFi support
* rakwala for the nudge to do encrypted data partitions and all the help
* The `tang` and `clevis` projects for the very cool Network Bound Disk Encryption capability

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
