# Common class for neutron installation
# Private, and should not be used on its own
# Sets up configuration common to all neutron nodes.
# Flags install individual services as needed
# This follows the suggest deployment from the neutron Administrator Guide.
class openstack::common::neutron (
  $enable_service = false,
) {

  if $enable_service {
	if $::openstack::config::enable_ssl {
	# TODO: when neutron has a wsgi api class available disable eventlet
	# and switch name to httpd, then add neutron::wsgi::apache config
		$enable_api_eventlet = true
		$service_name = 'neutron-server'
	} else {
		$enable_api_eventlet = true
		$service_name = 'neutron-server'
	}
  } else {
	$enable_api_eventlet = false
	$service_name = 'neutron-server'
  }

# What it does: https://access.redhat.com/solutions/53031
# See http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty&f=13
  ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }
  ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }



  $controller_management_address = $::openstack::config::controller_address_management

  $data_network = $::openstack::config::network_data
  $data_address = ip_for_network($data_network)

  # neutron auth depends upon a keystone configuration
  #include ::openstack::common::keystone
  class { '::vswitch::ovs': }


# Base Neutron config. No server, no agents. 
  class { '::neutron':
    rabbit_host           => $controller_management_address,
    core_plugin           => $::openstack::config::neutron_core_plugin,
    allow_overlapping_ips => true,
    rabbit_user           => $::openstack::config::rabbitmq_user,
    rabbit_password       => $::openstack::config::rabbitmq_password,
    rabbit_hosts          => $::openstack::config::rabbitmq_hosts,
    debug                 => $::openstack::config::debug,
    verbose               => $::openstack::config::verbose,
    service_plugins       => $::openstack::config::neutron_service_plugins,
    bind_host => '127.0.0.1',
# NOTE: http://miroslav.suchy.cz/blog/archives/2015/03/05/how_to_enable_ssl_for_neutron_and_other_openstack_services/index.html
# https://github.com/Juniper/contrail-controller/wiki/SSL-configuration-for-API,-neutron-server-and-openstack-keystone-in-Contrail
# --> Neutron SSL is buggy. 
# This might help: https://github.com/rcbops-cookbooks/glance/blob/fd73f48b13f25e285f48bcbe93f35db5ec20f036/files/default/api_modwsgi.py
#    use_ssl               => $::openstack::config::enable_ssl,
#    cert_file             => $::openstack::config::keystone_ssl_certfile,
#    key_file              => $::openstack::config::keystone_ssl_keyfile,
	 # ca_file can be either the CA file or Chain File
#    ca_file               => $::openstack::config::ssl_chainfile,
  }


  $user                = $::openstack::config::mysql_user_neutron
  $pass                = $::openstack::config::mysql_pass_neutron
  $database_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"

  if 'vpnaas' in $::openstack::config::neutron_service_plugins {
    $ensure_vpnaas_pkg = true
  } else {
    $ensure_vpnaas_pkg = false
  }

  if "neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2" in $::openstack::config::neutron_service_plugins or 'lbaas' in $::openstack::config::neutron_service_plugins {
    $ensure_lbaas_pkg = true
  } else {
    $ensure_lbaas_pkg = false
  }

    # Neutron API
  class { '::neutron::server':
    auth_uri            => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    auth_url            => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    identity_uri        => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
    auth_password       => $::openstack::config::neutron_password,
    database_connection => $database_connection,
    enabled             => $enable_api_eventlet,
    #service_name 	=> $service_name,
    sync_db             => $enable_service,
    service_providers => ['LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default'],
    ensure_vpnaas_package => $ensure_vpnaas_pkg,
    ensure_fwaas_package  => false,
    ensure_lbaas_package  => $ensure_lbaas_pkg,
  }

  # Note: bug in the neutron module. The neutron-fwaas package can either be installed by the 
  # class { '::neutron::services::fwaas': } or by ensure_fwaas_package above. They can not both be used though.
  # This ensure makes the fwaas package is present and does not conflict with the other driver
  ensure_resource( 'package', 'neutron-fwaas', {
      'name'   => 'openstack-neutron-fwaas',
      'ensure' => 'present',
      'tag'    => 'openstack'
  })

  # This is a HUGE hack. The Neutron puppet module does not include a
  # wsgi::apache.pp class yet. I adapted from the nova class to ensure we are
  # consistently using wsgi endpoints for our apis. 
  #class { '::openstack::profile::neutron::wsgi_apache':
  #    ssl             => $::openstack::config::enable_ssl,
  #    ssl_cert        => $::openstack::config::keystone_ssl_certfile,
  #    ssl_key         => $::openstack::config::keystone_ssl_keyfile,
  #    ssl_chain       => $::openstack::config::ssl_chainfile,
  #    #ssl_ca          => $::openstack::config::ssl_chainfile,
  #    workers         => 2
  #}



  if $::osfamily == 'redhat' {
    package { 'iproute':
        ensure => latest,
        before => Class['::neutron']
    }
  }
}
