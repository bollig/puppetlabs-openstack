# The profile to set up the neutron server
class openstack::profile::neutron::server {

  openstack::resources::database { 'neutron': }
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron

  $tenant_network_type           = $::openstack::config::neutron_tenant_network_type # ['gre']
  $type_drivers                  = $::openstack::config::neutron_type_drivers # ['gre']
  $mechanism_drivers             = $::openstack::config::neutron_mechanism_drivers # ['openvswitch']
  $tunnel_id_ranges              = $::openstack::config::neutron_tunnel_id_ranges # ['1:1000']
  $network_management_address = $::openstack::config::network_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  if ($::openstack::config::neutron_core_plugin == 'ml2') {
    class  { '::neutron::plugins::ml2':
      type_drivers         => $type_drivers,
      tenant_network_types => $tenant_network_type,
      mechanism_drivers    => $mechanism_drivers,
      tunnel_id_ranges     => $tunnel_id_ranges
    }
  } elsif ($::openstack::config::neutron_core_plugin == 'plumgrid') {
    $user = $::openstack::config::mysql_user_neutron
    $pass = $::openstack::config::mysql_pass_neutron
    $db_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"

    neutron_config {
      'DEFAULT/service_plugins': ensure => absent,
    }
    ->
    class { '::neutron::plugins::plumgrid':
      director_server      => $::openstack::config::plumgrid_director_vip,
      username             => $::openstack::config::plumgrid_username,
      password             => $::openstack::config::plumgrid_password,
      admin_password       => $::openstack::config::keystone_admin_password,
      controller_priv_host => $controller_management_address,
      connection           => $db_connection,
    }

    class { '::neutron::agents::metadata':
      auth_password => $::openstack::config::neutron_password,
      shared_secret => $::openstack::config::neutron_shared_secret,
      auth_url      => "http://${controller_management_address}:35357/v3",
      #auth_url      => "http://${controller_management_address}:35357",
      debug         => $::openstack::config::debug,
      auth_region   => $::openstack::config::region,
      metadata_ip   => $controller_management_address,
      enabled       => true,
    }
  }

# The following installs python-neutron-plugin packages 
#
# TODO: update puppet-neutron module to a version that does not need these
# agents configured on the Neutron-API server (the neutron::api should
# implicitly install python libraries for these deps 
   if 'network' in $node_type { 
    notify{'network': message => "Node type prevents neutron agents and services from being installed via profile/neutron/server.pp"}
   } else {
    ensure_resource('class', '::neutron::agents::l3', {
        'enabled'        => 'false',
        'manage_service' => 'false',
      })
    ensure_resource('class', '::neutron::agents::dhcp', {
        'enabled' => 'false',
      })
    ensure_resource('class', '::neutron::agents::lbaas', {
        'enabled' => 'false',
      })
    ensure_resource('class', '::neutron::agents::vpnaas', {
        'enabled' => 'false',
      })
    ensure_resource('class', '::neutron::agents::metering', {
        'enabled' => 'false',
      })
    ensure_resource('class', '::neutron::services::fwaas', {
       'enabled' => 'false',
      })
   }

  anchor { 'neutron_common_first': } ->
  class { '::neutron::server::notifications':
    nova_url            => "http://${controller_management_address}:8774/v2/",
    nova_admin_auth_url => "http://${controller_management_address}:35357/v3/",
    #nova_admin_auth_url => "http://${controller_management_address}:35357",
    nova_admin_password => $::openstack::config::nova_password,
    nova_region_name    => $::openstack::config::region,
  } ->
  anchor { 'neutron_common_last': }

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
