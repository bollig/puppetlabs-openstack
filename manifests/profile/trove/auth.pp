# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::trove::auth {

  # TODO: this auth could be through the storage_address_api or
  # storage_address_management, but we'd need to ensure the Trove::API is also
  # distributed via the storage role, not the control role
  class { '::trove::keystone::auth':
    password         => $::openstack::config::trove_password,
    public_address   => $::openstack::config::storage_address_api,
    admin_address    => $::openstack::config::storage_address_management,
    internal_address => $::openstack::config::storage_address_management,
    region           => $::openstack::config::region,
  }

}
