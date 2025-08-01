# Using sdm plugins on a system created without sdm

So you have a system that you configured up without using sdm, and now you want to use one of the sdm Plugins because they're so cool?

It's pretty simple. Here's how:

```
curl -L https://raw.githubusercontent.com/gitbls/sdm/master/install-sdm | bash
```

EZsdmInstaller will:

* Download and install sdm into `/usr/local/sdm`
* Create and populate the directory tree `/etc/sdm`
* Create a link from `/usr/local/bin/sdm` to `/usr/local/sdm/sdm`

That's it! Then, to run a plugin (in this case, the `hotspot` plugin)  on your running system:
```
sudo sdm --runonly plugins --oklive --plugin hotspot
```

This should work for all plugins except for `explore`, `extractfs`, and `parted`.

Of course you can also use sdm to customize IMGs and burn them to SSDs/SD Cards.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
