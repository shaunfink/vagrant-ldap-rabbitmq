# LDAP Configurations
class { 'openldap::server': }
openldap::server::database { 'dc=rabbitmq,dc=dev':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=rabbitmq,dc=dev',
  rootpw    => 'secret',
}

openldap::server::access { '0 on dc=rabbitmq,dc=dev':
  what     => 'attrs=userPassword,shadowLastChange',
  access   => [
    'by dn="cn=admin,dc=rabbitmq,dc=dev" write',
    'by anonymous auth',
    'by self write',
    'by * none',
  ],
}

# RabbitMQ Configurations
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

rabbitmq_plugin { 'rabbitmq_auth_backend_ldap':
  ensure => present,
}

rabbitmq_plugin { 'rabbitmq_auth_mechanism_ssl':
  ensure => present,
}

rabbitmq_vhost { 'devvhost':
  ensure => present,
}

rabbitmq_user { 'rabbitadmin':
  ensure   => 'present',
  admin    => true,
  password => 'rabbitadmin',
}

rabbitmq_user { 'rabbitdev':
  ensure   => 'present',
  admin    => false,
  password => 'rabbitdev',
}

rabbitmq_user_permissions { 'rabbitdev@devvhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
