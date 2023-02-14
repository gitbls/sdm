# sdm
Raspberry Pi SSD/SD Card Image Manager

## Description

`sdm` provides a quick and easy way to build consistent, ready-to-go SSDs and/or SD cards for the Raspberry Pi. This command line management tool is especially useful if you:

* have multiple Raspberry Pi systems and you want them all to start from an identical and consistent set of installed software packages, configuration scripts and settings, etc.

* want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed. Every time.

* want to do the above repeatedly and a LOT more quickly.

What does *ready-to-go* mean? It means that every one of your systems is fully configured with Keyboard mapping, Locale, Timezone, and WiFi set up as you want, all of your personal customizations and all desired RasPiOS packages and updates installed.

In other words, all ready to work on your next project.

With `sdm` you'll spend a lot less time rebuilding SSDs/SD Cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

Have questions about sdm? Please don't hesitate to ask in the Issues section of this github. If you don't have a github account (so can't post an issue/question here), please feel free to email me at: [gitbls@outlook.com](mailto:gitbls@outlook.com).

Need more details? Watch sdm in action [here](https://youtu.be/CpntmXK2wpA)

If you find sdm useful, please consider starring it to help me understand how many people are using it. Thanks!

## Usage overview

### sdm Quick Start

Here's how to quickly and easily to create and customize an IMG file and burn it to an SD Card. It's assumed that there is an SD Card in /dev/sde.

**Throughout this document read "SD Card" as "SSD or SD Card".** They are treated equivalently by sdm.

## Install sdm
`curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash`

* **If needed, download** the desired RasPiOS zipped IMG from the raspberrypi.org website and **unzip it**. Direct link to the downloads: [Raspberry Pi Downloads](https://downloads.raspberrypi.org//?C=M;O=D). Pick the latest (Bullseye) image in the *images* subfolder of **raspios_armhf** (32-bit), **raspios_lite_armhf** (32-bit), **raspios_arm64** (64-bit), or **raspios_lite_arm64** (64-bit), as appropriate. Buster images are in the folders **raspios_oldstable_lite_armhf** and **raspios_oldstable_armhf**.

## Customize the image with sdm
`sudo sdm --customize --wpa /path/to/working/wpa_supplicant.conf --L10n --restart --user myuser --password-user mypassword 2022-04-04-raspios-bullseye-armhf.img `

sdm will make the following changes to your IMG file:
* Copy your **Localization settings** (Keymap, Locale, Timezone, and WiFi Country) from the system on which it's running
* Copy the **wpa_supplicant.conf** you specified into the IMG file at /etc/wpa_supplicant/wpa_supplicant.conf
* Configure the system in the IMG file to have **SSH enabled**
* Prompt for a new **password for user pi**
* Do an  `apt update` and `apt upgrade`

No additional packages are installed in this example, but as you'll see, it's a simple addition to the command line to install your list of packages.

## Burn the image onto the SD Card
`sudo sdm --burn /dev/sde --hostname mypi1 --expand-root 2022-04-04-raspios-buster-armhf.img`

## Boot and Go

Load the SD card into a Pi and power it up. The system will come up as it always does:

* **WILL NOT:** Resize the root file system and restarts automatically, thanks to the use of `--expand-root`, which expands the root file system on the SD Card after the burn completes.
* After the system restarts it goes through a complete system startup, just as it always does on a fresh SD Card
* Toward the end of the boot process an sdm systemd service script runs once and sets the WiFi country, unblocking WiFi. It will also take other actions as needed to fulfill the switch settings.
* When the system boot is fully complete (it can take a while on a large SD card!), the system automatically restarts again

When the system comes back up your Pi is all happy, ready to go, and configured with:

* **The latest RasPiOS updates installed** for all installed packages
* **User created** and password set for username and password of your choice
* **Hostname** set to *mypi1*, or whatever you choose to use as the hostname
* **Keymap**, **Locale**, and **Timezone** configured the same as the system on which you are running sdm (easily changeable, of course)
* **Wifi** configured and operational
* **SSH** enabled

## What else can sdm do?

Here are a few examples:

* **Install applications**  &mdash; Editors (emacs, vim, etc), and any other packages you always install in a new system. sdm has two built-in package install lists, creatively named *apps* and *xapps*. You can select which of the two lists to include when you build an image, so you can build images with no additional apps, *apps* only, *xapps* only, or both.

    See <a href="Docs/Example-Commands.md">Example Commands</a> for some examples, and also see the files sdm-apps-example and sdm-xapps-example in this GitHub.

* **Install and configure VNC** &mdash; Have every system or only selected systems come up with VNC installed and configured, using either RealVNC on the console, or TightVNC or TigerVNC virtual desktops. Or a combination of RealVNC on the console AND virtual desktops. See <a href="Docs/VNC.md">VNC</a>.

* **Install and configure an Access Point (hotspot)** &mdash; Install a customizable, fully operational hotspot in any of three modes: *local*, *routed*, or *bridged*.

* **Enable Pi-specific devices** &mdash; Easily enable camera, i2c, etc, via raspi-config automation. See <a href="Docs/Bootset-and-1piboot.md">`--bootset` and 1piboot</a>.

* **Personal customizations** &mdash; Have every system come up running with your own customizations such as your favorite .bashrc and any other files that you always want on your system. This can be done easily with a personal Plugin. See <a href="Docs/Example-Plugin.md">my personal plugin</a> for an example.

* **Append Custom fstab file to /etc/fstab** &mdash; Automatically append your site-specific fstab entries to /etc/fstab. See <a href="Docs/fstab.md">fstab details</a>.

* **systemd service configuration and management** &mdash; If there are services that you always enable or disable, you can easily configure them with sdm. See `--svc-disable` and `--svc-disable` descriptions <a href="Docs/Command-Details.md">here</a>.

* **Other customizations** &mdash; Done through a simple batch script called a <a href="Docs/Plugins.md">Plugin</a>. sdm-plugin-example is a skeleton Plugin that you can copy, modify, and use. See <a href="Docs/Programming-Plugins-and-Custom-Phase-Scripts.md">Programming Plugins</a>.

* **Burn SD Card Image for network distribution** &mdash; You can build a customized SD Card Image to distribute via a mechanism other than an actual SD Card, such as the Internet.

    The recipient can burn the SD Card using any one of a number of tools on Linux ([Installing Operating System Images](https://www.raspberrypi.org/documentation/installation/installing-images/)), Windows ([Installing Operating System Images Using Windows](https://www.raspberrypi.org/documentation/installation/installing-images/windows.md)), or MacOS ([Installing Operating System Images Using MacOS](https://www.raspberrypi.org/documentation/installation/installing-images/mac.md)).

* **Update an already-burned RasPiOS SD Card or SSD** &mdash; use the `--explore` command switch to nspawn into the SD Card or SSD. While in the nspawn you can take care of system management activities in a near-online manner, such as changing the password for an account, installing additional packages, etc.

    This can be VERY handy if you forget the password to the 'pi' account on your favorite SD Card, for instance. You can boot up a second SD Card, install sdm on it, and then use `sdm --explore` to update the 'pi' account password on that favorite SD Card.

## Complete sdm Documentation

Need more details? You'll find complete details on sdm in the <a href="Docs/index.md">online documentation</a>. You can watch sdm in action <a href="https://youtu.be/CpntmXK2wpA">here</a>
