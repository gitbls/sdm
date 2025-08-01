# Detailed Installation Guide

## Simple install

To install sdm into /usr/local/sdm from the latest release use

```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
```

## Flexible install

Alternatively, if you want to install a specific branch or use a directory other than /usr/local/sdm:
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm -o /path/to/install-sdm
chmod 755 /path/to/install-sdm
# Inspect the install-sdm script if desired
/path/to/install-sdm V13.12
```
NOTE: install-sdm can only install releases V13.12 and later. Use EZsdmInstaller for earlier releases.

## install-sdm command line documentation

Full command syntax:

```sh
sudo /path/to/install-sdm release-name install-directory repo-name saved-local-tarball
```
Where:

* `release-name` is the name of the release (e.g., V14.1). [Default: latest]
* `install-directory` is the directory on the host where sdm will be installed [Default:/usr/local/sdm]
* `repo-name` is the repository name [Default:gitbls/sdm]
* `saved-local-tarball` is the full path to a saved local copy of the tarball [Default:""]

All arguments are optional and will use the above defaults.

### Examples

Install the latest release into the default directory (/usr/local/sdm)

```sh
/path/to/install-sdm
```
Install the latest release into a specific directory
```sh
/path/to/install-sdm "" /usr/local/zsdm
```

Install a specific branch into the default directory
```sh
/path/to/install-sdm V13.12
```
Install a specific branch into a specific directory
```sh
/path/to/install-sdm V13.12 /usr/local/zsdm
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
