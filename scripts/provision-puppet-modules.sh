#!/bin/bash
# Install the required modules that we need to provision the rabbitmq and ldap server

puppetModules=(puppetlabs-stdlib puppetlabs-apt puppet-rabbitmq camptocamp-openldap)

for m in ${puppetModules[@]}; do
    puppet module install $m
done
