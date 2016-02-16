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
      verbose             => true,
      debug               => false,
      database_connection => $database_connection,
    }

    # Make the 'gnocchi' user in keystone: 
    class { '::gnocchi::keystone::auth':
        password => $::openstack::config::gnocchi_password,
        public_url   => "http://${::openstack::config::controller_address_api}:8042",
        admin_url    => "http://${::openstack::config::controller_address_management}:8042",
        internal_url => "http://${::openstack::config::controller_address_management}:8042",
        region           => $::openstack::config::region,
    }

    # Setup the gnocchi api endpoint
    class { '::gnocchi::api':
        keystone_password     => $::openstack::config::gnocchi_password,
        keystone_identity_uri => "http://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "http://${::openstack::config::controller_address_management}:35357/",
        #service_name          => 'httpd',
        manage_service        => false,
        enabled               => false,
    }
    include ::apache
    class { '::gnocchi::wsgi::apache':
      ssl => false,
    }

    class { '::gnocchi::client': }
    class { '::gnocchi::db::sync': }
    class { '::gnocchi::metricd': }
    class { '::gnocchi::storage': }
    class { '::gnocchi::storage::file': }
# TODO: enable statsd
    #class { '::gnocchi::statsd':
    #  archive_policy_name => 'high',
    #  flush_delay         => '100',
    #  # random datas:
    #  resource_id         => '07f26121-5777-48ba-8a0b-d70468133dd9',
    #  user_id             => 'f81e9b1f-9505-4298-bc33-43dfbd9a973b',
    #  project_id          => '203ef419-e73f-4b8a-a73f-3d599a72b18d',
    #}

}
