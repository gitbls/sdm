# Example: Custom Phase Script

This is my (lightly edited) personal Custom Phase script that I used to use. I am now using a <a href="Plugins.md">Plugin</a>, which you can see <a href="Example-Plugin.md">here</a> for comparison and contrast.
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
if [ "$phase" == "0" ]
loadparams
then
    #
    # In Phase 0 all references to directories in the image
    # must be preceded by $SDMPT. References not preceded
    # by $SDMPT refer to the system on which sdm is running.
    # Hence easy to copy additional files into the image.
    #
    #
    logtoboth "* $pfx Phase 0"
    logfreespace "at start of $pfx Custom Phase 0"
    logtoboth "> $pfx Create NFS mount points"
    for f in h k l rpi ssd
    do
	[ ! -d $SDMPT/$f ] && mkdir $SDMPT/$f
    done
    
    echo "#/home/${myuser}    192.168.42.0/24(rw,no_root_squash,no_subtree_check,insecure)" >> $SDMPT/etc/.my-personal-exports
    
    logtoboth "> $pfx Copy /usr/local/bin config scripts"
    for f in \
	    wlanset \
	    btset \
	    xdmset \
	    tman 
    do
        cp -f /rpi/local/$f $SDMPT/usr/local/bin
    done
    
    if [ "$myuser" != "" ]
    then
	# I like to have the same environment on all my systems
	# Copy in the files that I require everywhere
	logtoboth "> $pfx Copy $myuser login files to $SDMPT/home/$myuser"
	[ ! -d $SDMPT/home/$myuser ] && mkdir $SDMPT/home/$myuser
	cp -f /home/$myuser/{.bashrc,.colordiffrc,.dircolors,.emacs,.inputrc,.vimrc,.Xmodmap,.Xdefaults,.tmux.conf} $SDMPT/home/$myuser
	echo "source /home/$myuser/.bashrc" > $SDMPT/home/$myuser/.bash_profile
	chmod 755 $SDMPT/home/$myuser/.bash_profile
	[ ! -d $SDMPT/home/$myuser/bin ] && mkdir $SDMPT/home/$myuser/bin
	for fd in .icewm \
		      .lftp \
		      .ncftp
	do
	    [ -d /home/$myuser/$fd ] && cp -a -f /home/$myuser/$fd $SDMPT/home/$myuser/$fd
	done
	
	logtoboth "> $pfx Copy ssh files"
	cp -a /rpi/my-ssh-files $SDMPT/home/$myuser/.ssh
	chmod 700 $SDMPT/home/$myuser/.ssh
	mkdir -p $SDMPT/home/$myuser/.gnupg
	# This is also set for root (just below). Also see in Phase 1 where /usr/lib/gnupg/scdaemon is hacked
	echo "disable-scdaemon" > $SDMPT/home/$myuser/.gnupg/gpg-agent.conf
	chmod 700 $SDMPT/home/$myuser/.gnupg
	logtoboth "> $pfx Copy login scripts to $SDMPT/root"
	[ ! -d $SDMPT/root/orig ] && mkdir $SDMPT/root/orig && mv $SDMPT/root/.bashrc $SDMPT/root/orig
	[ -f $SDMPT/root/.bash_profile ] && mv $SDMPT/root/.bash_profile $SDMPT/root/orig
	cp /home/$myuser/{.bashrc,.colordiffrc,.dircolors,.emacs,.inputrc,.tmux.conf} $SDMPT/root
	echo "source /root/.bashrc" > $SDMPT/root/.bash_profile
	chmod 755 $SDMPT/root/.bash_profile
	cp -a $SDMPT/home/$myuser/.ssh $SDMPT/root/.ssh
	chown -R root.root $SDMPT/root/.ssh
	mkdir -p $SDMPT/root/.gnupg
	echo "disable-scdaemon" > $SDMPT/root/.gnupg/gpg-agent.conf
	chmod 700 $SDMPT/root/.gnupg
    fi
    
    logtoboth "> $pfx Copy systemd services"
    cp $csrc/systemd/*.service         $SDMPT/etc/systemd/system

    logtoboth "> $pfx Disable $SDMPT/etc/profile.d/wifi-check.sh and sshpwd.sh"
    [ -f $SDMPT/etc/profile.d/wifi-check.sh ] && mv $SDMPT/etc/profile.d/wifi-check.sh $SDMPT/etc/profile.d/sdm.wifi-check.sh
    [ -f $SDMPT/etc/profile.d/sshpwd.sh ] &&     mv $SDMPT/etc/profile.d/sshpwd.sh $SDMPT/etc/profile.d/sdm.sshpwd.sh
    
    logfreespace "at end of $pfx Custom Phase 0"
    logtoboth "* $pfx Phase 0 Completed" 

elif [ "$phase" == "1" ]
then
    #
    # Phase 1 (in nspawn)
    #
    # In Phase 1 all references to directories in the image can be direct
    #
    logtoboth "* $pfx Phase 1"
    logfreespace "at start of $pfx Custom Phase 1"
    
    if [[ ! "$custom1" =~ "nohaveged" ]]
    then
	logtoboth "> $pfx Disable rng-tools and install haveged"
	doapt "install --yes --no-install-recommends haveged" $showapt
	systemctl disable rng-tools > /dev/null 2>&1
	systemctl disable rng-tools-debian > /dev/null 2>&1   # On some systems it is named this
	systemctl enable haveged > /dev/null 2>&1
    else
	logtoboth "> $pfx Skip replace rng-tools with haveged"
    fi

    logtoboth "> $pfx Add group 'mygroup'"
    groupadd -g 3700 mygroup
    usermod -a -G 4300 bls

    logfreespace "at end of $pfx Custom Phase 1"
    logtoboth "* $pfx Custom Phase 1 completed"
else
    #
    # Post-install edits
    #
    logtoboth "* $pfx Custom Phase post-install"
    logfreespace "at start of $pfx Custom Phase post-install"

    #
    # Disable gnugp scdaemon error completely
    #
    logtoboth "> $pfx Eliminate gnupg scdaemon error messages"
    if [ ! -f /usr/lib/gnupg/scadaemon ]
    then
	cat > /usr/lib/gnupg/scdaemon <<EOF
#!/bin/bash
exit 0
EOF
	chmod 755 /usr/lib/gnupg/scdaemon
    fi

    if [ -f /etc/default/nfs-kernel-server ]
    then
	logtoboth "> Change nfsd process count from 8 to 4 in /etc/default/nfs-kernel-server"
	sed -i "s/RPCNFSDCOUNT=8/RPCNFSDCOUNT=4/" /etc/default/nfs-kernel-server
	logtoboth "> $pfx Eliminate NFS /run/rpc_pipefs/nfs/blocklayout boot message"
	mkdir /etc/systemd/system/nfs-blkmap.service.d
	cat > /etc/systemd/system/nfs-blkmap.service.d/fixpipe.conf <<EOF
[Service]
ExecStartPre=/usr/sbin/modprobe blocklayoutdriver
EOF
    fi

    if [[ ! "$custom1" =~ "nopostfix" ]]
    then
	#
	# Installs postfix as a satellite system.
	# Need to do final fixups in First Boot so that environment is correct
	#
	logtoboth "> $pfx Install postfix"
	debconf-set-selections <<< "postfix postfix/main_mailer_type select Satellite system"
	debconf-set-selections <<< "postfix postfix/mailname string $domain"
	debconf-set-selections <<< "postfix postfix/relayhost string $custom2"
	doapt "install --yes --no-install-recommends bsd-mailx postfix libsasl2-modules" $showapt
	cp /etc/postfix/main.cf /etc/postfix/main.cf.orig
	logtoboth "> $pfx Set postfix completion script to run after first boot"
	pf01="/etc/sdm/0piboot/080-complete-postfix.sh"
	[ -f $pf01 ] && rm -f $pf01
	cat > $pf01 <<EOF
#!/bin/bash
source /usr/local/sdm/sdm-cparse ; readparams
sed -i "s/raspberrypi.\$domain/\$hostname.\$domain/" /etc/postfix/main.cf
sed -i "s/\$domain,//" /etc/postfix/main.cf               # Remove domain name from mydestinations (was first in list. If it moves, this breaks)
#Rerun make-ssl-cert now that host name is known
make-ssl-cert generate-default-snakeoil --force-overwrite
newaliases
systemctl enable postfix
EOF
	chmod 755 $pf01
	systemctl disable postfix
	echo "root: myemail@somewhere.com" >> /etc/aliases
	echo "bls:  myemail@somewhere.com" >> /etc/aliases
    fi
    logfreespace "at end of $pfx Custom Phase post-install"
    logtoboth "* $pfx Custom Phase post-install Completed"
fi
exit 0

```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
