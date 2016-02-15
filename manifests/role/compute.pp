class openstack::role::compute inherits ::openstack::role {
  $node_type = "${node_type}|compute"
  class { '::openstack::profile::neutron::agent': }
  class { '::openstack::profile::nova::compute': }
  class { '::openstack::profile::ceilometer::agent': }
}
