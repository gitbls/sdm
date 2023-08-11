# Plugins

## Plugin Overview

Plugins are a modular way to extend sdm capabilities. Plugins are similar to <a href="Custom-Phase-Script.md">Custom Phase Scripts</a>, but can work both during customization and/or when burning an SSD/SD Card.

It makes sense to include some plugins into the IMG you're creating (e.g., postfix, samba) so they are installed onto every system burned from that IMG, but some are typically installed once per network (e.g., apt-cacher-ng), or not needed on every system. In that case you can use the plugin when burning the SSD/SD for that specific system.

The set of plugins provided with sdm includes: apt-cacher-ng, apt-file, btwifiset, clockfake, imon, pistrong, postfix, rxapp, samba, vnc, wificonfig, and wsdd.

Other plugins are planned. If there are any specific plugins you're interested in, let me know!

You can add your own plugins as well. Put the plugin script in /usr/local/sdm/local-plugins, and it will be automatically found. sdm looks at local-plugins first, so you can override an sdm-provided plugin with your modifications if desired.

You can also specify the plugin name with a full path. sdm will copy the plugin to /usr/local/sdm/local-plugins if it does not exist or the one specified is newer than the one in local_plugins.

## Invoking a plugin on the sdm command line

Specify each plugin with a separate `--plugin` switch:

```
sdm --plugin samba:"args" --plugin postfix:"args" . . .
```

Multiple `--plugin` switches can be used on the command line. This includes specifying the same plugin multiple times (the `apps` plugin, for example).

The complete plugin switch format is:
```sh
--plugin plugname:"key1=val1|key2=val2|key3=val3"
```
Enclose the keys/values in double quotes as above if there is more than one key/value or bash will be confused by the "|".

See below for plugin-specific examples and important information.

## Plugin-specific notes

### sdm-plugin-template

sdm-plugin-template can be used to build your own plugin. It contains some code in Phase 0 demonstrating some of the things you can do with the *plugin_getargs* function and how to access the results.

### addusers

addusers can be used to add user accounts quickly and easily, either during IMG customization or burning a disk. The user information can be specified in the plugin arguments, or an argument pointing to a list (file) of users to add can be used. addusers will log the added account information to a file on the host if directed to do so.

#### Arguments

* **username** &mdash; Specifies the username to add
* **password** &mdash; Specifies the password for the new username. If no password is provided, no password is set for the new user
* **uid** &mdash; Specifies the UID for the new user. If not provided, the system will assign an unused uid
* **groups** &mdash; Specifies the list of groups to be added to the new user. If not specified, the groups specified by the command line `--groups` switch are used. The default is "dialout,cdrom,floppy,audio,video,plugdev,users,adm,sudo,users,input,netdev,spi,i2c,gpio"
* **homedir** &mdash; Specifies the home directory for the new user. If not specified, /home/$username is used
* **nohomedir** &mdash; if `nohomedir=y` is specified, no home directory will be created for the user, even if `homedir` is provided
* **nosudo** &mdash; If `nosudo=y` is specified, the user will not be enabled to use the `sudo` command. In other words, `sudo` is enabled by default
* **samba** &mdash; If `samba=y` is specified, add the username to the samba password file. If `smbpasswd` is not specified, `password` will be used. If neither is provided, the user will not be added to the samba password file
* **smbpasswd** &mdash; Use this password for samba for the user instead of the user's password
* **userlist** &mdash; The /full/path/to/logfile of a list of users to add. See below.
* **log** &mdash; The /full/path/to/file of a file on the host OS where sdm is running to log all users added via the addusers plugin. If `log` is not specified, addusers will not write a separate log file.

The `userlist=/full/path/to/logfile` option points to a file that consists of one line per user in the format:
```
username=theusername|password=thepassword|homedir=homedir|...
```
Only arguments that are set for a user need be specified, and they are processed as described above.

NOTE: If you do not want any user's passwords to be visible in /etc/sdm/history, use `userlist`, rather than `--plugin addusers` on the command line.

### apps

Use the apps plugin to install applications. The apps plugin can be called multiple times on a command line. In that case, each invocation must include the `name=` parameter. The name can be any alphanumeric (including "-", "_", etc.) you want.

