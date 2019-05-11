# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_version = ">= 20180719.0.0"

  #######################################################################
  # THIS REQUIRES YOU TO INSTALL A PLUGIN. RUN THE COMMAND BELOW...
  #   $ vagrant plugin install vagrant-disksize
  # Default images are not big enough to build Armbian.
  config.disksize.size = "40GB"

  # forward terminal type for better compatibility with Dialog
  # - disabled on Ubuntu by default
  config.ssh.forward_env = ["TERM"]

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Packer ARM Builder"

    # Tweak these to fit your needs.
    vb.memory = "8192"
    vb.cpus = "4"
  end

  config.vm.synced_folder "./", "/vagrant", disabled: false

  # provisioning: install dependencies
  config.vm.provision "build-env", type: "shell", :path => "provision-build-env.sh", privileged: false

  config.vm.provision "packer-builder-arm-image", type: "shell", :path => "provision-packer-builder-arm-image.sh", privileged: false, env: {"GIT_CLONE_URL" => ENV["GIT_CLONE_URL"]}

  config.vm.provision "build-image", type: "shell", :path => "provision-build-image.sh", privileged: false, env: {"PACKERFILE" => ENV["PACKERFILE"]}
end
