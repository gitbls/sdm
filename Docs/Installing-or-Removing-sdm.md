# Installing or Removing sdm

## Installing sdm

```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
```
EZsdmInstaller is a simple script that downloads the sdm files to /usr/local/sdm, and installs packages systemd-container, qemu-user-static, binfmt-support, file, and parted if they are not installed.

**Or, download the Installer script to examine it before running:**
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller -o ./EZsdmInstaller
chmod 755 ./EZsdmInstaller
# Inspect the EZsdmInstaller script if desired
sudo ./EZsdmInstaller
```
## Removing sdm

```sh
sudo rm -rf /usr/local/sdm
sudo rm -f /usr/local/bin/sdm
```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
