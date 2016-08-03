# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class openstack::profile::glance::api (
	$cert_chain_bundle  = undef,
) {
  $api_network = $::openstack::config::network_api
  $api_address = ip_for_network($api_network)

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $controller_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_glance
  $pass                = $::openstack::config::mysql_pass_glance
  $database_connection = "mysql://${user}:${pass}@${controller_address}/glance"

  openstack::resources::firewall { 'Glance API (Test)': port      => '9293', }
  openstack::resources::firewall { 'Glance Registry (Test)': port => '9192', }
  openstack::resources::firewall { 'Glance API': port      => '9292', }
  openstack::resources::firewall { 'Glance Registry': port => '9191', }

# Triggers the glance::api
  $enable_wsgi = false
  $enable_haproxy = true
  $api_port = '9292'
  $registry_port = '9191'

  if $enable_wsgi { 
	$enable_api_service = false
	$enable_registry_service = false
	$bind_host = '0.0.0.0'
  }
  else {
	$enable_api_service = true
	$enable_registry_service = true

  	if $enable_haproxy {
		$bind_host = '127.0.0.1'
		$registry_host = '127.0.0.1'
  	}
  	else {
		$bind_host = '0.0.0.0'
	}
  }

  class {'::openstack::common::glance': 
	enable_service => $enable_api_service,
	# NOTE: only override registry port if haproxy is not in use and user-facing service endpoint is not 9191 
	#registry_port  => $registry_port,
	api_bind_host => $bind_host,
	api_port => $api_port,
  }

  #include ::openstack::common::glance


  class { '::glance::registry':
    keystone_password   => $::openstack::config::glance_password,
    database_connection => $database_connection,
    identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
    auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled 		=> $enable_registry_service,
    #TODO: test this
    bind_host	 	=> $bind_host,
    bind_port	 	=> $registry_port,
  }

  if $enable_wsgi {
	  ::openstack::profile::glance::wsgi_apache { 'glance-api_wsgi':
	      wsgi_service_name => 'glance-api',
	      api_port 		=> $api_port, 
	      ssl             => $::openstack::config::enable_ssl,
	      ssl_cert        => $::openstack::config::keystone_ssl_certfile,
	      ssl_key         => $::openstack::config::keystone_ssl_keyfile,
	      ssl_chain       => $::openstack::config::ssl_chainfile,
	      #ssl_ca          => $::openstack::config::ssl_chainfile,
	      workers         => 2,
	      notify => Service['httpd'],
	  }
	  ::openstack::profile::glance::wsgi_apache { 'glance-registry_wsgi':
	      wsgi_service_name => 'glance-registry',
	      api_port 		=> $registry_port, 
	      ssl             => $::openstack::config::enable_ssl,
	      ssl_cert        => $::openstack::config::keystone_ssl_certfile,
	      ssl_key         => $::openstack::config::keystone_ssl_keyfile,
	      ssl_chain       => $::openstack::config::ssl_chainfile,
	      #ssl_ca          => $::openstack::config::ssl_chainfile,
	      workers         => 2,
	      notify => Service['httpd'],
	  }
  }

  if $enable_haproxy {
	include ::openstack::profile::haproxy::init
	include ::openstack::profile::haproxy::glance
#	haproxy::listen { 'glance-api-in':
# 	  bind => {
#	    # binding to a specific address, so the underlying service can bind to same port on localhost
#	    "$::ipaddress:9292"	=> ['ssl', 'crt', $cert_chain_bundle],
#	  },
#	}
#	haproxy::listen { 'glance-registry-in':
# 	  bind => {
#	    "$::ipaddress:9191"	=> ['ssl', 'crt', $cert_chain_bundle],
#	  },
#	}
#	haproxy::balancermember { 'glance-api-01':
#	  listening_service => 'glance-api-in',
#	  ipaddresses => '127.0.0.1',
#	  ports     => $api_port,
#	  options   => '',
#	}
#	haproxy::balancermember { 'glance-registry-01':
#	  listening_service => 'glance-registry-in',
#	  ipaddresses => '127.0.0.1',
#	  ports     => $registry_port,
#	  options   => '',
#	}
  }

  class { '::glance::notify::rabbitmq':
    rabbit_password => $::openstack::config::rabbitmq_password,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_host     => $::openstack::config::controller_address_management,
  }

  $images = $::openstack::config::images

  create_resources('glance_image', $images)
}
