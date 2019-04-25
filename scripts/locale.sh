#!/bin/bash
set -x

# Set locale to en_US.UTF-8
sudo cp /etc/locale.gen /etc/locale.gen.dist
sudo sed -i -e "/^[^#]/s/^/#/" -e "/en_US.UTF-8/s/^#//" /etc/locale.gen

cp /var/cache/debconf/config.dat /var/cache/debconf/config.dat.dist
sudo sed -i -e "s/Value: en_GB.UTF-8/Value: en_US.UTF-8/" \
       -e "s/ locales = en_GB.UTF-8/ locales = en_US.UTF-8/" /var/cache/debconf/config.dat

sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
