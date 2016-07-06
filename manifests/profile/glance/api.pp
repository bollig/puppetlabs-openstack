# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class openstack::profile::glance::api {
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

  if $enable_wsgi { 
	$enable_api_service = false
	$enable_registry_service = false
	$api_port = '9292'
	$registry_port = '9191'
  } else {
	$enable_api_service = true
	$enable_registry_service = true
	$api_port = '9292'
	$registry_port = '9191'
	$enable_haproxy = false
  }

  class {'::openstack::common::glance': 
	enable_service => $enable_api_service,
	api_port       => $api_port,
	registry_port  => $registry_port,
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
    #mysql_module        => '2.2',
  }

  if $enable_wsgi {
	  ::openstack::profile::glance::wsgi_apache { 'glance-api_wsgi':
	      wsgi_service_name => 'glance-api',
	      api_port 		=> '9293', 
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
	      api_port 		=> '9192', 
	      ssl             => $::openstack::config::enable_ssl,
	      ssl_cert        => $::openstack::config::keystone_ssl_certfile,
	      ssl_key         => $::openstack::config::keystone_ssl_keyfile,
	      ssl_chain       => $::openstack::config::ssl_chainfile,
	      #ssl_ca          => $::openstack::config::ssl_chainfile,
	      workers         => 2,
	      notify => Service['httpd'],
	  }
  }

  class { '::glance::notify::rabbitmq':
    rabbit_password => $::openstack::config::rabbitmq_password,
    rabbit_userid   => $::openstack::config::rabbitmq_user,
    rabbit_host     => $::openstack::config::controller_address_management,
  }

  $images = $::openstack::config::images

  create_resources('glance_image', $images)
}
