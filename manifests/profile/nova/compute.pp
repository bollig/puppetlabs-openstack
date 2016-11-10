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
    vncproxy_protocol 		  => $::openstack::config::http_protocol,
    instance_usage_audit 	  => true,
    instance_usage_audit_period   => 'hour',
# DONE: not sure why, but setting this to false will break our glance image imports in Horizon
# NOTE: Glance images MUST be RAW. If they are compressed in any way, the image
# is first copied down to the local hypervisor (from Ceph), decompressed, and
# the RAW image uploaded back into Ceph. This voids the ability to
# Copy-On-Write in Ceph and benefit from duplicate data.
    force_raw_images 		  => true,
    allow_resize_to_same_host     => true,
# NOTE: the remainder of the ceilometer notificatons settings are in ::nova
  }

  nova_config { 
	#'DEFAULT/compute_monitors': value => 'nova.compute.monitors.cpu.virt_driver';
	'DEFAULT/resize_fs_using_block_device': value => 'true';
  }


  class { '::nova::compute::libvirt':
    libvirt_virt_type => $::openstack::config::nova_libvirt_type,
    libvirt_cpu_mode => $libvirt_cpu_mode,
    #vncserver_listen  => $management_address,
	# NOTE: this is required for live migration (listens on all interfaces)
    vncserver_listen  => '0.0.0.0',
    # This is required to enable disk caching and avoid this bug when snapshotting VMs: http://tracker.ceph.com/issues/14522
    libvirt_disk_cachemodes => ['network=writeback'], 
    # This requires images to have properties set: 
    # and it requires QEMU 1.6.0+ (CentOS 7 is only 1.5.3) 
    #libvirt_hw_disk_discard => 'ignore',
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
        # http://docs.openstack.org/releasenotes/nova/mitaka.html
	  live_migration_flag  => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE',
	  block_migration_flag => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_SHARED_INC',
	  #block_migration_flag => true,
  } -> 
  nova_config {
    # FORCE THE USE OF RBD LIVE MIGRATION
    'libvirt/live_migration_tunneled': value => 'False';
    'libvirt/snapshot_image_format': value => 'raw';
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
