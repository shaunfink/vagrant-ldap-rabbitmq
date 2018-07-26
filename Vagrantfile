# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify which box to use
  config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "ubuntu/bionic64"

  # Some VM configs
  config.vm.hostname = "rabbitmq.dev"
  config.vm.network :private_network, ip: "10.0.0.150"

  # Configure port forwading for our vagrant image
  config.vm.network :forwarded_port, guest: 389, host: 3890
  config.vm.network :forwarded_port, guest: 5671, host: 5671
  config.vm.network :forwarded_port, guest: 5672, host: 5672
  config.vm.network :forwarded_port, guest: 15672, host: 15672

  # Map some folders to the vagrant image
  config.vm.synced_folder "./ldap/", "/vagrant_data/ldap/"
  config.vm.synced_folder "./certs/", "/vagrant_data/certs/"
  #config.vm.synced_folder "./scripts/", "/vagrant_data/scripts/"

  # Set up some usedul stuff for our image
  config.vm.provider :virtualbox do |vb|
    vb.name = "rabbitmq.dev"
    vb.customize ["modifyvm", :id, "--memory", "4096"]
	  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Make sure we're installing the latest puppet agent
  config.puppet_install.puppet_version = :latest

  # I'd like to use the puppet librarian plugin for vagrant, but
  # I'm having issues getting it to work. Will continue with this at a later stage.
  #config.librarian_puppet.puppetfile_dir = "./puppet/"

  # Run pre-install script
  config.vm.provision "shell", path: "./scripts/pre-install.sh"

  # Provision puppet modules using a script
  #config.vm.provision "shell", path: "./scripts/provision-puppet-modules.sh"

  # Set up our environment using Puppet
  config.vm.provision :puppet do |puppet|
    puppet.options = "--verbose --debug"
    puppet.module_path = "./puppet/modules/"
    puppet.manifests_path = "./puppet/manifests/"
    puppet.manifest_file = "default.pp"
  end

  # Run a post install script for stuff i've not been able to do with Puppet
  config.vm.provision "shell", path: "./scripts/post-install.sh"
end
