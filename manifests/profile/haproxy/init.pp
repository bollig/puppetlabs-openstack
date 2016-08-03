# Core HAProxy Config
# Good example: https://programmaticponderings.wordpress.com/2015/02/21/automating-a-haproxy-reverse-proxy-load-balanced-apache-web-cluster-with-foreman/
# 
# TODO: redirect http to SSL: http://stackoverflow.com/questions/13227544/haproxy-redirecting-http-to-https-ssl
# TODO: consider switching to the "frontend" and "backend" resources
class openstack::profile::haproxy::init {
  # NOTE: in modules/openstack/manifests/profile/neutron/router.pp, I set
  # "manage_haproxy_package=>false" for the lbaas service. If this gets
  # disabled, we probably want to enable that option again
  class { 'haproxy':
    enable           => $enabled,
    global_options   => {
      'log'     => "${::ipaddress} local0",
      'chroot'  => '/var/lib/haproxy',
      'pidfile' => '/var/run/haproxy.pid',
      'maxconn' => '4000',
      'user'    => 'haproxy',
      'group'   => 'haproxy',
      'daemon'  => '',
      'stats'   => 'socket /var/lib/haproxy/stats',
    },
    defaults_options => {
      'log'     => 'global',
      'stats'   => 'enable',
      'option'  => 'redispatch',
      'retries' => '3',
      'timeout' => [
        'http-request 10s',
        'queue 1m',
        'connect 10s',
        'client 1m',
        'server 1m',
        'check 10s',
      ],
    'maxconn' => '8000',
    },
  }

  # construct ssl cert using concat module
  # into: $::openstack::config::haproxy_ssl_certfile
  #ssl_cert        => $::openstack::config::keystone_ssl_certfile,
  #ssl_key         => $::openstack::config::keystone_ssl_keyfile,
  #ssl_chain       => $::openstack::config::ssl_chainfile,

  $haproxy_cert = $::openstack::config::haproxy_ssl_certfile
  concat { $haproxy_cert:
    owner => 'root',
    group => 'haproxy',
    mode => '0640',
    ensure_newline => true
  }

  concat::fragment { 'haproxy_cert':
    target => $haproxy_cert,
    source => $::openstack::config::keystone_ssl_certfile,
    order => '01',
  }

  concat::fragment { 'haproxy_key':
    target => $haproxy_cert,
    source => $::openstack::config::keystone_ssl_keyfile,
    order => '02',
  }
  concat::fragment { 'haproxy_chain':
    target => $haproxy_cert,
    source => $::openstack::config::ssl_chainfile,
    order => '03',
  }

}
