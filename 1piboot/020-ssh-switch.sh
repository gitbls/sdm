#!/bin/bash

logger "1piboot Setting up socket-managed SSH..."
systemctl disable --now ssh.service

# Uncomment this line V to enable root to login with a password. If not changed, only ssh key can be used for root login
#sed -i "s/\#PermitRootLogin prohibit-password/\#PermitRootLogin prohibit-password\nPermitRootLogin Yes\n/" /etc/ssh/sshd_config

# Uncomment this line V if IPV6 is disabled on Pi
#echo "AddressFamily inet" >> /etc/ssh/sshd_config

systemctl enable ssh.socket
systemctl start ssh.socket
