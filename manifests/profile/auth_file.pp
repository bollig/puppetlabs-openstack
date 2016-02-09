# The profile to install an OpenStack specific mysql server
class openstack::profile::auth_file {
  class { '::openstack_extras::auth_file':
    tenant_name => 'admin',
    password    => $::openstack::config::keystone_admin_password,
    auth_url    => "http://${::openstack::config::controller_address_api}:5000/v3/",
    #auth_url    => "http://${::openstack::config::controller_address_api}:5000",
    region_name => $::openstack::config::region,
# TODO: update puppet-openstack_extras module to version that supports adding
# v3 creds to /root/openrc (and creating additional openrc files for other
# users). Missing in this version: OS_USER_DOMAIN_NAME and
# OS_PROJECT_DOMAIN_NAME
  }
}
