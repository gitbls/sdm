# Getting started with kvm virtualization on RasPiOS

Virtualization is a software technology that creates multiple virtual environments—called Virtual Machines (VMs)—each running a separate operating system, on a single physical computer's hardware.

It acts as an abstraction layer that divides a machine’s physical resources (CPU, memory, storage) so that multiple, independent operating systems can run effectively simultaneously on the same physical hardware. If the guest VM's CPU  instruction set is identical to that of the host computer hardware (e.g., both host and guest are ARM64) the VM will run at close to native hardware speeds.

This document is not a tutorial on virtualization. It's best to think of it as:

* A guide on how to install `kvm-based` virtualization with `libvirt` management on RasPiOS using sdm
* A high-level HowTo create a VM running Debian Trixie ARM64 with either manual or automatic installation
* Some handy simplification / getting started scripts 

`libvirt` and `kvm` support a broad range of capabilities. None of these are covered in this Getting Started document. See the <a href="https://libvirt.org/docs.html">libvirt documentation</a> for complete documentation, and here's a handy link to the <a href="https://libvirt.org/manpages/virsh.html">virsh command-line documentation</a>.

libvirt includes the `virt-manager` GUI, optionally installed via the <a href="Plugins.md#kvm">`kvm` plugin</a>, which is a great way to get started. This guide is oriented around the command line `virsh`.

sdm's `kvm` plugin and this guide will enable you to take VM virtualization for a spin quickly and easily and create a ARM64 Debian Trixie VM running on RasPiOS.

The guide also explains how to update a Debian netinst CD to enable the VM installation to be fully automatic and customized just for you, using a Debian preseed configuration file.

This is a work in progress. Using RasPiOS or Windows Guest VM docs are TBD.

# Virtualization hardware

* A Pi5 with at least 4GB memory. The more the merrier. This will run on a Pi4, but of course, more slowly.
* Use the fastest storage possible for ISO and VM disk storage. For example, I use an NVMe disk for this. 

```sh
# Adjust for your configuration as needed
sudo mkdir -p /nv
sudo mount /dev/nvme0n1p1 /nv
mkdir -p /nv/disks
mkdir -p /nv/iso
```

# Creating a Debian Trixie VM

Here are the steps to create a Debian Trixie VM.

* Install the `kvm` plugin
* Grab the Debian netinst ARM64 CD
* Create the virtual disk for the VM
* Define the VM

Each of these steps are explained below.


## Install the kvm plugin

sdm's `kvm` plugin configures the host system to enable virtualization:

* Installs the necessary software packages (libvirt, qemu, etc)
* Configures a network bridge for Network Manager enabling you to create VMs on a network that is:
    * Routed to the LAN
    * Bridged to the LAN so the VM appears directly on the LAN
* Assigns the optional specified user to the `libvirt` group (can also be done later with `sudo usermod -a -G libvirt a_user ; sudo usermod -a -G libvirt-qemu a_user`)
* Populates /usr/local/sdm/kvm with a few scripts, shown below, that simplify getting started with kvm

See the <a href="Plugins.md#kvm">kvm plugin documentation</a> for argument details.

Run the plugin during one of:
* Customization (`--customize`) &mdash; Every host installed from this customized IMG will have kvm installed
* Burning (`--burn` or `--burnfile`) &mdash; The host that runs this burned disk will have kvm installed
* Live on the running system (`sdm --runonly plugins --oklive --plugin kvm`) &mdash; The system on which the plugin is run will have kvm installed.
  * If the running system does not have sdm installed, install sdm first:
```sh
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
```

## Download the Debian arm64 network installer

Download the Debian ISO for use with both `virt-install` and `virt-manager`.

* Browse to https://www.debian.org/CD/http-ftp and then select the CD/USB arm64 link
* At the time of this writing, you will download https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-13.5.0-arm64-netinst.iso

## Create the qcow2 disk for the VM

The kvm plugin drops an example script to create a qcow2 disk: `/usr/local/sdm/kvm/create-disk`

* `/usr/local/sdm/kvm/create-disk /path/to/file.qcow2 20G` will create a 20G qcow2 file that grows dynamically as needed (fast creation, slightly less runtime performance)
* `/usr/local/sdm/kvm/create-disk /path/to/file.qcow2 20G full` will create a fully preallocated 20G qcow2 file (slow creation, optimal runtime performance)

```sh
# Create a 20G dynamically growing disk.
/usr/local/sdm/kvm/create-disk /nv/disks/vm1.qcow2
```

## Define the VM

Use the `virt-install` command to define a VM. Here are a couple of useful examples:

The kvm plugin places this file in /usr/local/sdm/kvm/create-vm-and-start

```sh
# Create a new VM and start it. The VM will start and a console window will pop up
#
# $1: vm name
# $2: ISO /path/to/iso
# $3: network name (default is the internal network)

vmname=${1:-vm1}
iso=${2:-/nv/iso/debian-13.5.0-arm64-netinst.iso}
network=${3-default}

virt-install \
  --name $vmname \
  --memory 2048 \
  --vcpus 4 \
  --disk path=/nv/disks/$vmname.qcow2,format=qcow2 \
  --network network=$network \
  --cdrom $iso \
  --os-variant debian13 \
  --machine virt
```

