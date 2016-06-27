# Common class for neutron installation
# Private, and should not be used on its own
# Sets up configuration common to all neutron nodes.
# Flags install individual services as needed
# This follows the suggest deployment from the neutron Administrator Guide.
class openstack::common::neutron (
  $enable_service = false,
) {

# What it does: https://access.redhat.com/solutions/53031
# See http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty&f=13
  ::sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value     => '0',
  }
  ::sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value     => '0',
  }



  $controller_management_address = $::openstack::config::controller_address_management

  $data_network = $::openstack::config::network_data
  $data_address = ip_for_network($data_network)

  # neutron auth depends upon a keystone configuration
  include ::openstack::common::keystone
  class { '::vswitch::ovs': }


# Base Neutron config. No server, no agents. 
  class { '::neutron':
    rabbit_host           => $controller_management_address,
    core_plugin           => $::openstack::config::neutron_core_plugin,
    allow_overlapping_ips => true,
    rabbit_user           => $::openstack::config::rabbitmq_user,
    rabbit_password       => $::openstack::config::rabbitmq_password,
    rabbit_hosts          => $::openstack::config::rabbitmq_hosts,
    debug                 => $::openstack::config::debug,
    verbose               => $::openstack::config::verbose,
    service_plugins       => $::openstack::config::neutron_service_plugins,
  }

# Base Neutron authentication config (pointing to Keystone)
  class { '::neutron::keystone::auth':
    password         => $::openstack::config::neutron_password,
    public_url       => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:9696",
    admin_url        => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:9696",
    internal_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:9696",
    region           => $::openstack::config::region,
  }


  $user                = $::openstack::config::mysql_user_neutron
  $pass                = $::openstack::config::mysql_pass_neutron
  $database_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"

    # Neutron API
  class { '::neutron::server':
    auth_uri            => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    auth_url            => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    identity_uri        => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
    auth_password       => $::openstack::config::neutron_password,
    database_connection => $database_connection,
    enabled             => $enable_service,
    sync_db             => $enable_service,
    service_providers => ['LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default'],
#'LOADBALANCERV2:Octavia:neutron_lbaas.drivers.octavia.driver.OctaviaDriver:default'],
#        'LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver',
#        'VPN:openswan:neutron_vpnaas.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default'

    #mysql_module        => '2.2',
  }


  if $::osfamily == 'redhat' {
    package { 'iproute':
        ensure => latest,
        before => Class['::neutron']
    }
  }
}
