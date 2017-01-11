class openstack::role::controller inherits ::openstack::role {
  include ::openstack::role::common

  # Generic Controller has all API services
  class { '::openstack::profile::keystone': }
  class { '::openstack::profile::nova::api': } 
  class { '::openstack::profile::heat::api': }
  class { '::openstack::profile::ceilometer::api': }

  # It also has the web server
  class { '::openstack::profile::horizon': }

  # Disabled 
  #class { '::openstack::profile::swift::proxy': }
  #class { '::openstack::profile::cloudkitty': } 
}
