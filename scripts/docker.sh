#!/usr/bin/env bash
set -x

# Docker
## Install Docker
curl -sSL get.docker.com | sh
## add pi user to docker group
usermod pi -aG docker

## Roll back Docker version for k8s
apt-get autoremove -y --purge docker-ce
rm -rf /var/lib/docker
apt-get install -y docker-ce=17.09.0~ce-0~raspbian

# For Kubernetes 1.7 and onwards you will get an error if swap space is enabled.
# Turn off swap:
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

## k8s
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Update after said changes so we can pull the archive keyring
apt-get update -qq
apt-get install -qy kubeadm

## Enable cgroups

# echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
# sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
# orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
# echo $orig | sudo tee /boot/cmdline.txt

echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=c1dc39e5-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory modules-load=dwc2,g_ether quiet init=/usr/lib/raspi-config/init_resize.sh" | tee /boot/cmdline.txt
