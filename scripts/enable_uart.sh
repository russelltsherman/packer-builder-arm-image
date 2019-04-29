#!/usr/bin/env bash

CONFIG=/boot/config.txt

# Enable OTG in config
if [ -e $CONFIG ] && grep -q "enable_uart=1" $CONFIG; then
  echo "enable_uart=1 present in $CONFIG"

  if [ -e $CONFIG ] && grep -q "^#enable_uart=1$" $CONFIG; then
    echo "uncommenting"
    sed -i -e "s|#enable_uart=1|enable_uart=1|" $CONFIG
  fi
else
  echo "enable_uart=1 added to $CONFIG"
  printf "\n#enable serial console\nenable_uart=1\n" | tee -a $CONFIG
fi
