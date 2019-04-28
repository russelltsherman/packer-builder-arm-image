#!/usr/bin/env bash

CMDLINE=/boot/cmdline.txt

## Install Docker
curl -sSL get.docker.com | sh
## add pi user to docker group
usermod pi -aG docker

## Roll back Docker version for kubernetes
apt-get autoremove -y --purge docker-ce
rm -rf /var/lib/docker
apt-get install -y docker-ce=17.09.0~ce-0~raspbian

## Install kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Update after said changes so we can pull the archive keyring
apt-get update -qq && apt-get install -qy kubeadm

# add cmdline parameter for cgroups
if [ -e $CMDLINE ] && grep -q "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" $CMDLINE; then
  echo "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory present in $CMDLINE"
else
  echo "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory added to $CMDLINE"
  sed -i -e "s|rootwait|rootwait cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory|" $CMDLINE
fi
