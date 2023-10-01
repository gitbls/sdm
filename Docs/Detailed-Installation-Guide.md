# Detailed Installation Guide

## Simple install

To install sdm into /usr/local/sdm from the latest release use

```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash
```

## Flexible install

Alternatively, if you want to install a specific branch or use a directory other than /usr/local/sdm:
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/<branch-name>/EZsdmInstaller -o /path/to/EZsdmInstaller
chmod 755 /path/to/EZsdmInstaller
# Inspect the EZsdmInstaller script if desired
sudo /path/to/EZsdmInstaller
```
For instance, to install the V8.6 version:
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/V8.6/EZsdmInstaller -o /path/to/EZsdmInstaller
chmod 755 /path/to/EZsdmInstaller
# Inspect the EZsdmInstaller script if desired
sudo /path/to/EZsdmInstaller V8.6
```

## EZsdmInstaller command line documentation

Full command syntax:

```sh
sudo /path/to/EZsdmInstaller branch hostdir
```
Where:

* `branch` is the name of the release branch install [Default: latest, which is `master`]
* `hostdir` is the full path to where sdm should be installed [Default: /usr/local/sdm]

Both arguments are optional and will use the above defaults.

### Examples

Install the latest release into the default directory (/usr/local/sdm)

```sh
sudo /path/to/EZsdmInstaller
```
Install the latest release into a specific directory
```sh
sudo /path/to/EZsdmInstaller "" /usr/local/zsdm
```

Install a specific branch into the default directory
```sh
sudo /path/to/EZsdmInstaller V9.1
```
Install a specific branch into a specific directory
```sh
sudo /path/to/EZsdmInstaller V9.1 /usr/local/zsdm
```

**NOTE:** In order to install a version other than the latest release, be sure to use the EZsdmInstaller for that version. To pick up, for instance, the V8.6 EZsdmInstaller, use:


    curl -L https://raw.githubusercontent.com/gitbls/sdm/V8.6/EZsdmInstaller -o /path/to/EZsdmInstaller

## Removing sdm

```sh
sudo rm -rf /usr/local/sdm
sudo rm -f /usr/local/bin/sdm
```

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
