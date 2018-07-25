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

# Import users into LDAP
exec { 'ldapadd':
  path    => '/usr/bin',
  cwd     => '/vagrant_data/ldap',
  command => 'ldapadd -x -D "cn=admin,dc=rabbitmq,dc=dev" -w "secret" -h "rabbitmq.dev" -f "ldap-data.ldif"',
}

# Provsion RabbitMQ
class { 'rabbitmq':
  delete_guest_user           => true,
  admin_enable                => true,
  management_ssl              => false,
  management_hostname         => 'rabbitmq.dev',
  ssl                         => true,
  port                        => 5672,
  ssl_port                    => 5671,
  ssl_depth                   => 3,
  ssl_cacert                  => '/vagrant_data/certs/cacert.pem',
  ssl_cert                    => '/vagrant_data/certs/cert.pem',
  ssl_key                     => '/vagrant_data/certs/key.pem',
  ssl_verify                  => 'verify_peer',
  ssl_fail_if_no_peer_cert    => true,
  auth_backends               => ['rabbit_auth_backend_ldap', 'rabbit_auth_backend_internal'],
  ldap_auth                   => true,
  ldap_server                 => 'rabbitmq.dev',
  ldap_port                   => 389,
  ldap_user_dn_pattern        => 'cn=${username},ou=services,dc=rabbitmq,dc=dev',
  ldap_other_bind             => "{'cn=rabbitbind,ou=services,dc=rabbitmq,dc=dev', 'rabbitbind'}",
  #ldap_other_bind             => "{'cn=admin,dc=rabbitmq,dc=dev', 'secret'}",
  #ldap_other_bind             => "{'rabbitbind', 'rabbitbind'}",
  ldap_log                    => true,
  config_variables            => {
    ssl_cert_login_from       => 'common_name',
    auth_mechanisms           => "['EXTERNAL', 'AMQPLAIN', 'PLAIN']",
    log_levels                => "[{connection, debug}, {default, debug}, {channel, debug}, {queue, debug}, {mirroring, debug}, {federation, debug}, {upgrade, debug}]"
  },
  ldap_config_variables       => {
    #dn_lookup_base            => "'ou=services,dc=rabbitmq,dc=dev'",
    #dn_lookup_attribute       => "'cn'",
    #group_lookup_base         => "'ou=groups,dc=rabbitmq,dc=dev'",
    tag_queries               => "[{administrator, {constant, true}}, {management, {constant, true}}]",
    vhost_access_query        => "{constant, true}",
    #vhost_access_query        => "{in_group, 'cn=services,ou=groups,dc=rabbitmq,dc=dev'}",
    resource_access_query     => "{constant, true}",
    #resource_access_query     => "{in_group, 'cn=services,ou=groups,dc=rabbitmq,dc=dev'}",
    topic_access_query        => "{constant, true}"
    #topic_access_query        => "{in_group, 'cn=services,ou=groups,dc=rabbitmq,dc=dev'}",
  }
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

# rabbitmq_user { 'rabbitbind':
#  ensure   => 'present',
#  admin    => true,
#  password => 'rabbitbindlocal',
# }

# rabbitmq_user { 'rabbitdev':
#  ensure   => 'present',
#  admin    => true,
#  password => 'rabbitdevlocal',
# }

# rabbitmq_user { 'rabbitdevcode':
#  ensure   => 'present',
#  admin    => true,
#  password => 'rabbitdevcodelocal',
# }

# Assign permissions to users
# rabbitmq_user_permissions { 'rabbitadmin@/':
#   configure_permission => '.*',
#   read_permission      => '.*',
#   write_permission     => '.*',
# }

# rabbitmq_user_permissions { 'rabbitadmin@devvhost':
#   configure_permission => '.*',
#   read_permission      => '.*',
#   write_permission     => '.*',
# }

# rabbitmq_user_permissions { 'rabbitdev@devvhost':
#   configure_permission => '.*',
#   read_permission      => '.*',
#   write_permission     => '.*',
# }

# rabbitmq_user_permissions { 'rabbitdevcode@devvhost':
#   configure_permission => '.*',
#   read_permission      => '.*',
#   write_permission     => '.*',
# }
