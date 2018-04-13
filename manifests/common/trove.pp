# Common class for trove installation
# Private, and should not be used on its own
class openstack::common::trove {

  $management_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_trove
  $pass                = $::openstack::config::mysql_pass_trove
  $database_connection = "mysql+pymysql://${user}:${pass}@${management_address}/trove"

  class { '::trove::client': }

  class { '::trove':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    #rabbit_use_ssl	=> 
    nova_proxy_admin_pass => $::openstack::config::nova_password,
    os_region_name      => $::openstack::config::region,
  }

  # TODO: bugfix this for trove. They dont set it properly
  trove_config {
    'DEFAULT/rabbit_password':                      value => $rabbit_password;
  }
}
