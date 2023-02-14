#!/usr/bin/env bash
#
DEBUG=${DEBUG:-1}
[ "$DEBUG" -ge 1 ] && set -o errtrace                                     # If set, the ERR trap is inherited by shell functions.
[ "$DEBUG" -ge 1 ] && set -o errexit                                      # Exit immediately if a command exits with a non-zero status.
[ "$DEBUG" -ge 1 ] && set -o nounset                                      # Treat unset variables as an error when substituting.
[ "$DEBUG" -ge 1 ] && set -o pipefail                                     # The return value of a pipeline is the status of the last command to exit with
[ "$DEBUG" -ge 2 ] && set -x                                               # Debugging
[ "$DEBUG" -ge 1 ] && export DEBUG
#
function fDebugLog() {
    logLvl=${1:-99}             # Logging level to log message at.
    logMsg="${2:-"NO MSG"}"     # Messge to log.
    logWait="${3:-"nowait"}"    # wait="Press any key to continue."
                                # yesno="Do you wish to continue (Y/N)?"
                                # nowait=Don't wait.

    if [ $logLvl -le $DEBUG ]; then
        printf "[${logLvl}/${DEBUG}] %s\n" ${logMsg} 1>&2
        if [ "$logWait" == "wait" ]; then
            printf "Press any key to continue...\n" 1>&2
            read -n 1 -s -r
        elif [ "$logWait" == "yesno" ]; then
            printf "Do you wish to continue? (Y/N)\n" 1>&2
            while true
                do
                    read -r -n 1 -s choice
                    case "$choice" in
                        n|N) exit 1;;
                        y|Y) break;;
                        *) echo 'Response not valid' 1>&2 ;;
                    esac
            done
        fi
    fi
}

function errexit() {
    echo -e "$1" 1>&2
    exit 1
}

function printhelp() {
    echo $"$0 $version
Usage:
 $0 --baseUrl baseUrl --os|-o os --arch|-a arch --edition|-e edition --version|-v --help|-h --test|-t
   Download the most recent raspios from the internet to the current directory.

Command Switches
 --os os                Operation System to download.  Currently only raspios is supported.  Default \"raspios\".
 --edition edition      Eddition to download.  \"lite\" & \"full\" are currently supported.  Default \"lite\".
 --arch arch            Architecture to download.  \"arm\" and \arm64\" are currently supported.  Default \"arm64\".
 --baseUrl baseUrl      URL to download from.  Default \"https://downloads.raspberrypi.org/\${os}_\${edition}_\${arch}/images/\".
 --test                 Lookup and show the download URL only, without downloading anything.
 --version              Print $0 version number and exit.
 --help                 Display this help and exit." 1>&2

}
#
# Initialize and Parse the command
#
#
version="V0.0.1dev"
#
# Set command line defaults
#
os=raspios
edition=lite
arch=arm64
baseUrl="https://downloads.raspberrypi.org/${os}_${edition}_${arch}/images/"
testing=0
pvers=0
#
# Parse the command line
#
cmdline="$0 $*"
longopts="help,os:,edition:,arch:,baseUrl:,version,test"

OARGS=$(getopt -o o:e:a:u:vth --longoptions $longopts -n 'get_latest_pios.sh' -- "$@")
[ $? -ne 0 ] && errexit "? $0: Unable to parse command"
eval set -- "$OARGS"

while true
do
    case "${1,,}" in
	# 'shift 2' if switch has argument, else just 'shift'
	-o|--os)          os=$2         ; shift 2 ;;
	-e|--edition)     edition=$2    ; shift 2 ;;
	-a|--arch)        arch=$2       ; shift 2 ;;
	-u|--url)         baseUrl="$2"  ; shift 2 ;;
	-v|--version)     pvers=1       ; shift 1 ;;
	-t|--test)        testing=1     ; shift 1 ;;
	--)               shift         ; break ;;
	-h|--help)        printhelp ; shift ; exit 0 ;;
	*)                errexit "? $0: Internal error" ;;
    esac
done

[ $pvers -eq 1 ] && echo "$0 Version $version" && exit 0

fDebugLog 0 "DEBUG=${DEBUG}"
fDebugLog 1 "baseUrl=${baseUrl}" 
latestUrl=$(curl -s ${baseUrl} | sed -n 's/.*href="\([^"]*\).*/\1/p' | tail -1)

fDebugLog 1 "latestUrl=${latestUrl}" 
filename=$(curl -s ${baseUrl}${latestUrl} | sed -n 's/.*href="\([^"]*\).*/\1/p' | head -3 | tail -1)

fDebugLog 1 "filename=${filename}" 
downloadUrl="${baseUrl}${latestUrl}${filename}"

fDebugLog 0 "downloadUrl=${downloadUrl}"
extractedFilename=${filename::-3}

fDebugLog 0 "extractedFilename=${extractedFilename}"
if [ ${testing} -eq 0 ]; then
    fDebugLog 1 "About to download ${downloadUrl}" yesno && curl ${downloadUrl} | unxz - > ./${extractedFilename}
else
    echo "${downloadUrl}" 2>&1
fi
exit 0