#### Arguments

* **apps** &mdash; Specifies the list of apps to install or @filename to provide a list of apps (one per line) to install. Comments are indicated by a pound sign (#) and are ignored, so you can document your app list if desired. If the specified file is not found, sdm will look in the sdm directory (/usr/local/sdm). 
* **name** &mdash; Specifies the name of the apps list. The default name is *default*, but it can only be used once per customization. If you want to use the apps plugin 2 or more times, all plugin instances after the first must have a name provided.

#### Examples

* `--plugin apps:"apps=emacs,vim,zile"` &mdash; Install emacs, vim, and zile
* `--plugin apps:"apps=@my-apps|name=myapps" --plugin apps:"apps=@my-xapps|name=myxapps"` &mdash; Install the list of apps in the file @my-apps, and the list of apps in @my-xapps
* `--plugin apps:"apps=@mycoreapps|name=core-apps"` `--plugin apps:"apps=@myaddtlapps|name=extra-apps"` &mdash; Install the list of apps from @mycoreapps and @myaddtlapps

### apt-cacher-ng

apt-cacher-ng installs the RasPiOS apt-cacher-ng service into the IMG or onto the SSD/SD card (If used with `--burn`).

#### Arguments

**NOTE: All arguments are optional**

* **gentargetmode** &mdash; Possible values: 'Set up once', 'Set up now and update later', and 'No automated setup'. [Default: 'No automated setup']. TBH not sure what this does. If you figure it out, let me know ;)
* **bindaddress** &mdash; the IP address to which the server should bind. [Default: 0.0.0.0], which is all IP addresses on the server.
* **cachedir** &mdash; apt-cacher-ng directory. [Default: */var/cache/apt-cacher-ng*]
* **port** &mdash; TCP port [Default: 3142]
* **tunnelenable** &mdash;Do not enable this. [Default: *false*]
* **proxy** &mdash;TBH not sure what this does. If you figure it out, let me know ;)

The default apt-cacher-ng server install uses port 3142. apt-cacher-ng will be enabled by sdm FirstBoot and ready to process requests after the FirstBoot process completes.

### apt-file

apt-file installs the *apt-file* command and builds the database. This is very handy for looking up apt-related information.

#### Arguments

There are no `--plugin` arguments for apt-file

### btwifiset

btwifiset is a service that enables WiFi SSID and password configuration over Bluetooth using an iOS app. Once the service is running, you can use the BTBerryWifi iOS app to connect to the service running on your Pi and configure the WiFi. See https://github.com/nksan/Rpi-SetWiFi-viaBluetooth for details on btwifiset itself.

#### Arguments

* **country** &mdash; The WiFi country code. This argument is mandatory
* **localsrc** &mdash; Locally accessible directory where the btwifiset.py can be found, instead of downloading from GitHub
* **btwifidir** &mdash; Directory where btwifiset will be installed. [Default: */usr/local/btwifiset*]
* **timeout** &mdash; After *timeout* seconds the btwifiset service will exit [Default: *15 minutes*]
* **logfile** &mdash; Full path to btwifiset log file [Default: *Writes to syslog*]

### burnpwd

burnpwd enables you to defer setting the password on an account until the SD card is actually burned,. To use burnpwd, use the `--nopassword` switch during customization, and add `--burnpwd username:"arguments"` to the sdm burn command. burnpwd can either prompt for the password, or it can generate a random password.

The password is not stored in an unencrypted form anywhere on the burned output device. You can use the *log* argument to burnpwd to direct burnpwd to log passwords **on the host**, which is handy, especially if you have burnpwd generate a random password.

#### Arguments

* **user** &mdash; The username to set the password for. The user must already exist in the IMG. If you need to do multiple users, add the `--burnpwd` switch multiple times.
* **method** &mdash; Specifies the method to obtain the password. *prompt* will prompt for the password; *random* will generate a random password
* **length** &mdash; Used with **method=random** to specify the length of the generated password. Default:20
* **log** &mdash; Specifies the /full/path/to/logfile on the host where the passwords are stored. This is extremely important if you use **method=random**, as the password is not stored anywhere else!

