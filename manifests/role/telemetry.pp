class openstack::role::telemetry inherits ::openstack::role {
  include ::openstack::role::common

  # Generic Controller has all API services
  class { '::openstack::profile::ceilometer::api': }

  #class { '::openstack::profile::cloudkitty': } 
}
