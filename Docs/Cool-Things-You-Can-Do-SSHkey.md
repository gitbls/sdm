# Cool and Useful Things: SSHkey

Generate a host-specific SSH key when burning the disk and retrieve it for use elsewhere.

Use the `sshkey` plugin to create an SSH key for a specific user/disk. Use the `postburn` plugin to run a script that extracts certs from the burned disk to a host-based directory.
```
--plugin sshkey:"sshuser=myuser|keyname=mykeyname|passphrase=mypassphrase"
--burn-plugin postburn:"runscript=/path/to/postburn-get-certs|runphase=phase0|where=host"
```

with the script post-burn-get-certs:

```
#!/bin/bash

mydir="/path/to/my/dir"
echo "> Copy certs to save location on the host"
# This will require your customization. Use $SDMPT to reference files and directories on the burned disk
# 
#cp $SDMPT/path/cert-file /path/on/host/dir
#
# For example
#
cp $SDMPT/home/myuser/.ssh/mykeyname /path/on/host/dir
```

<a href="Plugins.md#sshkey">`sshkey` plugin documentation</a><br>
<a href="Plugins.md#postburn">`postburn` plugin documentation</a>


<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
