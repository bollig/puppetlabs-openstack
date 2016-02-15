class openstack::role::common inherits ::openstack::role {
  $node_type = "${node_type}|common"
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::auth_file': }
}