### chrony

Chrony installs the chronyd time service.

#### Arguments

* **conf** &mdash; /full/path/to/confname.conf that will be placed into /etc/chrony/conf.d
* **conf2** &mdash; /full/path/to/confname2.conf that will be placed into /etc/chrony/conf.d
* **conf3** &mdash; /full/path/to/confname3.conf that will be placed into /etc/chrony/conf.d
* **source** &mdash; /full/path/to/sourcename.conf that will be placed into /etc/chrony/sources.d
* **source2** &mdash; /full/path/to/sourcename2.conf that will be placed into /etc/chrony/sources.d
* **source3** &mdash; /full/path/to/sourcename3.conf that will be placed into /etc/chrony/sources.d

Chrony processes the files in the conf.d and sources.d directories on startup. Having 3 provides flexibility in how these are structured. See `man chrony.conf` for details.

A RasPiOS system should only have one time service enabled. It's up to you to disable others. For instance, on a standard RasPiOS IMG you should add `--svc-disable systemd-timesyncd` to disable the in-built time service, which is enabled by default.

### clockfake

The fake-hwclock provided with RasPiOS runs hourly as a cron job. clockfake does the same thing as fake-hwclock, but you control the interval, and it's always running. Lower overhead, less processes activated, and more control. Life is good.

#### Arguments

* **interval** &mdash; Interval in minutes between fake hardware clock updates

### graphics

The graphics plugin configures various graphics-related settings. It doesn't do much for wayland at the current time, although you might use it to set the video mode in /boot/cmdline.txt.

#### Arguments

* **graphics** &mdash; Supported values for the graphics keyword are `wayland` and `X11`. At the present time `wayland` does very little. If graphics is set to `X11`, the Core X11 packages (xserver-xorg, xserver-xorg-core, and xserver-common) are installed if not already installed. In the post-install phase, the plugin will look for a known Display Manager (lightdm, xdm, or wdm), and make appropriate adjustments (see below)
* **lhmouse** &mdash; If LXDE is installed (RasPiOS Desktop), set the mouse to left-handed. 
* **nodmconsole** &mdash; If graphics=X11, nodmconsole directs sdm to NOT start the Display Manager on the console, if the Display Manager is lightdm, wdm, or xdm.
* **videomode** &mdash; Specifies the string to add to the video= argument in cmdline.txt. See below for an example.

wayland is the Default graphics subsystem on Bookworm with Desktop images, so `graphics=wayland` is ignored on those images. The plugin currently will not install wayland on a Bookworm Lite IMG. Wayland is not supported by sdm on releases prior to Bookworm.

If graphics=X11 and the Display Manager is known, the graphics plugin makes a few adjustments. Specifically:
* If LXDE is installed, the mouse will be set to left-handed if specified on the command line. This works for wayland as well.
* For lightdm, wdm, and xdm, sdm will cause the boot behavior you might specify to be delayed until after the First Boot.

The videomode argument takes a string of the form: 'HDMI-A-1:1024x768M@60D'. sdm will add video=HDMI-A-1:1024x768M@60D to /boot/cmdline.txt

#### Examples

* `--plugin graphics:"graphics=X11|nodmconsole` &mdash; Installs the X11 core components and disables the Display Manager on the console
* `--plugin graphics:"videomode=HDMI-A-1:1920x1280@60D"` &mdash; Sets the specified video mode in /boot/cmdline.txt
### imon

imon installs an <a href="https://github.com/gitbls/imon">Internet Monitor</a> that can monitor:

* **Dynamic DNS (DDNS) Monitor** &mdash; Monitors your external IP address. If it changes changes, your action script is called to take whatever you'd like, such as update your ddns IP address.
* **Network Failover Monitor** &mdash; If your system has two connections to the internet, internet-monotor can provide a higher availability internet connection using a primary/secondary standby model.
* **Ping monitor** &mdash; Retrieve ping statistics resulting from pinging an IP address at regular intervals.
* **Up/down IP Address Monitor** &mdash; Monitors a specified IP address, and logs outages.

#### Arguments

There are no `--plugin` arguments for imon

### knockd

