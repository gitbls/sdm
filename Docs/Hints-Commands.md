# sdm Command Hints and Tricks

I'll be expanding this with useful commands and what they do, often leaning more toward the intermediate to advanced user.

* Do the most minimally possible sdm to test out a new plugin, or some other setting that depends only on the base system

  Test a new plugin doing as little as possible so that plugin test run is quick
```sh
sudo sdm --customize --nouser --poptions noupdate,noupgrade,noautoremove --plugin myplugin 2023-02-21-raspios-bullseye-arm64.img 
```
