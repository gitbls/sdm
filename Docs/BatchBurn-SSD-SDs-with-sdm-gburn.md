# Batch burn SSDs and SDs

## sdm-gburn overview

sdm-gburn is a convenient way to burn a large number of SD cards for different users from a single IMG. sdm-gburn's data file consists of one line per user, with all the configuration for that user:
```
username password=thepassword,option,option,...
```
username is always required. password is required unless makeuser=no. All other options are optional. Valid options:

* **password=*thepassword*** &mdash; The user's password
* **keymap=*km*** &mdash; Keymap for user. See `sudo /usr/local/sdm/sdm --info keymap`
* **locale=*lc*** &mdash; Locale for user. See `sudo /usr/local/sdm/sdm --info locale`
* **timezone=*tz*** &mdash; Timezone for user. See `sudo /usr/local/sdm/sdm --info timezone`
* **wificountry=*thewificountry*** &mdash; WiFi country for user. See `sudo /usr/local/sdm/sdm --info wifi`
* **wifissid=*wifissidforuser*** &mdash; WiFi SSID. If the SSID contains the dollar sign character ('$') you must use a WPA config file.
* **wifipassword=*wifipasswordforuser*** &mdash; WiFi password. If the password contains the dollar sign character ('$') you must use a WPA config file.
* **wpa=*/full/path/to/wpasupplicantconf*** &mdash; Specify a wpa_supplicant.conf file. File is renamed when copied so your file ned not be named *wpa_supplicant.conf*
* **hostname=*userhostname*** &mdash; Host name. Default: the username
* **makeuser=[yes|no]** &mdash; Add new user for given username/password. Default: **yes**
* **sudo=[yes|no]** &mdash; Enable sudo. Default: ***yes***
* **piwiz=[yes|no]** &mdash; Enable piwiz. Default: ***no***
* **autologin=[yes|no]** &mdash; Enable autologin. Default: ***no***
* **reboot=*n*** &mdash; Enable auto reboot at completion of first boot after waiting *n* seconds. Default: 20 seconds
* **mouse=left** &mdash; Set left-handed mouse for user. Default: right-handed mouse
* **b0script=*/full/path/to/myb0script*** &mdash; Provide a b0script. See below for details. Default: Not used
* **b1script=*/full/path/to/myb1script*** &mdash; Provide a b1script. See below for details. Default: Not used
* **dhcpcd=[dev:name;ipaddress:ipv4ip;router:routerip;dns:dnsip]** &mdash; Append a static network configuration to /etc/dhcpcd.conf. Up to two devices (e.g., eth0 and wlan0) can be configured using separate dhcpcd=. If you require more, open an issue.

All options are provided on a single line, separated by commas. Although order is not important, the parsing is a bit primitive so the format and punctuation is strict. For example
```
bls   password=mysecret,wifissid=myssid,wifipassword=mywifisecret,autologin=yes,mouse=left,reboot=30
bls2  password=mysecret2,dhcpcd=[dev:eth0;ipaddress:192.168.42.77;router:192.168.42.1;dns:192.168.42.2]
```
One way to minimize the amount of configuration per user is to set as many settings as possible that cover the most users when customizing the IMG.

For instance, if most users are in the same country, you would use `sdm --customize` and set keymap, locale, timezone, and wificountry to the appropriate settings for that country. Then, for those users located in other countries, configure them specifically in the sdm-gburn data file.

Of course, if there are applications or other configuration settings that you want in place for all users, include those in your `sdm --customize`.

## Command line

```
/usr/local/sdm/sdm-gburn img-name data-file burn-device
```
* **img-name** is the name of the IMG that you want to burn. The IMG must be (at least minimally) customized by sdm. 
* **data-file** is the aforementioned data file in the format described above
* **burn-device** is the name of the device (e.g., /dev/sdX). It must not be mounted.

## Operation

sdm-gburn verifies that the files exist, and that the IMG is sdm-enhanced (certain functions will fail if it is not).

It then reads and processes the data-file and prompts you for each user, displaying the configuration information it found for the user as well:
```
p81/ssd/work$ sudo /l/work/sdm/sdm-gburn 2022-04-04-raspios-bullseye-arm64.img student3 /dev/sdc
Configuration read for user 'bls'
>  password=abc
>  autologin=no
>  reboot=20
>  mouse=left
Ready to burn '/dev/sdc' for user 'bls'? [Yes/no/skip/quit/list/help]
```

Valid responses to the prompt:
```
Valid [case-insensitive] responses:
 Y - Burn the disk for user 'bls' (or press ENTER)
 N or S - Skip burning disk for user 'bls'
 Q - Do not burn the disk for user 'bls' and exit
 L - Display the generated b0script/b1script for user 'bls'
 H - Print this help
Ready to burn '/dev/sdc' for user 'bls'? [Yes/no/skip/quit/list/help]
```

## b0script and b1script

b0script and b1script burn files are described here: <a href="Burn-Scripts.md">Burn Scripts</a>. sdm-gburn generates burn scripts to fulfill the specified configuration for each user.

sdm-gburn enables per-user b0script and b1script. b1script is precisely as described at the above wiki entry.

b0script is handled slightly differently. Due to implementation considerations, the b0script is read as text and inserted into the b0script that sdm-gburn creates. This means that your b0script file must contain only executable bash script lines. There should be no functions, etc.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
