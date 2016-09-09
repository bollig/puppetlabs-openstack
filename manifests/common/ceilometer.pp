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

    # Install ceilometer base classes and setup the [DEFAULT] and
    # [oslo_messaging_rabbit] sections in /etc/ceilometer/ceilometer.conf
  class { '::ceilometer':
    metering_secret => $::openstack::config::ceilometer_meteringsecret,
    debug           => $::openstack::config::debug,
    verbose         => $::openstack::config::verbose,
    rabbit_hosts    => $::openstack::config::rabbitmq_hosts,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_password => $::openstack::config::rabbitmq_password,
  }

    # setup the [service_credentials] section in /etc/ceilometer/ceilometer.conf (control and compute)
  class { '::ceilometer::agent::auth':
    auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:5000",
    auth_password => $::openstack::config::ceilometer_password,
    auth_region   => $::openstack::config::region,
    auth_endpoint_type => 'publicURL',
  }
    # add missing entry to [keystone_authtoken]
  #ceilometer_config {
  #  'keystone_authtoken/auth_version': value => 'v2.0';
  #}

  class { '::ceilometer::db':
    database_connection => $mongo_connection,
  }

  class {'::mongodb::client':}
}

