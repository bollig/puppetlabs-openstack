# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::glance {

  $controller_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_glance
  $pass                = $::openstack::config::mysql_pass_glance
  $database_connection = "mysql://${user}:${pass}@${controller_address}/glance"

  $backend_store = 'rbd'

  $http_store = ['http']

  case $backend_store {
	'file':  {
		class { '::glance::backend::file': }
	}
	'rbd': {
		class { '::glance::backend::rbd': 
		  rbd_store_user => 'glance',
		  rbd_store_pool => 'images',
		}
	}
	default: {
         fail("Unsupported glance backend (${backend})")
	}
  }

  $glance_stores = concat($http_store, $backend_store)

  class { '::glance::api':
    keystone_password   => $::openstack::config::glance_password,
    auth_host           => $::openstack::config::controller_address_management,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    known_stores	=> $glance_stores,
    database_connection => $database_connection,
    registry_host       => $::openstack::config::storage_address_management,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_storage,
    os_region_name      => $::openstack::config::region,
  }

  if $::openstack::config::insecure_ssl == true {
         glance_registry_config {
             'keystone_authtoken/insecure': value => true; 
         }
         glance_api_config {
             'keystone_authtoken/insecure': value => true; 
         }
  }
}
