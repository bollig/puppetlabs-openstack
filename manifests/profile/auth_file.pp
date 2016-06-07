# The profile to install an OpenStack specific mysql server
class openstack::profile::auth_file {
  #class { '::openstack_extras::auth_file':
  #  tenant_name => 'admin',
  #  password    => $::openstack::config::keystone_admin_password,
  #  auth_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:5000/v3/",
  #  #auth_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:5000",
  #  region_name => $::openstack::config::region,
# #TODO: update puppet-openstack_extras module to version that supports adding
# v3 creds to /root/openrc (and creating additional openrc files for other
# #users). Missing in this version: OS_USER_DOMAIN_NAME and
# OS_PROJECT_DOMAIN_NAME
  #}

  class { '::openstack_extras::auth_file':
    #password       => $::openstack::config::msyql_pass_keystone,
    password    => $::openstack::config::keystone_admin_password,
    tenant_name => 'admin',
    project_name => 'admin',
    project_domain => 'default',
    user_domain    => 'default',
    region_name => $::openstack::config::region,
    auth_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:5000/v3/",
  }
}
