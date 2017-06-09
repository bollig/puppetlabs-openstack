define openstack::profile::haproxy::listen (
  $port = undef,
  $bind_address = pick($::ipaddress_br_ex, $::ipaddress),
) {
  include openstack::profile::haproxy::init

  ::haproxy::listen { "${name}-in":
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$bind_address:$port"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    options => {
      'mode'   => 'http',
      'reqadd' => 'X-Forwarded-Proto:\ https',
      'option'  => [
        'httplog',
      ],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  ::haproxy::balancermember { "${name}-01":
    listening_service => "${name}-in",
    ipaddresses => '127.0.0.1',
    ports     => $port,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }

}
