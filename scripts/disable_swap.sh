#!/usr/bin/env bash

# disable swap
dphys-swapfile swapoff
dphys-swapfile uninstall
systemctl disable dphys-swapfile
sudo update-rc.d dphys-swapfile remove

# /var/log and /tmp to in memory file system to prevent excessive sd write
echo "tmpfs    /var/log    tmpfs   size=10M,noatime     0   0" | tee -a /etc/fstab
echo "tmpfs    /tmp        tmpfs   size=100M,noatime    0   0" | tee -a /etc/fstab
