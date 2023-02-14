# Example: Burn Scripts

Another way to accomplish these types of customizations is to use <a href="Plugins.md">Plugins</a>, which are more capable and easier to understand.

## b0script
```
#!/bin/bash
#
# Script run after burn, in a --mount mode (running system and burned disk both accessible)
#
function do_b0script() {
    logtoboth "* Start b0script for host '$hostname'"
    [ "$SDMPT" == "" ] && echo "? SDMPT is undefined in do_b0script ; aborting" && return
    #
    # Copy to final location if related service already installed (or no service)
    # Copy to /etc/sdm/local-assets if service not yet installed (logwatch, apcupsd, chrony, etc)
    #
    # Logwatch
    #
    logtoboth "> Copy assets for 'logwatch'"
    rsync -a /rpi/etc/logwatch/ $SDMPT/etc/sdm/local-assets/logwatch
    #
    # apcupsd
    #
    logtoboth "> Copy assets for 'apcupsd'"
    mkdir -p $SDMPT/etc/sdm/local-assets/apcupsd
    cp /rpi/pisrv1/etc/apcupsd/apcupsd.conf $SDMPT/etc/sdm/local-assets/apcupsd
    #
    # chronyd
    #
    logtoboth "> Copy assets for 'chronyd'"
    mkdir -p $SDMPT/etc/sdm/local-assets/chrony
    cp /rpi/pisrv1/etc/chrony/chrony.conf $SDMPT/etc/sdm/local-assets/chrony
    #
    # Other configuration stuff
    #
    logtoboth "> Copy other configuration assets"
    logtoboth "> ...to /etc/sdm/local-assets/config"
    mkdir -p $SDMPT/etc/sdm/local-assets/config
    [ -f /my/safe-place/$hostname/dhcpcd-append.conf ] && cp /my/safe-place/$hostname/dhcpcd-append.conf $SDMPT/etc/sdm/local-assets/config
    [ -f /my/safe-place/$hostname/exports-append.conf ] && cp /my/safe-place/$hostname/exports-append.conf $SDMPT/etc/sdm/local-assets/config
}
```
## b1script
```
#!/bin/bash
#
# Runs in an nspawn so references are direct
#
source /etc/sdm/sdm-readparams
logtoboth "* Start b1script for host '$hostname'"

# Install pvn-specific packages

logtoboth "> Install 'logwatch' and place assets"
doapt "install --yes --no-install-recommends logwatch" $showapt
rsync -a /etc/sdm/local-assets/logwatch/ /etc/logwatch

logtoboth "> Install 'chrony' and place assets"
doapt "install --yes --no-install-recommends chrony"
[ -f /etc/chrony/chrony.conf ] && mv /etc/chrony/chrony.conf /etc/chrony/chrony.conf.orig
cp $SDMPT/etc/sdm/local-assets/chrony/chrony.conf /etc/chrony/chrony.conf

logtoboth "> Install 'apcupsd' and place assets"
doapt "install --yes --no-install-recommends apcupsd"
[ -f /etc/apcupsd/apcupsd.conf ] && mv /etc/apcupsd/apcupsd.conf /etc/apcupsd/apcupsd.conf.orig
cp $SDMPT/etc/sdm/local-assets/apcupsd/apcupsd.conf /etc/apcupsd/apcupsd.conf

logtoboth "> b1script Complete"
```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
