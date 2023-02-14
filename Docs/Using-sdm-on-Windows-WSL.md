# Using sdm on Windows WSL

sdm can run on Windows WSL2 systems. sdm can be used for customize, explore, mount, and burnfile. It cannot, however, be used to burn an SD Card due to constraints in WSL.

sdm automatically detects that it's running on WSL and enables sdm to work seamlessly for supported operations. 

The restriction around burning SSDs/SD cards has to do with WSL being unable to properly address USB storage. If and when this restriction is lifted, you'll be able to burn SSDs/SD Cards on WSL, just like you can on other supported platforms.

You can take advantage of sdm's burn-time customizations by using `--burnfile` to burn to a .IMG file, and then using another tool such as Win32 Disk Imager, Cygwin dd, etc. to burn the IMG to the target SSD/SD Card.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
