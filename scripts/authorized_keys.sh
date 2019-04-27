#!/bin/bash -e
set -x

mkdir -p /home/pi/.ssh

sudo tee /home/pi/.ssh/authorized_keys <<'KEYS'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4QCqtjvfm3Ih+pIQ0cS1NmHIpzhO2/p4xBSk/dzyJxXaljygwxdE+19qLh11HKK2tlZXBjGAb6JIPm+QbiIFdSzc/74+Ls+TiUIWKicygqniWn1cJHsREZ1WuMjzyzA4yfdkjDkmQlFZlkaWMOE8yYaZl3R63h+mD4klMJoAFdeONqABwXNW7Kt3QcMnYH+k+wR09MyhWwxZgpzrjPaenfGW010YSG3MsbFkSCQMjZOBFSbIkNRc0yXL+ENZvI+JVYA1HVNES5roFqRI9j1McrAZgkHuvz83IcDe5oFbvZq2s7nfwNYTXw0vsKjGDSAkLbc/Uh40QuUJ4rkejuuqb russell.t.sherman@gmail.com
KEYS

chown pi:pi /home/pi/.ssh/authorized_keys
chmod 600 /home/pi/.ssh/authorized_keys
