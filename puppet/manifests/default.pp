# Provision OpenLDAP
class { 'openldap::server': }
openldap::server::database { 'dc=rabbitmq,dc=dev':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=rabbitmq,dc=dev',
  rootpw    => 'secret',
} ->

# Set up some global configs
openldap::server::globalconf { 'ServerID':
  ensure => present,
  value  => { 'ServerID' => [ '1 ldap://rabbitmq.dev' ] }
} ->

# openldap::server::access { '0 on dc=rabbitmq,dc=dev':
#   what     => 'attrs=userPassword,shadowLastChange',
#   access   => [
#     'by dn="cn=admin,dc=rabbitmq,dc=dev" write',
#     'by anonymous auth',
#     'by self write',
#     'by * none',
#   ],
# } ->

# Import users into LDAP
exec { 'ldapadd':
  path    => '/usr/bin',
  cwd     => '/vagrant_data/ldap',
  command => 'ldapadd -x -D "cn=admin,dc=rabbitmq,dc=dev" -w "secret" -h "rabbitmq.dev" -f "ldap-data.ldif"',
}

# Provsion RabbitMQ
class { 'rabbitmq':
  admin_enable                => true,
  management_ssl              => false,
  management_hostname         => 'rabbitmq.dev',
  ssl                         => true,
  port                        => 5672,
  ssl_port                    => 5671,
  ssl_cacert                  => '/vagrant_data/certs/cacert.pem',
  ssl_cert                    => '/vagrant_data/certs/cert.pem',
  ssl_key                     => '/vagrant_data/certs/key.pem',
  ssl_verify                  => 'verify_peer',
  ssl_fail_if_no_peer_cert    => true,
  #auth_backends               => ['ldap', 'internal'],
  ldap_auth                   => true,
  ldap_server                 => 'ldap://localhost',
  ldap_port                   => 389,
  #ldap_user_dn_pattern        =>'cn=${username},ou=services,dc=rabbitmq,dc=dev',
  ldap_user_dn_pattern        =>'${username}',
  ldap_log                    => true,
  #config_additional_variables => {
  #  rabbit => '[{auth_mechanisms, [EXTERNAL, PLAIN]}]'
  #}
}

# Enable SSL Auth plugin
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
 password => 'rabbitadminlocal',
}
rabbitmq_user { 'rabbitdevadmin':
 ensure   => 'present',
 admin    => true,
 password => 'rabbitdevadminlocal',
}
rabbitmq_user { 'rabbitdevcode':
 ensure   => 'present',
 admin    => false,
 password => 'rabbitdevcodelocal',
}

# Set permissions for users
rabbitmq_user_permissions { 'rabbitdevadmin@devvhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
rabbitmq_user_permissions { 'rabbitdevcode@devvhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
