# The profile for installing the TROVE API
class openstack::profile::trove::api {

  # This resources::database call includes a call to  class { '::trove::db::mysql': password => 'trove' }
  openstack::resources::database { 'trove': }
  openstack::resources::firewall { 'TROVE API': port => '8779', }

  include ::openstack::common::trove

  class { '::trove::api':
    keystone_password  => $::openstack::config::trove_password,
    keystone_auth_host => $::openstack::config::controller_address_management,
# TODO: use identity_uri (?)
    enabled            => true,
    debug              => true, 
    verbose            => true, 
  }

  class { '::trove::conductor':
    debug    => true,
    verbose  => true,
    auth_url => 'http://127.0.0.1:5000/',
  }
  class { '::trove::taskmanager':
    debug    => true,
    verbose  => true,
    auth_url => 'http://127.0.0.1:5000/',
  }

}
