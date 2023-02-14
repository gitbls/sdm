# Performance: How Fast is sdm

I timed how long it took to build my personal IMG from a "stock" RasPiOS Bullseye IMG. Times rounded to the closest minute. The Lite customization takes longer because I install XWindows, xdm, icewm, xterm, chromium-browser, firefox, and all the packages that those apps pull in, as opposed to the "with Desktop" system which doesn't need to install XWindows, the display manager, and window manager, since they're already installed.

* Running RasPiOS on an SD Card and customizing an IMG located locally on that SD card
  * RasPiOS with Desktop: 7m
  * RasPiOS Lite: 9m
* Running RasPiOS on an SSD and customizing an IMG located on an NFS-mounted SSD
  * RasPiOS with Desktop: 5m
  * RasPiOS Lite: 6m
* Running RasPiOS on an SSD and customizing an IMG located locally on that SSD
  * RasPiOS with Desktop: 4m
  * RasPiOS Lite: 5m

Burning RasPiOS Lite with --expand-root to an SSD and booting it:
* 00:00:00 Start burn to SSD
* 00:01:15 Burn complete
* 00:01:45 Power on Pi. System boots and among other things runs the sdm FirstBoot script
* 00:02:52 System automatically reboots via sdm FirstBoot script
* 00:03:26 System at command prompt ready to login

You read that correctly...In less than 20 minutes, you can go from a "stock" RasPiOS IMG to having your own customized system booted and ready to go. 

And, if you keep your customized image around, you can have another freshly-made system booted and ready to go in less than 5 minutes. With all your customizations already in place. How sweet is that?
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
