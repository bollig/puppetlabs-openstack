# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }
# See http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty&f=13
  #::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    #value     => '0',
  #}
  #::sysctl::value { 'net.ipv4.conf.all.rp_filter':
  #  value     => '0',
  #}


  $controller_management_address = $::openstack::config::controller_address_management
  $network_management_address = $::openstack::config::network_address_management

  include ::openstack::common::neutron

  ### Router service installation

  if 'vpnaas' in $::openstack::config::neutron_service_plugins {
      $vpnaas_enabled = true
    # NOTE: old versions of OS did not allow these services to run in the same space
      $start_l3_agent = true
  } else { 
      $vpnaas_enabled = false
      $start_l3_agent = true
  }

     # L3 Agent  (required)
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    external_network_bridge => 'br-ex',
    enabled                 => $start_l3_agent,
    manage_service          => $start_l3_agent, 
  }

    # DHCP Agent 
  class { '::neutron::agents::dhcp':
    debug   => $::openstack::config::debug,
    enabled => true,
    dnsmasq_config_file => '/etc/neutron/dnsmasq-neutron.conf',
    subscribe           => File['/etc/neutron/dnsmasq-neutron.conf'],
  }

  file { '/etc/neutron/dnsmasq-neutron.conf':
    content => 'dhcp-option-force=26,1400',
    owner   => 'root',
    group   => 'neutron',
    mode    => '0640',
    require => Class['::neutron'],
  }

    # Metadata Agent
  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v3",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
# TODO: Offload metadata to network address
    metadata_ip   => $network_management_address,
    enabled       => true,
  }

#### EXTRAS #######
  class { '::neutron::services::lbaas': 
#	service_providers => 'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default',
	# lbaasv2
	service_providers => 'LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default',
  }

  class { '::neutron::agents::lbaas':
    debug   => $::openstack::config::debug,
    enabled => true,
    enable_v2 => true,
    enable_v1 => false,
    #interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
    #interface_driver => 'openvswitch',
    #device_driver => 'neutron_lbaas.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver',
    #user_group       => 'haproxy',
  }
  
  class { '::neutron::agents::vpnaas':
    enabled => $vpnaas_enabled,
  }

    # Packstack establishes this
    if defined(Class['neutron::services::fwaas']) {
          Class['neutron::services::fwaas'] -> Class['neutron::agents::l3']
    }


    # Metering Agent requires L3 Agent 
  class { '::neutron::agents::metering':
    enabled => true,
    debug   => $::openstack::config::debug,
    interface_driver => 'neutron.agent.linux.interface.OVSInterfaceDriver',
    #driver  => 'neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver',
  }

  class { '::neutron::services::fwaas':
    driver => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
    enabled => true,
  }

  $external_bridge = 'br-ex'
  $external_network = $::openstack::config::network_external
  $external_device = device_for_network($external_network)
  vs_bridge { $external_bridge:
    ensure => present,
    require => Service['neutron-ovs-agent-service'],
  }
   #notify {"DEVICE FOR NETWORK: ${external_device} ; ${external_network} ; ${external_bridge}": }
  if $external_device != $external_bridge {
    vs_port { $external_device:
      ensure => present,
      bridge => $external_bridge,
      require => Service['neutron-ovs-agent-service'],
    }
  } else {
    # External bridge already has the external device's IP, thus the external
    # device has already been linked
  }

  $defaults = { 'ensure' => 'present' }
  create_resources('neutron_network', $::openstack::config::networks, $defaults)
  create_resources('neutron_subnet', $::openstack::config::subnets, $defaults)
  create_resources('neutron_router', $::openstack::config::routers, $defaults)
  create_resources('neutron_router_interface', $::openstack::config::router_interfaces, $defaults)

}
