# sdm
Raspberry Pi SSD/SD Card Image Manager

## Description

`sdm` provides a quick and easy way to build consistent, ready-to-go SSDs and/or SD cards for the Raspberry Pi. This command line management tool is especially useful if you:

* have multiple Raspberry Pi systems and you want them all to start from an identical and consistent set of installed software packages, configuration scripts and settings, etc.

* want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed. Every time.

* want to be nice to your future self and make it super-easy to build fresh, customized systems when that next release of RasPiOS comes out.

* want to produce disks or IMGs for others without risk of having ANY of your own bits accidentally distributed

* want to do the above repeatedly and a LOT more quickly and easily.

What does *ready-to-go* mean? It means that every one of your systems is fully configured with Keyboard mapping, Locale, Timezone, and WiFi set up as you want, all of your personal customizations and all desired RasPiOS packages and updates installed.

In other words, all ready to work on your next project.

With `sdm` you'll spend a lot less time rebuilding SSDs/SD Cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

Have questions about sdm? Please don't hesitate to ask in the Issues section of this github. If you don't have a github account (so can't post an issue/question here), please feel free to email me at: [gitbls@outlook.com](mailto:gitbls@outlook.com).

If you find sdm useful, please consider starring it to help me understand how many people are using it. Thanks!

## Usage overview

### sdm Quick Start

Here's how to quickly and easily to create and customize an IMG file and burn it to an SD Card. It's assumed that there is an SD Card in /dev/sde.

**Throughout this document read "SD Card" as "SSD or SD Card".** sdm treats them equivalently.

## Install sdm

```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
```
`install-sdm` installs the sdm files to /usr/local/sdm, and installs other required RasPiOS packages if they are not installed (binfmt-support coreutils gdisk keyboard-configuration parted qemu-user-static rsync systemd-container uuid)

**Or, download the Installer script to examine it before running:**
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm -o /path/to/install-sdm
chmod 755 /path/to/install-sdm
# Inspect the install-sdm script if desired
/path/to/install-sdm
```
## Grab an IMG to customize

* **If needed, download** the desired RasPiOS zipped IMG from the raspberrypi.org website and **unxz** it. (IMGs from older releases were zipped)
* Direct link to the downloads: [Raspberry Pi Downloads](https://downloads.raspberrypi.org//?C=M;O=D)
* Pick the latest (Trixie) image in the *images* subfolder of **raspios_armhf** (32-bit), **raspios_lite_armhf** (32-bit), **raspios_arm64** (64-bit), or **raspios_lite_arm64** (64-bit), as appropriate. Bookworm images are in the **raspios_oldstable** folders.

## Customize the image with sdm

The easiest way to get started with sdm customization is to take a copy of `/usr/local/sdm/ezsdm` into your own directory and edit it as desired.

If you use the default `ezsdm` without modifying it, sdm will make the following changes to your IMG file:
* Copy your **Localization settings** (Keymap, Locale, Timezone, and WiFi Country) from the system on which it's running (if running on RasPiOS, Debian, or a Debian derivative such as Mint or Ubuntu)
* Configure the system in the IMG file to have **SSH enabled**
* Create the user `myuser` with the given password and enable sudo for that user
* Do an `apt update` and `apt upgrade`
* Installs a few example apps
* Configures WiFi for SSID `myssid` and password `mywifipassword`
* Prevents piwiz and cloudinit from running (neither are needed when using sdm and could cause unexpected behaviors)

## Burn the image onto the SD Card
```sh
sudo sdm --burn /dev/sdX --hostname mypi1 --expand-root 2025-10-01-raspios-trixie-arm64.img --plugin sshhostkey:generate-keys
```
Modify `/dev/sdX` to refer to the disk you want to burn.

Using the `sshhostkey` plugin regenerates the SSH host keys as part of burning the disk and ensures that the system has higher entropy than during a system boot.

## Boot and Go

Load the SD card into a Pi and power it up. The system will come up as it always does:

* **WILL NOT:** Resize the root file system and restarts automatically, thanks to the use of `--expand-root`, which expands the root file system on the SD Card after the burn completes.
* After the system starts it goes through a complete system startup, just as it always does on a fresh SD Card
* Toward the end of the boot process the sdm FirstBoot service runs (once). It takes other actions as needed to fulfill the requested configuration.
* When the system boot is fully complete, the system automatically restarts again

When the system comes back up your Pi is all happy, ready to go, and configured with:

* **The latest RasPiOS updates installed** for all installed packages
* **User created** and password set for username and password of your choice and sudo enabled
* **Hostname** set to *mypi1*, or whatever you choose to use as the hostname
* **Keymap**, **Locale**, and **Timezone** configured the same as the system on which you are running sdm (easily changeable, of course)
* **SSH** enabled

You can review the output of the sdm first boot script on the newly-booted system with:
```sh
journalctl -b -1 | grep FirstBoot
```

NOTE: Sometime late in Bookworm the default retention of the system journal changed from keeping them all to removing them on shutdown. If you want to retain all system journals, uncomment or add `system:journal=persistent` to your personal `ezsdm` script.

## Next steps

If you want to adopt sdm into your RasPiOS management tools, a great way to get started is to use the <a href="Docs/Example-Commands.md#official-getting-started-with-sdm-script">Official Getting Started With sdm script</a> to quickly and easily learn how to customize an IMG.

The most important new user docs are: <a href="Docs/Command-Details.md">Command Details</a> and <a href="Docs/Plugins.md">Plugins</a>.

## What else can sdm do?

Here are a few examples:

* **Install applications**  &mdash; Editors (emacs, vim, zile, etc), and any other packages (browsers, etc) you always install in a new system. Direct sdm to install apps using the `apps` plugin. See <a href="Docs/Plugins.md#apps">the apps plugin</a> for details.

* **Install and configure VNC** &mdash; Have every system or only selected systems come up with VNC installed and configured, using either RealVNC on the console, or TightVNC or TigerVNC virtual desktops. Or a combination of RealVNC on the console AND virtual desktops. See <a href="Docs/Plugins.md#vnc">the VNC plugin</a>.

* **Install and configure a WiFi Access Point (hotspot)** &mdash; Install a customizable, fully operational WiFi hotspot in any of three modes: *local*, *routed*, or *bridged*.

* **Install and configure a USB hotspot** &mdash; Enable the Pi to provide USB-tethered network connections via USB to another computer

* **Install and configure USB gadget mode** &mdash; Enable the Pi to access networking via USB tethering from a host computer

* **Enable Pi-specific devices** &mdash; Easily enable camera, i2c, etc, via raspi-config automation. See <a href="Docs/Plugins.md#raspiconfig">raspiconfig plugin </a>.

* **Personal customizations** &mdash; Have every system come up running with your own customizations such as your favorite .bashrc and any other files that you always want on your system. This can be done easily using <a href="Docs/Plugins.md#copyfile">the `copyfile` plugin</a> or with a personal Plugin. See <a href="Docs/Example-Plugin.md">my personal plugin</a> for an example.

* **Append Custom fstab file to /etc/fstab** &mdash; Automatically append your site-specific fstab entries to /etc/fstab. See <a href="Docs/Plugins.md#system">system plugin for details</a>.

* **systemd service configuration and management** &mdash; If there are services that you always enable or disable, you can easily configure them with sdm. See the description of the `service-disable` and `service-enable` arguments to <a href="Docs/Plugins.md#system">the system plugin</a>.

* **Other customizations** &mdash; Done through a simple batch script called a <a href="Docs/Plugins.md">Plugin</a>. sdm-plugin-example is a skeleton Plugin that you can copy, modify, and use. See <a href="Docs/Programming-Plugins-and-Custom-Phase-Scripts.md">Programming Plugins</a>.

* **Automatic rootfs encryption** &mdash; Make your system more secure with an encrypted root file system using only a few commands.

* **Burn SD Card Image for network distribution** &mdash; You can also burn a customized SD Card Image to distribute via a mechanism other than an actual SD Card, such as the Internet.

    The recipient can burn the SD Card using any one of a number of tools on Linux ([Installing Operating System Images](https://www.raspberrypi.org/documentation/installation/installing-images/)), Windows ([Installing Operating System Images Using Windows](https://www.raspberrypi.org/documentation/installation/installing-images/windows.md)), or MacOS ([Installing Operating System Images Using MacOS](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)).

* **Choose from a wide selection of sdm plugins** &mdash; sdm Plugins are <a href="Docs/Plugins.md">fully documented</a> and provide a broad set of functionality including: copy files into the IMG, install IPSEC or Wireguard VPNs, configure SSH host and user keys, install PiApps, etc.

* **Update an already-burned RasPiOS SD Card or SSD** &mdash; use the `--explore` command switch to nspawn into the SD Card or SSD. While in the nspawn you can take care of system management activities in a near-online manner, such as changing the password for an account, installing additional packages, etc.

    This can be VERY handy if you forget the password to your user account on your favorite SD Card, for instance. You can boot up a second SD Card, install sdm on it, and then use `sdm --explore` to update the account password on that favorite SD Card.

## Complete sdm Documentation

Need more details? You'll find complete details about sdm in the <a href="Docs/Index.md">online documentation</a> and plugin-specific documentation <a href="Docs/Plugins.md">here.</a>

You can watch sdm in action <a href="https://youtu.be/CpntmXK2wpA">here</a> It's an older video and doesn't use plugins, but will give you a good idea of how sdm works.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/gitbls/sdm)
