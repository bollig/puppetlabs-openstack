class openstack::role::network inherits ::openstack::role {
  class { '::openstack::profile::neutron::router': } ->
  class { '::openstack::profile::neutron::agent': }
}
