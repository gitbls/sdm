# Detailed Installation Guide

## Simple install

To install sdm into /usr/local/sdm from the latest branch use

    curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

## Flexible install

Alternatively, if you want to install a specific branch or use a directory other than /usr/local/sdm:

    curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller -o /path/to/EZsdmInstaller
    chmod 755 /path/to/EZsdmInstaller
    # Inspect the EZsdmInstaller script if desired
    sudo /path/to/EZsdmInstaller

## EZsdmInstaller command line

Full command syntax:

```
sudo /path/to/EZsdmInstaller branch hostdir
```
Where:

* `branch` is the name of the release branch install [Default: latest]
* `hostdir` is the full path to where sdm should be installed [Default: /usr/local/sdm]

Both arguments are optional and will use the above defaults.

### Examples

Install the latest released branch into the default directory (/usr/local/sdm)

	sudo /path/to/EZsdmInstaller

Install the latest released branch into a specific directory

	sudo /path/to/EZsdmInstaller "" /usr/local/zsdm

Install a specific branch into the default directory

	sudo /path/to/EZsdmInstaller V9.1

Install a specific branch into a specific directory

	sudo /path/to/EZsdmInstaller v9.1 /usr/local/zsdm


<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
