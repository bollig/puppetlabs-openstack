# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::cinder::auth {

  # TODO: this auth could be through the storage_address_api or
  # storage_address_management, but we'd need to ensure the Cinder::API is also
  # distributed via the storage role, not the control role
  class { '::cinder::keystone::auth':
    password         => $::openstack::config::cinder_password,
    public_url   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8776/v1/%(tenant_id)s",
    admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v1/%(tenant_id)s",
    internal_url => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v1/%(tenant_id)s",
    password_user_v2      => $::openstack::config::cinder_password,
    public_url_v2   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8776/v2/%(tenant_id)s",
    admin_url_v2    => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v2/%(tenant_id)s",
    internal_url_v2 => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v2/%(tenant_id)s",
    configure_user_v2 => true,
    configure_user_role_v2 => true,
    password_user_v3      => $::openstack::config::cinder_password,
    public_url_v3   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8776/v3/%(tenant_id)s",
    admin_url_v3   => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8776/v3/%(tenant_id)s",
    region           => $::openstack::config::region,
    configure_user_v3 => true,
    configure_user_role_v3 => true,
  }

}
