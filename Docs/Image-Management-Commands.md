# sdm Image and Disk management commands

sdm has several simple convenience commands to assist with managing a RasPiOS IMG or burned disk. Every one of these commands complete tasks that can of course be done other ways, but are included for their ease of use.

The command format is:
```
sdm <command> /path/to/img [arg1] [arg2]
```

The commands and their arguments are described below. `DEVIMG` can be either a burned disk (/dev/sdX) or a path to an IMG (/path/to/IMG)

* `sdm cat DEVIMG /path/to/file` &mdash; cat the file in the IMG `/path/to/file`
* `sdm df DEVIMG` &mdash; Run `df` on the specified IMG or device
* `sdm journalctl DEVIMG` &mdash; Run `journalctl --boot` on the system journal in the IMG
* `sdm jc DEVIMG` &mdash; A synonym for journalctl
* `sdm jca DEVIMG` &mdash; Run `journalctl` on the system journal in the IMG to display journal entries from all boots
* `sdm jcall DEVIMG` &mdash; A synonym for `jca`
* `sdm less DEVIMG /path/to/file` &mdash; Run `less` on the file `/path/to/file` in the IMG
* `sdm list-boots DEVIMG` &mdash; Run `journalctl --list-boots` on the system journal in the IMG to list the system boots
* `sdm ls DEVIMG /path/to/file` &mdash; run `ls -al` on `/path/to/file` in the IMG
* `sdm rm DEVIMG /path/to/file` &mdash; Run `rm -f` on `/path/to/file` in the IMG
* `sdm rmdir DEVIMG /path/to/dir` &mdash; Run `rmdir -rf` on the directory `/path/to/dir` in the IMG
* `sdm get DEVIMG /path/to/srcfile /path/to/output-dir` &mdash; Copy the file from `/path/to/srcfile` in the IMG to `/path/to/output-dir` on the host
* `sdm put DEVIMG /path/to/srcfile /path/to/output-dir` &mdash; Copy `/path/to/srcfile` on the host system to the directory `/path/to/output-dir` in the IMG. The directory must exist.

<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
