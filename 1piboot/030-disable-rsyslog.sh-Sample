#!/bin/bash

logger "FirstBoot: Disabling rsyslog and creating permanent journal..."
systemctl disable rsyslog.service
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/030-sdm-no-syslog.conf <<EOF
[Journal]
ForwardToSyslog=no
EOF
[ ! -d /var/log/journal ] && mkdir /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
#
# Turn off logrotate for rsyslog
#
if [ -f /etc/logrotate.d/rsyslog ]
then
   mkdir -p /etc/logrotate.d/.sdmsave
   mv /etc/logrotate.d/rsyslog /etc/logrotate.d/.sdmsave/rsyslog
fi
   
