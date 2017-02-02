class openstack::profile::haproxy::murano {
  include openstack::profile::haproxy::init

  haproxy::listen { 'murano-api-in':
    bind => {
      # binding to a specific address, so the underlying service can bind to same port on localhost
      "$::ipaddress:8082"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::listen { 'murano-api_cfn-in':
    bind => {
      "$::ipaddress:8083"	=> ['ssl', 'crt', $::openstack::config::haproxy_ssl_certfile],
    },
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::balancermember { 'murano-api-01':
    listening_service => 'murano-api-in',
    ipaddresses => '127.0.0.1',
    ports     => 8082,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }

  haproxy::balancermember { 'murano-api_cfn-01':
    listening_service => 'murano-api_cfn-in',
    ipaddresses => '127.0.0.1',
    ports     => 8083,
    options   => '',
    require => Class['openstack::profile::haproxy::init'],
  }
}
