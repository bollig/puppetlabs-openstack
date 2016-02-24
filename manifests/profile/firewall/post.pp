# post-firewall rules to reject remaining traffic
class openstack::profile::firewall::post {
  firewall { '8999 - Accept all management network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_management,
  } ->
  firewall { '9100 - Accept all vm network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_data,
  } ->
#iptables -A INPUT -p gre -s 10.31.13.128/26 -j ACCEPT
  firewall { '9888 - Accept GRE traffic (DATA)':
    proto  => 'gre',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_data,
  } -> 
  firewall { '9888 - Accept GRE traffic (MGMT)':
    proto  => 'gre',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_management,
  } -> 
  firewall { '9999 - Reject remaining traffic':
    proto  => 'all',
    action => 'reject',
    reject => 'icmp-host-prohibited',
    source => '0.0.0.0/0',
  }
}
