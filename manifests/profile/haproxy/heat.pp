class openstack::profile::haproxy::heat (
  $bind_address = pick($::ipaddress_br_ex, $::ipaddress),
) {

  openstack::profile::haproxy::listen { 'heat-api':
    port => 8004,
  }
  openstack::profile::haproxy::listen { 'heat-api_cfn':
    port => 8000,
  }
}
