# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::firewall { 'Cinder API': port => '8776', }

  include ::openstack::common::cinder

  class { '::cinder::quota': }

  class { '::cinder::scheduler':
    #scheduler_driver => 'cinder.scheduler.simple.SimpleScheduler',
    enabled          => true,
  }
  class { '::cinder::scheduler::filter': }

  include ::apache
  class { '::cinder::wsgi::apache':
      ssl             => $::openstack::config::enable_ssl,
      ssl_cert        => $::openstack::config::keystone_ssl_certfile,
      ssl_key         => $::openstack::config::keystone_ssl_keyfile,
      ssl_chain       => $::openstack::config::ssl_chainfile,
      #ssl_ca          => $::openstack::config::ssl_chainfile,
      workers         => 2
  }

}
