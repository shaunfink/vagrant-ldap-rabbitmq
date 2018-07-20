# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.hostname = "rabbitmq.dev"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 389, host: 3890
  config.vm.network :forwarded_port, guest: 5671, host: 5671
  config.vm.network :forwarded_port, guest: 5672, host: 5672
  config.vm.network :forwarded_port, guest: 15672, host: 15672

  config.vm.network :private_network, ip: "192.168.1.160"

  config.vm.synced_folder "./ldap/", "/vagrant_data/deploy/"
  config.vm.synced_folder "./scripts/", "/vagrant_data/scripts/"

  config.vm.provider :virtualbox do |vb|
    vb.name = "rabbitmq.dev"
    vb.customize ["modifyvm", :id, "--memory", "4096"]
	  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
  end
end
