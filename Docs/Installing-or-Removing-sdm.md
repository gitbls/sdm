# Installing or Removing sdm

To install sdm:
```
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
```
EZsdmInstaller is a simple script that downloads the sdm files to /usr/local/sdm, and installs packages systemd-container, qemu-user-static, binfmt-support, file, and parted if they are not installed.

To remove sdm:
```
sudo rm -rf /usr/local/sdm
sudo rm -f /usr/local/bin/sdm
```
See <a href="Detailed-Installation-Guide.md">the detailed installation guide</a> for additional information.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
