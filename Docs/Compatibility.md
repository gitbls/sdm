# Compatibility

## Compatibility &mdash; Non-Pi Linux and Pi 32-bit vs 64-bit

sdm only performs customization of RasPiOS images. However, sdm itself can run on other Linux platforms.

sdm, written in Bash, is largely Linux distro-independent and is completely 32-vs-64-bit agnostic.

As of sdm V7.2, sdm itself can now be run on x86_64 Debian-like distros. In addition, sdm running on 32-bit ARM can now operate on 64-bit ARM RasPiOS images. sdm also runs on the <a href="Using-sdm-on-Windows-WSL.md">Windows Subsystem for Linux</a>)

In order to do image customization or use `--explore` on an image when running on a non-RasPiOS host (e.g., x86 or x86_64), the following packages must be installed. EZsdmInstaller installs these packages, and is the recommended method for installing sdm. See <a href="Installing-or-Removing-sdm.md">Installing sdm</a>

    sudo apt install qemu-user-static binfmt-support systemd-container parted

These components enable image customization and `--explore` on an RasPiOS image. If this doesn't work on your Linux system, it may be too old and lacking updated support or fixes. I have tested this on Ubuntu 20.04, and it's able to operate on both RasPiOS 32 and 64-bit images. 

Running on **64-bit RasPiOS** sdm can perform all functions: customize, explore, burn, and mount both 32-bit and 64-bit RasPiOS images.

Running on **32-bit RasPiOS** sdm can also perform all functions. However, when operating on 64-bit RasPiOS images qemu emulation (which runs more slowly) must be used in Phase1, post-install, and burn b0script/b1script functions, as well as Phase 1 and post-install phases in Plugins.

Running on **x86 Debian-like distros**, sdm can also perform all functions. However, as with 32-bit RasPiOS, qemu emulation must be used in Phase1, post-install, and burn b0script/b1script functions and Plugin Phase 1 and post-install phases
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
