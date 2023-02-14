# Local apt caching server

apt-cacher-ng is a great RasPiOS package, and practically essential if you have more than a couple of Pi systems. The savings in download MB and installation wait time is really quite impressive.

For example, a quick demonstration at 9:44 in the video https://www.youtube.com/watch?v=CpntmXK2wpA shows a 175MB apt update reduced from *40 seconds* with 175MB of internet download to ***5 seconds*** of LAN-only (no internet) download. Per Pi. The more Pis you have and the more you rebuild those Pi systems, the more you save.

apt-cacher-ng requires a system running the apt-cacher server. For your sanity and the best and most reliable results, run this on a "production", always available Pi.

You can use `--plugin apt-cacher-ng` when burning the SD card for the system you've targeted to be the server.

Alternatively, if the system is already running, copy sdm-apt-cacher to the server and execute the command `sudo /path/to/sdm-apt-cacher server`. This will install apt-cacher-ng on the server and configure it for use. If the server firewall blocks port 3142 you'll need to add a rule to allow it.

Once you have the apt-cacher server configured you can use the `--aptcache` *IPaddr* sdm command switch to configure the IMG system for all your other systems to use the APT cacher.

If you have other existing, running Pis that you want to convert to using your apt-cacher server, copy sdm-apt-cacher to each one and execute the command `sudo /path/to/sdm-apt-cacher client`.
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
