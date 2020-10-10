# Changelog

## V3.2

This is a major overhaul from prior versions. Error and message handling has been cleaned up and improved. 

New features:

* **Automatic reboot** after the system First Boot &mdash; Get to a fully-configured system more quickly. Super-useful if you're using the Serial Port to connect to your Pi.
* **RasPiOS Desktop **integration &mdash; Automatic reboot shows in the console window during the system First Boot, and reboots to the full Graphical Desktop
* **rasPiOS device support **(serial, i2c, spi, camera, etc...) &mdash; Any device capabilities that can be set with raspi-config, can be set with sdm.
* **Burn to an IMG file** in addition to burn to an SD card. Very useful if you want to send an SD Card Image to someone so that they can burn their own SD Card
* **/etc/fstab extension** &mdash; Easily add site-specific mounts to add to /etc/fstab
*  Simplified Localization&mdash; `--L10n` gathers the localization settings from the system on which sdm is running, or easily specify on the command line using `--keymap`, `--locale`, `--timezone`, and `--wifi-country
* **Integrated wpa_supplicant.conf handling** &mdash; Specify your wpa_supplicant.conf on the command line
* **Integrated SSH handling** &mdash; SSH is enabled by default. Use `--ssh none` to disable SSH, or `--ssh socket` to use systemd socket-based SSH to remove one process from the running system.
