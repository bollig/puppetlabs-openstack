# The profile to set up the Nova controller (several services)
class openstack::profile::nova::api {

  $controller_management_address = $::openstack::config::controller_address_management

  openstack::resources::database { 'nova': }
  openstack::resources::firewall { 'Nova API': port => '8774', }
  openstack::resources::firewall { 'Nova Metadata': port => '8775', }
  openstack::resources::firewall { 'Nova EC2': port => '8773', }
  openstack::resources::firewall { 'Nova S3': port => '3333', }
  openstack::resources::firewall { 'Nova novnc': port => '6080', }

  class { '::nova::keystone::auth':
    password         => $::openstack::config::nova_password,
# TODO: in subsequent versions of the puppet nova module we wont be able to
# specify public_address. Use public_uri, or public_url and ec2_public_url
    public_address   => $::openstack::config::controller_address_api,
    internal_address => $::openstack::config::controller_address_management,
    admin_address    => $::openstack::config::controller_address_management,
# TODO: if needed replace the following 3 lines with public_uri
    public_url_v3    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v3",
    internal_url_v3  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
    admin_url_v3     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
    region           => $::openstack::config::region,
  }

  include ::openstack::common::nova

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    identity_uri                         => "${::openstack::config::http_protocol}://${controller_management_address}:35357/",
    auth_uri                         => "${::openstack::config::http_protocol}://${controller_management_address}:5000/",
    osapi_v3                             => true,
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    enabled                              => true,
    default_floating_pool                => 'public' 
  }

  class { '::nova::compute::neutron': }

  class { '::nova::vncproxy':
    host    => $::openstack::controller_address_api,
    enabled => true,
  }

  class { [
    'nova::scheduler',
    'nova::objectstore',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true
  }
  class { 'nova::scheduler::filter': 
	cpu_allocation_ratio => "4.0",
	ram_allocation_ratio => "1.2",
  }
}
