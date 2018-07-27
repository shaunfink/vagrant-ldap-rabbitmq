
# Add the apt class
class { 'apt': }

# Add sources first
Apt::Source<| |> -> Exec['apt_update'] -> Package<|

# Add the official RabbitMQ Repository
$codename = downcase($facts['os']['distro']['codename'])
apt::source { 'rabbitmq-repo':
  location    => 'https://dl.bintray.com/rabbitmq/debian',
  repos       => '$codename main erlang',
  key      => {
    id      => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
    source  => 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc'
  }
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

# Provsion RabbitMQ
class { 'rabbitmq':
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
  ldap_other_bind          => '{"CN=rabbitbind,OU=services,DC=rabbitmq,DC=dev", "rabbitbind"}',
  ldap_log                 => true,
  config_variables         => {
    ssl_cert_login_from    => 'common_name',
    auth_mechanisms        => "['EXTERNAL', 'AMQPLAIN', 'PLAIN']",
    log_levels             => '[{connection, debug}, {default, debug}, {channel, debug}, {queue, debug}, {mirroring, debug}, {federation, debug}, {upgrade, debug}]'
  },
  ldap_config_variables    => {
    tag_queries            => '[{administrator, {constant, false}}, {monitoring, {constant, false}}, {policymaker, {constant, false}}, {management, {constant, true}}]',
    vhost_access_query     => '{constant, true}',
    resource_access_query  => '{for, [{permission, configure, {in_group, "CN=rabbitconfig,OU=groups,DC=rabbitmq,DC=dev"}}, {permission, write, {for, [{resource, queue, {in_group, "CN=rabbitwrite,OU=groups,DC=rabbitmq,DC=dev"}}, {resource, exchange, {in_group, "CN=rabbitwrite,OU=groups,DC=rabbitmq,DC=dev"}}]}}, {permission, read, {for, [{resource, exchange, {in_group, "CN=rabbitread,OU=groups,DC=rabbitmq,DC=dev"}}, {resource, queue, {in_group, "CN=rabbitread,OU=groups,DC=rabbitmq,DC=dev"}}]}}]}',
    topic_access_query     => '{for, [{permission, write, {in_group, "CN=rabbitwrite,OU=groups,DC=rabbitmq,DC=dev"}}, {permission, read, {in_group, "CN=rabbitread,OU=groups,DC=rabbitmq,DC=dev"}}]}'
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

# Set the staging order
Class['apt'] => Class['openldap::server'] => Class['rabbitmq']
