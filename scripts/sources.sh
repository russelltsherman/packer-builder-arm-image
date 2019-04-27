#!/usr/bin/env bash
set -x

# Updates

# original raspi.list content
# deb http://archive.raspberrypi.org/debian/ stretch main ui
# # Uncomment line below then 'apt-get update' to enable 'apt-get source'
# #deb-src http://archive.raspberrypi.org/debian/ stretch main ui

## Add the missing raspbian repo
echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi firmware" | tee -a /etc/apt/sources.list.d/raspi.list

## Get proper keys & update
apt-get install -y debian-archive-keyring --allow-unauthenticated
apt-get install -y debian-keyring
apt-get update

## Run upgrades
apt-get dist-upgrade -y --force-yes
