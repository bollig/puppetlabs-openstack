# Adds AODH to the stack
class openstack::profile::ceilometer::aodh (
) {

      $management_address  = $::openstack::config::controller_address_management
      $user                = $::openstack::config::mysql_user_aodh
      $pass                = $::openstack::config::mysql_pass_aodh
      $database_connection = "mysql://${user}:${pass}@${management_address}/aodh"
      
	    # Make the mysql db user 'aodh' exists
      openstack::resources::database { 'aodh': }
      openstack::resources::firewall { 'AODH API': port => '8042', }

      class { '::aodh':
        rabbit_userid       => $::openstack::config::rabbitmq_user,
        rabbit_password     => $::openstack::config::rabbitmq_password,
        verbose             => true,
        debug               => false,
        rabbit_hosts         => $::openstack::config::rabbitmq_hosts,
            # TODO: update to mongo when possible
     	database_connection => $database_connection,
      }
	    # Make the 'aodh' user in keystone: 
      class { '::aodh::keystone::auth':
        password => $::openstack::config::aodh_password,
    	public_url   => "http://${::openstack::config::controller_address_api}:8042",
    	admin_url    => "http://${::openstack::config::controller_address_management}:8042",
    	internal_url => "http://${::openstack::config::controller_address_management}:8042",
    	region           => $::openstack::config::region,
      }

        # Setup the aodh api endpoint
      class { '::aodh::api':
        keystone_password     => $::openstack::config::aodh_password,
        keystone_identity_uri => "http://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "http://${::openstack::config::controller_address_management}:35357/",
        #service_name          => 'httpd',
        manage_service        => false,
        enabled               => false,
      }
        # Setup the aodh service behind apache wsgi
      include ::apache
      class { '::aodh::wsgi::apache':
        ssl => false,
      }

        # Configure aodh to point to keystone
      class { '::aodh::auth':
        auth_url      => "http://${::openstack::config::controller_address_management}:5000/v2.0",
        auth_password => $::openstack::config::aodh_password,
      }
      class { '::aodh::client': }
      class { '::aodh::notifier': }
      class { '::aodh::listener': }
      class { '::aodh::evaluator': }
      class { '::aodh::db::sync': }

}