class openstack::role::network inherits ::openstack::role {
  class { '::openstack::profile::neutron::router': }
}
