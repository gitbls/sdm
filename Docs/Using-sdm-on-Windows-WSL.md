# Using sdm on Windows WSL

sdm can run on Windows WSL2 distros. sdm can be used for all functions including customize, explore, mount, burn, and burnfile. Burn to disk requires adding `usbipd` on the Windows host, as documented below.

## usbipd Documentation

<a href="https://github.com/dorssel/usbipd-win">usbipd</a> is addon software for Windows that provides WSL2 guests access raw disk storage.

usbip Documentation:

* <a href="https://github.com/dorssel/usbipd-win/blob/master/README.md">usbipd README</a>
* <a href="https://github.com/dorssel/usbipd-win/wiki/Tested-Devices">usbipd Tested Devices</a>
* <a href="https://github.com/dorssel/usbipd-win/wiki/Tested-Devices#preparation">usbipd Device usage HowTo</a>
* <a href="https://github.com/dorssel/usbipd-win/wiki/Troubleshooting">usbipd Troubleshooting</a>

If you have problems using usbipd your first stop for assistance should be <a href="https://github.com/dorssel/usbipd-win">the usbipd-win GitHub</a>. I'm a usbipd user just like you; the experts are *over there*.

## Install usbipd

Perform these at the Windows Command Prompt.

* **Shutdown WSL** &mdash; `wsl --shutdown`
* **Update WSL** &mdash; `wsl --update`
* **Install usbipd** &mdash; `winget install --interactive usbipd`

## Using usbipd

Here are the steps I recommend to help ensure success and ease of use. Perform these steps at the Command Prompt.

* Start with the USB disk or SD card reader NOT inserted
* **Enable `sudo`** &mdash; (Optional) This makes the rest of what follows MUCH easier. <a href="https://learn.microsoft.com/en-us/windows/advanced-settings/sudo/">Follow this Microsoft guide</a>. If you opt to not enable sudo, you'll need a separate Administrator Command Prompt as indicated.
* **Disable Windows autoplay** &mdash; (Optional) Don't fight with Windows when inserting a drive. Open the **Settings app (WIN+I)**, search for *Autoplay* and select *AutoPlay settings*. On that page turn off *Use AutoPlay for all media and devices*, and set AutoPlay defaults for both Removable drive and Memory card to *Take no action*.
* **Start the WSL2 instance** &mdash; `wsl`
* **Verify and connect the device** &mdash; <a href="https://github.com/dorssel/usbipd-win/wiki/Tested-Devices#verify-device">Detailed steps</a>. Where the document indicates that it should be run as Administrator use `sudo` instead if you enabled it
* **Identify WSL disk name** &mdash; `dmesg | tail -n 20`. The newly connected disk should now  be displayed at the end of the dmesg output (at least on Debian-based systems)

**NOTES:**

* A `bind` is permanent, even across reboots. Use `usbipd unbind` to break the association. `bind` and `unbind` require `sudo` or an Administrator Command Prompt.
* `usbipd attach` must be redone after every system reboot or WSL restart. Use `usbipd detach` to detach a device from the WSL instance. NO `sudo` or Administrator Command Prompt required

## If usbipd not installed

The disk burning restriction is because WSL is unable to properly address USB storage. `usbipd`, documented above, fills the gap. If you do NOT install `usbipd` sdm's `--burn` command WILL fail.

Without `usbipd` you can still take advantage of sdm's burn-time customizations by using `--burnfile` to burn to a .IMG file, and then using another tool such as Win32 Disk Imager, Cygwin dd, etc. to burn the IMG to the target SSD/SD Card.

## WSL Information

For information on installing WSL and a Distro on Windows see <a href="https://learn.microsoft.com/en-us/windows/wsl/install">Install WSL</a>. You can see the available distros with this command (either Cmd prompt or Powershell): `wsl --list --online`. I recommend using Debian, since it's the most like RasPiOS, it's well-supported, and it's stable.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
