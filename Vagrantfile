# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "opscode-ubuntu-12.04"

  config.vm.network "private_network", ip: "192.168.11.10"


  config.vm.provision "shell", path: "init.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.options        = "--verbose --debug"
    puppet.module_path    = "kabam-puppet/modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "devbox.pp"
  end

end
