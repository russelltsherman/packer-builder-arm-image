#!/usr/bin/env bash

CONFIG=/boot/config.txt
CMDLINE=/boot/cmdline.txt

# Enable OTG in config
if [ -e $CONFIG ] && grep -q "dtoverlay=dwc2" $CONFIG; then
  echo "dtoverlay=dwc2 present in $CONFIG"

  if [ -e $CONFIG ] && grep -q "^#dtoverlay=dwc2$" $CONFIG; then
    echo "uncommenting"
    sed -i -e "s|#dtoverlay=dwc2|dtoverlay=dwc2|" $CONFIG
  fi
else
  echo "dtoverlay=dwc2 added to $CONFIG"
  printf "\n#enable OTG\ndtoverlay=dwc2" | tee -a $CONFIG
fi

# add cmdline parameter for OTG
if [ -e $CMDLINE ] && grep -q "modules-load=dwc2,g_ether" $CMDLINE; then
  echo "modules-load=dwc2,g_ether present in $CMDLINE"
else
  echo "modules-load=dwc2,g_ether added to $CMDLINE"
  sed -i -e "s|rootwait|rootwait modules-load=dwc2,g_ether|" $CMDLINE
fi
