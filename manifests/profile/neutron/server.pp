# The profile to set up the neutron server
class openstack::profile::neutron::server (
  $bgp_router_id = '127.0.0.1'
) {
  
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  class { '::openstack::common::neutron': enable_service => true }

  $tenant_network_type           = $::openstack::config::neutron_tenant_network_type # ['gre']
  $type_drivers                  = $::openstack::config::neutron_type_drivers # ['gre']
  $mechanism_drivers             = $::openstack::config::neutron_mechanism_drivers # ['openvswitch']
  $tunnel_id_ranges              = $::openstack::config::neutron_tunnel_id_ranges # ['1:1000']
  $network_management_address = $::openstack::config::network_address_management
  $controller_management_address = $::openstack::config::controller_address_management

     # Connect the L2 Plugin but do not setup the L2 Agent**
  if ($::openstack::config::neutron_core_plugin == 'ml2') {
    class  { '::neutron::plugins::ml2':
      network_vlan_ranges  => 'external', 
      type_drivers         => $type_drivers,
      tenant_network_types => $tenant_network_type,
      mechanism_drivers    => $mechanism_drivers,
      tunnel_id_ranges     => $tunnel_id_ranges,
#      vni_ranges           => '10:100',
      enable_security_group => true, 
      firewall_driver      => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
    }

    # For cases where "neutron-db-manage upgrade" command is called
    # we need to fill config file first
    if defined(Exec['neutron-db-manage upgrade']) {
          Neutron_plugin_ml2<||> ->
            File['/etc/neutron/plugin.ini'] ->
              Exec['neutron-db-manage upgrade']
    }
  } elsif ($::openstack::config::neutron_core_plugin == 'plumgrid') {

    neutron_config {
      'DEFAULT/service_plugins': ensure => absent,
    }
    ->
    class { '::neutron::plugins::plumgrid':
      director_server      => $::openstack::config::plumgrid_director_vip,
      username             => $::openstack::config::plumgrid_username,
      password             => $::openstack::config::plumgrid_password,
      admin_password       => $::openstack::config::keystone_admin_password,
      controller_priv_host => $controller_management_address,
      connection           => $db_connection,
    }

    class { '::neutron::agents::metadata':
      auth_password => $::openstack::config::neutron_password,
      shared_secret => $::openstack::config::neutron_shared_secret,
      auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v3/",
      #auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:35357",
      debug         => $::openstack::config::debug,
      auth_region   => $::openstack::config::region,
      metadata_ip   => $controller_management_address,
      enabled       => true,
    }
  }

  $enable_haproxy = true
#  neutron_config { 
#    'DEFAULT/bind_host': value => '127.0.0.1';
#  }
  if $enable_haproxy {
	include ::openstack::profile::haproxy::neutron
  }

  if 'bgp' in $::openstack::config::neutron_service_plugins {
      # Note: depends on the bgp_router_id to be set properly
      file { '/etc/neutron/conf.d/neutron-bgp-dragent/bgp_dragent.conf':
        content => template('openstack/etc__neutron__bgp_dragent.erb'),
        owner   => 'root',
        group   => 'neutron',
        mode    => '640',
      }

      Package['neutron-bgp-dragent'] -> Service['neutron-bgp-dragent']
      Package['neutron-bgp-dragent'] -> File['/etc/neutron/conf.d/neutron-bgp-dragent/bgp_dragent.conf']
      package { 'neutron-bgp-dragent':
        ensure  => 'present',
        name    => 'openstack-neutron-bgp-dragent',
        require => Package['neutron'],
        tag     => ['openstack', 'neutron-package'],
      }

      Package['neutron'] ~> Service['neutron-bgp-dragent']
      Package['neutron-bgp-dragent'] ~> Service['neutron-bgp-dragent']

      service { 'neutron-bgp-dragent':
        ensure  => 'running',
        name    => 'neutron-bgp-dragent',
        enable  => true,
        require => Class['neutron'],
        tag     => 'neutron-service',
      }
  }

  anchor { 'neutron_common_first': } ->
  class { '::neutron::server::notifications':
    nova_url       => "${::openstack::config::http_protocol}://${controller_management_address}:8774/v2/",
    auth_url       => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v3/",
    password       => $::openstack::config::nova_password,
    region_name    => $::openstack::config::region,
  } ->
  anchor { 'neutron_common_last': }

  #Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
