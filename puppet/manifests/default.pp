class { 'rabbitmq':
  admin_enable          => true,
  port                  => 5672,
  ssl                   => true,
  ssl_port              => 5671,
  ssl_cacert            => '/vagrant_data/certs/cacert.pem',
  ssl_cert              => '/vagrant_data/certs/cert.pem',
  ssl_key               => '/vagrant_data/certs/key.pem',
  auth_backends         => ['rabbit_auth_backend_internal', 'rabbit_auth_backend_ldap'],
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
  ensure => 'present',
  admin    => true,
  password => 'rabbitadmin',
}

rabbitmq_user { 'rabbitdev':
  ensure => 'present',
  admin    => false,
  password => 'rabbitdev',
}

rabbitmq_user_permissions { 'rabbitdev@devvhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
