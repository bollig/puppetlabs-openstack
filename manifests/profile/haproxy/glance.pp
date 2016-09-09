class openstack::profile::haproxy::glance {

  haproxy::listen { 'glance-api-in':
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$::ipaddress:9292"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
  }

  haproxy::listen { 'glance-registry-in':
    bind => {
      "$::ipaddress:9191"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
  }

  haproxy::balancermember { 'glance-api-01':
    listening_service => 'glance-api-in',
    ipaddresses => '127.0.0.1',
    ports     => 9292,
    options   => '',
  }

  haproxy::balancermember { 'glance-registry-01':
    listening_service => 'glance-registry-in',
    ipaddresses => '127.0.0.1',
    ports     => 9191,
    options   => '',
  }
}
