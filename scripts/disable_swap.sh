#!/usr/bin/env bash

# disable swap
dphys-swapfile swapoff
dphys-swapfile uninstall
systemctl disable dphys-swapfile
sudo update-rc.d dphys-swapfile remove

# direct /var/log to in memory file system to prevent excessive writing to sd card
echo "none            /var/log            tmpfs   size=1M,noatime             0   0" | tee -a /etc/fstab
