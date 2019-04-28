#!/usr/bin/env bash

export GOPATH=/home/pi

github_clone() {
  provider="github.com"
  user="$1"
  repo="$2"
  mkdir -p "$GOPATH/src/$provider/$user"
  git clone "https://$provider/$user/$repo" "$GOPATH/src/$provider/$user/$repo"
}

github_clone russelltsherman gpio
github_clone russelltsherman blinkt
github_clone russelltsherman blinkt_examples
github_clone cckuailong colorsys-go

chown -R pi:pi "$GOPATH/src/"

# fix permissions issue with userspace control of gpio
chgrp -R gpio /sys/class/gpio
chmod -R g+rw /sys/class/gpio

echo "writing /etc/systemd/system/revolving.service"
cat > /etc/systemd/system/revolving.service << 'EOL'
[Unit]
Description=Blinkt Color revolving

[Service]
Environment=GOPATH=/home/pi
Environment=GOCACHE=/home/pi/.cache/go-build
ExecStart=/usr/local/bin/go run /home/pi/src/github.com/russelltsherman/blinkt_examples/revolving/app.go

[Install]
WantedBy=multi-user.target
EOL

echo "enable revolving.service"
systemctl enable revolving
