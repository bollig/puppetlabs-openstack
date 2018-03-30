# The profile to install a local instance of memcache
class openstack::profile::memcache (
  $listen_ip = $::openstack::config::controller_address_management,
) {
  if $listen_ip == 'ip_address' { 
    $l_listen_ip = $::ipaddress
  } else {
    $l_listen_ip = $listen_ip
  } 
  class { 'memcached':
    listen_ip => $l_listen_ip,
    #listen_ip => $::openstack::config::controller_address_management, #'127.0.0.1',
    tcp_port  => 11211,
    udp_port  => 11211,
  }
}
