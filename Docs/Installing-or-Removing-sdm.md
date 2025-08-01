# Installing or Removing sdm

## Installing sdm

```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
```
`install-sdm` installs the sdm files to /usr/local/sdm, and installs other required packages if they are not installed (binfmt-support coreutils gdisk keyboard-configuration parted qemu-user-static rsync systemd-container uuid)

**Or, download the Installer script to examine it before running:**
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm -o /path/to/install-sdm
chmod 755 /path/to/install-sdm
# Inspect the install-sdm script if desired
/path/to/install-sdm
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
