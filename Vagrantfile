# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # We're using Ubuntu 12.04 (precise)
  config.vm.box = "opscode-ubuntu-12.04"
  # This will auto download if you don't have the box yet
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"

  config.vm.network "private_network", ip: "192.168.11.10"

  config.vm.provision "shell", path: "init.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.options        = "--verbose --debug"
    puppet.module_path    = "kabam-puppet/modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "devbox.pp"
  end

end
