# The profile to install an OpenStack specific MongoDB server
class openstack::profile::mongodb (
	$bind_address = 'localhost',
) {
  $management_network = $::openstack::config::network_management

  if $bind_address == 'ip_address' { 
    $l_bind_address = $::ipaddress
  } else {
    $l_bind_address = $bind_address
  }

  class { '::mongodb::globals':
    manage_package_repo => true,
  }

  class { '::mongodb::server':
    #bind_ip => ['127.0.0.1', $::openstack::config::controller_address_management],
    bind_ip => ['127.0.0.1', $l_bind_address ],
  }

# THIS IS NOW PART OF THE common/ceilometer.pp
#  class { '::mongodb::client': }
}
