class openstack::role::primary_controller inherits ::openstack::role {
  include ::openstack::role::common

  # Primary controller has all databases
  class { '::openstack::profile::rabbitmq': } 
  class { '::openstack::profile::memcache': } 
  class { '::openstack::profile::mysql': }
  class { '::openstack::profile::mongodb': } 

  # It also has all APIs
  include ::openstack::role::controller 

  # It also manages service account creations
  class { '::openstack::profile::heat::auth': }
  class { '::openstack::profile::cinder::auth': } 
  class { '::openstack::profile::keystone::auth': }
  class { '::openstack::profile::nova::auth': }
  class { '::openstack::profile::ceilometer::auth': }
  class { '::openstack::profile::glance::auth': }
  class { '::openstack::profile::neutron::auth': } 
}
