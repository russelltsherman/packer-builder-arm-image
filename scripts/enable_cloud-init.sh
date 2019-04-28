#!/bin/bash -e

# Get cloud-init
apt-get update
debconf-set-selections -v <<<"cloud-init cloud-init/datasources multiselect NoCloud, None" 2>/dev/null
apt-get install -y cloud-init

# Prepare datasource
tee /etc/cloud/cloud.cfg <<'YAML'
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
   - default

# If this is set, 'root' will not be able to ssh in and they
# will get a message to login instead as the above $user (debian)
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# Example datasource config
# datasource:
#    Ec2:
#      metadata_urls: [ 'blah.com' ]
#      timeout: 5 # (defaults to 50 seconds)
#      max_wait: 10 # (defaults to 120 seconds)
datasource:
  NoCloud:
    seedfrom: /boot/

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - disk_setup
 - mounts
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
 - emit_upstart
 - ssh-import-id
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - ntp
 - timezone
 - disable-ec2-metadata
 - runcmd
 - byobu

# The modules that run in the 'final' stage
cloud_final_modules:
 - package-update-upgrade-install
 - fan
 - puppet
 - chef
 - salt-minion
 - mcollective
 - rightscale_userdata
 - scripts-vendor
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
 - power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
   # This will affect which distro class gets used
   distro: debian
   # Default user name + that default users groups (if added/used)
   default_user:
     name: debian
     lock_passwd: True
     gecos: Debian
     groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
   # Other config here will be given to the distro class and/or path classes
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
      upstart_dir: /etc/init/
   package_mirrors:
     - arches: [default]
       failsafe:
         primary: http://deb.debian.org/debian
         security: http://security.debian.org/
   ssh_svcname: ssh
YAML

# Create meta-data
tee /boot/meta-data <<'YAML'
instance-id: iid-raspberrypi-nocloud
YAML

# Create user-data
tee /boot/user-data <<'YAML'
#cloud-config

users:
  - name: devops
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: adm, dialout, cdrom, sudo, audio, video, plugdev, games, users, input, netdev, gpio, i2c, spi
    ssh_authorized_keys:
     - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4QCqtjvfm3Ih+pIQ0cS1NmHIpzhO2/p4xBSk/dzyJxXaljygwxdE+19qLh11HKK2tlZXBjGAb6JIPm+QbiIFdSzc/74+Ls+TiUIWKicygqniWn1cJHsREZ1WuMjzyzA4yfdkjDkmQlFZlkaWMOE8yYaZl3R63h+mD4klMJoAFdeONqABwXNW7Kt3QcMnYH+k+wR09MyhWwxZgpzrjPaenfGW010YSG3MsbFkSCQMjZOBFSbIkNRc0yXL+ENZvI+JVYA1HVNES5roFqRI9j1McrAZgkHuvz83IcDe5oFbvZq2s7nfwNYTXw0vsKjGDSAkLbc/Uh40QuUJ4rkejuuqb russell.t.sherman@gmail.com

YAML