knockd installs the knockd service and <a href="https://github.com/gitbls/pktables">pktables</a> to facilitate easier knockd iptables management.

#### Arguments

* **config** &mdash; Full path to your knockd.conf. If **config** isn't provided, /etc/knockd.conf will be the standard knockd.conf
* **localsrc** &mdash; Locally accessible directory where pktables, knockd-helper, and knockd.service can be found, instead of downloading them from GitHub. If there is a knockd.conf in this directory, it will be used, unless overridden with the **config** argument

### network

Use the network plugin to configure various network settings

#### Arguments

* **netman** &mdash; Specify which network manager to use. Supported values are `dhcpcd`, `network-manager`, and `nm` (short for network-manager). dhcpcd is the default on Bullseye (Debian 11) and earlier, while Network Manager is the default on Bookworm (Debian 12).
* **dhcpcdappend** &mdash; Specifies a file that should be appended to /etc/dhcpcd.conf. Only processed if `netman=dhcpcd`
* **dhcpcdwait** &mdash; Specifies that dhcpcd wait for network online should be enabled. Only processed if `netman=dhcpcd`
* **wpa** &mdash; Specifies the file to be copied to /etc/wpa_supplicant/wpa_supplicant.conf. Only processed if `netman=dhcpcd`. Network Manager does not use wpa_supplicant.
* **wifissid** &mdash; Specifies the WiFi SSID to enable. If `wifissid`, `wifipassword`, and `wificountry` are all set, the network plugin will create /etc/wpa_supplicant/wpa_supplicant.conf (if `netman=dhcpcd`), or will use nmcli during First Boot to establish the specified WiFi connection.
* **wifipassword** &mdash; Password for the `wifissid` network. See `wifissid`
* **wificountry** &mdash; WiFi country for the `wifissid` network. See `wifissid`
* **noipv6** &mdash; Specifies that IPv6 should be disabled. Works with both `netman=dhcpcd` and `netman=nm`
* **nmconf** &mdash; Specifies a comma-separated list of Network Manager config files that are to be copied to /etc/NetworkManager/conf.d (*.conf)
* **nmconn** &mdash; Specifies a comma-separated list of Network Manager connection definitions that are to be copied to /etc/NetworkManager/system-connections (*.nmconnection)

#### Examples

* `--network:"netman=dhcpcd|noipv6"` &mdash; On Bookworm, set the network manager to dhcpcd (and disable Network Manager), and direct dhcpcd to not request an IPv6 address.
* `--network:"netman=nm|wifissid=myssid|wifipassword=myssidpassword|wificountry=US|noipv6"` &mdash; Use Network Manager to configure the network and also configure the specified WiFi network.

### pistrong

<a href="https://github.com/gitbls/pistrong">pistrong</a> installs the strongSwan IPSEC VPN server and `pistrong`. pistrong provides

* A fully-documented, easy-to-use Certificate Manager for secure VPN authentication with Android, iOS, Linux, MacOS, and Windows clients
* Tools to fully configure a Client/Server Certificate Authority and/or site-to-site/host-to-host VPN Tunnels. Both can be run on the same VPN server instance

#### Arguments

* **ipforward** &mdash; Enable IP forwarding from the VPN server onto the LAN. Value can be `yes` or `no` [Default: *no*]

### postfix

postfix installs the postfix mail server. This plugin installs the postfix server but at the moment doesn't do too much to simplify configuring postfix. BUT, once you have a working /etc/postfix/main.cf, it can be fed into this plugin to effectively complete the configuration.

#### Arguments

* **maincf** &mdash; The full /path/to/main.cf for an already-configured /etc/postfix/main.cf. If provided, it is placed into /etc/postfix after postfix has been installed.
* **mailname** &mdash; Domain name [Default: *NoDomain.com*]
* **main_mailer_type** &mdash; Type of mailer [Default: *Satellite system*]
* **relayhost** &mdash; Email relay host DNS name [Default: *NoRelayHost*]

#### Examples

* `--plugin postfix:"maincf=/path/to/my-postfix-main.cf` &mdash; Uses a fully-configured main.cf, and postfix will be ready to go.
* `--plugin postfix:"relayhost=smtp.someserver.com|mailname=mydomain.com|rootmail=myemail@somedomain.com` &mdash; Set some of the postfix parameters, but more configuration will be required to make it operational. A good reference will be cited here at some point.

