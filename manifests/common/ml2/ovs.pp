# Private class
# Set up the OVS agent
class openstack::common::ml2::ovs {
  $data_network        = $::openstack::config::network_data
  $data_address        = ip_for_network($data_network)
  $enable_tunneling    = $::openstack::config::neutron_tunneling # true
  $tunnel_types        = $::openstack::config::neutron_tunnel_types #['gre']
    
  $bridge_mappings  = []
  $bridge_uplinks   = []

  #notify { "DataAdress: ${data_address}": }
# TODO: link the config file properly
  file { ['/etc/neutron','/etc/neutron/plugins','/etc/neutron/plugins/ml2/']:
    ensure=>'directory', 
  } -> 
  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => $enable_tunneling,
    local_ip         => $data_address,
    enabled          => true,
    tunnel_types     => $tunnel_types,
 #   bridge_mappings  => $bridge_mappings,
 #   bridge_uplinks   => $bridge_uplinks,
 #   vxlan_udp_port   => '4789', 
# enable this if ml2 has l2population driver enabled
 #   l2_population    => false,
  }
}
