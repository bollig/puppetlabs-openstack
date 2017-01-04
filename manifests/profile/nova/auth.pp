#
class openstack::profile::nova::auth (
) {
  openstack::resources::database { 'nova': }

  $controller_management_address = $::openstack::config::controller_address_management

  class { '::nova::keystone::auth':
      password         => $::openstack::config::nova_password,
  # TODO: in subsequent versions of the puppet nova module we wont be able to
  # specify public_address. Use public_uri, or public_url and ec2_public_url
      public_address   => $::openstack::config::controller_address_api,
      internal_address => $::openstack::config::controller_address_management,
      admin_address    => $::openstack::config::controller_address_management,
  # TODO: if needed replace the following 3 lines with public_uri
      public_protocol  => $::openstack::config::http_protocol, 
      admin_protocol  => $::openstack::config::http_protocol, 
      internal_protocol  => $::openstack::config::http_protocol, 
      public_url_v3    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v3",
      internal_url_v3  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      admin_url_v3     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      public_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v2",
      internal_url  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2",
      admin_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2",
      region           => $::openstack::config::region,
  }
}

