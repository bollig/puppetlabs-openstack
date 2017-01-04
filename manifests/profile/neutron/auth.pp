# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::neutron::auth {

  # Defines ::neutron::db::mysql
  openstack::resources::database { 'neutron': }

# Base Neutron authentication config (pointing to Keystone)
  class { '::neutron::keystone::auth':
    password         => $::openstack::config::neutron_password,
# TODO: when neutron supports chain files and/or wsgi, enable ssl: 
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:9696",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:9696",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:9696",
    region           => $::openstack::config::region,
  }

}
