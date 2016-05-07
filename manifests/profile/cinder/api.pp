# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::database { 'cinder': }
  openstack::resources::firewall { 'Cinder API': port => '8776', }

  include ::openstack::common::cinder

  class { '::cinder::quota': }

  class { '::cinder::scheduler':
    #scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    enabled          => true,
  }
  class { '::cinder::scheduler::filter': }
}
