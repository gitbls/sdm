#!/bin/bash

logger "FirstBoot: Disabling rsyslog and creating permanent journal..."
systemctl disable rsyslog.service
sed -i "s/\#ForwardToSyslog=yes/ForwardToSyslog=no/" /etc/systemd/journald.conf
[ ! -d /var/log/journal ] && mkdir /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
#
# Turn off logrotate for rsyslog
#
[ ! -d /etc/logrotate.d/.save ] && mkdir /etc/logrotate.d/.save
[ -f /etc/logrotate.d/rsyslog ] && mv /etc/logrotate.d/rsyslog /etc/logrotate.d/.save/rsyslog
