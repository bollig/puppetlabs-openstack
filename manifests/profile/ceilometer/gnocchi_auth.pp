# The profile to set up the Ceilometer API
# For co-located api and worker nodes this appear
# after openstack::profile::ceilometer::agent
class openstack::profile::ceilometer::gnocchi_auth (
) {
    # Make the mysql db user 'gnocchi' exists
    openstack::resources::database { 'gnocchi': }

    $management_address  = $::openstack::config::controller_address_management
    $user                = $::openstack::config::mysql_user_gnocchi
    $pass                = $::openstack::config::mysql_pass_gnocchi
    $database_connection = "mysql://${user}:${pass}@${management_address}/gnocchi"

    # Make the 'gnocchi' user in keystone: 
    class { '::gnocchi::keystone::auth':
        password     => $::openstack::config::gnocchi_password,
        public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8041",
        admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8041",
        internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8041",
        region       => $::openstack::config::region,
    }

    class { '::gnocchi::db::sync': }
}
