#!/usr/bin/env bash

export GOPATH=/home/pi

# Install additional packages
apt-get install -y git

github_clone() {
  provider="github.com"
  user="$1"
  repo="$2"
  mkdir -p "$GOPATH/src/$provider/$user"
  git clone "https://$provider/$user/$repo.git" "$GOPATH/src/$provider/$user/$repo"
}

github_clone russelltsherman new-age-bullshit
# GO111MODULE=on go mod tidy

chown -R pi:pi "$GOPATH/src/"

apt-get install -y espeak festival libttspico-utils

echo "writing /etc/systemd/system/bullshit.service"
cat > /etc/systemd/system/bullshit.service << 'EOL'
[Unit]
Description=New Age Bullshit Generator

[Service]
Environment=GOPATH=/home/pi
Environment=GOCACHE=/home/pi/.cache/go-build
ExecStart=/usr/local/bin/go run /home/pi/src/github.com/russelltsherman/new-age-bullshit/app.go pico

[Install]
WantedBy=multi-user.target
EOL

systemctl enable bullshit
