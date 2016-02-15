class openstack::role::swiftstorage (
  $zone = undef,
) inherits ::openstack::role  {
  $node_type = "${node_type}|swiftstorage"
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::swift::storage': zone => $zone }
}
