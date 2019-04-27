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
  echo "
  #enable i2c
  dtparam=i2c_arm=on" | tee -a $CONFIG
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

# Enable SPI
if [ -e $CONFIG ] && grep -q "dtparam=spi=on" $CONFIG; then
  echo "dtparam=spi=on present in $CONFIG"

  if [ -e $CONFIG ] && grep -q "^#dtparam=spi=on$" $CONFIG; then
    echo "uncommenting"
    sed -i -e "s|#dtparam=spi=on|dtparam=spi=on|" $CONFIG
  fi
else
  echo "dtparam=spi=on added to $CONFIG"
  echo "
  #enable spi
  dtparam=spi=on" | tee -a $CONFIG
fi

# Configure your Pi to use I2C devices
apt-get install -y \
  python-smbus \
  i2c-tools \
  python3-pip

pip3 install --upgrade setuptools
pip3 install RPI.GPIO
pip3 install adafruit-blinka
pip3 install adafruit-circuitpython-servokit

tee /home/pi/blinkatest <<'PYTHON'
#!/usr/bin/env python3

import board
import digitalio
import busio

print("Hello blinka!")

# Try to great a Digital input
pin = digitalio.DigitalInOut(board.D4)
print("Digital IO ok!")

# Try to create an I2C device
i2c = busio.I2C(board.SCL, board.SDA)
print("I2C ok!")

# Try to create an SPI device
spi = busio.SPI(board.SCLK, board.MOSI, board.MISO)
print("SPI ok!")

print("done!")
PYTHON
chown pi:pi /home/pi/blinkatest

# You can then detect if the HAT is found on the #1 I2C port with:
# i2cdetect -y 1
