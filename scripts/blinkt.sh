#!/usr/bin/env bash

export GOPATH=/home/pi/

github_clone() {
  provider="github.com"
  user="$1"
  repo="$2"
  mkdir -p "$GOPATH/src/$provider/$user"
  git clone "https://$provider/$user/$repo" "$GOPATH/src/$provider/$user/$repo"
}

apt-get install -qy wiringpi

github_clone russelltsherman blinkt_go
github_clone russelltsherman blinkt_go_examples
