# Changelog

## V15.0

* New Features
  * `--convert-root` takes a value formatted as `fstype[,size]` to increase rootfs by size (using +size) or to specify the rootfs size
* Improvements
  * Enable btrfs rootfs encryption. See <a href="Docs/Disk-Encryption.md#btrfs-rootfs-notes">Disk Encryption</a>. lvm rootfs encryption remains unsupported.
  * Plugin `cryptroot` has new `no-expand-root` argument that is passed to sdm-cryptconfig
  * sdm-cryptconfig has new `--no-expand-root` switch
  * sdmcryptfs honors the above `no-expand-root` setting
  * Minor improvements to `ezsdm`
* Bug Fixes
  * Don't use parted to divine disk size due to fail on certain blank disks
  * Correct sdm-gburn: restart default and pluglist errors. Thanks @jdeitmerg

## V14.14

* New Features
  * New plugin `apt-config` enables customizing apt in the IMG
    * Command-line switch `--apt-options`/`--poptions` arguments `no-install-recommends`, `confold`, and `confdel` removed in favor of `apt-config` plugin
    * `apt-config` arguments `nopager` and `nocolor` provide some control over the `apt` command output
  * New plugin `swap` enables configuring `rpi-swap`. `system` plugin argument `swap` remains as is
* Improvements
  * Add `static-ip` argument to `gadgetmode` plugin, which also forces static MAC
* Bug Fixes
  * `cloudinit` plugin ensures /boot/firmware gets mounted before cloud-init-main runs

## V14.13

* New Features
  * `sdm-cryptconfig` can now enable using WiFi for unloking an encrypted rootfs. Thanks @pygmymarmoset!
* Improvements
* Bug Fixes
  * Update `trim-enable` and standalone `satrim` for Trixie. Disks that are trim-capable will get trim enabled

## V14.12

* New Features
  * `cloudinit` plugin actually included now, and improved to optionally add yaml-formatted cfg files to /etc/cloud/cloud.cfg.d
* Improvements
  * Plugin `apt-cacher-ng` now disables VfileUseRangeOps by default for improved reliability
  * sdm-cryptconfig properly disables getty@tty1 before encryption and re-enables it afterwards, correcting an annoying issue (at least to me!) on Desktop systems
  * Update list of default user groups for consistency with rpi-imager and Trixie
* Bug Fixes

## V14.11

* New Features
  * New plugin `cloudinit` facilitates adding cloud-init user-data to leverage cloud-init capabilities if desired
* Improvements
  * Plugin `disables` argument `cloudinit` now only disables cloudinit. No need to touch NM on Trixie as of RasPiOS 2025-11-24
  * Remove `yubi` plugin and replace with sdm-yubi-config which does not require sdm
  * Plugin `user` argument `prompt` for password now asks for a retype and tests for the two passwords match
* Bug Fixes

## V14.10

* New Features
  * Also display host pagesize in /etc/sdm/history at start of customization
* Improvements
* Bug Fixes
  * `disables` plugin `cloudinit` now actually works for 32-bit systems

## V14.9

* New Features
  * Plugin 'yubi' enables encrypted rootfs unlock via a Yubikey when used with `cryptroot` and/or `sdm-cryptconfig`
* Improvements
  * `--extract-log` files inherit owner of output directory
  * Print Pi model and memory to history at start of sdm FirstBoot in the system journal and /etc/sdm/history
  * `copyfile` plugin duplicate file copies eliminated
* Bug Fixes
  * `--aptcache` was broken. Not any more.
  * `runscript` plugin can now be used to run the same script for multiple users, although only once per user.
  * Fix mounting of on-disk IMGs with more than 2 partitions so that bootfs and rootfs are correctly mounted (exhibited via `parted` plugin applied to an IMG)

## V14.8

* New Features
  * `--expand-at-boot` does the rootfs expansion at boot time, but relies on you to do SSH host key generation using `--regen-ssh-host-keys` or `--plugin sshhostkey:generate-keys` at burn time. Trixie only
  * Plugin `system` argument `service-disable-at-boot` argument to disable services at the very end of the first system boot
* Improvements
  * Minor doc updates for Trixie
  * Use internal `do_raspiconfig` everywhere, removing a few errant naked raspi-config calls
  * Add `--no-last-reboot` to sdm-cryptconfig. Useful (for me) when debugging ;)
  * Enhance error messages when an apt failure is identified during customization
  * Plugin `disable` argument `cloudinit` only supported on 64-bit OS
* Bug Fixes
  * apt autoremove was getting done too early as a result of some internal code shuffling. Shuffled it a bit more

## V14.7

* New Features
  * Plugin `bootconfig` argument `commentize` will comment out the specified line in config.txt
  * Plugin `system` argument `service-enable-at-boot` disables the specified services and re-enables them during FirstBoot
* Improvements
  * Plugin `disable` argument `cloudinit` also properly configures NetworkManager to avoid using /run/NetworkManager/system-connections. See <a href="Docs/Hints-Trixie.md">Trixie Hints</a> for details.
  * Plugin `user` sets new user home directory protections to 700 to conform with Debian
  * Enhance customization out of disk space error so it's (hopefully) much, much, much more obvious
  * Log boot-time final configuration events such as localization, hotspot, and other plugins with late configuration in /etc/sdm/history
* Bug Fixes
  * Update `hotspot` plugin to accomodate NetworkManager breaking change
  * Correct `copyfile` file list handling and allow blank and comment lines
  * Correctly exit on errors during apt upgrade and apt autoremove

## V14.6

* New Features
* Improvements
  * Add `--apt-options no-install-recommends`, which can also be enabled with `--apt-options none`. sdm uses `--no-install-recommends` when installing apps. This enables it for use in the running system
  * Updates for Trixie
    * Add `cloudinit` as an option to the `disables` plugin, which disables all cloud-init services
    * Remove `resize` from cmdline.txt if sdm expands rootfs (`--expand-root`)
* Bug Fixes
  * Resolve a few issues in the `runscript` plugin

## V14.5

* New Features
  * `update-alternatives` plugin to manipulate Debian alternatives
    * <a href="Docs/Plugins.md#update-alternatives">Documentation</a>
* Improvements
* Bug Fixes
  * Correct `user` plugin so `userdel` followed by `adduser` of the first user (e.g., pi) doesn't remove the login directory

## V14.4

* New Features
  * Bash sdm command completion
* Improvements
  * Trixie updates
    * Update `labwc` plugin and `sdm-collect-labwc-config` for wf-panel-pi directory change
    * Update `graphics` plugin labwc handling to accomodate raspi-config changes
    * Update `wsdd` plugin for package name change
  * `sdm-cryptconfig` `--sshtimeout` default increased to 3600 seconds (1 hour)
  * Improve ssh host key and `--regen-ssh-host-keys` handling
  * Rename journald logging config file created by the `system` plugin to better ensure it wins the systemd config search path bingo
  * Include `parted` in initramfs when using cryptroot/sdm-cryptconfig for distros that don't (e.g., Ubuntu)
  * Plugin `copyfile` now renames the destination file if it exists, with a warning
  * Improve plugin `disables` handling of triggerhappy if it's not installed
  * `system` plugin `swap` feature automatically handles configuration of `rpi-swap` and `dphys-swapfile`
  * Keep `sgdisk -p` happy by leaving 33*2 'blocks' at end of disk on expand
  * Highlight sdm warning messages (if any) at the end of customization
* Bug Fixes
  * Re-enable the `keyboard-setup` service during FirstBoot
  * Correct `labwc` `kanshi` config file handling

## V14.3

* New Features
  * `wireguard` plugin to easily configure both ends of a wireguard VPN
  * <a href="Docs/Plugins.md#wireguard">Documentation</a>
  * <a href="Docs/Cool-Things-You-Can-Do-wireguard.md">Complete working wireguard demo</a>
* Improvements
  * Automatically rerun sdm as root if needed
  * `system` plugin argument `swap` value of `zram` installs `rpi-swap` if it's available (e.g., Trixie)
  * Some long overdue internal restructuring
* Bug Fixes

## V14.2

* New Features
* Improvements
  * `clockfake` plugin disables fake-hwclock-save.timer if present (new in Trixie)
* Bug Fixes
  * Correct broken country checking in `btwifiset` plugin
  * Correct broken `venv` plugin and add it to the sdm tarball

## V14.1

