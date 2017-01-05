class openstack::role::storage inherits ::openstack::role {
  include ::openstack::role::common

  class { '::openstack::profile::glance::api': }
  class { '::openstack::profile::cinder::api': }
  class { '::openstack::profile::cinder::volume': }
  # class { '::openstack::profile::swift::storage': zone => $zone }
  class { '::openstack::profile::swift::radosgw': }
}
