class openstack::role::storage inherits ::openstack::role {
  $node_type = "${node_type}|storage"
  class { '::openstack::profile::glance::api': }
  class { '::openstack::profile::cinder::api': }
  class { '::openstack::profile::cinder::volume': }
}
