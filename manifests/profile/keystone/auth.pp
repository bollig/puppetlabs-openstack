# The profile to install the Keystone service
class openstack::profile::keystone::auth(
) {

  openstack::resources::database { 'keystone': }

  class { '::keystone::roles::admin':
    email        => $::openstack::config::keystone_admin_email,
    password     => $::openstack::config::keystone_admin_password,
    admin_tenant => 'admin',
    require      => Class['::openstack::common::keystone']
  }

  #class { '::keystone::disable_admin_token_auth': require => Class[ '::keystone::endpoint'] }
  class { '::keystone::disable_admin_token_auth': } # require => Class[ '::keystone::endpoint'] }

  class { 'keystone::endpoint':
    public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:5000",
    admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
    internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    region       => $::openstack::config::region,
# If set to '' then the API version is detected at runtime
    #version      => 'v3',
    version      => '',
    require      => Class['::openstack::common::keystone']
  }

  $domains = $::openstack::config::keystone_domains
  $tenants = $::openstack::config::keystone_tenants
  $users   = $::openstack::config::keystone_users

  create_resources('openstack::resources::domain', $domains)
  create_resources('openstack::resources::tenant', $tenants)
  create_resources('openstack::resources::user', $users)
 
} 
