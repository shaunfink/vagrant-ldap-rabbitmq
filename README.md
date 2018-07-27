# Description
A vagrant build for RabbitMQ and LDAP, so that I can do some mTLS testing and dev work, and work on configs for RabbitMQ relatively easily.

I've been using a python client to test my configs, stored in another git repo:
- [Python RabbitMQ Testing Client](https://github.com/shaunfink/python-rabbitmq-client)

# Usage:
## Preperation:
- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Install [Vagrant](https://www.vagrantup.com/)

## To use:
- Clone this Git Repo
- cd to cloned repo and run vagrant up
- VM can be accessed using vagrant ssh
- RabbitMQ admin console can be accessed here: http://127.0.0.1:15672, Credentials are rabbitadmin/rabbitadmin

# Puppet Modules i'm using:
- https://forge.puppet.com/camptocamp/openldap
- https://forge.puppet.com/puppet/rabbitmq
- https://forge.puppet.com/puppetlabs/stdlib
- https://forge.puppet.com/puppetlabs/apt

# To Do:
- I need to figure out how to get the Puppet librarian plugin working with vagrant, as this will make life a wee bit easier.
