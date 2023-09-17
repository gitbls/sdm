# Using sdm on Windows WSL

sdm can run on Windows WSL2 distros. sdm can be used for customize, explore, mount, and burnfile. At the current time, however, it cannot be used to burn an SD Card due to constraints in WSL.

sdm automatically detects that it's running on a WSL distro and enables sdm to work seamlessly for supported operations. 

The restriction around burning SSDs/SD cards has to do with WSL being unable to properly address USB storage. If and when this restriction is lifted, you'll be able to burn SSDs/SD Cards on WSL, just like you can on other supported platforms.

You can take advantage of sdm's burn-time customizations by using `--burnfile` to burn to a .IMG file, and then using another tool such as Win32 Disk Imager, Cygwin dd, etc. to burn the IMG to the target SSD/SD Card.

For information on installing WSL and a Distro on Windows see <a href="https://learn.microsoft.com/en-us/windows/wsl/install">Install WSL</a>. You can see the available distros with this command (either Cmd prompt or Powershell): `wsl --list --online`. I recommend using Debian, since it's the most like RasPiOS, it's well-supported, and it's stable.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
