# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::cinder {

  $management_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_cinder
  $pass                = $::openstack::config::mysql_pass_cinder
  $database_connection = "mysql://${user}:${pass}@${management_address}/cinder"

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
  }

  class { '::cinder::api':
    keystone_password  => $::openstack::config::cinder_password,
#    keystone_auth_host => $::openstack::config::controller_address_management,
    identity_uri       => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
    auth_uri           => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0",
    enabled            => true,
  }

  #$storage_server = $::openstack::config::storage_address_api
  #$glance_api_server = "${storage_server}:9292"

  class { '::cinder::glance':
    glance_api_servers => [ $::openstack::config::glance_api_servers ],
  }

  class { 'cinder::ceilometer': }
}
