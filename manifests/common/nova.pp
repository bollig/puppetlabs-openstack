# Common class for nova installation
# Private, and should not be used on its own
# usage: include from controller, declare from worker
# This is to handle dependency
# depends on openstack::profile::base having been added to a node
class openstack::common::nova {

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $storage_management_address = $::openstack::config::storage_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  $user                = $::openstack::config::mysql_user_nova
  $pass                = $::openstack::config::mysql_pass_nova
  $database_connection = "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova"
  $api_database_connection = "mysql+pymysql://${user}_api:${pass}@${controller_management_address}/nova_api"

  class { '::nova':
    database_connection => $database_connection,
    api_database_connection => $api_database_connection,
    glance_api_servers  => join($::openstack::config::glance_api_servers, ','),
    memcached_servers   => ["${controller_management_address}:11211"],
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
# FOR CEILOMETER NOTIFICATIONS: 
    notify_on_state_change => 'vm_and_task_state', 
    notification_driver    => 'messagingv2',
    #mysql_module        => '2.2',
  }

  #nova_config { 'DEFAULT/default_floating_pool': value => 'public' }
  #class { '::nova::api': 
  #  default_floating_pool => 'public' 
  #}

  class { '::nova::network::neutron':
    neutron_admin_password => $::openstack::config::neutron_password,
    neutron_region_name    => $::openstack::config::region,
#TODO: update puppet-neutron to a version that supports v3 auth
    neutron_admin_auth_url => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v2.0",
    neutron_url            => "${::openstack::config::http_protocol}://${controller_management_address}:9696",
    vif_plugging_is_fatal  => false,
    vif_plugging_timeout   => '0',
  }
}
