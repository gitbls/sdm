#!/usr/bin/env bash

[ "$DEBUG" -ge 1 ] && set -o errtrace                                     # If set, the ERR trap is inherited by shell functions.
[ "$DEBUG" -ge 1 ] && set -o errexit                                      # Exit immediately if a command exits with a non-zero status.
[ "$DEBUG" -ge 1 ] && set -o nounset                                      # Treat unset variables as an error when substituting.
[ "$DEBUG" -ge 1 ] && set -o pipefail                                     # The return value of a pipeline is the status of the last command to exit with
#[ $DEBUG -ge 2 ] && set -x                                               # Debugging
[ $DEBUG -ge 1 ] && export DEBUG
                                                    # a non-zero status, or zero if no command exited with a non-zero status.
declare -x baseDirectory           && baseDirectory=${baseDirectory:-/home/carl/dev/origsdm}
declare -x baseImage               #&& baseImage=${baseImage:-2022-09-22-raspios-bullseye-arm64-lite.img}
declare -x baseImageDirectory      && baseImageDirectory=${baseImageDirectory:-"baseos"}
declare -x hostName                && hostName=${hostName:-"rpicm4-1"}
declare -x baseUrl                 && baseUrl=${baseUrl:-"https://downloads.raspberrypi.org/"}
declare -x downloadUrl

downloadUrl="$("${baseDirectory}"/get_lasest_pios.py ${baseUrl} raspios lite arm64 bullseye)"
baseImage=$(echo ${downloadUrl} | sed 's:.*/::')
baseImage=${baseImage::-3}

function fDebugLog() {
    logLvl=${1:-99}             # Logging level to log message at. Default 99.
    logMsg="${2:-"NO MSG"}"     # Messge to log.
    logWait="${3:-"nowait"}"    # wait="Press any key to continue."
                                # yesno="Do you wish to continue (Y/N)?"
                                # nowait=Don't wait.

    if [ $logLvl -le $DEBUG ]; then
        printf "[${logLvl}/${DEBUG}] %s\n" ${logMsg}
        if [ "$logWait" == "wait" ]; then
            printf "Press any key to continue...\n"
            read -n 1 -s -r
        elif [ "$logWait" == "yesno" ]; then
            printf "Do you wish to continue? (Y/N)\n"
            while true
                do
                    read -r -n 1 -s choice
                    case "$choice" in
                        n|N) exit 1;;
                        y|Y) break;;
                        *) echo 'Response not valid';;
                    esac
            done
        fi
    fi
}

IFS=''
fDebugLog 1 "downloadUrl=${downloadUrl}"
fDebugLog 1 "baseDirectory=${baseDirectory}"
fDebugLog 1 "baseImageDirectory=${baseImageDirectory}"
fDebugLog 1 "baseImage=${baseImage}"
fDebugLog 1 "hostName=${hostName}"

if [ ! -d "${baseDirectory}/${baseImageDirectory}/" ] ; then
    fDebugLog 1 "Making directory ${baseDirectory}/${baseImageDirectory}/"
    mkdir -pv "${baseDirectory}/${baseImageDirectory}/"
else
    fDebugLog 1 "Skipping Making directory ${baseDirectory}/${baseImageDirectory}/"
fi

if [ ! -e "${baseDirectory}/${baseImageDirectory}/${baseImage}" ] ; then
    fDebugLog 0 "Downloading & extracting ${downloadUrl}"
    fDebugLog 0 " to ${baseDirectory}/${baseImageDirectory}/${baseImage}" yesno
    curlOps="" && [ "$DEBUG" -ge 2 ] && curlOps="--verbose"
    curl $curlOps $downloadUrl | unxz - > "${baseDirectory}"/"${baseImageDirectory}"/"${baseImage}"
else
    fDebugLog 1 "Skipping Downloading & extracting $downloadUrl"
    fDebugLog 1 " to ${baseDirectory}/${baseImageDirectory}/${baseImage}"
fi

if [ ! -d "${baseDirectory}/output/" ] ; then
    fDebugLog 1 "Making directory ${baseDirectory}/output/"
    mkdir -pv "${baseDirectory}/output/"
else
    fDebugLog 1 "Skipping Making directory ${baseDirectory}/output/"
fi

fDebugLog 1 "Syncing ${baseDirectory}/${baseImageDirectory}/${baseImage} to ${baseDirectory}/output/${hostName}.img"
rsync -ah --progress "${baseDirectory}"/"${baseImageDirectory}"/"${baseImage}" "${baseDirectory}"/output/"${hostName}".img

fDebugLog 0 "Running ${baseDirectory}/sdm --customize"
"${baseDirectory}"/sdm --customize "${baseDirectory}"/output/"${hostName}".img \
    --apt-dist-upgrade \
    --disable piwiz,swap \
    --dtoverlay i2c-rtc,pcf85063a,i2c_csi_dsi,dwc2,dr_mode=host \
    --dtparam i2c_vc=on \
    --l10n --password-user Manager09 \
    --restart \
    --showapt \
    --showpwd \
    --svcdisable fake-hwclock \
    --user carl \
    --wpa /etc/wpa_supplicant/wpa_supplicant.conf \
    --extend \
    --xmb 3073 \
    --batch \
    --fstab "${baseDirectory}"/my-fstab \
    --plugin apt-file \
    --plugin btfix:"assetDir=${baseDirectory}/assets/"
#    --poptions apps \
#    --apps "zram-tools nmap tmux git command-not-found bash-completion gparted btrfs-progs systemd-container jq python3-pip shellcheck lvm2" \
    
fDebugLog 0 "Running ${baseDirectory}/sdm --shrink ${baseDirectory}/output/${hostName}.img" yesno
"${baseDirectory}"/sdm --shrink "${baseDirectory}"/output/"${hostName}".img || true

exit 0
