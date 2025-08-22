# Cool and Useful Things: wireguard VPN

The `wireguard` plugin simplifies Wireguard configuration. Specifically, the plugin enables you to configure:

* A single Wireguard host and define peer connections for it
* Additional interfaces and/or peer connections to an already-installed system
* A fully operational two-node Wireguard VPN

In the third scenario, when properly configured and enabled, the two-node VPN will automatically start.

This note focuses on configuring a two-node VPN, but all the techniques used here can be used in other wireguard scenarios as well.

This document will show you how you can

* Use one of three different methods for handling the host and remote keys
* Create customized host OS disks from a single IMG, each with host-specific configurations
* Extract host-specific files from an IMG (or burned disk in this case)
* Configure a host with a static IP address

As noted in the `wireguard` plugin documentation, creating a fully-configured Wireguard interface requires two unique invocations of the `wireguard` plugin. The first invocation defines the interface (e.g., wg0), and the second (and others, if desired) define the Wireguard peer using the plugin's `addpeer` argument.

## Introduction

You can use sdm to create two systems to be Wireguard VPN endpoints very easily. The two endpoints have identical RasPiOS software configurations, since they will be built from a single customized IMG. You can, of course, use different customized IMGs for each end if desired.

Host-specific configuration is done when the disks for each host are burned.

The 3 different methods for handling the host and remote keys are:

* **Generate the keys before burning and provide them to the `wireguard` plugin invocations.** This is the easiest from a process perspective, but take care to prevent key leakage.
* **Generate keys for both hosts on the *first* host**, extract the keys needed to configure the second host, and provide them to the `wireguard` plugin on the 2nd host.

  This is also easy from a process perspective, but the first host has the private key for the 2nd host, which may be undesirable for some scenarios. It is, however, easily deleted.

* **Generate keys for each host on the corresponding host**. Extract the public keys on both during burning and provide them to the `wireguard` plugin on the other host.

  This is the most secure, in that neither VPN host has private keys for the other host. However, it requires two simple and well-understood additional steps that are explained in detail below.

## Overview

Here's an outline of the steps that will be done. These are detailed in following sections.

* Customize the <i>base image</i> that is used by both endpoints. This is simply the standard typically-headless server install with all your customizations in it. While you can use a RasPiOS edition that has a desktop, it's generally less recommended for server systems.

  Of course you can use different IMGs for each endpoint if desired.

* Burn one VPN endpoint's disk using the already-customized IMG
  * Use the `wireguard` plugin to install and configure the VPN for the first host (see Examples below)
  * Depending on which of the 3 scenarios you're using the burn command can include using the `postburn` plugin to implement needed key sharing between the two hosts
* Burn the second endpoint's disk using the same customized IMG
  * Use the `wireguard` plugin to install and configure the VPN for the second host (see Examples below)
  * Depending on which of the 3 scenarios you're using the burn command can include using the `postburn` plugin to implement needed key sharing between the two hosts

When each host completes the FirstBoot process and restarts its VPN will be running and ready for operation.

## Network configuration

My test internet configuration uses two interconnected routers.

NOTES:
* Although the example uses IP addresses to connect to the remote host, I strongly recommend you use a DNS name to protect against IP address changes. That is, instead of using the addresses 2.2.2.2, use a DNS name (using a dynamic DNS service if needed). This insulates your configuration from changes to your external IP address.

```
+--------------+    +-----------------+
| 192.168.16.2 |____| Router          |
|  left        |    | I: 192.168.16.1 |____+
+--------------+    | O: 2.2.2.2      |    |
                    +-----------------+    |
                                        Network Switch
+--------------+    +-----------------+    |
| 192.168.32.2 |____| Router          |----+
|  right       |    | I: 192.168.32.1 |
+--------------+    | O: 2.2.2.3      |
                    +-----------------+
```

I found that it was VERY handy to have a reliable time source in the configuration, so I added another Pi with 2 ethernet adapters running an apppropriately configured time server. I also installed `apt-cacher-ng`, which is very handy for installing that forgotten package. The Pi was connected to both my home LAN (192.168.92.0/24) and the test network internet (2.2.2.x).
```
+-----------------+
| TimeServer      |
| I: 192.168.92.8 |----Test network switch
| O: 2.2.2.4      |
+-----------------+
```
Additionally, since this Pi was on my home LAN I use it as an SSH jump host into the test network.

## Host network configuration

Typically you want your servers to have static IP addresses. You can configure a static IP address on a host by:

* Having your DHCP server always issue the same IP address to a host, typically based on the host's MAC address
* Providing a static IP configuration on the host directly

  You can use something like this on an sdm host-specific burn command to configure a static IP address:
```
network:ifname=eth0|ipv4-static-ip=192.168.16.2|ipv4-static-gateway=192.168.16.1|autoconnect=true
```

## Key management scenario details

The 3 scenarios are described in a bit more detail.

### Scenario 1A: Generate keys before burning host disks (static-keys)

In this scenario keys are generated through a method outside of sdm and the `wireguard` plugin.

