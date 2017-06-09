class openstack::profile::haproxy::ec2api (
  $bind_address = pick($::ipaddress_br_ex, $::ipaddress),
  $bind_port_api = 8788,
  $bind_port_metadata = 8789,
) {

  openstack::profile::haproxy::listen { 'ec2-api':
    port => $bind_port_api,
  }
  openstack::profile::haproxy::listen { 'ec2-metadata':
    port => $bind_port_metadata,
  }

}
