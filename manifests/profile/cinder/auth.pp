# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::cinder::auth {

  # TODO: this auth could be through the storage_address_api or
  # storage_address_management, but we'd need to ensure the Cinder::API is also
  # distributed via the storage role, not the control role
  class { '::cinder::keystone::auth':
    password         => $::openstack::config::cinder_password,
    public_url   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8776",
    admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776",
    internal_url => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776",
    region           => $::openstack::config::region,
  }

}
