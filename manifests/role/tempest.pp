class openstack::role::tempest inherits ::openstack::role {
  $node_type = "${node_type}|tempest"
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::tempest': }
  class { '::openstack::profile::auth_file': }
}
