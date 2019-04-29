# Packer plugin for ARM images

This plugin lets you take an existing ARM image, and modify it on your x86 machine.
It is optimized for raspberry pi use case - MBR partition table, with the file system partition
being the last partition.

With this plugin, you can:

- Provision new ARM images from existing ones.
- Use ARM binaries for provisioning ('apt-get install' for example)
- Resize the last partition (the filesystem partition in the raspberry pi) in case you need more
  space than the default.

Tested for Raspbian images on built on Ubuntu 17.10. It is based partly on the chroot AWS
provisioner, though the code was copied to prevent AWS dependencies.

## How it works

The plugin runs the provisioners in a chroot environment.  Binary execution is done using
`qemu-arm-static`, via `binfmt_misc`.

### Dependencies

This builder uses the following shell commands:

- kpartx - mapping the partitons to mountable devices
- qemu-user-static - Executing arm binaries

To install the needed binaries on derivatives of the Debian Linux variant:

```sh
sudo apt install kpartx qemu-user-static
```

Other commands that are used are (that should already be installed) : mount, umount, cp, ls, chroot.

To resize the filesystem, the following commands are used:

- e2fsck
- resize2fs

To provide custom arguments to `qemu-arm-static` using the `qemu_args` config, `gcc` is required (to compile a C wrapper).

Note: resizing is only supported for the last active
partition in an MBR partition table (as there is no need to move things).

This builder uses the following uses this kernel feature:

- support for `/proc/sys/fs/binfmt_misc` so that ARM binaries are automatically executed with qemu

### Operation

This provisioner allows you to run packer provisioners on your ARM image locally.
It does so by mounting the image on to the local file system, and then using `chroot` combined with `binfmt_misc` to the provisioners in a simulated ARM environment.

## Configuration

To use, you need to provide an existing image that we will then modify.
We re-use packer's support for downloading ISOs (though the image should not be an ISO file).
Supporting also zipped images (enabling you downloading official raspbian images directly).

See [example.json](example.json) and [builder.go](pkg/builder/builder.go) for details.

## Compiling and Testing

### Building

As this tool performs low-level OS manipulations - consider using a VM to run this code for isolation.
While this is highly recommended, it is not mandatory.

This project uses [go modules](https://github.com/golang/go/wiki/Modules) for dependencies introduced in Go 1.11.
To build:

```sh
git clone https://github.com/russelltsherman/packer-builder-arm-image
cd packer-builder-arm-image
go mod download
go build
```

### Running with Vagrant

This project includes a Vagrant file and helper script that build a VM run time environment. The run time environment has
custom provisions to build an image in an iterative fashion (thanks to @tommie-lie for adding this feature).

To use the Vagrant environment, run the following commands:

```sh
git clone https://github.com/russelltsherman/packer-builder-arm-image
cd packer-builder-arm-image
vagrant up
```

To build an image edit example.json (or set PACKERFILE to point to your json config), and use `vagrant provision` like so :

```sh
vagrant provision --provision-with build-image
```

The example config produces an image with go installed and extends the filesystem by 1GB.

That's it! Flash it and run!

## Flashing

We have a post-processor stage for flashing. You can also use the command line:

```sh
go build cmd/flasher/main.go
```

It will auto-detect most things and guides you with questions.

## Cookbook

## Raspberry Pi

(see full examples in contrib folder)
Add these provisioners to:

### Set WiFi password

set the user variables name `wifi_name` and `wifi_password`. then:

```json
    {
      "type": "shell",
      "inline": [
        "echo 'network={' >> /etc/wpa_supplicant/wpa_supplicant.conf",
        "echo '    ssid=\"{{user `wifi_name`}}\"' >> /etc/wpa_supplicant/wpa_supplicant.conf",
        "echo '    psk=\"{{user `wifi_password`}}\"' >> /etc/wpa_supplicant/wpa_supplicant.conf",
        "echo '}' >> /etc/wpa_supplicant/wpa_supplicant.conf"
        ]
    }
```

### A complete example

See everything included in here: [packer/pi-secure-wifi-ssh.json](packer/pi-secure-wifi-ssh.json). Build like so:

```sh
vagrant up && vagrant ssh
sudo packer build  -var wifi_name=SSID -var wifi_password=PASSWORD /vagrant/packer/pi-secure-wifi-ssh.json
```

### create image with support with otg

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-otg.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-otg.img
```

### create image with support with otg and docker

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-docker.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-docker.img
```

### create image with support with otg and adafruit speakerbonnet

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-speakerbonnet.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-speakerbonnet.img
```

### create image with support with otg and adafruit servo hat

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-servo.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-servo.img
```

### create image with support with otg and pimoroni blinkt

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-blinkt.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-blinkt.img
```

### create image with support with otg and bullshit generator

```sh
vagrant up && vagrant ssh
sudo packer build /vagrant/packer/pi-zero-bullshit.json
rsync --progress --archive /home/vagrant/output-arm-image/image /vagrant/pi-zero-bullshit.img
```

### cleanup after building

the vagrant disk will fill quickly if building multiple images.
to clean between generations.

```sh
sudo rm -rf /home/vagrant/output-arm-image/
sudo rm -rf /home/vagrant/work/src/github.com/
```
