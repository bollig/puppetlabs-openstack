class openstack::role::storage inherits ::openstack::role {
  class { '::openstack::profile::glance::api': }
  class { '::openstack::profile::cinder::volume': }
}
