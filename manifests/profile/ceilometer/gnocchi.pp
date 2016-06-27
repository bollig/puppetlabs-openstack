# Adds gnocchi to the stack
# NOTE: to use, add GNOCCHI_ENDPOINT to your env (see http://docs.openstack.org/developer/python-gnocchiclient/shell.html)
#       - Disabling this because it requires major resources, and does not function well (Evan) 
class openstack::profile::ceilometer::gnocchi ( 
) {
      $management_address  = $::openstack::config::controller_address_management
      $user                = $::openstack::config::mysql_user_gnocchi
      $pass                = $::openstack::config::mysql_pass_gnocchi
      $database_connection = "mysql://${user}:${pass}@${management_address}/gnocchi"

 	    # Make the mysql db user 'gnocchi' exists
      openstack::resources::database { 'gnocchi': }
      openstack::resources::firewall { 'GNOCCHI API': port => '8041', }

    class { '::gnocchi':
      verbose             => false,
      debug               => false,
      database_connection => $database_connection,
    }

    # Make the 'gnocchi' user in keystone: 
    class { '::gnocchi::keystone::auth':
        password => $::openstack::config::gnocchi_password,
        public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8041",
        admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8041",
        internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8041",
        region           => $::openstack::config::region,
    }

    # Setup the gnocchi api endpoint
    class { '::gnocchi::api':
        keystone_password     => $::openstack::config::gnocchi_password,
        keystone_identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        service_name          => 'httpd',
        #manage_service        => false,
        enabled               => true,
    }
    include ::apache
    class { '::gnocchi::wsgi::apache':
      ssl => false,
    }

    class { '::gnocchi::db::sync': }
    class { '::gnocchi::metricd': }
    class { '::gnocchi::storage': }
    class { '::gnocchi::storage::file': }

    include ::openstack::common::gnocchi
}
