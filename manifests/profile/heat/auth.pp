class openstack::profile::heat::auth (
) {
  openstack::resources::database { 'heat': }

  $controller_management_address = $::openstack::config::controller_address_management
  $user                          = $::openstack::config::mysql_user_heat
  $pass                          = $::openstack::config::mysql_pass_heat
  $database_connection           = "mysql://${user}:${pass}@${controller_management_address}/heat"


  class { '::heat::keystone::auth':
    password         => $::openstack::config::heat_password,
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8004/v1/%(tenant_id)s",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8004/v1/%(tenant_id)s",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8004/v1/%(tenant_id)s",
    region           => $::openstack::config::region,

#NOTE: this is required to create the heat_stack_owner role. This role is
# required to allow users to create orchestration stacks. Option will default
# to true in Mitaka or later
    configure_delegated_roles => true,
  }

  class { '::heat::keystone::auth_cfn':
    password         => $::openstack::config::heat_password,
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_api}:8000/v1",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8000/v1",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::storage_address_management}:8000/v1",
    region           => $::openstack::config::region,
  }

}
