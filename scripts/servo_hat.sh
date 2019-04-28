#!/usr/bin/env bash

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
