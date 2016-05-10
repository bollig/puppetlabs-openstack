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
    verbose            => false, 
  }  
  class { '::trove::conductor':
    debug    => true,
    verbose  => false,
    auth_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
  }  
  class { '::trove::taskmanager':
    debug    => true,
    verbose  => false,
    auth_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
  }  
  class { '::trove::db::sync': }


  # The trove services take a second or so to start 
  exec {"wait for trove":
    require => Service["trove-taskmanager"],
    command => "/bin/sleep 2",
  }
  Service['trove-api'] -> Service['trove-conductor'] -> Service['trove-taskmanager'] 
    
  if pick(hiera(openstack::trove::datastores), false) {
	  $datastores = hiera(openstack::trove::datastores)
	  $datastore_versions = hiera(openstack::trove::datastore_versions)
	  create_resources('trove_datastore', $datastores)
	# TODO: note the trove_data_store_version must specify a valid image ID (not NAME). 
	  create_resources('trove_datastore_version', $datastore_versions)
  
	# Don't try to create datastores unless the trove service is fully running
	  Exec['wait for trove'] -> Trove_datastore<||> -> Trove_datastore_version<||>
  }

}
