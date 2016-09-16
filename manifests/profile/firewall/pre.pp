# Starts up standard firewall rules. Pre-runs

class openstack::profile::firewall::pre {

  # Set up the initial firewall rules for all nodes
  firewallchain { 'INPUT:filter:IPv4':
    purge  => true,
    ignore => ['neutron','virbr0'],
    before => Firewall['0001 - Accept GRE traffic (INTERNAL_DATA)'],
  }

  include ::firewall

  # Default firewall rules, based on the RHEL defaults
#iptables -A INPUT -p gre -s 10.31.13.128/26 -j ACCEPT
  firewall { '0001 - Accept GRE traffic (INTERNAL_DATA)':
    proto  => 'gre',
    action => 'accept',
    source => $::openstack::config::network_data,
    before => [ Class['::firewall'] ],
  } -> 
  firewall { '0002 - Accept GRE traffic (EXTERNAL)':
    proto  => 'gre',
    action => 'accept',
    source => $::openstack::config::network_external,
  } ->
  firewall { '0003 - related established':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  } ->
  firewall { '0004 - localhost':
    proto  => 'icmp',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0005 - localhost':
    proto  => 'all',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0010 - Accept vxlan traffic':
    proto  => 'udp',
    dport  => 4789,
    action => 'accept',
  } ->
  firewall { '0022 - ssh':
    proto  => 'tcp',
    state  => ['NEW', 'ESTABLISHED', 'RELATED'],
    action => 'accept',
    dport   => 22,
    before => [ Firewall['8999 - Accept all management network traffic'] ],
  }
}
