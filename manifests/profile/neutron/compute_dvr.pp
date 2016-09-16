class openstack::profile::neutron::compute_dvr {
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    #DEPRECATED: 
    #external_network_bridge => 'br-ex',
    # NOTE: this is empty otherwise l3 wont start with mutliple external networks
    # defined
    external_network_bridge => '',
    enabled                 => $start_l3_agent,
    manage_service          => $start_l3_agent,
    agent_mode              => 'dvr',
  }
  class { '::neutron::services::fwaas':
    driver => 'neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
    enabled => true,
  }
  # Metadata Agent
  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v3",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
# TODO: Offload metadata to network address
    metadata_ip   => hiera("openstack::controller::address::api"),
    enabled       => true,
  }
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

}
