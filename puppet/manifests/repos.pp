# Configure apt repo's
class repos (
  String $key_id          = '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
  String $key_source      = 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc',
  String $location        = 'https://dl.bintray.com/rabbitmq/debian',
  Boolean $include_src    = false,
) {
  $osname = downcase($facts['os']['name'])
  $codename = downcase($facts['os']['distro']['codename'])

  # ordering / ensure to get the last version of repository
  Class['repos']
  -> Class['apt::update']

  apt::key { 'rabbitmq':
    id      => $key_id,
    source  => $key_source
  }

  apt::source { 'erlang':
    include_src => $include_src,
    location    => $location,
    repos       => '$codename erlang'
  }

  apt::source { 'rabbitmq':
    include_src => $include_src,
    location    => $location,
    repos       => '$codename main'
  }

  apt::pin { 'rabbitmq':
    packages => '*',
    priority => 100,
    origin   => 'dl.bintray.com',
  }
}
