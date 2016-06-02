# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {
  $management_network            = $::openstack::config::network_management
  $management_address            = ip_for_network($management_network)
  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::nova

  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $::openstack::config::controller_address_api,
    instance_usage_audit 	      => true,
    instance_usage_audit_period   => 'hour',
# TODO: not sure why, but setting this to false will break our glance image imports in Horizon
    force_raw_images 		  => true,
    allow_resize_to_same_host     => true,
# NOTE: the remainder of the ceilometer notificatons settings are in ::nova
  }

  nova_config { 
	'DEFAULT/compute_monitors': value => 'nova.compute.monitors.cpu.virt_driver';
	'DEFAULT/resize_fs_using_block_device': value => 'true';
  }

  $libvirt_rbd=true

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $::openstack::config::nova_libvirt_type,
    libvirt_cpu_mode => 'host-passthrough',
    #vncserver_listen  => $management_address,
	# NOTE: this is required for live migration (listens on all interfaces)
    vncserver_listen  => '0.0.0.0',
  }

  if $libvirt_rbd {
    class { '::nova::compute::rbd':
      libvirt_rbd_user        => 'cinder',
      libvirt_rbd_secret_uuid => '06a25e2f-5a2e-461a-aa6f-66efd6b5fe0a',
      libvirt_images_rbd_pool => 'vms',
      rbd_keyring             => 'client.cinder',
    }
  }


#TODO: test live migration
  class { 'nova::migration::libvirt':
	  #use_tls              => false,
	  #auth                 => 'none',
	# From: http://www.tcpcloud.eu/en/blog/2014/11/20/block-live-migration-openstack-environment/
	  live_migration_flag  => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_TUNNELLED',
	  #block_migration_flag => true,
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/openstack/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  if $::osfamily == 'RedHat' {
    package { 'device-mapper':
      ensure => latest
    }
    Package['device-mapper'] ~> Service['libvirtd'] ~> Service['nova-compute']
  }
  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}