* New Features
  * The new `install-sdm` tool is now the recommended installer. All docs now refer to this new installer. EZsdmInstaller remains but will be removed in a future version.
  * `hotspot` plugin has new arguments to augment default nmcli config for hotspot, bridge master, and bridge slave. See <a href="Docs/Plugins.md#hotspot">here</a> for details.
* Improvements
  * `clockfake` plugin now forks so it can do a last gasp system time update as system shuts down
  * `sshkey` plugin has new `import-pubkey` argument that provides a public key to add to the specified user's authorized_keys
  * `sdm --version`, `sdm --help`, and `sdm --info` do not require `sudo`
  * Add `--extract-script` to extend `--extract-log`
  * Accomodate other devices that get partition names with '**p***n*' appended to them (ala nvme and mmcblk). See <a href="Docs/Disks-Partitions.md#device-names">here</a> for details.
* Bug Fixes
  * Capture `venv` plugin venv creation output in /etc/sdm/apt.log
  * Correctly identify bad WiFi country names
  * Remove the `serial` argument from plugin `raspiconfig`. Use the `serial` plugin.

## V13.12

* New Features
  * `--extract-log` switch to extract the sdm logs from an IMG or burned disk. <a href="Docs/Hints-Commands.md#easily-get-access-to-the-logs-within-a-customized-img-or-burned-disk">See here for details</a>
* Improvements
  * Optional new sdm installer. See <a href="https://github.com/gitbls/sdm/discussions/318">this discussion for details</a>
  * Debian Trixie prep
    * Prevent systemd-nspawn from gratuitously changing terminal colors
* Bug Fixes
  * Improve device checking when burning to correctly detect a partition name vs a device name

## V13.11

* New Features
  * Plugin `venv` creates and populates a python virtual environment. <a href="Docs/Plugins.md#venv">venv plugin documentation</a>
  * Automatically force GPT disk format when burning to a disk GE 2TB (Thanks @mjsmall for the idea!)
* Improvements
  * `parted` plugin improvements  (Thanks @mjsmall!)
    * Can create a swap partition
    * **NOTE:** Incompatible change! Less-than-useful `partitiontype` argument removed in favor of mount point support
  * rootfs crypto works on 4kb pagesize Pi5 with rpi-eeprom version 27.8-1 and later
* Bug Fixes

## V13.10

* New Features
  * New `cmdline` plugin to update or replace cmdline.txt
* Improvements
  * `network` plugin `ipv4-static-ip` honors provided subnet and defaults subnet to `/24` if not provided (Thanks @eelco)
* Bug Fixes
  * Correct error handling for `--aptmaint` failures
  * Fix WiFi configuration in batch burn script sdm-gburn

## V13.9

* New Features
  * Plugin `docker-install` installs the docker runtime
  * Fully document automatic site-to-site and VPN configuration
* Improvements
  * Fix cosmetic issue with ezsdm's plugin list generation
* Bug Fixes
  * Remove `dsa` encryption from `sshkey` plugin since openSSH 9.8 and later no longer support it

## V13.8

* New Features
  * Add arguments `password-hash` and `password-plain` to the `user` plugin
  * Add argument `nmdebug` to the `network` plugin
* Improvements
  * Improve `hotspot` plugin nftables management
* Bug Fixes
  * `parted` plugin: Ensure align_to_sector set to minimum 2048
  * Use 'EOF' instead of EOF in ezsdm to enable un-quoted dollar signs in arguments such as passwords, SSIDs, etc., in pluglist files

## V13.7

* Improvements
  * `network` plugin has new parameter `timesyncwait` to adjust the FirstBoot wait for time synchronization. Default is 120 seconds
  * Improve systemd boot behavior restoration in systemd-cryptconfig for systems with a graphical desktop
* Bug Fixes
  * Correctly sequence setting wificountry during FirstBoot so WiFi earlier in the boot process

## V13.6

* New Features
  * Add `sshhostkey` plugin to generate SSH host keys during customize or burn when there's more entropy in the system (Thanks @omya3qno)
  * `hotspot` plugin now accepts `portal` and `portalif` arguments which install the WiFi network selector app <a href="https://www.raspberrypi.com/tutorials/host-a-hotel-wifi-hotspot/">described here</a>
* Improvements
  * Redaction (`--redact`) improved. No sensitive information is leaked to the console and /etc/sdm/history from included plugins
  * `sshd` plugin new argument `address-family` to control the sshd_config AddressFamily directive
* Bug Fixes

## V13.5

* New Features
  * `cryptroot` and `sdm-cryptconfig` rootfs encryption
    * Massively improved `sdmluksunlock` script can either type the password or insert a USB key disk at any time
    * `sdm-make-luks-key` accepts an existing key as well as creating a new key 
* Improvements
  * Eliminate RequiresMountsFor journal message
  * `L10n` settings are not instantiated in the system until FirstBoot. Last change wins
* Bug Fixes
  * `Fix git-clone` preclone and postclone script protection issue

## V13.4

* New Features
  * `hotspot` and `network` plugins
    * New argument `pskencrypt` to request that PSK be encrypted
    * Spaces, exclamation points, and single quote are enabled in the connection name, WiFi SSID, and password
  * `graphics` plugin argument `graphics` now has 3 values: `x11`, `wayfire`, and `labwc` to control the raspi-config `wayland` setting
* Improvements
  * Code cleanups
  * `sdm-collect-labwc-config` and `labwc` plugin improvements
    * Ensure propagated during customize
    * Correctly process wf-panel-pi.ini
  * `bootconfig` was not allowing an existing dtoverlay to be properly updated (e.g., `dtoverlay=vc4-kms-v3d` to `dtoverlay=vc4-kms-v3d,noaudio`)
  * `network` plugin will warn of existing .nmconnection, delete it, and continue rather than fail
* Bug Fixes
  * Remove extra config file write that broke `wificountry` setting in some instances
  * `sshkey` plugin works for multiple users
  * Correct update-initramfs config handling so `cryptroot` and `sdm-cryptconfig` work with 2024-11-19 and later builds/updates

## V13.3

* Bug Fix
  * Update /etc/initramfs-tools/initramfs.conf for proper operation with 2024-11-13 and later IMGs

## V13.2

* New Features
  * New 'labwc' plugin for making your labwc desktop just the way you want it. <a href="Docs/Plugins.md#labwc">labwc plugin documentation</a>
  * New tool `sdm-collect-labwc-config` grabs all your config files on a customized to your liking system to feed into future sdm customizations
* Improvements
  * `apps` plugin accepts multiple invocations without using the `name=` argument
  * `gadgetmode` improvements
    * Improved robustness
    * New argument `mac-vendor`
  * `hotspot` plugin improvements
    * Improved robustness with USB hotspot
    * Workaround fix for usb0 devices sometimes incorrectly showing up as eth1 (cdc_ether problem?)
* Bug Fixes
  * Correct message typo in `L10n`
  * EZsdmInstaller also ensures keyboard-configuration is installed for `L10n`

## V13.1

* New Features
  * `gadgetmode` plugin configures a tethered USB client. <a href="Docs/Plugins.md#gadgetmode">gadgetmode documentation</a>
    * Use the `hotspot` plugin with `device=usb0` to configure a USB-connected tether server/host
* Improvements
  * `sdm-make-luks-key` now uses `uuid -v4` instead of `uuid`
* Bug Fixes

## V13.0

* New Features
  * New plugins
    * `postburn` &mdash; A *burn plugin*, runs after a burn to copy files from the burned disk to/from the host or run scripts that require access to the burned disk. <a href="Docs/Plugins.md#postburn">postburn plugin documentation</a>
    * `sshd` &mdash; Configures SSH service (SSH enabled remains the default) and/or configure sshd settings in /etc/sshd_config: `ListenAddress`, `PasswordAuthentication`, and `Port`. <a href="Docs/Plugins.md#sshd">sshd plugin documentation</a>
    * `sshkey` &mdash; Create or import an SSH key, optionally create a putty private key <a href="Docs/Plugins.md#sshkey">sshkey plugin documentation</a>
