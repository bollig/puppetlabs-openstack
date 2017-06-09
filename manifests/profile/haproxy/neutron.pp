class openstack::profile::haproxy::neutron (
  # network nodes have the mian ip on br-ex interface rather than "default"
  $bind_address = pick($::ipaddress_br_ex, $::ipaddress),
) {

  openstack::profile::haproxy::listen { 'neutron-api':
    port => 9696,
  }

}
