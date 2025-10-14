# Using Docker

sdm can work from within a Docker container.

Some reasons to do this are:
- reliable and repeatable image creation (much in the spirit of sdm)
- one might dislike the dependencies of sdm (e.g. as installed by EZsdmInstaller)
- one might dislike to run so many "scary" (e.g. fdisk, ...) commands as root on important systems
- one might dislike to run shell scripts freshly downloaded from the Internet (in particular as root)

But in order to function, sdm still needs elevated permissions (e.g. for losetup and mount calls), so the `--priviledged` flag to docker is required. That flag means the docker container can protect against mistakes by the sdm developers, but won't prevent malicious attacks.

First (after making sure that `sudo docker run hello-world` does work well), create a script `myscript.sh` that you want to run inside the container:

```
#!/bin/bash

# prepare the environment and download sdm
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get --yes install fdisk git file binfmt-support systemd binfmt-support gdisk keyboard-configuration parted qemu-user-static rsync systemd-container uuid
git clone https://github.com/gitbls/sdm

# customize the image. Probably add many more --plugin lines here
sdm/sdm --customize --sdmdir /root/sdm \
  --plugin sshd:"password-authentication=no" \
  --plugin disables:piwiz \
  /root/sdm_working_dir/2024-11-19-raspios-bookworm-armhf-lite.img

# burn the image
sdm/sdm --sdmdir /root/sdm \
  --burnfile /root/sdm_working_dir/burned.img \
  --host somepi \
  /root/sdm_working_dir/2024-11-19-raspios-bookworm-armhf-lite.img
```

See <a href="Example-Burn-Multiple-Hosts-From-Single-IMG.md">Example-Burn-Multiple-Hosts-From-Single-IMG</a> for an idea how to burn many images in one loop.

Second, prepare a directory to inject into the container:
```
mkdir working_dir
cd working_dir
wget https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-11-19/2024-11-19-raspios-bookworm-armhf-lite.img.xz
unxz 2024-11-19-raspios-bookworm-armhf-lite.img.xz
cd ..
```

Third, execute!

```
sudo docker run --privileged --network host --rm \
  -v "$(pwd)/myscript.sh:/myscript.sh" \
  -v "$(pwd)/working_dir:/root/sdm_working_dir" \
  --device=/dev/loop-control \
  --device=/dev/loop0 \
   debian:latest bash /myscript.sh
```

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
