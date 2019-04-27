#!/usr/bin/env bash

version="1.12.4"
arch="linux-armv6l"
release="go${version}.${arch}.tar.gz"

wget https://dl.google.com/go/$release
sudo tar -xvf $release -C /usr/local/
rm $release

ln -s /usr/local/go/bin/go /usr/local/bin/go
ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc
ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

echo "
# set gopath
export GOPATH=/home/pi
" | tee -a /home/pi/.bashrc