* Improvements
  * `apt-cacher-ng` now creates /usr/local/bin/reset-apt-cacher in case the cacher has a problem
  * Add several new arguments to the `pistrong` plugin to enable fully-automated IPSEC VPN configuration
    * See <a href="Docs/Plugins.md#pistrong">pistrong plugin documentation</a> for details
  * `network` plugin changes/enhancements
    * Explicit SSH service configuration moved to the new plugin `sshd`. sdm still enables SSH by default, so `sshd` plugin only needed to disable SSH or make other configuration changes newly supported by the `sshd` plugin. 
    * Static IP configuration, autoconnect, autoconnect-priority, connection name
    * Identify device as wifi if it's not named 'wlan*'
    * Invoke plugin for each network device to configure
    * OR run it to copy existing .conf or .nmconnection files into the IMG
    * <a href="Docs/Plugins.md#network">Network plugin documentation</a>
  * `imon` plugin updated
  * `samba` plugin enhancements
    * `enablesvc` argument to enable the service
    * Disable `nmbd` and `samba-ad-dc` services, which are hardly used
* Bug Fixes
  * Correct `user` plugin handling for samba passwords
  * Correct burn device already mounted check

## V12.10

* New Features
  * `dovecot-imap` plugin installs a local imap server. Requires the postfix email server
  * `logwatch` plugin installs logwatch, a system log analyzer and reporter
* Improvements
  * Internal coding simplification for apt app installs
* Bug Fixes
  * Update `sdm-cryptconfig`. keyfiles work with latest Debian `initramfs-tools` update

## V12.9

* Improvements
  * Add `linger` argument to the `user` plugin to enable user services to run without login
  * Improve `hotspot` plugin device flexibility
  * Update `EZsdmInstaller` so that once sdm installed it can run plugins on the live running system

## V12.8

* Bug Fixes
  * Correct argument handling when spawning/chrooting into container. Args with spaces broke the world
  * Correct `apt-addrepo` gpg key name handling

## V12.7

* New Features
* Improvements
  * Run plugin's 0piboot scripts after running the plugin on live system, fully completing the plugin installation/configuration (Can't believe nobody ran into this!)
  * Improve new `syncthing` user service enablement
* Bug Fixes

## V12.6

* New Features
  * `ndm` plugin supports dnsmasq as well as bind9/isc-dhcp-server, and build/install of service config files if an ndm config file provided
* Improvements
  * Rework `hotspot` plugin: Bookworm only. Bridged or routed with NetworkManager internal, `ndm`, or roll-your-own on-host DHCP server
  * `network` plugin
      * Add `iwname` parameter to control which wireless interface is configured. Default is `wlan0`
      * Add `nowifi` to disable automatic WiFi network configuration
      * Improve logic that decides whether to create a WiFi nmconnection file
  * Add `vnc_resolution` parameter to `raspiconfig` plugin
* Bug Fixes
  * Correct SSID with space handling in `network` plugin

## V12.5

* Improvements
  * Error handling improvements in several plugins
  * `user` plugin now fails (as it should) if the useradd command fails
* Bug Fixes
  * Correct 1piboot.conf handling

## V12.4

* New Features
  * New plugin `modattr` to modify directory and file protection/owner
* Improvements
  * Add the official Getting Started with sdm script to <a href="Docs/Example-Commands.md">Example sdm commands</a>
  * New `powersave` argument for the `network` plugin to control WiFi power save setting (2:Disable, 3:Enable)
  * `--expand-root` and `--regen-ssh-host-keys` can be set on customize (and are automatically passed to --burn)
  * Ability to configure encrypted rootfs initramfs Port and Timeout for SSH
  * Enable setting fslabel in `parted` plugin (Thanks @ykharuzhy!)
  * Plugin `graphics` now accepts `graphics=X11` as well as `graphics=x11`
  * Make it clearer that customization terminated if IMG fills up ("Customization terminated due to low disk space condition")
  * `btwifiset` plugin updates
  * Only print days in elapsed times if non-zero
* Bug Fixes

## V12.3

