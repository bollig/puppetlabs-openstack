# The profile to install the volume service
class openstack::profile::cinder::volume {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)


  include ::openstack::common::cinder
  openstack::resources::firewall { 'ISCSI API': port => '3260', }

  class { '::cinder::setup_test_volume':
    volume_name => 'cinder-volumes',
    size        => $::openstack::config::cinder_volume_size
  } ->

  class { '::cinder::volume':
    package_ensure => present,
    enabled        => true,
  }

  #$backend = 'iscsi'
#
#  case $backend {
#     'iscsi': {
#	  class { '::cinder::volume::iscsi':
#	    iscsi_ip_address => $management_address,
#	    volume_group     => 'cinder-volumes',
#	  }
#     }
#     'rbd': {
#	  class { '::cinder::volume::rbd':
#		  rbd_user        => 'cinder',
#		  rbd_pool        => 'volumes',
#	  }
#      }
#      default: {
#         fail("Unsupported backend (${backend})")
#      }
#  }
  $enable_extra_backend=true
  if $enable_extra_backend {
	  cinder::backend::rbd { 'rbd2':
		  rbd_user        => 'cinder',
		  rbd_pool        => 'volumes',
	  }
	  Cinder::Type {
	      os_password     => $::openstack::config::keystone_admin_password,
	     os_tenant_name  => 'admin',
	      os_username     => 'admin',
	      os_auth_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0",
	  }
	  cinder::type { 'frankenCeph':
		set_key => 'volume_backend_name',
		set_value => 'rbd2',
	  }
	  class { 'cinder::backends':
		enabled_backends => ['DEFAULT', 'rbd2'],
	  }  
	  Class['Cinder::Backends'] -> Service['httpd']
  }


}
