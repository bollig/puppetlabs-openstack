# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {

  openstack::resources::database { 'glance': }

  class  { '::glance::keystone::auth':
	password => $::openstack::config::glance_password,
	# TODO: enable http_protocol when glance supports SSL
	#public_url   => "http://${::openstack::config::storage_address_api}:9292",
	#admin_url    => "http://${::openstack::config::storage_address_management}:9292",
	#internal_url => "http://${::openstack::config::storage_address_management}:9292",
	public_url   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:9292",
	admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:9292",
	internal_url => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:9292",
	region           => $::openstack::config::region,
	configure_endpoint => true,
	# endpoint service name (defaults to Image Service)
	service_name => 'glance',
  }

  $images = $::openstack::config::images

  create_resources('glance_image', $images)
}

