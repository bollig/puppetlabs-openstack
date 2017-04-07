# 
class openstack::common::keystone (
	$enable_service = false,
) {
  if $enable_service {
    $admin_bind_host = '0.0.0.0'
    if $::openstack::config::keystone_use_httpd == true {
      $service_name = 'httpd'
      $enable_ssl = false
      $enable_fernet = true
    } else {
      $service_name = undef
      $enable_ssl = $::openstack::config::enable_ssl
      $enable_fernet = true
    }
  } else {
    $admin_bind_host = $::openstack::config::controller_address_management
    $service_name    = undef
    $enable_ssl = false
    $enable_fernet = true
  }

  $management_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_keystone
  $pass                = $::openstack::config::mysql_pass_keystone
  $database_connection = "mysql://${user}:${pass}@${management_address}/keystone"
  
  class { '::keystone::client': }
  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $database_connection,
    #verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $enable_service,
    admin_bind_host     => $admin_bind_host,
    service_name        => $service_name,
    enable_ssl          => $enable_ssl, 
    public_endpoint     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    admin_endpoint      => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
    # NOTE: this should only be set to true if we are on Debian systems
    #manage_policyrcd    => true,
    using_domain_config => true,
    #enable_fernet_setup => $enable_fernet,
# FOR CEILOMETER:
    #notification_format => 'cadf',  
    #notification_driver => 'messagingv2',
    cache_enabled => true,
    token_caching => true,
    memcache_servers   => ["${::openstack::config::controller_address_management}:11211"],
    cache_backend  => 'oslo_cache.memcache_pool',
    token_driver => 'memcache',
    # for fernet, 255; uuid = 32
    max_token_size => 512,
  }

}
