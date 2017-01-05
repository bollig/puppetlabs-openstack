class openstack::role::common inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::auth_file': }
}
