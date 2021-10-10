#!/bin/bash
logger "FirstBoot: Disabling TriggerHappy..."
[ -f /usr/sbin/thd ] && mv /usr/sbin/thd /usr/sbin/.thd           # Speeds up /etc/init.d/raspi-config.service
systemctl disable triggerhappy.service
systemctl disable triggerhappy.socket
# Eliminate thd.socket journalctl errors
[ -f /lib/udev/rules.d/60-triggerhappy.rules ] && mv /lib/udev/rules.d/60-triggerhappy.rules /lib/udev/rules.d/.60-triggerhappy.rules
