# 
class openstack::common::keystone {
  if $::openstack::profile::base::is_controller {
    $admin_bind_host = '0.0.0.0'
    if $::openstack::config::keystone_use_httpd == true {
      $service_name = 'httpd'
      $enable_ssl = false
    } else {
      $service_name = undef
      $enable_ssl = $::openstack::config::enable_ssl
    }
  } else {
    $admin_bind_host = $::openstack::config::controller_address_management
    $service_name    = undef
  }

  $management_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_keystone
  $pass                = $::openstack::config::mysql_pass_keystone
  $database_connection = "mysql://${user}:${pass}@${management_address}/keystone"

  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $database_connection,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_controller,
    admin_bind_host     => $admin_bind_host,
    service_name        => $service_name,
    enable_ssl          => $enable_ssl, 
    public_endpoint     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    admin_endpoint      => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
# FOR CEILOMETER:
    #notification_format => 'cadf',  
    #notification_driver => 'messagingv2',
  }

}
