# Install the required modules that we need to provision the rabbitmq and ldap server
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-apt
puppet module install puppet-rabbitmq
puppet module install puppet-archive
puppet module install camptocamp-openldap
