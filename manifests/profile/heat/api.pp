# The profile for installing the heat API
class openstack::profile::heat::api (
	$bind_address = '127.0.0.1',
        $enable_haproxy = true
) {

  openstack::resources::database { 'heat': }
  openstack::resources::firewall { 'Heat API': port     => '8004', }
  openstack::resources::firewall { 'Heat CFN API': port => '8000', }

  $controller_management_address = $::openstack::config::controller_address_management
  $user                          = $::openstack::config::mysql_user_heat
  $pass                          = $::openstack::config::mysql_pass_heat
  $database_connection           = "mysql://${user}:${pass}@${controller_management_address}/heat"

  heat_config { 
    #'DEFAULT/default_floating_pool': value => 'public';
    # ssl needs set for both api and compute (for novnc)
    'DEFAULT/ssl_only': value => $::openstack::config::enable_ssl;
    'DEFAULT/cert': value => $::openstack::config::horizon_ssl_certfile;
    'DEFAULT/key': value => $::openstack::config::horizon_ssl_keyfile;
  }

  class { '::heat::keystone::auth':
    password         => $::openstack::config::heat_password,
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8004/v1/%(tenant_id)s",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8004/v1/%(tenant_id)s",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8004/v1/%(tenant_id)s",
    region           => $::openstack::config::region,

#NOTE: this is required to create the heat_stack_owner role. This role is
# required to allow users to create orchestration stacks. Option will default
# to true in Mikasa or later
    configure_delegated_roles => true,
  }

  class { '::heat::keystone::auth_cfn':
    password         => $::openstack::config::heat_password,
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8000/v1",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8000/v1",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8000/v1",
    region           => $::openstack::config::region,
  }

  class { '::heat':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
    keystone_password     => $::openstack::config::heat_password,
    identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
    auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
    #mysql_module        => '2.2',
  }

  class { '::heat::api':
#    bind_host => $::openstack::config::controller_address_api,
    bind_host => $bind_address,
  }

  class { '::heat::api_cfn':
#    bind_host => $::openstack::config::controller_address_api,
    bind_host => $bind_address,
  }

  class { '::heat::engine':
    auth_encryption_key => $::openstack::config::heat_encryption_key,
  }

  if $enable_haproxy {
	include ::openstack::profile::haproxy::init
	include ::openstack::profile::haproxy::heat
  }
}
