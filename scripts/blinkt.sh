#!/usr/bin/env bash


apt-get install -qy wiringpi

export GOPATH=/home/pi/go/

mkdir -p $GOPATH/src/github.com/russelltsherman/

cd $GOPATH/src/github.com/russelltsherman/ || exit

git clone https://github.com/russelltsherman/blinkt_go

git clone https://github.com/russelltsherman/blinkt_go_examples

cd blinkt_go || exit

go get

go build
