#
class openstack::profile::ceilometer::aodh_auth (
) {
    # Make the mysql db user 'aodh' exists
    openstack::resources::database { 'aodh': }

    $management_address  = $::openstack::config::controller_address_management
    $user                = $::openstack::config::mysql_user_aodh
    $pass                = $::openstack::config::mysql_pass_aodh
    $database_connection = "mysql://${user}:${pass}@${management_address}/aodh"

    # Make the 'aodh' user in keystone: 
    class { '::aodh::keystone::auth':
      password => $::openstack::config::aodh_password,
      public_url   => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_api}:8042",
      admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_management}:8042",
      internal_url => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_management}:8042",
      region           => $::openstack::config::region,
    }

}
