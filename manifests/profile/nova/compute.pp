# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute (
  $libvirt_use_rbd=false,
  $libvirt_rbd_user='cinder',
  $libvirt_rbd_secret_uuid='',
  $libvirt_images_rbd_pool='vms',
  $rbd_keyring='client.cinder',
  $libvirt_cpu_mode = 'host-passthrough',
) {
  $management_network            = $::openstack::config::network_management
  $management_address            = ip_for_network($management_network)
  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::nova

  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $::openstack::config::controller_address_api,
    instance_usage_audit 	  => true,
    instance_usage_audit_period   => 'hour',
# TODO: not sure why, but setting this to false will break our glance image imports in Horizon
    force_raw_images 		  => true,
    allow_resize_to_same_host     => true,
# NOTE: the remainder of the ceilometer notificatons settings are in ::nova
  }

  nova_config { 
	#'DEFAULT/compute_monitors': value => 'nova.compute.monitors.cpu.virt_driver';
	'DEFAULT/compute_monitors': value => ["cpu.virt_driver, numa_mem_bw.virt_driver"];
	'DEFAULT/resize_fs_using_block_device': value => 'true';
  }


  class { '::nova::compute::libvirt':
    libvirt_virt_type => $::openstack::config::nova_libvirt_type,
    libvirt_cpu_mode => $libvirt_cpu_mode,
    #vncserver_listen  => $management_address,
	# NOTE: this is required for live migration (listens on all interfaces)
    vncserver_listen  => '0.0.0.0',
  }

  if $libvirt_use_rbd {
    class { '::nova::compute::rbd':
      libvirt_rbd_user        => $libvirt_rbd_user,
      libvirt_rbd_secret_uuid => $libvirt_rbd_secret_uuid,
      libvirt_images_rbd_pool => $libvirt_images_rbd_pool,
      rbd_keyring             => $rbd_keyring,
    }
  }


#TODO: test live migration
  class { 'nova::migration::libvirt':
	  #use_tls              => false,
	  #auth                 => 'none',
	# From: http://www.tcpcloud.eu/en/blog/2014/11/20/block-live-migration-openstack-environment/
	  live_migration_flag  => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_TUNNELLED',
	  block_migration_flag => 'VIR_MIGRATE_SHARED_INC,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_UNDEFINE_SOURCE',
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
