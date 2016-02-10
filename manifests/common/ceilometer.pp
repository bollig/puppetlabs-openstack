# Common class for ceilometer installation
# Private, and should not be used on its own
class openstack::common::ceilometer {

  $mongo_username                = $::openstack::config::ceilometer_mongo_username
  $mongo_password                = $::openstack::config::ceilometer_mongo_password

  $ceilometer_management_address = $::openstack::config::ceilometer_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  if ! $mongo_username or ! $mongo_password {
    $mongo_connection = "mongodb://${ceilometer_management_address}:27017/ceilometer"
  } else {
    $mongo_connection = "mongodb://${mongo_username}:${mongo_password}@${ceilometer_management_address}:27017/ceilometer"
  }

  class { '::ceilometer':
    metering_secret => $::openstack::config::ceilometer_meteringsecret,
    debug           => $::openstack::config::debug,
    verbose         => $::openstack::config::verbose,
    rabbit_hosts    => $::openstack::config::rabbitmq_hosts,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_password => $::openstack::config::rabbitmq_password,
  }

  class { '::ceilometer::db':
    database_connection => $mongo_connection,
  }

  class {'::mongodb::client':}
}

