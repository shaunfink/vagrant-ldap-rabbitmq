# Configure apt repo's
# class repos (
#   String $key_id          = '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
#   String $key_source      = 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc',
#   String $location        = 'https://dl.bintray.com/rabbitmq/debian',
#   Boolean $include_src    = false,
# ) {
#   $osname = downcase($facts['os']['name'])
#   $codename = downcase($facts['os']['distro']['codename'])
#
#   # ordering / ensure to get the last version of repository
#   Class['repos']
#   -> Class['apt::update']
#
#   apt::key { 'rabbitmq':
#     id      => $key_id,
#     source  => $key_source
#   }
#
#   apt::source { 'erlang':
#     include_src => $include_src,
#     location    => $location,
#     repos       => '$codename erlang'
#   }
#
#   apt::source { 'rabbitmq':
#     include_src => $include_src,
#     location    => $location,
#     repos       => '$codename main'
#   }
#
#   apt::pin { 'rabbitmq':
#     packages => '*',
#     priority => 100,
#     origin   => 'dl.bintray.com',
#   }
# }

# Install some packages
package { 'monit':
  ensure => installed,
}

# Install erlang
package { 'erlang-nox':
  ensure => installed,
}

# Provision OpenLDAP
class { 'openldap::server': }

# Configure the default OpenLdap Database
openldap::server::database { 'dc=rabbitmq,dc=dev':
  directory => '/var/lib/ldap',
  rootdn    => 'cn=admin,dc=rabbitmq,dc=dev',
  rootpw    => 'secret',
}

# Set up some global OpenLdap configs
openldap::server::globalconf { 'ServerID':
  ensure => present,
  value  => { 'ServerID' => [ '1 ldap://rabbitmq.dev' ] }
}

# Import users into LDAP
exec { 'ldapadd':
  path    => '/usr/bin',
  cwd     => '/vagrant_data/ldap',
  command => 'ldapadd -x -D "cn=admin,dc=rabbitmq,dc=dev" -w "secret" -h "rabbitmq.dev" -f "ldap-data.ldif"',
  require => Class['openldap::server']
}

# # Install latest erlang version
# class { 'erlang': }

# package { 'erlang-base':
#   ensure => 'latest',
# }

# # Ensure we're using the latest repo
# class { 'rabbitmq::repo::apt':
#   key_source => 'https://packagecloud.io/gpg.key',
# }

# Provsion RabbitMQ
class { 'rabbitmq':
  #require                     => Class['rabbitmq::repo::apt'],
  #repos_ensure             => true,
  #package_ensure           => 'latest',
  #package_apt_pin          => '900',
  #package_gpg_key          => 'https://packagecloud.io/gpg.key',
  delete_guest_user        => true,
  admin_enable             => true,
  management_ssl           => false,
  management_hostname      => 'rabbitmq.dev',
  ssl                      => true,
  port                     => 5672,
  ssl_port                 => 5671,
  ssl_depth                => 3,
  ssl_cacert               => '/vagrant_data/certs/cacert.pem',
  ssl_cert                 => '/vagrant_data/certs/cert.pem',
  ssl_key                  => '/vagrant_data/certs/key.pem',
  ssl_verify               => 'verify_peer',
  ssl_fail_if_no_peer_cert => true,
  auth_backends            => ['rabbit_auth_backend_ldap', 'rabbit_auth_backend_internal'],
  ldap_auth                => true,
  ldap_server              => 'rabbitmq.dev',
  ldap_port                => 389,
  ldap_user_dn_pattern     => 'CN=${username},OU=services,DC=rabbitmq,DC=dev',
  ldap_other_bind          => "{'CN=rabbitbind,OU=services,DC=rabbitmq,DC=dev', 'rabbitbind'}",
  #ldap_other_bind             => "{'CN=admin,DC=rabbitmq,DC=dev', 'secret'}",
  #ldap_other_bind             => "{'rabbitbind', 'rabbitbind'}",
  ldap_log                 => true,
  config_variables         => {
    ssl_cert_login_from => 'common_name',
    auth_mechanisms     => "['EXTERNAL', 'AMQPLAIN', 'PLAIN']",
    log_levels          => '[{connection, debug}, {default, debug}, {channel, debug}, {queue, debug}, {mirroring, debug}, {federation, debug}, {upgrade, debug}]'
  },
  ldap_config_variables    => {
    #dn_lookup_base            => "'OU=services,DC=rabbitmq,DC=dev'",
    #dn_lookup_attribute       => "'CN'",
    #group_lookup_base         => "'OU=groups,DC=rabbitmq,DC=dev'",
    tag_queries           => '[{administrator, {constant, true}}, {management, {constant, true}}]',
    vhost_access_query    => '{constant, true}',
    #vhost_access_query        => "{in_group, 'CN=services,OU=groups,DC=rabbitmq,DC=dev'}",
    resource_access_query => '{constant, true}',
    #resource_access_query     => "{in_group, 'CN=services,OU=groups,DC=rabbitmq,DC=dev'}",
    topic_access_query    => '{constant, true}'
    #topic_access_query        => "{in_group, 'CN=services,OU=groups,DC=rabbitmq,DC=dev'}",
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

# Set the staging order
# Class['::repos'] -> Class['openldap::server'] -> Class['rabbitmq']
Class['openldap::server'] -> Class['rabbitmq']
