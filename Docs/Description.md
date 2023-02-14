# Description

`sdm` provides a quick and easy way to build consistent, ready-to-go SSDs and/or SD cards for the Raspberry Pi. This command line management tool is especially useful if you:

* have multiple Raspberry Pi systems and you want them all to start from an identical and consistent set of installed software packages, configuration scripts and settings, etc.

* want to rebuild your Pi system in a consistent manner with all your favorite packages and customizations already installed. Every time.

* want to do the above repeatedly and a LOT more quickly.

What does *ready-to-go* mean? It means that every one of your systems is fully configured with Keyboard mapping, Locale, Timezone, and WiFi set up as you want, all of your personal customizations and all desired RasPiOS packages and updates installed.

In other words, all ready to work on your next project.

With `sdm` you'll spend a lot less time rebuilding SSDs/SD Cards, configuring your system, and installing packages, and more time on the things you really want to do with your Pi.

Someone in the RaspberryPi.org forums said *"Generally I get by by reflashing an SD card and reinstalling everything from the notes I made previously. That is not such a long winded process."*

While better than not having *any* notes, this approach requires relatively complete notes, and careful attention to detail each and every time you need to reflash a card.

`sdm` lets you keep your notes in simple working bash code and comments, and makes a "not such a long winded process" into a single command that you run whenever you need to create a new SD card or SSD. And the disk is built with ALL of your favorite apps installed and all your favorite customizations.

`sdm` is for RasPiOS, and runs on RasPiOS Stretch, Buster, and Bullseye. It can also run on other Linux systems. See <a href="Compatibility.md">Compatibility</a>. `sdm` requires a USB SD Card reader to write a new SD Card, or a USB adapter to write a new SSD. You cannot use `sdm` to rewrite the running system's system disk.

`sdm` is written completely in Bash, except for the Captive Portal module, which is Python. This means that you can:

* **Easily inspect** EVERYTHING that sdm does
* **Easily make changes to sdm**, although sdm makes it easy to implement your customizations so you shouldn't need to modify sdm itself

Have questions about sdm? Please don't hesitate to ask in the Issues section of this github. If you don't have a github account (so can't post an issue/question here), please feel free to email me at: [gitbls@outlook.com](mailto:gitbls@outlook.com).

You can watch sdm in action [here](https://youtu.be/CpntmXK2wpA)
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
