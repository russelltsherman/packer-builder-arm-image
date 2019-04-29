#!/usr/bin/env bash

CONFIG=/boot/config.txt

if [ -e $CONFIG ] && grep -q "^device_tree=$" $CONFIG; then
  echo "No Device Tree Detected, not supported"
  exit 1
fi

# Enable SPI
if [ -e $CONFIG ] && grep -q "dtparam=spi=on" $CONFIG; then
  echo "dtparam=spi=on present in $CONFIG"

  if [ -e $CONFIG ] && grep -q "^#dtparam=spi=on$" $CONFIG; then
    echo "uncommenting"
    sed -i -e "s|#dtparam=spi=on|dtparam=spi=on|" $CONFIG
  fi
else
  echo "dtparam=spi=on added to $CONFIG"
  printf "\n#enable spi\ndtparam=spi=on\n" | tee -a $CONFIG
fi
