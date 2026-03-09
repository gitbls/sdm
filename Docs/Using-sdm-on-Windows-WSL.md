# Using sdm on Windows WSL

sdm can run on Windows WSL2 distros. sdm can be used for customize, explore, mount,burnfile and burn SSD/SD Card mounted through USB. 

sdm automatically detects that it's running on a WSL distro and enables sdm to work seamlessly for supported operations. 

Using sdm to burn an image on Windows WSL requires a few more steps : 
1. Install usbipd-win :
```
winget install --interactive --exact dorssel.usbipd-win
```

2. In a command prompt on the host, list USB devices :
```
usbipd list
```

3. Once the SSD/SD card adapter identified, bind it using its bus ID:
```
usbipd bind --busid <busid-here>
```

4. Finally, attach it :
```
usbipd attach --wsl --busid <busid-here>
```

The SSD/SD card can then be identified using `lsblk` and the image can be burned as it would be on a Linux host.
Once burned, the SSD/SD Card can be detached : 
```
usbipd detach --busid <busid-here>
```

You can also take advantage of sdm's burn-time customizations by using `--burnfile` to burn to a .IMG file, and then using another tool such as Win32 Disk Imager, Cygwin dd, etc. to burn the IMG to the target SSD/SD Card.

For information on installing WSL and a Distro on Windows see <a href="https://learn.microsoft.com/en-us/windows/wsl/install">Install WSL</a>. You can see the available distros with this command (either Cmd prompt or Powershell): `wsl --list --online`. I recommend using Debian, since it's the most like RasPiOS, it's well-supported, and it's stable.

For information on using usbipd-win and how to connect USB devices to WSL, see [usbipd-win by dorssel](https://github.com/dorssel/usbipd-win) and [Connect USB devices](https://learn.microsoft.com/en-us/windows/wsl/connect-usb).
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>

