class openstack::role::experimental inherits ::openstack::role {
  $node_type = "${node_type}|experimental"
#  class { '::openstack::profile::trove::auth': }
#  class { '::openstack::profile::trove::api': }
}
