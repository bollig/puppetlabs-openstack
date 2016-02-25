# The profile for installing the TROVE API
class openstack::profile::trove::api {

  # This resources::database call includes a call to  class { '::trove::db::mysql': password => 'trove' }
  openstack::resources::database { 'trove': }
  openstack::resources::firewall { 'TROVE API': port => '8779', }

  include ::openstack::common::trove

  class { '::trove::api':
    keystone_password  => $::openstack::config::trove_password,
    # NOTE: this is the KEYSTONE auth host
    auth_host          => $::openstack::config::controller_address_management,
    enabled            => true,
    debug              => true, 
    verbose            => true, 
  }

  class { '::trove::conductor':
    debug    => true,
    verbose  => true,
    auth_url => "http://${::openstack::config::controller_address_management}:5000/",
  }
  class { '::trove::taskmanager':
    debug    => true,
    verbose  => true,
    auth_url => "http://${::openstack::config::controller_address_management}:5000/",
  }
    
  # Build the base images
  $datastores = hiera(openstack::trove::datastores)
  $datastore_versions = hiera(openstack::trove::datastore_versions)
  create_resources('trove_datastore', $datastores)
  create_resources('trove_datastore_version', $datastore_versions)
  
    Trove_datastore<||> -> Trove_datastore_version<||>
}
