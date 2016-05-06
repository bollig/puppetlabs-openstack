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

   $backend = 'rbd'
   case $backend {
    'iscsi': {
      class { '::cinder::setup_test_volume':
        size => '1G',
      }
      cinder::backend::iscsi { 'BACKEND_1':
        iscsi_ip_address => '127.0.0.1',
      }
    }
    'rbd': {
      cinder::backend::rbd { 'BACKEND_1':
        rbd_user        => 'client.cinder',
        rbd_pool        => 'volumes',
        rbd_secret_uuid => '7200aea0-2ddd-4a32-aa2a-d49f66ab554c',
      }
    }
    default: {
      fail("Unsupported backend (${backend})")
    }
  }
  Cinder::Type {
      os_password     => $::openstack::keystone::admin_password,
      os_tenant_name  => 'admin',
      os_username     => 'admin',
      os_auth_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0",
  }
  cinder::type { 'BACKEND_1':
	set_key => 'volume_backend_name',
	set_value => 'BACKEND_1',
  }
  class { 'cinder::backends':
	enabled_backends => ['BACKEND_1'],
  }
  Class['Cinder::Backends'] -> Service['httpd']

  class { 'cinder::ceilometer': }
}