The kvm plugin places this file in /usr/local/sdm/kvm/create-vm-no-start

```sh
# Create a new VM but don't start it

# $1: vm name
# $2: ISO /path/to/iso
# $3: network name (default is the internal network)

vmname=${1:-vm1}
iso=${2:-/nv/iso/debian-13.5.0-arm64-netinst.iso}
network=${3-default}

virt-install \
  --name $vmname \
  --memory 2048 \
  --vcpus 4 \
  --disk path=/nv/disks/$vmname.qcow2,format=qcow2 \
  --network network=$network \
  --cdrom $iso \
  --os-variant debian13 \
  --machine virt \
  --print-xml=1 | virsh define /dev/stdin
```

# Debian VM installation configuration

By default, when a Debian netinst ISO boots the installer steps through the configuration items for you to fill them all in manually. The installer can also use a preseed configuration file that automates the entire process.

## Manual VM installation configuration

Once the machine starts it will go through the standard Debian configuration dialog. If you're on a fast internet connection the installation it will take a few to 20 minutes.

## Automatic VM installation configuration

Debian can use a preseed configuration file (preseed.cfg) to automate the VM installation configuration. The kvm plugin drops a couple of scripts into /usr/local/sdm/kvm that you can use to create an updated Debian netinst ISO.

The steps to to accomplish this are detailed below.

###  Create a preseed file

Download this example preseed file it to your system and edit it as desired: https://github.com/gitbls/sdm/blob/master/extras/trixie-example-preseed.txt

I created the customized preseed.cfg from the standard Debian preseed config: https://www.debian.org/releases/trixie/example-preseed.txt. The changes I made were strictly to get to a working, fully automatic preseed.

You can diff these two files to see what I changed, and therefore, what settings you may want to modify. If you want to make further changes, see <a href="https://www.debian.org/releases/trixie/amd64/apb.en.html ">the preseed documentation</a>.

The disk is configured with a 512MB EFI partition, a 256MB swap partition, and a single partition for the remaining space. Probably best to not change the disk configuration your first go unless you've had prior experience with Debian preseed.

In addition to the disk configuration (all denoted by partman-*) I changed (or would have changed, if needed) these items, so review/modify as appropriate.

* keyboard-configuration/xkb-keymap
* netcfg/get_hostname
* netcfg/get_domain
* passwd/root-password
* passwd/root-password-again
* passwd/user-fullname
* passwd/username
* passwd/user-password
* passwd/user-password-again
* time/zone
* pkgsel/include

passwd/root-passwd-crypted and passwd/user-password-crypted can be used instead of clear-text passwords. Use `mkpasswd -m sha-512` to generate the crypted password.

Preseed documentation: https://www.debian.org/releases/trixie/amd64/apb.en.html 

### Extract the Debian netinst ISO into an work directory

```sh
mkdir -p /nv/isowork
/usr/local/sdm/kvm/extract-iso /path/to/netinst-iso.iso /nv/isowork
```

### Update the work directory to include the preseed.cfg file

```sh
/usr/local/sdm/kvm/update-iso-with-preseed /nv/isowork /path/to/my-edited-preseed.cfg
```

### Build an updated ISO

```sh
/usr/local/sdm/kvm/remake-iso /nv/isowork /nv/iso/my-updated-iso.iso
```

### Use the updated ISO to install Debian

Create a new VM using the updated ISO or update an existing VM to use it by plugging the CDROM into the VM with `virsh change-media`.

### Boot the VM

When the VM starts it will automatically start the installer after a few seconds, and will run to completion, unless you broke it ;)

# Basic VM management commands

These commands helped me jump-start my leap from using `virt-manager` to using the command line `virsh`, which has an extremely rich command set for VM creation and management. Problem-solving TBD.

**virsh command help**
* `virsh help | less`
* `man virsh`

**Viewing and controlling the VM**
* **Connect to a VM console**: `virsh console vmname`
* **Display a VM's graphical desktop**: `virt-viewer` vmname
* **Get VM configuration information from the guest**: `virsh guestinfo vmname`

**Network configuration**
* **Set default (routed) network to autostart**: `virsh net-autostart default`
* **Start the default (routed) network**: `virsh net-start default`
* **Add bridge** to a VM: `virsh attach-interface vmname bridge --source br0 --config`
* **Remove bridge** from a VM: `virsh detach-interface vmname bridge --config`
* **Add default network** to a VM: `virsh attach-interface vmname network --source default --config`
* **Remove default network** from a VM: `virsh detach-interface vmname network --config`

**CDROM plug and eject**
* **Plug in CDROM** (must already be created): `virsh change-media vmname sda /path/to/iso --update`
* **Eject CDROM**: `virsh change-media vmname sda --eject`

**Delete VM**
* **Delete VM definition**: `virsh undefine --domain vmname`

# Creating a RasPiOS Trixie VM

TBD. It's not as easy as vanilla debian ;(

# Creating a Windows VM

TBD

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>