For instance, you can generate them manually on a host with the apt package `wireguard-tools` installed:

```
mkdir certs
cd certs
# Generate keys for host left
wg genkey | tee left.privatekey | wg pubkey > left.publickey
# Generate keys for host right
wg genkey | tee right.privatekey | wg pubkey > right.publickey
```

If you want to use a second-factor preshared key, generate the preshared key:
```
wg genpsk > preshared.key
```

The demo uses a preshared key for this scenario.

**NOTE:** The certs provided for this scenario are pre-generated for your convenience. You MUST regenerate these keys to use these hosts in a production deployment!

### Scenario 1B: Generate keys before burning host disks (lan-static-keys)

This scenario is identical to Scenario 1a, except that it is configured to easily demonstrate a Wireguard VPN running *completely on your LAN*. This is the only scenario that does not use the network configuration described above, as it runs on two hosts on the local LAN.

Edit `left/pluglist` and `right/pluglist` to configure the host, gateway, and endpoint IP addresses correctly for your LAN. Install and boot the configured disks on your hosts.

When on one of the VPN endpoint hosts, reference the remote end of the tunnel using the remote host's tunnel IP (10.1.10.*).

### Scenario 2: Generate keys for both hosts on the first host (build-keys-on-one-host)

In this scenario all keys are generated on the first host (`left`), and the required certs are extracted and made available to the remote host (`right`).

The sdm burn command for `left` runs the additional plugin `postburn`, which runs a script to extract `lefts`'s public key (so it's available for `right`) and `right`'s private and public keys.

### Scenario 3: Generate each host's keys on the host (each-host-builds-own-keys)

In this scenario each host generates its own keys. At the end of *each* host's burn command the host's public key is extracted.

During the burn command each host only runs the `wireguard` plugin once (vs twice on the first 2 scenarios). The peer configuration is added by running the `wireguard` plugin with the `addpeer` argument on the newly-burned disk when the remote host's public key is available.

## Using the wireguard demo tarball

Here are the steps to take to demo any of the wireguard 2-node VPN scenarios

* Your host must be running 64-bit RasPiOS. This should work on other Debian-based OS as well, but all untested.

* Ensure that your system is up to date. It's a good idea to reboot if any updates are installed, although this is not strictly necessary.

```
sudo apt update
sudo apt upgrade --yes
```

* Make an empty directory and `cd` into it. This is important; the scripts will fail if you aren't in the correct directory.
* Download the tarball and untar it
```
curl --fail --silent --show-error -L  https://raw.githubusercontent.com/gitbls/sdm/master/extras/wireguard-example.tar.xz | tar --extract --xz --verbose --file - --overwrite -C .
```
* Run the script `bin/create-base-img` to build a customized base IMG: `bin/create-base-img`

  `create-base-img` will install sdm if it's not installed, and install the packages that sdm requires: binfmt-support coreutils gdisk keyboard-configuration parted qemu-user-static rsync systemd-container uuid

  It will also download the IMG 2025-05-13-raspios-bookworm-arm64-lite, make a saved copy of it in `imglib`, and also copy it to the current directory.

  The IMG will then be lightly customized. You can modify `stuff/my.plugins` to change the IMG customization.

  If needed, `create-base-img` can be rerun. It will skip installing sdm, and will start with a fresh copy of the saved IMG (in `imglib`), so it's quite fast to rebuild your customized IMG.

* Select one of the three key management scenarios and cd into the desired directory
  * `cd static-keys` &mdash; Use pre-defined keys. This scenario has a set already defined, but you can rebuild them per above if desired
  * `cd lan-static-keys` &mdash; Use pre-defined keys in a local LAN configuration. Like `static-keys` this scenario has keys already defined, but you can rebuild them per above if desired
  * `cd build-keys-on-one-host` &mdash; Build new keys on one host and propagate as needed to the second host
  * `cd each-host-own-keys` &mdash; Each host builds its own keys, and the public keys are installed into the other host

* Edit the pluglists for `left` and `right` to configure the VPN for your network. **NOTE: the pluglists are *different* between the 3 scenarios**
  * Edit left/pluglist to configure `left`'s VPN to correspond to your actual configuration
  * Edit right/pluglist to configure `right`'s VPN

* Run the `doburn` script to burn the disk for host `left`
```
sudo ./doburn left ../2025-05-13-raspios-bookworm-arm64-lite.img /dev/sdX
```
* Run the `doburn` script to burn the disk for host `right`
```
sudo ./doburn right ../2025-05-13-raspios-bookworm-arm64-lite.img /dev/sdX
```

If you are using the `each-host-own-keys` scenario two additional steps are required. These can be done in either order, but since the disk for `right` was just burned it's convenient to update it first.

* Update the disk for `right` to install a peer connection for `left`
```
sudo ./doburn right2 ../2025-05-13-raspios-bookworm-arm64-lite.img /dev/sdX
```
* Update the disk for `left` to install a peer connection for `right`
```
sudo ./doburn left2 ../2025-05-13-raspios-bookworm-arm64-lite.img /dev/sdX
```

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