* New Features
* Improvements
  * Don't change terminal colors if `--ecolors 0` (for explore and customize) or `--mcolors 0` (for mount); useful for terminal emulators that don't correctly handle terminal coloring escape sequences (https://www.xfree86.org/current/ctlseqs.html)
  * Documentation improvements
  * Issue a warning if systemctl commands fail in the `system` plugin
* Bug Fixes
  * Accomodate systemd version string variations

## V12.2

* New Features
  * Encrypted rootfs can now be configured with only a keyfile (no passphrase). See <a href="Docs/Disk-Encryption.md">Disk Encryption</a>
  * New argument `service-mask` for `system` plugin (Thanks  @ytret!)
* Improvements
  * By default /etc/sdm/apt.log lines are now time-stamped. Disable with `--apt-options nologdates`
  * `--apt-options none` means `--apt-options noupdate,noupgrade,noautoremove` (does not affect `nologdates`)
  * Update `btwifiset` plugin to V2 (See <a href="https://github.com/nksan/Rpi-SetWiFi-viaBluetooth/tree/main">btwifiset</a>)
  * Strip comment lines starting with `#` from `--plugin @file`
  * `sdmcryptfs` gives the option to zap the temporary disk in order to remove unencrypted rootfs copy
  * `bootconfig` plugin will report config.txt line too long (>96) to prevent boot mystery
* Bug Fixes
  * Correctly handle boot_behavior when set via `raspiconfig` plugin
  * Burn time is now correctly logged

## V12.1

* New Features
  * Add `zeroconf` argument to `network` plugin which will automatically configure a 169.254.x.x address if the ethernet device does not acquire an IP address (NetworkManager only). Idea from: https://github.com/thagrol/Guides/blob/main/bookworm.pdf
  * New tool sdm-ssh-initramfs adds SSH capability to an already installed and encrypted RasPiOS/Debian system
* Improvements
  * Remove restriction identified in V12.0 if encrypted rootfs with a USB key but key not inserted AND no keyboard
  * `network` plugin code improvements
  * Add more host diagnostic information in /etc/sdm/history
  * Print elapsed time for copies in `sdmcryptfs`
* Bug Fixes
  * Correct inverted null string test in `apt-addrepo` plugin
  * Enable `trim-enable` to continue on a couple of errors that it formerly died on

## V12.0

* New Features
  * New plugin `runscript`: Runs the specified script during Phase 1 (default) or post-install (optional)
    * Useful for codifying installs for some software
    * See <a href="Docs/Plugins.md#runatboot">runatboot</a>
  * rootfs encryption can now use LUKS encryption key on USB disk for non-stop boot of encrypted rootfs
    * See <a href="Docs/Disk-Encryption.md">Disk Encryption</a> for complete details
    * Use `sdm-make-luks-key` to create the encryption key and set up a USB keydisk
    * Use `sdm-add-luks-key` to add an encryption key to an already-encrypted rootfs
    * If using `sdm --explore` with an encrypted rootfs specifying `--keyfile` implies `--encrypted`
    * Known issue: If the USB key is not inserted in a drive and the system has no keyboard attached the system will not be able to boot
      * Fixable if anyone knows a reliable way to detect if the keyboard is attached in initramfs
* Improvements
  * rootfs encryption supports more aes ciphers: anything that starts with `aes-` is assumed valid; if it's not you'll find out during actual rootfs encryption
    * Default encryption if not specified is now `aes-xts-plain64`
  * Add `--apt-options` as a synonym for `--poptions` and make `--apt-options none` be `noupdate,noupgrade,noautoremove` (Default is to perform all 3)
  * `copydir` plugin option `nodirect` removed. All copies now done in Phase 0
  * Improve the error message if running on a Pi5 with an encrypted rootfs and trying to access a 32-bit Bookworm IMG
* Bug Fixes
 * `cryptroot` plugin did not require `authkeys` with `ssh`. Now it does
 * Correct some broken links in the Documentation
 * Correct plugin `serial` configuration

## V11.8

* New Features
* Improvements
  * Warn instead of abort if `copyfile` plugin rerun with same source/dest
  * Improve NetworkManager default connection management and only defer actual configuration to sdm First Boot if pre-Bookworm NetworkManager
* Bug Fixes
  * `serial plugin: If `enableshell` is NOT specified or `disableshell` IS specified, disable the shell on the serial console

## V11.7

* New Features
  * rootfs encryption now supports `aes` encryption (default), for best performance on the Pi5
    * For Pi4 and earlier use `crypto=xchacha` encryption for best performance on those devices. See <a href="Docs/Disk-Encryption.md">Disk Encryption</a>
    * Thanks @jollycar for the suggestion and sussing out the initramfs changes
* Improvements
  * Add `stdout` and `stderr` arguments to `copydir` plugin and remove `tee` argument
  * Ensure rsync is installed on sdm host in EZsdmInstaller. Some distros don't include it by default
* Bug Fixes
  * Don't try to `--convert-root` from a non-sdm-enhanced IMG
  * Several corrections to `copyfile` plugin
    * Copying two different files with the same filename but in different source directories now works
    * Don't check for non-existent directory until it's time to actually copy the file (phase1 or postinstall)

## V11.6

* New Features
  * Add `--convert-root fstype` which converts the rootfs to `btrfs` or `lvm` when burning
  * Explore or mount encrypted disks with `--encrypted`
* Improvements
  * Code cleanups
  * Burn-time logging improved
* Bug fixes
  * Improve apps plugin apt failure handling
* Notes
  * `--plugin vnc:wayvnc is deprecated but not yet tied. Don't use it with 2024-03-15 IMG

## V11.5

* Improvements
  * Improve/simplify systemd-nspawn/chroot/qemu usage
    * Cross-architecture detection/support vastly improved
      * New! Can customize 32-bit IMG on 64-bit (only) ARM OS (e.g., Mac M2 with no 32-bit mode)
      * Also can customize 64-bit IMG on 32-bit ARM OS (e.g., Pi0W) (dog slow, but it works!)
  * Add some missing informative messages...useful for WTF happened debugging
  * Add note to `user` plugin about `--plugin disables:piwiz`
  * More updates of "FirstBoot" to "sdm FirstBoot"
  * Copy directories in addition to files in /etc/skel to new user (unless `noskel`, of course) 
  * sdm-cportal works better on Bookworm. Works, but not 100% baked so would appreciate any/all feedback on it
  * EZsdmInstaller can now install from alternate repo (e.g., if you clone sdm) (Thanks @jchan-legendpower)
* Bug fixes
  * Correct L10n plugin keymap setting
  * Correct `EZsdmInstaller` so it properly enables burn plugins to run on hosts not created with sdm
  * Correct mount failure path to use *old* style loop-mounts (needed, e.g., for some older Mint and Ubuntu releases)

## V11.4

* New Features
  * `sdm --burn` can convert burned disk to GPT with `--gpt` switch
    * Not for use on IMGs; GPT only enabled for burned disks at the moment
    * Well-tested on Pi5/Pi4/Pi3B+/Pi02W/Pi0W
    * `--burn-plugin parted` works on GPT disks
 * `--plugin raspiconfig` enables overlayfs read-only file system
 * Enable SSH for remote crypt rootfs unlock if not enabled when rootfs was encrypted

## V11.3

* New Features
  * sdm-gburn optimized for plugins and Bookworm. See <a href="Docs/BatchBurn-SSD-SDs-with-sdm-gburn.md">Batch Burning SSDs and SD cards</a>
    * Simplifies burning a batch of SSDs/SD cards from a common base, each with unique configurations
  * Encrypted rootfs can now be configured and unlocked via SSH for headless systems
* Improvements
  * Document known plugin ordering issues in <a href="Docs/Plugins.md">Plugins</a>
  * Maintain text-mode console until rootfs encryption completes when used from sdm
  * Provide elapsed time guesstimates for sdmcryptfs encryption operations in initramfs
  * Update plugin vnc:wayvnc to use the wayvnc service
  * Change FirstBoot logging in the journal and on the console to be `sdm FirstBoot` to differentiate from non-sdm `FirstBoot` logging. Searching the system log for `sdm` will now find all sdm-related log entries
  * Improve `--shrink` by using "shrink partition" instead of "delete/recreate partition"
* Bug fixes
  * Partition reference issues resolved for NVME drives
  * Correct trim (both standalone `satrim` and `trim-enable` plugin) to do better handle NVME drives

## V11.2

* New Features
  * `cryptroot` plugin enables encrypted rootfs
    * Non-sdm-customized systems can also be encrypted. See <a href="Docs/Disk-Encryption.md">Disk Encryption</a>
  * Add `bookmarks` as an argument to the `lxde` plugin `lxde-config` argument
* Improvements
  * Improve error handling in apps and apt-addrepo plugins
  * apps plugin now takes `remove` argument, same format as `apps`. Removes are done before new apps are installed. If you try to remove an apt packge that doesn't exist it will log in /etc/sdm/apt.log and sdm will notify you at the end of the customize: '? apt reported errors; review /etc/sdm/apt.log'
  * Add `ledheartbeat` argument to the `system` plugin which enables LED heartbeat flashing on Pis so equipped. Pi4 and Pi5 work. Pi 02W does not support this. Others have not been tested.
* Bug fixes
  * Correct mis-handling of cmdline.txt on burned disk
  * Correct location for placement of the `lxde` plugin `lxde-config` `pcmanfm` value
  * One final /boot/firmware fix

## V11.1

* New Features
  * `vnc` plugin accepts `wayvnc[=geometry]` argument to enable wayvnc. If geometry (widthXheight) specified, the headless desktop geometry will be set

## V11.0

* New Features
  * Add `--burn-plugin` which specifies plugins to be run AFTER a burn has been completed. Only certain plugins can be invoked as burn plugins. Burn plugins can also be used with `--runonly` to operate on an IMG or burned device. See <a href="Docs/Plugins.md#burn-plugin">Burn Plugins </a> for details.
    * `explore` &mdash; A burn plugin that enables you to explore the just-burned disk or IMG ala `sdm --explore`, or just mount it ala `sdm --mount`
    * `extractfs` &mdash; Extracts the boot and root file trees from the IMG into the file system
    * `parted` &mdash; A burn plugin that provides more flexible control over burn device (and burnfile) partitions
      * Enables root partition expand by nnnnMB and creating partitions of size nnnnMB with a supported file system on it
  * New Plugins See <a href="Docs/Plugins.md">Plugins </a>
    * `apt-addrepo` &mdash; Add apt Repos and gpgkeys for apt
    * `ndm` &mdash; Installs and configures `named` (bind9), `isc-dhcp-server`, and `ndm` which generates their config files
    * `git-clone` &mdash; Clones a repo to the specified path.
    * `piapps` &mdash; Install @Botspot's Pi-Apps control (https://github.com/Botspot/pi-apps) as part of customizing your Pi disk
    * `serial` &mdash; Properly set serial configuration at burn time based on target Pi (Pi5 serial config differs from other Pi serial config)
* Improvements
  * Use `truncate` rather than `qemu-img` to extend an IMG. (Thanks @1stcall) Same result but removes a package dependency
  * `--shrink` switch now honors `--xmb nnnn` to shrink the root partition and leave some additional free space
  * IMG mounting redone to use dynamic loop devices (Thanks @simlu). Still need to bring this to a few other functions (shrink, expand, parted plugin)
  * Add `wayfire-ini` argument to `lxde` plugin to copy your pre-configured wayfire.ini into the IMG
  * Add `wayvnc` argument to `vnc` plugin to enable wayvnc when using Wayland
* Bug fixes
  * Further improve handling of cmdline.txt and config.txt WRT /boot/firmware
  * Remove the `gid` keyword from the `user` plugin. Not relevant in an sdm environment. The user's primary group can be fully specified with the `Group` and `groups` keywords. This has no effect on the gid specified with the `user` plugin `addgroup` directive

## V10.2

* Bug fixes
  * If /boot/firmrware exists, touch /boot/firmware/ssh in addition to /boot/ssh
  * Improve some quoted parameter handling. A bug with spaces in plugin argument strings still remains
  * Correct erroneous colon handling in code that checks for newer plugins on host than in IMG

## V10.1

* Improvements
  * Change to the `copydir` plugin
    * If `rsyncopts` is specified, ALL desired rsync switches must be included. If `rsyncopts` is NOT provided, plugin will use the default `-a`
* Bug fixes
  * URGENT: Correctly handle /boot/firmware. See <a href="https://github.com/gitbls/sdm/issues/144">this bug report</a> for details
  * Correctly check for and handle `redact` in the `user` plugin

## V10.0

* New Features
  * New plugins
    * `copydir` &mdash; Copy a directory from the host into the IMG using rsync
    * `mkdir` &mdash; Create a directory and optionally set owner and protection
  * Eliminate `--plugin` command line explosion
    * sdm interprets a plugin name starting with **@** as the name of a file containing a list of plugins
    * Each file contains plugins, one per line. For example: user:useradd=pi. The string `--plugin` is not acceptable in the file    * Reduces sdm command line clutter
    * See <a href="Docs/Plugins.md#invoking-a-plugin-on-the-sdm-command-line">Plugins </a> for details
  * Stop customization and exit sdm if:
    * A plugin returns failure (non-zero) status
    * An apt command fails
    * IMG root partition is full (checked at points where remaining size is checked and printed)
  * Add `plugin_addnote` function for plugins to add notes to log (/etc/sdm/history)
    * Collected during the run and appended to the log at run completion
    * Useful for reminders, guidance, etc
    * See <a href="Docs/Programming-Plugins-and-Custom-Phase-Scripts.md"> Programming Plugins </a> for details and plugins `pistrong` and `postfix` for usage examples
* Improvements
  * *Dramatically* speed up extending an IMG by using qemu-img (Thanks @carriba)
    * EZsdmInstaller also installs `qemu-utils`. You'll need to install this manually if not using the Installer
  * Dramatically speed up `--burnfile` on btrfs and other copy-on-write file systems (Thanks @1stcall)
  * Increase apt usage consistency in sdm and plugins (code quality)
  * Add additional information about host and IMG in /etc/sdm/history
* Bug fixes
  * Fix rare "IMG already attached to a loop device" race condition
  * Ensure that parted always prints in MB during extend
  * copyfile plugin corrections
    * Eliminate case where file is copied multiple times
    * Eliminate redundant 'directory created' messages
    * Log when setting chown and chmod

## V9.6

* Add `--no-expand-root` command line switch
  * Forces `--regen-ssh-host-keys`, does not expand the root partition after burn, and...
  * Disables the RasPiOS firstboot service that expands the root partition
  * Net result: Root partition does not expand to fill the disk, so you can add additional partitions
* Enable `system` plugin to be correctly invoked multiple times
  * Use `name=` argument for 2nd-subsequent invocations
  * See <a href="Docs/Plugins.md#system">system plugin</a> for details
  * Best practice to avoid problems is to always include the `name=` argument
* Log IMG architecture (32-bit vs 64-bit) in /etc/sdm/history at start of customization
* Don't check for plugin in current directory unless explicitly specified
* Correct typo in sdm-apt-cacher
* Updates to `chrony` plugin
  * Correct plugin operation and rename argument `source` to `sources` to improve code
  * Add `nodistsources` argument that comments out the Debian vendor zone pool (in case you don't want it)
* If systemd-nspawn fails running on 64-bit system and IMG is 32-bit, report host/IMG pagesize issue with suggested fix
  * Problem exists b/c not all programs and shared libraries are linked to 16Kb alignment on 32bit RasPiOS
  * See <a href="https://github.com/gitbls/sdm/issues/123">this issue</a> for details and a link to the RasPiOS bug
* The `pistrong` plugin now disables the strongswan service after apt install
* sdm-firstboot can now check for time synchronization with chrony in addition to systemd-timesyncd

## V9.5

* Update strongSwan modules loaded in pistrong plugin
* Correct `dtoverlay=something`
* Make sure that generated new disk ids are always valid

## V9.4

* Move `--rclocal` from command line to `system` plugin. This should be the last switch that gets pluginated
* sdm will always use `systemd-nspawn`. If this fails with an execve the command switch `--chroot` can be added to your command line
  * ALSO, if systemd-nspawn fails for you please open an issue on this GitHub. I'd like to do some testing, but I'm having trouble finding one that fails!
* And, if using chroot, set up temporary /etc/resolv.conf
* Improve GiB/GB printing code. Thanks @origonn!

## V9.3

* New Features
* Improvements
  * Update Install Guide
  * Update (minor) Network Manager hints based on learnings
* Bug Fixes
  * Be more careful with file ownership/protection

## V9.2

* New Features
  * `hotspot` plugin is available in Beta &mdash; Supports bridged and routed hotspots. See <a href="Docs/Plugins.md#hotspot">Hotspot plugin</a> for details. Your feedback is greatly appreciated.
  * `wificonfig` plugin is available (also Beta) &mdash; `wificonfig` runs a captive portal to get WiFi config information via a WiFi-served web page at FirstBoot
* Improvements
  * Print size in GB and GiB when starting a `--burn` (IMG size) or `--extend` (extend size)
* Bug Fixes
  * Correct boot_behavior, er, behaviour
  * Network plugin now sets /etc/NetworkManager/system-connections/*.* protection to 600
  * `bootconfig` plugin correctly handles `dtoverlay` and `dtparam`
  * `L10n` plugin picks up `wificountry` from host if `host` argument specified and it's available
  * `network` plugin correctly saves `wificountry`, rescuing it from walkabout.

## V9.1.1

* sdm in-line code restructured into plugins, grouping similar functions together, and related code together
* Many Command-Line Switches replaced by plugins, and switches removed from sdm command line
  * If you run sdm from a script, you'll need to make some very straightforward updates to it
  * See the <a href="Docs/9Upgrade-Notes.md">complete switch migration guide here</a>
  * New or updated plugins: L10n, system, user, graphics, lxde, bootconfig, and raspiconfig
  * The `adduser` and `burnpwd` plugins are removed and replaced by an enhanced `user` plugin
* Improvements
  * sdm on github now has prior releases available. v8.6 is the first. See <a href="Docs/Detailed-Installation-Guide.md">installing sdm</a> for details
  * List selected plugins at top of /etc/sdm/history for easy review
  * Since the (former) command line switches are now in plugins, they can now all be used during both customization and burning
  * Plugin keys can now contain a hyphen. Internally hyphens are changed to `__`, plugins are responsible for handling this (see `system` plugin, for instance)
  * Time sync wait extended to 2 mins (120 seconds) in sdm-firstboot to accomodate slower processors and more heavyweight Network Manager (guess?)
* Bug fixes
  * Correct `--extend` operation
  * At start of customize don't try to re-protect local-plugins if there aren't any 
  * Re-enable using chroot in certain instances. systemd-nspawn not qemu-capable yet on some distros
  * Handle --autologin for CLI only system
  * Repair broken 'exit' in copyfile plugin
  * Correct `apt-cacher-ng` plugin `bindaddress` handling

## V8.6

* Correct copyfile plugin multiple invocations and clean up error handling

## V8.5

* Correct device handling for --expand-root during burn
* Add support for --bootadd on the --burn command

## V8.4

* Add new `copyfile` plugin. Simplifies copying files into an IMG without you writing a plugin

## V8.3

* Allow hostname to be set during customize as well as burn
* If runas `user` provided to plugin runatboot, check that it exists before running the script at First Boot
* First phase of spawn usage improvements; should be no visible changes
* If `--regen-ssh-host-keys`, delay starting ssh service at FirstBoot until host key regen completes
* Code cleanups

## V8.2

* Add new `ufw` plugin to install and configure ufw
* Update EZsdmInstaller with new files
* If `--regen-ssh-host-keys` is set, disable running the service; sdm-firstboot runs it if after the system time has been set
* Remove extraneous chmods on files in /etc/sdm/0piboot. sdm-firstboot now does that before running them
* Add new arguments to `runatboot` plugin: `user` and `sudoswitches`

## V8.1

* Enable these switches to be specified multiple times on the command line: `--disable`, `--poptions`, `--bootset`, `--poptions`, `--svc-disable`, and `--svc-enable`
* Improve  wpa configuration handling and wificountry in `network` plugin
* Handle hostname NOT being "raspberrypi" when burning and `--hostname` used
* Ensure that WiFi country is set and properly configured if it's available (`--l10n`, `--wificountry`, or in wpa_supplicant.conf)
* New plugin: `runatboot` runs the specified script with the provided arguments during the First Boot of the system

## V8.0

* Initial Bookworm support
* Changes in apps installs, graphics, network handling with new plugins: `apps`, `network`, `graphics`, `quietness`
* Removed switches no longer needed: `--apps`, `--xapps`, `--netman`, `--dhcpcd`, `--dhcpcdwait`, `--nowpa`, `--mouse`, and `--vncbase`
  * See <a href="Docs/Upgrade-Notes.md">Upgrade Notes</a>
* Removed poptions no longer needed: `apps`, `nodmconsole`, `xwindows`, `xapps`
  * See <a href="Docs/Upgrade-Notes.md">Upgrade Notes</a>
* Graphics (X11, Wayland) changes to accomodate Bookworm and new features
  * `graphics` plugin installs X11 core (xserver-xorg xserver-xorg-core xserver-common) if X11 requested
  * On Bullseye Desktop and earlier, system default is X11. Switching to Wayland not supported
  * On Bookworm Desktop and later, system default is Wayland, can switch to X11
* `quietness` plugin provides simple control for the cmdline.txt settings quiet and nosplash
* Bug fixes
  * Fixed incorrect default bindaddress in apt-cacher-ng plugin
  * Fixed incorrect echoing of terminal color inquiry responses
  * Fixed plugin argument parsing handling of ':'
* Documentation updates (lots)

## V7.18

* When copying files from host into IMG in Phase 0, ensure proper file ownership and protection

## V7.17

* New plugin: `trim-enable` enables SSD trim on all or only selected SSD devices

## V7.16

* Captive portal updates: Optionally provide list of visible WiFi SSIDs in configuration dialog; Increase font sizes.

## V7.15

* Captive Portal updates including timeout and a plugin for enhanced implementation flexibility

## V7.14

* Reimplement the Captive Portal. See See <a href="Docs/Captive-Portal.md">Captive Portal</a> for details
## V7.13

* Add `--runonly plugin` to only run plugins (vs a full customize). See <a href="Docs/Programming-Plugins-and-Custom-Phase-Scripts.md#running-only-plugins">Running only plugins</a> for details

## V7.12

* Use `cp -a` for most file copies to preserve actual file creation date/time

## V7.11.1

* When burning, sdm checked for plugins' existence too late. It's now just right.

## V7.11

* Correct plugin update handling during burn commands when full path to plugin provided. See <a href="Docs/Programming-Plugins-and-Custom-Phase-Scripts.md">Programming Plugins</a> for details
* Improve message consistency

## V7.10

* Add new plugin burnpwd that will either prompt for a user's password or generate a random password, wih neither being stored in the IMG
* Add missing "delete loop device" to `--burnfile` after the burn
* Check for new plugins and new sdm files on the host relative to what is written to the burned output
* Add `--bupdate` to check and update plugins in the burned output
* Improve handling of SDMNSPAWN so it's always correct
* Set netman default to "" instead of dhcpcd. Default is now whatever is already installed instead of dhcpcd

## V7.9.1

* Make `--user` handling independent of `--nopassword`.

## V7.9

* Wiki documentation updated and completely moved to this github Docs/ directory. Wiki will be removed soon
* Add --nopassword to fully disable password processing during customize
* Add `--rename-pi newuser` to rename the 'pi' user during customization
* New plugins
  * **btwifiset**: Set WiFi SSID/password via Bluetooth
  * **imon**: Install internet up/down, External IP, and Failover monitor
  * **pistrong**: Install strongSwan IPSEC VPN and pistrong Cert Manager
* General code improvements

## V7.8

* Correct V7.7.1 chroot fix
* Ensure pre-phase0 and burn logging contain all messages
* Don't try to process `--user` in burn if it's already added

## V7.7.1

* unset/restore SDMPT around chroot

## V7.7

* If created user doesn't have .bashrc, .profile, or .bash_logout copy them from /etc/skel
* Re-jigger password getting/setting. `--user` now defaults to pi if not specified 
* Enable `--disable`, `--svc-disable', `--svc-enable', and `--autologin` switches with `--burn`
* Improve first boot graphical desktop switching
* Improve apt error detecting/reporting
* Code improvements

## V7.6

* Improve compressed file check
* Improve 'already mounted' check

## V7.5

* Report the occurrence of apt failures in the sdm history

## V7.4

* plugin names can be a full path spec now, and will be copied into local-plugins if needed
* Some generated new disk IDs will now be odd numbers

## V7.3

* Add `--redact` which redacts passwords from /etc/sdm/cparam and /etc/sdm/history. Best to only use on burn command, but also honored on customize
* Ensure that `--bootset` `boot_behaviour` setting is honored

## V7.2

* Use systemctl to get systemd version rather than systemd
* Redo wsl support to autodetect chroot required
  * Detects sdm running on WSL, x86/64
  * Also enables 32-bit RasPiOS to customize 64-bit RasPiOS (slow b/c of qemu but it works!)
* Enable `--user` on the `--burn` command
  * User will be created with specified uid (if `--uid`) or useradd choice of next uid, and home directory created
  * sdm will prompt for password if `--user` specified without `--password-user`
  * User directory can be populated by using a personalized plugin or b0script/b1script
* Correct usermod command in sdm-gburn to append, not replace, groups

## V7.1

* Plugins should do installs in Phase 1 so that Custom Phase Script post-installs can count on them being there. All provided plugins corrected.

## V7.0

* Plugins are here! Like Custom Phase Scripts, Plugins enable sdm functionality to be extended in a modular way. Plugins can be used during `--customize` and `--burn`. See https://github.com/gitbls/sdm/wiki/sdm-Plugins for details.
* Initial plugin set: apt-cacher-ng, apt-file, postfix, rxapp, samba, vnc. See above link for complete details.
* As a result of the new plugins, the following sdm switches have been removed: `--vnc` and `--poptions samba`, which are now available as plugins.
* If sdm installed into /usr/local/sdm, add a link to it in /usr/local/bin, eliminating the need for an alias. Thanks @arpj-rebola for the `realpath` hint
* Code cleanups. Replace most use of `readarray` with `read -a` and fix potential IFS breakage. Cleaner code, less cruft, less oopsie opportunity.

## V6.13

* Add `--debug apt` which installs packges from apps and xapps one at a time instead of all at once. This is useful, for instance, in tracking down which specific package has install problems.
* Streamline exit handling
* Handle down-rev sfdisk that does not have the --disk-id switch by falling back to fdisk
* Redo new disk ID generation for efficiency and simplicity 

## V6.12

* sdm works in Windows WSL! Well, for everything but burning to SSDs/SD Cards. See https://github.com/gitbls/sdm/wiki/Using-sdm-on-Windows-WSL for details.
* Add --nowait-timesync which skips waiting for date/time synchronization in sdm-firstboot. Useful if no network
* Remove /etc/ssh/sshd_config.d/rename_user.conf at the end of first boot; part of /usr/bin/cancel-rename

## V6.11

* Per-system wpa config option in sdm-gburn and allow comment lines and blank lines
* Improve delayed display manager handling for both Lite and Desktop editions

## V6.10

* systemd didn't get '--console` switch until V242, so don't use it on earlier versions

## V6.9

* Basic network manager configuration via `--netman dhcpcd|nm` switch. Preliminary and may change.
* Implement non-interactive sdm usage (--explore, --customize, --mount)

## V6.8

* Properly cleanup/exit when CTRL/C caught. This can obviously leave IMG/SSD/SD in indeterminate state, but mounts and loop devices cleaned up
* If both --expand-root (on burn command) and --regen-ssh-host-keys (on --burn or --customize command) are enabled, disable the unneeded RasPiOS firstboot script when burning
* Burn to (IMG) file improvements
* Always change Disk ID when burning
* Correct wrong parameter order bug identified by @StefanTischler
* Enable sdm-gburn to not add a user if needed for use case (e.g., users created in --customize)
* In addition to disabling userconfig service, also mask it, just in case.

## V6.7

* Correct re-enabling display manager after first boot
* Correct a couple of backwards stderr redirects

## V6.6

* Vast improvements to sdm-gburn. See https://github.com/gitbls/sdm/wiki/Batch-burn-SSD-SDs-with-sdm-gburn
* Reimagined and reimplemented autologin and firstboot autoreboot handling; it's MUCH better
* Add `--nouser` to disable user creation enforcement; Useful with sdm-gburn to burn a large number of SSD/SDs at one sitting
* Add `--autologin` to explicitly enable autologin, on Lite and with Desktop
* Change `--disable piwiz` to properly disable piwiz on Desktop version and userconfig service on both Desktop and Lite
* Set hostname on burn even if IMG is not sdm-enhanced
* Code cleanups

## V6.5

* Improve --expand-root processing, and enable it for non-customized images. Use sfdisk to extend the root partition and set the disk ID. Thanks @rpdom.

## V6.4

* Enable getty@tty1 if using `--svc-disable userconfig`. Since sdm can do effectively what the userconfig service does (add a new user with a password) it needs to complete the system configuration that the userconfig service does. /usr/lib/userconf-pi/userconf calls /usr/bin/cancel-rename, which enables getty@tty1.

## V6.3

* Check for parted installed if `--extend`

## V6.2

* Add sdm-gburn script, which burns a group of per-recipient customized SD Cards from a single IMG. Useful for classrooms or commercial distribution, for instance.
* Correct comments for in quote-stripping code

## V6.1

* Mask or unmask services when enabling/disabling them via --svc-enable/--svc-disable, as appropiate. Hat tip to RonR.

## V6.0

* Test and verify that sdm works correctly with RasPiOS 2022-04-07. See https://github.com/gitbls/sdm/wiki/Hint:-Using-sdm-on-2022-04-04-and-later-RasPiOS-images for details.
  * If using sdm on pre-2022-04-04 images, the user 'pi' password is changed by default (password of your choice, of course!)
  * If using sdm on 2022-04-04 or later images, the user 'pi' password is only changed if you specify `--user pi` on the command line
* `--user` is now **required** on customizations. For pre-2022-04-04 you can specify `--user pi` if you don't want a new user created. For 2022-04-04 or later images, use this to create your favorite username, or use `--user pi` if desired
* Remove requirement than sdm must reside in /usr/local/sdm. It can now be anywhere in the file system
  * To install sdm into a directory other than /usr/local/sdm on your running system, provide the directory name as the first argument to `EZsdmInstaller`. You must download and run EZsdmInstaller locally with `sudo /path/to/EZsdmInstaller` */path/to/install-sdm* to use this capability
  * Use `--sdmdir` */path/to/dir* when customizing to change where sdm places itself in the customized image
  * **IMPORTANT: This creates a (slightly) incompatible change in Custom Phase scripts.** See the 'loadparams' function in sdm-customphase and update your Custom Phase script accordingly
* Improved error checking in EZsdmInstaller
* Enable command line switch `--L10N` and `--L10n` in addition to `--l10n`

## V5.5

* Correct check for any partitions on the burn target device being mounted and provide a useful message if so.

## V5.4

* WARNING: In order to bring consistency between the burn phase and the customization phase, switch `--b1script` has been renamed to `--b0script` and `--b2script` has been renamed to `--b1script`. Apologies for any inconvenience this causes. See https://github.com/gitbls/sdm/wiki/Burn-Scripts for details.

## V5.3a

* Buglet fix: Incorrect check for /mnt/sdm existence

## V5.3

* Improve status message readability at --shrink completion
* When burning, don't set hostname to an fqdn if --domain specified, leaving that to the user. However, fqdn IS added to /etc/hosts entry 127.0.0.1
* Fix edge case in --shrink that threw an incorrect message

## V5.2

* Add --expand-root. When used with --burn, expands the root partition on the SSD/SD Card after burning. This eliminates the need for the resize/reboot when first booting the system, which, by the way, is automatically disabled when you use --expand-root.

## V5.1

* sdm now creates, but doesn't use, /etc/sdm/local-assets in the IMG, for your use in Custom Phase Scripts
* Don't try to flush the burn log if /etc/sdm doesn't exist in the burn target
* Multiple copies of sdm can be simultaneously active on the same system, removing a prior restriction. sdm uses /mnt/sdm if it's available. If not, it uses /mnt/sdm.$BASHPID. NOTE: If you are using a Custom Phase script and want to use multiple active sdm instances, you must edit your Custom Phase script and change all instances of /mnt/sdm to $SDMPT. See the updated example Custom Phase script
* Processing of svc-disable, svc-enable, and bootset switches are no longer deferred to FirstBoot, except in the case of using the switches on the --burn command. In this case they are processed during FirstBoot
* Tidy up VNC handling. sdm can install RealVNC for graphically accelerated console VNC. RealVNC Virtual Desktops require an Enterprise License, so you can use one of TigerVNC or TightVNC for virtual desktops.
* Fix cosmetic race condition on RasPiOS with Desktop where autologin was prematurely re-enabled by FirstBoot. 
* General code cleanups

## V5.0

* Rearrange documentation into a Wiki
* Add --shrink to shrink an IMG file
* Add --ppart to display the partitions in an IMG file or SSD/SD Card
* Add --svc-disable and --svc-enable for switch naming consistency
* Enable --rclocal on burn command
* Don't disable wpa_supplicant service and raspberrypi-net-mods. If you want them disabled, use either --svc-disable or a custom phase script
* Correct dhcpcd wait logic to accommodate buster/bullseye image location difference
* Move processing of several switches from Phase 0 to Phase 1, since they don't need access to local system storage: --bootadd, --bootconfig, --dtoverlay, --dtparam, --hdmi-force-hotplug, --hdmi-ignore-edid, --hdmigroup, --hdmimode, --rclocal

## V4.20

* Copy 1piboot.conf to /usr/local/sdm/1piboot on target in sdm as well as to /etc/sdm

## V4.19

* Add --gadget-mode to configure the image for USB Gadget Mode
* Add --swap n to set swap size to nMB
* Add --regenerate-ssh-host-keys to regenerate SSH host keys after system time is synced (or 60 seconds elapse)
* Enable --rclocal to be used on the burn command. (Each target burn can have a different set of rc.local commands if desired)
* Copy 1piboot.conf to /usr/local/sdm/1piboot as well as to /etc/sdm

## V4.18

* Add --disable options,in,a,list. Valid options are bluetooth, piwiz, swap, triggerhappy, and wifi
* Add --systemd-config item:filename to augment systemd config files for: login,network,resolve,system,timesync,user. See README for details
* Remove --noswap and --nopiwiz in favor of --disable
* Reorder and group processing "similar" Phase 0 and Phase 1 customizations together (sdm, networks, user, system)

## V4.17

* Add --journal to control the system journal configuration (syslog, journal|persistent, volatile, none)

## V4.16

* Add --noswap to disable dphys-swapfile and hence no swapfile created or used
* Suppress "Reading database" messages from apt/dpkg that were spewed into /etc/sdm/apt.log
* Correct xvnc*@.service definitions for Bullseye systemd: Remove User=nobody, set StandardError to journal
* 1piboot script 030-disble-rsyslog now writes the config change to a file in /etc/systemd/journald.conf.d/

## V4.15

* Add --password-pi, --password-user, and --password-root to set account passwords from the command line. See README for details, especially the important note about Password retention in the image. These switches can also be used to apply unique passwords when burning an SSD/SD Card.
* Add --password-same y|n, which avoids the "Use same password?" question during customization
* Add --redo-customize, which skips the "Image is already customized, Redo?" prompt
* add -q to systemd-nspawn command to eliminate some extraneous message spew
* Correct mis-handling of --info help command
* General message improvements
* General code improvements

## V4.14

* Add --lxde-config, which enables you to correctly load config files for lxterminal and pcmanfm. See the README for details. If there are other apps that you'd like to see included, please open an issue on this github. (Side note: The bash construct `${!symbol}` is so cool!)
* Add --logwidth N, which sets the maximum log line width before splitting. Default is 96 characters.

## V4.13

* Improve disk space used logging

## V4.12

* Always disable sdm-firstboot service at end of FirstBoot processing
* Improve check for "is package installed"

## V4.11

* Fix sdm-phase0 creating $myuser home directory on running system rather than in /mnt/sdm
* Fix erroneous redirects in sdm-phase1 (and checked others!)
* Have you ever mistakenly pointed sdm to a ZIP file instead of the IMG contained within it? I did today. Never again though!

## V4.10

* Add missing hyphens to hdmi-ignore-edid in switch table

## V4.09

* Add --hdmi-ignore-edid which sets hdmi_ignore_edid=0xa5000080 in /boot/config.txt
* Correct some references to logit function
* Correct dd switches for improved performance
* Enable sdm-hotspot to install hotspot without using sdm (see source)

## V4.08

* Improve and simplify Phase 0 vs 1 identification to reduce code complexity
* Improve --b2script handling

## V4.07

* Add --hotspot to install and configure a hotspot, either as 'local', 'routed', or 'bridged'
* Add --b1script to run a script after the SSD/SD Card has been burned. See README
* Add --b2script to run a script, like --b1script, but in the context of the newly-burned SD Card (nspawn)

## V4.06

* Add --mouse left to enable left-handed mouse in LXDE (for those that are in their right mind)
* Add --nopiwiz to disable piwiz from running on LXDE desktop systems (no effect if no LXDE)
* Remove --aptconfirm, a holdover from very early releases (didn't work, and could hang apt waiting for input)

## V4.05

* Log apt maintenance steps
* Add --cron-systemd to disable the cron service and use systemd timers instead.

## V4.04

* Have you been burned by running of of space in an IMG during customization and not noticing it? This fix is for you (and me!) Print number of free blocks at start of customization, start of Phase 1, and at the end of Phase 1. Also, if IMG appears full at end of Phase 1, log a very visible message.

## V4.03

* Set --eeprom value during FirstBoot so an upgrade during Phase 1 doesn't risk a deadlock if apt asks for resolution on the modified /etc/default/rpi-eeprom-update
* Disable --poptions 'nofirstboot' poption. It's still accepted in case anyone was using it, but it is ignored.
* Polished Display Manager configuration in Phase 1
* Add --poption 'noautoremove' to skip the apt autoremove in Phase 1
* Add --poption 'novnc' to skip processing --vnc. Useful for scripting.
* Add --showpwd to log passwords created in /etc/sdm/history. Explicitly set protection of /etc/sdm to 700.
* If --wpa is used to provide a wpa_supplicant.conf, disable raspberrypi-net-mods to speed up boot time by an infintesimally small amount.

## V4.02

* Add --vnc switch to configure tigervnc or tightvnc virtual servers, and/or the RealVNC graphical console server. You can easily install the RealVNC server attached to the graphical console (Lite), and several Virtual VNC servers (Desktop and Lite), each with their own preconfigured geometry (handy if you connect to a host from different systems with varied screen sizes)
* If xdm or wdm is installed, enable it on console after FirstBoot unless --poptions 'nodmconsole' (lightdm is not configurable for this AFAICT)
* Add --groups to control which groups are added to user created with --user

## V4.01

* EZinstaller update to make LAN-based testing easier
* Improve some help text
* Only copy "known" 1piboot/*.sh files when copying sdm into an image. If you have other scripts you want in the image, copy them using a Custom Phase Script.

## V4.00

* Rework readparams, logit, and logtoboth. If you are using a Custom Phase Script, you'll need to edit it and remove the first argument to logit and logtoboth. They now only take one argument, the string to be output. If you don't do this, you'll see blank lines, or lines with "/mnt/sdm".
* Add --domain domainname. This is not used by sdm, but is available for use in your Custom Phase Script
* Write hostname to cparams when burning

## V3.26

* Correct block device check so sdm doesn't try to mount a non-existent IMG file

## V3.25

* Enable sdm to operate on an OS directory tree with --directory
* Code cleanliness: Add missing 'local' declarations in functions
* Correct --motd handling, and enable --motd /dev/null to create a null /etc/motd

## V3.24

* Add --modprobe to add /etc/modprobe.d config files into image
* Add --motd to replace /etc/motd with a different message
* --sysctl can be specified multiple times

## V3.23

* Add --udev to add udev files into image

## V3.22

* Correct --noreboot operation
* Document switches supported on --burn command
* Make EZsdmInstaller OS-aware and install additional packages as appropriate
* Disable apt config file modification checking during apt upgrade
	

## V3.21

* Handle partitions on /dev/mmcblk0 correctly, named "p1" and "p2", not "1" and "2"

## V3.20

* Minor correction in handling of --dtparam --dtoverlay strings
* Add --rclocal to add command lines to /etc/rc.local
* Add --cron-{d,hourly,daily,weekly,monthly} to copy a crontab file to the corresponding /etc/cron.{d,hourly,daily,weekly,monthly} directory

## V3.19

* Implement --dtparam and --dtoverlay. Multiple of each can be specified
* Improve --help command code so it isn't so ugly

## V3.18

* --extend should not require --nowpa
* Redo --extend handling. --extend will extend an image by --xmb N MB. --extend with --customize extends image and then customizes, if used without --customize, just extends and then exits. --noextend is no longer needed.
* --customize is now required to customize an image.
* Basic testing on Stretch images, which work fine. Functions added to raspi-config in Buster will obviously not work on Stretch, but still handy to have Localization, WiFi, SSH, and app installations working if you need to go back to Stretch for any reason.

## V3.17

* Correct --apps and --xapps switch value handling

## V3.16

* Add --bootset powerled:n for Pi Zero and Pi400 (currently). n=0 to flash LED on disk activity, n=1 on constantly

## V3.15

* Complete logging of --exports, --sysctl, and --dhcpcd on burn command
* Improve --burn messages consistency

## V3.14

* Add --exports file which copies the specified file into the image as /etc/exports
* Add --sysctl file which copies the specified file into the image in /etc/sysctl.d The filename must end with '.conf'
* Change --dhcpcd behavior to append to /etc/dhcpcd.conf in the image during Phase 0, so that it is in place for the first system boot.
* Support --exports, --sysctl, and --dhcpcd on the burn command as well.

## V3.13

* Improve help if image has already been customized
* Add --aptmaint update,upgrade,autoremove for "batch" mode IMG maintenance

## V3.12

* Improve DHCP wait logic in sdm-firstboot
* Correct file naming local-1piboot(.conf) in sdm-firstboot
* Add --hdmi-force-hotplug 1 to easily enable the setting in config.txt
* Add --loadlocal wifi to get WiFi credentials via a Captive Portal WiFi hotspot. FlashLED doesn't work with this. Yet.
* Add --dhcpcdwait to enable 'wait for internet'. Equivalent to raspi-config System Option S6.
* Add --dhcpcd file to append the contents of 'file' to /etc/dhcpcd.conf

## V3.11

* --loadlocal accepts additional values 'flashled' signal status with the Green LED) and 'internet' (check for Internet connectivity)
    
## V3.10

* Add --loadlocal to load WiFi and Localization details from a USB device on First Boot. Handy if sending an image or SD Card to
someone who doesn't want to disclose their WiFi credentials.
* Add --info command to 'less' the databases used for checking Time Zones, Locales, Keymaps, and WiFi Country. See `sdm --info help` for details
* Check switch value errors for Locale, Keymap, Timezone, and WiFi Country

## V3.9

* Correct numeric test check

## V3.8

* Check that switches with numeric values are as they should be

## V3.7

* FirstBoot message cleanups
* Always run firstboot scripts created in /etc/sdm/0piboot (e.g., from Custom Phase Scripts)

## V3.6

* Minor logging updates in sdm-firstboot
* Remove gratuitous "Done" in sdm-cparse
* --reboot now takes a value for number of seconds to wait after system has reached default target before restarting. --restart does NOT take a value, and has a wait time of 20 seconds.

## V3.5

Updates:

* Redo FirstBoot handling for improved efficiency

## V3.4

New features:

* SSD tested and works
* Add --bootset command switch. Now all 1piboot settings can be done from the command line
* Strip carriage returns when importing wpa_supplicant.conf just in case
* Document enabling boot from USB disk (SSD)

## V3.3

New features:

* Strip carriage returns when importing wpa_supplicant.conf just in case
* --mount and --explore now operate on block devices, such as SD Cards, as well as IMG files

## V3.2

This is a major overhaul from prior versions. Error and message handling has been cleaned up and improved. 

New features:

* **Automatic reboot** after the system First Boot &mdash; Get to a fully-configured system more quickly. Super-useful if you're using the Serial Port to connect to your Pi.
* **RasPiOS Desktop **integration &mdash; Automatic reboot shows in the console window during the system First Boot, and reboots to the full Graphical Desktop
* **rasPiOS device support **(serial, i2c, spi, camera, etc...) &mdash; Any device capabilities that can be set with raspi-config, can be set with sdm.
* **Burn to an IMG file** in addition to burn to an SD card. Very useful if you want to send an SD Card Image to someone so that they can burn their own SD Card
* **/etc/fstab extension** &mdash; Easily add site-specific mounts to add to /etc/fstab
*  Simplified Localization&mdash; `--L10n` gathers the localization settings from the system on which sdm is running, or easily specify on the command line using `--keymap`, `--locale`, `--timezone`, and `--wifi-country
* **Integrated wpa_supplicant.conf handling** &mdash; Specify your wpa_supplicant.conf on the command line
* **Integrated SSH handling** &mdash; SSH is enabled by default. Use `--ssh none` to disable SSH, or `--ssh socket` to use systemd socket-based SSH to remove one process from the running system.