### quietness

The quietness plugin controls the quiet and splash settings in /boot/cmdline.txt

#### Arguments

* **quiet** &mdash; Enables 'quiet' in /boot/cmdline.txt
* **noquiet** &mdash; Disable 'quiet' in /boot/cmdline.txt. If `noquiet=keep` is NOT specified, sdm will re-enable 'quiet' in cmdline.txt after the First Boot.
* **splash** &mdash; Enables 'splash' in /boot/cmdline.txt
* **nosplash** &mdash; Disable 'splash' in /boot/cmdline.txt. If `nosplash=keep` is NOT specified, sdm will re-enable 'splash' in cmdline.txt after the First Boot.
* **plymouth** &mdash; Enables Plymouth in /boot/cmdline.txt. Not Yet Implemented
* **noplymouth** &mdash; Disables the Plymouth graphical splash screen for the First Boot (only). It is re-enabled at the end of First Boot.

#### Examples

* `--plugin quietness:"noquiet=keep|nosplash=keep"` &mdash; Remove 'quiet' and 'splash' from cmdline.txt and do not re-enable them
* `--plugin quietness:"noquiet|nosplash|noplymouth"` &mdash; Remove 'quiet' and 'splash' from cmdline.txt, and disable plymouth. All will be re-enabled after the First Boot.

### rxapp

**rxapp** is a handy tool to securely and remotely start X11 apps via SSH without a password. You can read about it [here](https://github.com/gitbls/rxapp).

rxapp is included because it is generally useful, but also as a demonstration of how to copy a file from the network (GitHub in this case) into the IMG in a plugin.

#### Arguments

There are no `--plugin` arguments for rxapp

### samba

#### Arguments

* **smbconf** &mdash; Full */path/to/smb.conf* for an already-configured /etc/samba/smb.conf. If provided it is placed into /etc/samba after samba has been installed.
* **shares** &mdash; Full */path/to/shares.conf* for a file containing only the samba share definitions. If provided it is appended to /etc/samba/smb.conf after samba has been installed.
* **dhcp** &mdash; TBH not sure what this does. If you figure it out, let me know ;)
* **do_debconf** &mdash; TBH not sure what this does. If you figure it out, let me know ;)
* **workgroup** &mdash; Workgroup name to replace WORKGROUP in the default /etc/samba/smb.conf. If *smbconf* is specified, the workgroup is NOT modified.

#### Examples

* `--plugin samba:smbconf=/home/bls/mylan-smb.conf` &mdash; Use the provided fully-configured file for /etc/samba/smb.conf
* `--plugin samba:"shares=/home/bls/mysmbshares.conf"` &mdash; Append the provided share definitions to the end of the default /etc/samba/smb.conf
* `--plugin samba:"workgroup=myworkgroup|shares=/home/bls/mysmbshares.conf"` &mdash; Use the default /etc/samba/smb.conf, set the workgroup name to *myworkgroup* and append the provided share definitions to /etc/samba/smb.conf

### trim-enable

trim-enable will enable <a href="https://en.wikipedia.org/wiki/Trim_(computing)">SSD Trim</a> on all or only selected devices. Trim is not actually enabled on the devices until the system first boots.

This plugin can be run manually on a running sdm-customized system by
```
sdm --runonly plugins --plugin trim-enable:"disks=/dev/sda,/dev/sdb"
```
The optional switch `--oklive` can be used to avoid the Prompt "Do you really want to run plugins live on the running host?"

#### Arguments

* **disks** &mdash; Specifies the disks on which to enable trim. `disks=all` will enable trim on all drives. Multiple disk names can be specified by, for example, `disks=/dev/sda,/dev/sdb`. If no disks are specified, `disks=all` is the default.

Additional information on SSD Trim for RasPiOS and Linux can be found <a href="https://forums.raspberrypi.com/viewtopic.php?t=351443">here</a>, <a href="https://lemariva.com/blog/2020/08/raspberry-pi-4-ssd-booting-enabled-trim">here</a>, and <a href="https://www.jeffgeerling.com/blog/2020/enabling-trim-on-external-ssd-on-raspberry-pi">here</a>.

