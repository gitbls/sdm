#!/bin/bash

logger "1piboot Setting up socket-managed SSH..."
systemctl disable ssh.service
systemctl enable ssh.socket
#sed -i "s/\#PermitRootLogin prohibit-password/\#PermitRootLogin prohibit-password\nPermitRootLogin Yes\n/" /etc/ssh/sshd_config
# Need this if IPV6 is disabled on Pi
#echo "AddressFamily inet" >> /etc/ssh/sshd_config
