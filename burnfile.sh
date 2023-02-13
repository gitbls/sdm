#!/usr/bin/env bash

set -o errtrace                                     # If set, the ERR trap is inherited by shell functions.
set -o errexit                                      # Exit immediately if a command exits with a non-zero status.
set -o nounset                                      # Treat unset variables as an error when substituting.
set -o pipefail                                     # The return value of a pipeline is the status of the last command to exit with

declare baseDirectory="/home/carl/dev/origsdm"
declare baseImage="2022-09-22-raspios-bullseye-arm64-lite.img"
declare baseImageDirectory="baseos"
declare hostName="rpicm4-1"

if [ -f "/home/carl/dev/origsdm/output/rpicm4-1-out.img" ] ; then
    mv -v "/home/carl/dev/origsdm/output/rpicm4-1-out.img" "/home/carl/dev/origsdm/output/rpicm4-1-out.img.old"
fi

/home/carl/dev/origsdm/sdm --burnfile /home/carl/dev/origsdm/output/rpicm4-1-out.img \
    --host rpicm4-1.1stcall.uk \
    --regen-ssh-host-keys \
    /home/carl/dev/origsdm/output/rpicm4-1.img
