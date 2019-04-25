#!/bin/bash
set -x

echo "
#enable OTG
dtoverlay=dwc2" | tee -a /boot/config.txt

echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=c1dc39e5-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait modules-load=dwc2,g_ether quiet init=/usr/lib/raspi-config/init_resize.sh" | tee /boot/cmdline.txt
