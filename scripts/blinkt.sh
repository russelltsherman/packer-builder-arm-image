#!/usr/bin/env bash

export GOPATH=/home/pi/

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

chown -R pi:pi "$GOPATH/src/"

# fix permissions issue with userspace control of gpio
chgrp -R gpio /sys/class/gpio
chmod -R g+rw /sys/class/gpio
