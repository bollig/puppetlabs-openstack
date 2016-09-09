class openstack::role::tempest inherits ::openstack::role {
  class { '::openstack::profile::tempest': }
}
