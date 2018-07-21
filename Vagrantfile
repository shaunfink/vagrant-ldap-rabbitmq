# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.hostname = "rabbitmq.dev"
  config.vm.network :private_network, ip: "10.0.0.150"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 389, host: 3890
  config.vm.network :forwarded_port, guest: 5671, host: 5671
  config.vm.network :forwarded_port, guest: 5672, host: 5672
  config.vm.network :forwarded_port, guest: 15672, host: 15672

  config.vm.synced_folder "./ldap/", "/vagrant_data/ldap/"
  config.vm.synced_folder "./scripts/", "/vagrant_data/scripts/"
  config.vm.synced_folder "./certs/", "/vagrant_data/certs/"

  config.vm.provider :virtualbox do |vb|
    vb.name = "rabbitmq.dev"
    vb.customize ["modifyvm", :id, "--memory", "4096"]
	  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.puppet_install.puppet_version = :latest

  config.vm.provision "shell", path: "./scripts/install_puppet_modules.sh"
  config.vm.provision :puppet do |puppet|
    puppet.options = "--verbose --debug"
    #puppet.module_path = "./puppet/modules"
    puppet.manifests_path = "./puppet/manifests"
    puppet.manifest_file = "default.pp"
  end
end
