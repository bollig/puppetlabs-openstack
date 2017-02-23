class openstack::profile::haproxy::neutron (
  # network nodes have the mian ip on br-ex interface rather than "default"
  $bind_address = pick($::ipaddress_br_ex, $::ipaddress),
) {
  include openstack::profile::haproxy::init

  haproxy::listen { 'neutron-api-in':
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$bind_address:9696"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
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
