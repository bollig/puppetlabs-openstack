# The profile to install the volume service
class openstack::profile::cinder::volume (
  $fixed_key = '2b1d0b36e5d1d2416a617a41eb46a488',
  $enable_extra_backend = false,
  $extra_backend_name = 'ssd',
  $extra_backend_pool = 'ssd',
) {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)


  include ::openstack::common::cinder

  class { '::cinder::setup_test_volume':
    volume_name => 'cinder-volumes',
    size        => $::openstack::config::cinder_volume_size,
    require     => [Service['httpd'], Class['::cinder::wsgi::apache']],
  }

  class { '::cinder::volume':
    package_ensure => present,
    enabled        => true,
  }

  # This is the primary (DEFAULT) backend. This is what users get when they
  # dont specify a backend in OpenStack
  $backend = 'rbd'

  case $backend {
    'iscsi': {
      openstack::resources::firewall { 'ISCSI API': port => '3260', }
      class { '::cinder::volume::iscsi':
        iscsi_ip_address => $management_address,
        volume_group     => 'cinder-volumes',
      }
    }
    'rbd': {
      class { '::cinder::volume::rbd':
        rbd_user        => 'cinder',
        rbd_pool        => 'volumes',
        rbd_flatten_volume_from_snapshot => false,
        volume_tmp_dir  => '/tmp',
        rbd_ceph_conf   => '/etc/ceph/ceph-nova.conf',
      }
    }
    default: {
      fail("Unsupported cinder backend (${backend})")
    }
  }
  if $enable_extra_backend {
          cinder::backend::rbd { "${extra_backend_name}":
		  rbd_user        => 'cinder',
		  rbd_pool        => "${extra_backend_pool}",
                  rbd_flatten_volume_from_snapshot => false,
                  #rbd_max_clone_depth => 5,
                  #rbd_store_chunk_size => 4,
                  volume_backend_name => "${extra_backend_name}",
	  } 
	  Cinder::Type {
	      os_password     => $::openstack::config::keystone_admin_password,
	      os_tenant_name  => 'admin',
	      os_username     => 'admin',
	      os_auth_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0",
              require => [Service['httpd'],Class['::cinder::wsgi::apache']],
	  }
	  cinder::type { "${extra_backend_name}":
            set_key => 'volume_backend_name',
            set_value => "${extra_backend_name}",
            require => [Service['httpd'],Class['::cinder::wsgi::apache']],
	  }
          cinder::type { 'DEFAULT':
            set_key => 'volume_backend_name',
            set_value => 'DEFAULT',
            require => [Service['httpd'],Class['::cinder::wsgi::apache']],
	  }
          cinder::backend::rbd { "DEFAULT_ANY":
		  rbd_user        => 'cinder',
		  rbd_pool        => "volumes",
                  rbd_flatten_volume_from_snapshot => false,
                  volume_backend_name => "ANY",
	  }
	  cinder::backend::rbd { "${extra_backend_name}_ANY":
		  rbd_user        => 'cinder',
		  rbd_pool        => "${extra_backend_pool}",
                  rbd_flatten_volume_from_snapshot => false,
                  volume_backend_name => "ANY",
	  }
	  cinder::type { 'ANY':
            set_key => 'volume_backend_name',
            set_value => ['ANY'],
            require => [Service['httpd'],Class['::cinder::wsgi::apache']],
	  }
	  
	  class { 'cinder::backends':
		enabled_backends => ['DEFAULT', 'DEFAULT_ANY', "${extra_backend_name}_ANY", "${extra_backend_name}"],
                notify => Service['httpd'],
	  }  
	  #Class['Cinder::Backends'] -> Service['httpd']
  } else {
	  class { 'cinder::backends':
		enabled_backends => ['DEFAULT'],
                notify => Service['httpd'],
	  }  
  }

  class { '::cinder::backup': }
  class { '::cinder::backup::ceph': 
	backup_ceph_user => 'cinder-backup',
	backup_ceph_pool => 'backups',
  }
  cinder_config {
    'DEFAULT/restore_discard_excess_bytes': value=> 'true';
# For use in encrypted volumes
    'keymgr/fixed_key': value => $fixed_key;
  }


}
