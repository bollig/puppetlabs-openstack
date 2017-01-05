class openstack::role::experimental inherits ::openstack::role {
  class { '::openstack::profile::ceilometer::gnocchi_metricd': }
#  class { '::openstack::profile::trove::auth': }
#  class { '::openstack::profile::trove::api': }
}
