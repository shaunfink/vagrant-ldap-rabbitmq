# Provision OpenLDAP
class { 'openldap::server': }
openldap::server::database { 'dc=rabbitmq,dc=dev':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=rabbitmq,dc=dev',
  rootpw    => 'secret',
} ->

# Import users into LDAP
exec { 'ldapadd':
  path     => '/usr/bin',
  cwd      => '/vagrant_data/ldap',
  command  => 'ldapadd -x -D "cn=admin,dc=rabbitmq,dc=dev" -w "secret" -h "localhost" -f "ldap-data.ldif"',
}

# Provsion RabbitMQ
class { 'rabbitmq':
  admin_enable             => true,
  management_ssl           => false,
  management_hostname      => 'rabbitmq.dev',
  ssl                      => true,
  port                     => 5672,
  ssl_port                 => 5671,
  ssl_cacert               => '/vagrant_data/certs/cacert.pem',
  ssl_cert                 => '/vagrant_data/certs/cert.pem',
  ssl_key                  => '/vagrant_data/certs/key.pem',
  ssl_verify               => 'verify_peer',
  ssl_fail_if_no_peer_cert => true,
  auth_backends            => ['rabbit_auth_backend_internal', 'rabbit_auth_backend_ldap'],
}

# Enable RabbitMQ Plugins
rabbitmq_plugin { 'rabbitmq_auth_backend_ldap':
  ensure => present,
}

rabbitmq_plugin { 'rabbitmq_auth_mechanism_ssl':
  ensure => present,
}

# Add a RabbitMQ Virtual Host
rabbitmq_vhost { 'devvhost':
  ensure => present,
}

# Add some RabbitMQ Users
rabbitmq_user { 'rabbitadmin':
 ensure   => 'present',
 admin    => true,
 password => 'rabbitadmin',
}

rabbitmq_user { 'rabbitlocaldev':
 ensure   => 'present',
 admin    => false,
 password => 'rabbitlocaldev',
}

rabbitmq_user_permissions { 'rabbitlocaldev@devvhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
