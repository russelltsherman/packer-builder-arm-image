#!/bin/bash
set -x

# Localse, uncomment if user-data didn't fix these
export LANGUAGE=en_US.UTF-8; export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8; locale-gen en_US.UTF-8

# Set locale to en_US.UTF-8
sudo cp /etc/locale.gen /etc/locale.gen.dist
sudo sed -i -e "/^[^#]/s/^/#/" -e "/en_US.UTF-8/s/^#//" /etc/locale.gen

cp /var/cache/debconf/config.dat /var/cache/debconf/config.dat.dist
sudo sed -i -e "s/Value: en_GB.UTF-8/Value: en_US.UTF-8/" \
       -e "s/ locales = en_GB.UTF-8/ locales = en_US.UTF-8/" /var/cache/debconf/config.dat

sudo locale-gen
sudo update-locale LANG=en_US.UTF-8

exec "$BASH" <<EOF
set -x

# Updates
## Add the missing raspbian repo
echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi firmware" | sudo tee -a /etc/apt/sources.list.d/raspi.list

## k8s
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Update after said changes so we can pull the archive keyring
sudo apt-get update -qq

## Get proper keys & update
sudo apt-get install -qy --force-yes debian-archive-keyring debian-keyring
sudo apt-get update -qq

## Run upgrades
export DEBIAN_FRONTEND=noninteractive
sudo apt-get dist-upgrade -qy --force-yes

# Install packages
## This installs some "handy" packages (vim, git, wget, curl)
## Along with avahi/netatalk so we can access the nodes by name
## Finally we add cloud-init to ease the flashing process

sudo apt-get install -qy \
    vim \
    git \
    wget \
    curl \
    unzip \
    avahi-daemon \
    netatalk \
    cloud-init \
    kubeadm=1.8.6-00

# Configure cloud-init
mkdir -p /var/lib/cloud/seed/nocloud-net
ln -s /boot/user-data /var/lib/cloud/seed/nocloud-net/user-data
ln -s /boot/meta-data /var/lib/cloud/seed/nocloud-net/meta-data

# Enable ssh for remote access
sudo systemctl enable ssh
sudo systemctl start ssh

# Settings so that k8s and Docker are able do their thing
## Disable swap
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove

## Enable cgroups
sed -i "s/$/ cgroup_enable=cpuset cgroup_memory=1/" /boot/cmdline.txt

# Docker
## Install Docker
curl -sSL get.docker.com | sh && \
sudo usermod pi -aG docker

## Roll back Docker version for k8s
sudo apt-get autoremove -y --purge docker-ce
sudo rm -rf /var/lib/docker
sudo apt-get install -y docker-ce=17.09.0~ce-0~raspbian

EOF