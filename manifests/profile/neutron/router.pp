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

     # L3 Agent  (required)
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    external_network_bridge => 'br-ex',
    enabled                 => true,
  }
    # DHCP Agent 
  class { '::neutron::agents::dhcp':
    debug   => $::openstack::config::debug,
    enabled => true,
  }

    # Metadata Agent
  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "http://${controller_management_address}:35357/v3",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
# TODO: Offload metadata to network address
    metadata_ip   => $network_management_address,
    enabled       => true,
  }

#### EXTRAS #######

  class { '::neutron::agents::lbaas':
    debug   => $::openstack::config::debug,
    enabled => true,
  }

  class { '::neutron::agents::vpnaas':
    enabled => true,
  }

    # Metering Agent requires L3 Agent 
  class { '::neutron::agents::metering':
    enabled => true,
    debug   => $::openstack::config::debug,
    driver  => 'neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver',
  }

  class { '::neutron::services::fwaas':
    enabled => true,
  }

  $external_bridge = 'br-ex'
  $external_network = $::openstack::config::network_external
  $external_device = device_for_network($external_network)
  vs_bridge { $external_bridge:
    ensure => present,
  }
#  notify {"DEVICE FOR NETWORK: ${external_device} ; ${external_network} ; ${external_bridge}": }
  if $external_device != $external_bridge {
    vs_port { $external_device:
      ensure => present,
      bridge => $external_bridge,
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
