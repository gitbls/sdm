# Example: Burn Multiple Hosts From a Single IMG

This is a very simple script that doesn't do much. See the sdm script sdm-gburn if your needs for this are more complex.

```
#!/bin/bash
#
# Burn a bunch of SSDs/SD Cards from the same image
# Each will have a unique hostname 
#
function askyn() {
    #
    # $1: Prompt string
    # $2: default answer: "y" or "n"
    #
    local ans
    echo -n "$1 " ; read -n 1 ans
    [ "$ans" == "" ] && ans="$2" || echo ""
    case "${ans,,}" in
        y*) return 0 ;;
        *) return 1 ;;
    esac
}

# Change this to be the name of the device you want to burn to
odev="/dev/sdc"
# Change this to be the full path to the IMG you want to burn
img="/path/to/customized.img"

# Change the host names to suit your needs. You'll need one SSD/SD Card
# for each of the hosts
#
for hn in host1 host2 host3 
do
    echo "* Insert SSD/SD Card in $odev then press Enter to burn"
    if askyn "Burn host '$hn' on $odev? [Y/n]:" "y"
    then
        sdm --burn $odev --hostname $hn --expand-root $img
    fi
done
```
<br>
<form>
<input type="button" value="Back" onclick="history.back()">
</form>
