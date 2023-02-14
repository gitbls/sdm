# Detailed Installation Guide

Installation is simple. sdm must be installed in and uses the path `/usr/local/sdm` both on your running system and within images that it manages. **The simplest way to install sdm is to use EZsdmInstaller**, which performs the commands listed in *the really long way*:

    curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller | bash

**Or, download the Installer script to examine it before running:**

    curl -L https://raw.githubusercontent.com/gitbls/sdm/master/EZsdmInstaller -o ./EZsdmInstaller
    chmod 755 ./EZsdmInstaller
    # Inspect the EZsdmInstaller script if desired
    sudo ./EZsdmInstaller

**Or, download it the really long way:**

    sudo mkdir -p /usr/local/sdm /usr/local/sdm/1piboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm -o /usr/local/sdm/sdm
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase0 -o /usr/local/sdm/sdm-phase0
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-phase1 -o /usr/local/sdm/sdm-phase1
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-cparse -o /usr/local/sdm/sdm-cparse
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-cmdsubs -o /usr/local/sdm/sdm-cmdsubs
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-readparams -o /usr/local/sdm/sdm-readparams
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-firstboot -o /usr/local/sdm/sdm-firstboot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-apt-cacher -o /usr/local/sdm/sdm-apt-cacher
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-apt -o /usr/local/sdm/sdm-apt
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-customphase -o /usr/local/sdm/sdm-customphase
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-apps-example -o /usr/local/sdm/sdm-apps-example
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-xapps-example -o /usr/local/sdm/sdm-xapps-example
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-cportal -o /usr/local/sdm/sdm-cportal
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-hotspot -o /usr/local/sdm/sdm-hotspot
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-logmsg -o /usr/local/sdm/sdm-logmsg
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-gburn -o /usr/local/sdm/sdm-gburn
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/sdm-1piboot/1piboot.conf -o /usr/local/sdm/1piboot/1piboot.conf
    sudo chmod -R 755 /usr/local/sdm/*
    sudo chmod 644 /usr/local/sdm/{sdm-apps-example,sdm-xapps-example} /usr/local/sdm/1piboot/1piboot.conf
    sudo apt install systemd-container qemu-user-static binfmt-support --no-install-recommends --yes
    #
    # Copy the plugins
    #
    sudo mkdir -p /usr/local/sdm/plugins /usr/local/sdm/local-plugins
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/apt-cacher-ng -o /usr/local/sdm/plugins/apt-cacher-ng
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/apt-file -o /usr/local/sdm/plugins/apt-file
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/clockfake -o /usr/local/sdm/plugins/clockfake
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/postfix -o /usr/local/sdm/plugins/postfix
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/rxapp -o /usr/local/sdm/plugins/rxapp
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/samba -o /usr/local/sdm/plugins/samba
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/sdm-plugin-template -o /usr/local/sdm/plugins/sdm-plugin-template
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/vnc -o /usr/local/sdm/plugins/vnc
    sudo curl -L https://raw.githubusercontent.com/gitbls/sdm/master/plugins/wsdd -o /usr/local/sdm/plugins/wsdd
    sudo chmod 755 /usr/local/sdm/plugins/*

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
