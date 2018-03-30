class openstack::profile::firewall {
  class { '::openstack::profile::firewall::pre': }
  # puppet should be handled elsewhere
  #class { '::openstack::profile::firewall::puppet': }
  class { '::openstack::profile::firewall::post': }
}
