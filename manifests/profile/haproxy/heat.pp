class openstack::profile::haproxy::heat {
  include openstack::profile::haproxy::init

  haproxy::listen { 'heat-api-in':
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$::ipaddress:8004"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::listen { 'heat-api_cfn-in':
    bind => {
      "$::ipaddress:8000"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::balancermember { 'heat-api-01':
    listening_service => 'heat-api-in',
    ipaddresses => '127.0.0.1',
    ports     => 8004,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::balancermember { 'heat-api_cfn-01':
    listening_service => 'heat-api_cfn-in',
    ipaddresses => '127.0.0.1',
    ports     => 8000,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }
}
