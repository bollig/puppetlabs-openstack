class openstack::profile::neutron::compute_dvr {

  $network_management_address = $::openstack::config::network_address_management

  # Packstack establishes this
  if defined(Class['neutron::services::fwaas']) {
    Class['neutron::services::fwaas'] -> Class['neutron::agents::l3']
  }

  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    #DEPRECATED: 
    #external_network_bridge => 'br-ex',
    # NOTE: this is empty otherwise l3 wont start with mutliple external networks
    # defined
    #external_network_bridge => '',
    enabled                 => $start_l3_agent,
    manage_service          => $start_l3_agent,
    agent_mode              => 'dvr',
  }
  # Metadata Agent
  class { '::neutron::agents::metadata':
    # After mitaka, these are provided by the neutron::keystone::authtoken:
    #auth_password => $::openstack::config::neutron_password,
    #auth_url      => "${::openstack::config::http_protocol}://${controller_management_address}:35357/v3",
    shared_secret => $::openstack::config::neutron_shared_secret,
    debug         => $::openstack::config::debug,
    #auth_region   => $::openstack::config::region,
# TODO: Offload metadata to network address
    metadata_ip   => $network_management_address,
    enabled       => true,
  }

  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

}