### vnc

Install and configure either or both of Virtual VNC and RealVNC.

#### Arguments

* **vncbase=port** &mdash; Starting port for VNC Servers (default: 5900)
* **realvnc=resolution** &mdash; Install RealVNC server with the specified resolution on the console. The resolution is optional.
* **tigervnc=res1,res2,...resn** &mdash; Install tigervnc server with virtual VNC servers for the specified resolutions
* **tightvnc=res1,res2,...resn** &mdash; Install tightvnc server with virtual VNC servers for the specified resolutions

Only one of tigervnc or tightvnc can be installed and configured on a system by sdm.

#### Examples

* `--plugin vnc:"realvnc|tigervnc=1280x1024,1600x1200` &mdash; Install RealVNC server for the console and tigervnc virtual desktop servers for the specified resolutions.
* `--plugin vnc:"realvnc=1600x1200"` &mdash; Install RealVNC server and configure the console for 1600x1200, just as raspi-config VNC configuration does.
* `--plugin vnc:"tigervnc=1024x768,1600x1200,1280x1024"` &mdash; Install tigervnc virtual desktop servers for the specified resolutions. Only configure RealVNC if it is already installed (e.g., RasPiOS with Desktop IMG).

#### Additional details

By default Virtual VNC desktops are configured with ports 5901, 5902, ... This can be modified with the `--vncbase` *base* switch. For instance, `--vncbase 6400` would place the VNC virtual desktops at ports 6401, 6402, ... Setting `--vncbase` does not change the RealVNC server port.

For RasPiOS Desktop, RealVNC Server will be enabled automatically. Well, actually, it will be disabled for the first boot of the system as will the graphical desktop, and the sdm FirstBoot service will-reenable both for subsequent use.

For RasPiOS Lite, if the `nodmconsole` keyword is specified to the graphics plugin AND the Display Manager is xdm or wdm, the Display Manager will not be started on the console, and neither will RealVNC Server. It can be started later, if desired, with `sudo systemctl enable --now vncserver-x11-serviced`. Note, however, that you must enable the Display Manager as well for it to really be enabled. To enable the Display Manager:

* **xdm:**&nbsp;`sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/xdm/Xservers`
* **wdm:** `sed -i "s/\#\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/\:0 local \/usr\/bin\/X :0 vt7 -nolisten tcp/"  /etc/X11/wdm/Xservers`

### wificonfig

wificonfig is used to enable the sdm Captive Portal to delay WiFi SSID/Password configuration until the first system boot.

#### Arguments

* **apssid=APSSID** &mdash;SSID for the Access Point. Default: *sdm*
* **apip=ap.ip.ad.dr** &mdash;IP Address for the Access Point. Default: *10.1.1.1*
* **country=cc** &mdash;Two-letter WiFi country code. The codes are found in /usr/share/zoneinfo/iso3166.tab
* **defaults=/path/to/defaults** &mdash;Path to defaults file. See <a href="Captive-Portal.md#defaults-file">Defaults file</a> for details
* **facility=facname** &mdash;Facility name. Default: *sdm*
* **retries=n** &mdash;Maximum number of retries for the user to set the SSID/Password. Default: *5*
* **timeout=n** &mdash;Captive Portal timeout (interval between network packets from the connecting device). Default: *900 seconds* (15 minutes)
* **wifilog=/path/to/wifilog** &mdash;Log file for the Captive Portal. Default: */etc/sdm/wifi-config.log*

### wsdd

wsdd is the Web Service Discovery host daemon. It's very useful in Windows/Samba environments. You can read about it at https://github.com/christgau/wsdd

Note that wsdd is available in Bookworm via apt, so this plugin is not needed on Bookworm (Debian 12) or later, although it can still be used if you prefer.

#### Arguments

* **wsddswitches=switchlist** &mdash; List of switches to write into /etc/default/wsdd
* **localsrc=/path/to/files** &mdash; Local directory with cached copy of wsdd (files: wsdd.py wsdd.8 wsdd.defaults wsdd.service)

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
