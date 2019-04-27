#!/usr/bin/env bash
# shellcheck disable=SC2068

CONFIG=/boot/config.txt
LOADMOD=/etc/modules

if [ -e $CONFIG ] && grep -q "^device_tree=$" $CONFIG; then
  echo "No Device Tree Detected, not supported"
  exit 1
fi

if [ -e $CONFIG ] && grep -q "^dtoverlay=hifiberry-dac$" $CONFIG; then
  echo "dtoverlay already active"
else
  echo "dtoverlay=hifiberry-dac" | tee -a $CONFIG
fi

if [ -e $CONFIG ] && grep -q "^dtoverlay=i2s-mmap$" $CONFIG; then
  echo "i2s mmap dtoverlay already active"
else
  echo "dtoverlay=i2s-mmap" | tee -a $CONFIG
fi

if [ -e $CONFIG ] && grep -q -E "^dtparam=audio=on$" $CONFIG; then
  sed -i "s|^dtparam=audio=on$|#dtparam=audio=on|" $CONFIG &> /dev/null
  if [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
    sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
  fi
elif [ -e $LOADMOD ] && grep -q "^snd-bcm2835" $LOADMOD; then
  sed -i "s|^snd-bcm2835|#snd-bcm2835|" $LOADMOD &> /dev/null
fi

echo "writing /etc/asound.conf"
cat > /etc/asound.conf << 'EOL'
pcm.speakerbonnet {
  type hw card 0
}

pcm.dmixer {
  type dmix
  ipc_key 1024
  ipc_perm 0666
  slave {
    pcm "speakerbonnet"
    period_time 0
    period_size 1024
    buffer_size 8192
    rate 44100
    channels 2
  }
}

ctl.dmixer {
  type hw card 0
}

pcm.softvol {
  type softvol
  slave.pcm "dmixer"
  control.name "PCM"
  control.card 0
}

ctl.softvol {
  type hw card 0
}

pcm.!default {
  type             plug
  slave.pcm       "softvol"
}
EOL

echo "writing /etc/systemd/system/aplay.service"
cat > /etc/systemd/system/aplay.service << 'EOL'
[Unit]
Description=Invoke aplay from /dev/zero at system start.

[Service]
ExecStart=/usr/bin/aplay -D default -t raw -r 48000 -c 2 -f S16_LE /dev/zero

[Install]
WantedBy=multi-user.target
EOL

echo "enable aplay.service"
systemctl enable aplay
