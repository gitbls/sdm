# Example: Plugin

This is my (lightly edited) personal Plugin script that I use. You can read about <a href="Plugins.md">Plugins here</a>, and you can compare and constrast this plugin with a similar Custom Phase Script <a href="Example-Custom-Phase-Script.md">here</a>.
```
#!/bin/bash
# My sdm customizations
#
function loadparams() {
    source $SDMPT/etc/sdm/sdm-readparams
}
#
# $1 is the phase: "0", "1", or "post-install"
#
phase=$1
pfx="$(basename $0)"
args="$2"
vldargs="|random|"
loadparams

if [ "$phase" == "0" ]
then
    #
    # In Phase 0 all references to directories in the image
    # must be preceded by $SDMPT
    #
    logtoboth "* Plugin $pfx: Start Phase 0"
    #logfreespace "at start of $pfx Phase 0"
    plugin_getargs $pfx "$args" "$vldargs"
    #
    # Print the keys found (example usage). plugin_getargs returns the list of found keys in $foundkeys
    #
    plugin_printkeys
    #plugin_dbgprint "This is how to do a Plugin Debug printout"      # Will only be printed if --plugin-debug specified
    logtoboth "> Plugin $pfx: Create NFS environment"
    for f in h k l rpi ssd
    do
	[ ! -d $SDMPT/$f ] && mkdir $SDMPT/$f
    done
    
    echo "#/        192.168.92.0/24(rw,no_root_squash,no_subtree_check,insecure)" >> $SDMPT/etc/.my-exports
    
    logtoboth "> Plugin $pfx: Copy /usr/local/bin scripts"
    for f in \
	ddpizip \
	    wlanset \
	    btset \
	    xdmset \
	    tman
    do
        cp -f $csrc/local/$f $SDMPT/usr/local/bin
    done

    if [ "$myuser" != "" ]
    then
	logtoboth "> Plugin $pfx: Copy $myuser login files to $SDMPT/home/$myuser"
	[ ! -d $SDMPT/home/$myuser ] && mkdir $SDMPT/home/$myuser
	cp -f $csrc/home/$myuser/{.bashrc,.colordiffrc,.dircolors,.emacs,.inputrc,.vimrc,.Xmodmap,.Xdefaults,.tmux.conf} $SDMPT/home/$myuser
	echo "source /home/$myuser/.bashrc" > $SDMPT/home/$myuser/.bash_profile
	chmod 755 $SDMPT/home/$myuser/.bash_profile
	[ ! -d $SDMPT/home/$myuser/bin ] && mkdir $SDMPT/home/$myuser/bin
	for fd in .icewm \
		      .lftp \
		      .ncftp
	do
	    [ -d $csrc/home/$myuser/$fd ] && cp -a -f $csrc/home/$myuser/$fd $SDMPT/home/$myuser/$fd
	done
	
	logtoboth "> Plugin $pfx: Copy $csrc/home/bls/ssh-mydomain to $SDMPT/home/$myuser"
	cp -a $csrc/home/bls/ssh-mydomain $SDMPT/home/$myuser/.ssh
	chmod 700 $SDMPT/home/$myuser/.ssh
	mkdir -p $SDMPT/home/$myuser/.gnupg
	# This is also set for root (just below). Also see in Phase 1 where /usr/lib/gnupg/scdaemon is created 
	echo "disable-scdaemon" > $SDMPT/home/$myuser/.gnupg/gpg-agent.conf
	chmod 700 $SDMPT/home/$myuser/.gnupg

	logtoboth "> Plugin $pfx: Copy login scripts to $SDMPT/root"
	[ ! -d $SDMPT/root/orig ] && mkdir $SDMPT/root/orig && mv $SDMPT/root/.bashrc $SDMPT/root/orig
	[ -f $SDMPT/root/.bash_profile ] && mv $SDMPT/root/.bash_profile $SDMPT/root/orig
	cp $csrc/home/${myuser}/{.bashrc,.colordiffrc,.dircolors,.emacs,.inputrc,.tmux.conf} $SDMPT/root
	echo "source /root/.bashrc" > $SDMPT/root/.bash_profile
	chmod 755 $SDMPT/root/.bash_profile
	cp -a $SDMPT/home/$myuser/.ssh $SDMPT/root/.ssh
	mkdir -p $SDMPT/root/.gnupg
	echo "disable-scdaemon" > $SDMPT/root/.gnupg/gpg-agent.conf
	chmod 700 $SDMPT/root/.gnupg
	chown -R root.root $SDMPT/root/.ssh
    fi
    
    #logfreespace "at end of $pfx Phase 0"
    logtoboth "* Plugin $pfx: Complete Phase 0"

elif [ "$phase" == "1" ]
then
    #
    # Phase 1 (in nspawn)
    #
    # In Phase 1 all references to directories in the image can be direct
    #
    logtoboth "* Plugin $pfx: Phase 1"
    plugin_getargs $pfx "$args" "$vldargs"
    #logfreespace "at start of $pfx Phase 1"
    
    if [ "$random" == "haveged" ]
    then
        logtoboth "> Plugin $pfx: Disable rng-tools and install haveged"
        doapt "install --yes --no-install-recommends haveged" $showapt
        systemctl disable rng-tools > /dev/null 2>&1
        systemctl disable rng-tools-debian > /dev/null 2>&1   # On some systems it is named this
        systemctl enable haveged > /dev/null 2>&1
    else
	# Bullseye: Be aware of this if the system runs more than 8 days: https://rachelbythebay.com/w/2022/04/20/rngd/
        logtoboth "> Plugin $pfx: Use rngd"
	logtoboth "> Plugin $pfx: Disable rngd logging"
	echo "RNGDOPTIONS=\"-S 0\"" >> /etc/default/rng-tools-debian
    fi

    logtoboth "> Plugin $pfx: Disable $SDMPT/etc/profile.d/wifi-check.sh and sshpwd.sh"
    [ -f $SDMPT/etc/profile.d/wifi-check.sh ] && mv $SDMPT/etc/profile.d/wifi-check.sh $SDMPT/etc/profile.d/.sdm.wifi-check.sh
    [ -f $SDMPT/etc/profile.d/sshpwd.sh ] &&     mv $SDMPT/etc/profile.d/sshpwd.sh $SDMPT/etc/profile.d/.sdm.sshpwd.sh
    
    logtoboth "> Plugin $pfx: Add group 'mygroup'"
    groupadd -g 2800 mygroup
    usermod -a -G 2800 bls

    logtoboth "> Plugin $pfx: Set APT::Install-Recommends to false"
    echo "APT::Install-Recommends \"false\";" >> /etc/apt/apt.conf.d/03-norecommends

    #logfreespace "at end of $pfx Phase 1"
    logtoboth "* Plugin $pfx: Phase 1 completed"
else
    #
    # Post-install edits
    #
    logtoboth "* Plugin $pfx: Phase post-install"
    plugin_getargs $pfx "$args" ""
    #logfreespace "at start of $pfx Phase post-install"
    #
    # Disable cron hourly
    #
    systemctl disable cron@hourly.timer
    #
    # Set fstab ext4 partition to a higher commit
    #
    logtoboth "> Plugin $pfx: Set ext4 partition commit higher"
    sed -i "s/ext4    defaults,noatime/ext4    defaults,noatime,commit=300/" /etc/fstab

    if [ -f /usr/bin/startlxde-pi ]
    then
	sed -i "s/window_manager=mutter/window_manager=openbox/" /etc/xdg/lxsession/LXDE-pi/desktop.conf
	[ -f /home/bls/.config/lxsession/LXDE-pi/desktop.conf ] && sed -i "s/window_manager=mutter/window_manager=openbox/" /home/bls/.config/lxsession/LXDE-pi/desktop.conf
    fi
    #logfreespace "at end of $pfx Custom Phase post-install"
    logtoboth "* Plugin $pfx: Phase post-install Completed"
fi
exit 0

```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
