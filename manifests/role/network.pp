class openstack::role::network inherits ::openstack::role {
  include ::openstack::role::common

  class { '::openstack::profile::neutron::server': } 
  class { '::openstack::profile::neutron::router': }
  class { '::openstack::profile::neutron::agent': }
}
