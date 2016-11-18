# Adds gnocchi to the stack
# 
# http://www.slideshare.net/GordonChung/gnocchi-v3-brownbag
# 
class openstack::profile::ceilometer::gnocchi ( 
) {
      $management_address  = $::openstack::config::controller_address_management
      $user                = $::openstack::config::mysql_user_gnocchi
      $pass                = $::openstack::config::mysql_pass_gnocchi
      $database_connection = "mysql://${user}:${pass}@${management_address}/gnocchi"

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

    include ::openstack::common::gnocchi
}
