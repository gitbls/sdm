# Plugins

## Plugin Overview

Plugins are a modular way to extend sdm capabilities. Plugins are similar to <a href="Custom-Phase-Script.md">Custom Phase Scripts</a>, but can work both during customization and/or when burning an SSD/SD Card.

It makes sense to include some plugins into the IMG you're creating (e.g., postfix, samba) so they are installed onto every system burned from that IMG, but some are typically installed once per network (e.g., apt-cacher-ng), or not needed on every system. In that case you can use the plugin when burning the SSD/SD for that specific system.

The set of plugins provided with sdm includes: apt-cacher-ng, apt-file, btwifiset, clockfake, imon, pistrong, postfix, rxapp, samba, vnc, and wsdd.

Other plugins are planned. If there are any specific plugins you're interested in, let me know!

You can add your own plugins as well. Put the plugin script in /usr/local/sdm/local-plugins, and it will be automatically found. sdm looks at local-plugins first, so you can override an sdm-provided plugin with your modifications if desired.

You can also specify the plugin name with a full path. sdm will copy the plugin to /usr/local/sdm/local-plugins if it does not exist or the one specified is newer than the one in local_plugins.

## Invoking a plugin on the sdm command line

Specify each plugin with a separate `--plugin` switch:

```
sdm --plugin samba:"args" --plugin postfix:"args" . . .
```

Multiple `--plugin` switches can be used on the command line.

The complete plugin switch format is:
```
--plugin plugname:"key1=val1|key2=val2|key3=val3"
```
Enclose the keys/values in double quotes as above if there is more than one key/value or bash will be confused by the "|".

See below for plugin-specific examples and important information.

## Plugin-specific notes

### sdm-plugin-template

sdm-plugin-template can be used to build your own plugin. It contains some code in Phase 0 demonstrating some of the things you can do with the *plugin_getargs* function and how to access the results.

### addusers

addusers can be used to add user accounts quickly and easily, either during IMG customization or burning a disk. The user information can be specified in the plugin arguments, or an argument pointing to a list of users to add can be used. addusers will log the added account information to a file on the host if directed to do so.

#### Arguments

* **username** &mdash; Specifies the username to add
* **password** &mdash; Specifies the password for the new username. If no password is provided, no password is set for the new user
* **uid** &mdash; Specifies the UID for the new user. If not provided, the system will assign an unused uid
* **groups** &mdash; Specifies the list of groups to be added to the new user. If not specified, the groups specified by the command line `--groups` switch are used. The default is "dialout,cdrom,floppy,audio,video,plugdev,users,adm,sudo,users,input,netdev,spi,i2c,gpio"
* **homedir** &mdash; Specifies the home directory for the new user. If not specified, /home/$username is used
* **nohomedir** &mdash; if `nohomedir=y` is specified, no home directory will be created for the user, even if `homedir` is provided
* **nosudo** &mdash; If `nosudo=y` is specified, the user will not be enabled to use the `sudo` command. In other words, `sudo` is enabled by default
* **samba** &mdash; Add the username to the samba password file. If `smbpasswd` is not specified, `password` will be used. If neither is provided, the user will not be added to the samba password file
* **smbpasswd** &mdash; Use this password for samba for the user instead of the user's password
* **userlist** &mdash; The /full/path/to/logfile of a list of users to add. See below.
* **log** &mdash; The /full/path/to/file of a file on the host OS where sdm is running to log all users added via the addusers plugin

The `userlist=/full/path/to/logfile` option points to a file that consists of one line per user in the format:
```
username=theusername|password=thepassword|homedir=homedir|...
```
Only arguments that are set for a user need be specified, and they are processed as described above.

NOTE: If you do not want any user's passwords to be visible in /etc/sdm/history, use `userlist`, rather than `--plugin addusers` on the command line.

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

### clockfake

The fake-hwclock provided with RasPiOS runs hourly as a cron job. clockfake does the same thing as fake-hwclock, but you control the interval, and it's always running. Lower overhead, less processes activated, and more control. Life is good.

#### Arguments

* **interval** &mdash; Interval in minutes between fake hardware clock updates

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

### vnc

#### Arguments

* **realvnc=resolution** &mdash; Install RealVNC server with the specified resolution on the console. The resolution is optional.
* **tigervnc=res1,res2,...resn** &mdash; Install tigervnc server with virtual VNC servers for the specified resolutions
* **tightvnc=res1,res2,...resn** &mdash; Install tightvnc server with virtual VNC servers for the specified resolutions

Only one of tigervnc or tightvnc can be installed and configured on a system by sdm.

#### Examples

* `--plugin vnc:"realvnc|tigervnc=1280x1024,1600x1200` &mdash; Install RealVNC server for the console and tigervnc virtual desktop servers for the specified resolutions.
* `--plugin vnc:"realvnc=1600x1200"` &mdash; Install RealVNC server and configure the console for 1600x1200, just as raspi-config VNC configuration does.
* `--plugin vnc:"tigervnc=1024x768,1600x1200,1280x1024"` &mdash; Install tigervnc virtual desktop servers for the specified resolutions. Only configure RealVNC if it is already installed (e.g., RasPiOS with Desktop IMG).

### wsdd

wsdd is the Web Service Discovery host daemon. It's very useful in Windows/Samba environments. You can read about it at https://github.com/christgau/wsdd

#### Arguments

* **wsddswitches=switchlist** &mdash; List of switches to write into /etc/default/wsdd
* **localsrc=/path/to/files** &mdash; Local directory with cached copy of wsdd (files: wsdd.py wsdd.8 wsdd.defaults wsdd.service)

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
