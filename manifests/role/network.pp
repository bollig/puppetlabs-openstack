class openstack::role::network inherits ::openstack::role {
  $node_type = "${node_type}|network"
  class { '::openstack::profile::neutron::router': }
}
