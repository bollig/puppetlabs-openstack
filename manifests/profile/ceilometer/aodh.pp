# Adds AODH to the stack
class openstack::profile::ceilometer::aodh (
	$gnocchi_enabled = false,
) {

      $management_address  = $::openstack::config::controller_address_management
      $user                = $::openstack::config::mysql_user_aodh
      $pass                = $::openstack::config::mysql_pass_aodh
      $database_connection = "mysql://${user}:${pass}@${management_address}/aodh"
      
	    # Make the mysql db user 'aodh' exists
      openstack::resources::database { 'aodh': }
      openstack::resources::firewall { 'AODH API': port => '8042', }

	if $gnocchi_enabled { 
		$gnocchi_url = "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8041"
	} else {
		$gnocchi_url = undef
	}

      class { '::aodh':
        rabbit_userid       => $::openstack::config::rabbitmq_user,
        rabbit_password     => $::openstack::config::rabbitmq_password,
        verbose             => true,
        debug               => false,
        rabbit_hosts         => $::openstack::config::rabbitmq_hosts,
            # TODO: update to mongo when possible
     	database_connection => $database_connection,
	gnocchi_url 	    => $gnocchi_url,	
      }
	    # Make the 'aodh' user in keystone: 
      class { '::aodh::keystone::auth':
        password => $::openstack::config::aodh_password,
    	public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8042",
    	admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8042",
    	internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8042",
    	region           => $::openstack::config::region,
      }

      # if Keystone is behind wsgi, we can put aodh there as well.   
      if $::openstack::config::keystone_use_httpd == true {
          # Setup the aodh service behind apache wsgi
          include ::apache
          class { '::aodh::wsgi::apache':
            ssl => false,
          }

          $service_enabled = false
          $service_managed = false
      } else {
          $service_enabled = true
          $service_managed = true
          # TODO: have not tested this branch
      }

        # Setup the aodh api endpoint
      class { '::aodh::api':
        keystone_password     => $::openstack::config::aodh_password,
        keystone_identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        #service_name          => 'httpd',
        manage_service        => $service_enabled,
        enabled               => $service_managed,
      }
        # Configure aodh to point to keystone
      class { '::aodh::auth':
        auth_url      => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0",
        auth_password => $::openstack::config::aodh_password,
      }
      class { '::aodh::client': } -> package {'python2-aodhclient': ensure => 'present' }
      class { '::aodh::notifier': }
      class { '::aodh::listener': }
      class { '::aodh::evaluator': }
      class { '::aodh::db::sync': }

}
