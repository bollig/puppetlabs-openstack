# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {

  openstack::resources::database { 'glance': }

  class  { '::glance::keystone::auth':
	password => $::openstack::config::glance_password,
	public_url   => "http://${::openstack::config::storage_address_api}:9292",
	admin_url    => "http://${::openstack::config::storage_address_management}:9292",
	internal_url => "http://${::openstack::config::storage_address_management}:9292",
	region           => $::openstack::config::region,
  }
}
