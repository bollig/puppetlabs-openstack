# The profile to set up the Ceilometer API
# For co-located api and worker nodes this appear
# after openstack::profile::ceilometer::agent
class openstack::profile::ceilometer::auth (
      $gnocchi_enabled = false,
      $aodh_enabled = false,
) {

  include ::openstack::common::mongodb

  $mongo_username                = $::openstack::config::ceilometer_mongo_username
  $mongo_password                = $::openstack::config::ceilometer_mongo_password

  mongodb_database { 'ceilometer':
    ensure  => present,
    tries   => 20,
    require => Class['mongodb::server'],
  }

  if $mongo_username and $mongo_password {
    mongodb_user { $mongo_username:
      ensure        => present,
      password_hash => mongodb_password($mongo_username, $mongo_password),
      database      => 'ceilometer',
      roles         => ['readWrite', 'dbAdmin'],
      tries         => 10,
      require       => [Class['mongodb::server'], Class['mongodb::client']],
      #before        => Class['ceilometer-dbsync'],
    }
  }

  if $gnocchi_enabled == true { 
    class {'::openstack::profile::ceilometer::gnocchi_auth':}
  }
  
  # AODH is always enabled
  class {'::openstack::profile::ceilometer::aodh_auth':}

  # Setup the ceilometer user in keystone and register endpoints (control)
  class { '::ceilometer::keystone::auth':
    password         => $::openstack::config::ceilometer_password,
    public_url   => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_api}:8777",
    admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_management}:8777",
    internal_url => "${::openstack::config::http_protocol}://${::openstack::config::telemetry_address_management}:8777",
    region           => $::openstack::config::region,
  }

}
