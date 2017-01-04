class openstack::profile::haproxy::neutron {
  include openstack::profile::haproxy::init

  haproxy::listen { 'neutron-api-in':
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$::ipaddress:9696"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::balancermember { 'neutron-api-01':
    listening_service => 'neutron-api-in',
    ipaddresses => '127.0.0.1',
    ports     => 9696,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }
}
