# Profile to install the horizon web service
class openstack::profile::horizon {
  $service_plugins  = $::openstack::config::neutron_service_plugins
  $enable_backups   = pick($::openstack::config::cinder_enable_backup, true)

  if "router" in $service_plugins { $enable_router = true } else { $enable_router = false }
  if "firewall" in $service_plugins { $enable_firewall = true } else { $enable_firewall = false }
   # check for "lbaas" or "neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2"
  if "lbaas" in $service_plugins { $enable_lbaas = true } else { 
  	if "neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2" in $service_plugins { $enable_lbaas = true } else { $enable_lbaas = false } 
  }
  if "vpnaas" in $service_plugins { $enable_vpnaas = true } else { $enable_vpnaas = false }

  if $::openstack::config::enable_ssl {
	$vhost_params = { add_listen => true , ssl_chain => $::openstack::config::ssl_chainfile }
  } else {
	$vhost_params = { }
  }

  class { '::horizon':
    allowed_hosts   => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_allowed_hosts),
    server_aliases  => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_server_aliases),
    secret_key      => $::openstack::config::horizon_secret_key,
    cache_server_ip => $::openstack::config::controller_address_management,
    neutron_options => { 
        'enable_lb'                 => $enable_lbaas,
        'enable_firewall'           => $enable_firewall,
        'enable_vpn'                => $enable_vpnaas,
        'enable_distributed_router' => $enable_router
    },
    cinder_options => {
	'enable_backup'		    => $enable_backups,
    },
    vhost_extra_params    => $vhost_params,
    listen_ssl	    => $::openstack::config::enable_ssl,
    horizon_cert    => $::openstack::config::horizon_ssl_certfile,
    horizon_key     => $::openstack::config::horizon_ssl_keyfile,
    horizon_ca      => $::openstack::config::ssl_chainfile,
  }

  openstack::resources::firewall { 'Apache (Horizon)': port => '80' }
  openstack::resources::firewall { 'Apache SSL (Horizon)': port => '443' }

  if $::selinux and str2bool($::selinux) != false {
    selboolean{'httpd_can_network_connect':
      value      => on,
      persistent => true,
    }
  }

}
