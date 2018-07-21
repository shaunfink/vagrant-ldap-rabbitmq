# Description
A vagrant build for RabbitMQ and LDAP, so that I can do some mTLS testing.

# To Do:
- I need to figure out hot to get the puppet librarian plugin working beforee this becomes applicable. For the time being, i'm just using provisioning scripts
- Get LDAP installed and configured
- Configure LDAP with RabbitMQ

# Setup (eventually, once I can get the Puppet Librarian working)
- Install virtualbox
- Install vagrant
- sudo gem install puppet --install-dir /Users/shaun/.vagrant.d/gems/2.4.4/
- sudo gem install librarian-puppet
- sudo gem install vagrant-puppet-install
- sudo gem install vagrant-librarian-puppet
- vagrant plugin install vagrant-librarian-puppet
- vagrant plugin install vagrant-puppet-install

# I am using these Puppet Modules:
- https://forge.puppet.com/camptocamp/openldap
- https://forge.puppet.com/puppet/rabbitmq
- https://forge.puppet.com/puppet/archive
- https://forge.puppet.com/puppetlabs/stdlib
- https://forge.puppet.com/puppetlabs/apt

# Some Helpful References:
- https://github.com/toretto460/vagrant-rabbitmq
- https://github.com/sepulworld/vagrant-ldap
- https://github.com/gusnips/vagrant-rabbitmq
- https://github.com/rgl/ldap-vagrant
