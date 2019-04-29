#!/usr/bin/env bash

CONFIG=/boot/config.txt
LOADMOD=/etc/modules

if [ -e $CONFIG ] && grep -q "^device_tree=$" $CONFIG; then
  echo "No Device Tree Detected, not supported"
  exit 1
fi

# Enable I2C
if [ -e $CONFIG ] && grep -q "dtparam=i2c_arm=on" $CONFIG; then
  echo "dtparam=i2c_arm=on present in $CONFIG"

  if [ -e $CONFIG ] && grep -q "^#dtparam=i2c_arm=on$" $CONFIG; then
    echo "uncommenting"
    sed -i -e "s|#dtparam=i2c_arm=on|dtparam=i2c_arm=on|" $CONFIG
  fi
else
  echo "dtparam=i2c_arm=on added to $CONFIG"
  printf "\n#enable i2c\ndtparam=i2c_arm=on\n" | tee -a $CONFIG
fi

if [ -e $LOADMOD ] && grep -q "i2c-dev" $LOADMOD; then
  echo "i2c-dev module present in $LOADMOD"

  if [ -e $LOADMOD ] && grep -q "^#i2c-dev$" $LOADMOD; then
    echo "uncommenting"
    sed -i -e "s|#i2c-dev|i2c-dev|" $LOADMOD
  fi
else
  echo "i2c-dev module added to $LOADMOD"
  echo "i2c-dev" | tee -a $LOADMOD
fi
