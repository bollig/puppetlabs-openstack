# The profile to install the Keystone service
class openstack::profile::keystone {

  openstack::resources::database { 'keystone': }
  openstack::resources::firewall { 'Keystone Public and Internal API': port => '5000', }
  openstack::resources::firewall { 'Keystone Admin API': port => '35357', }

  class { '::openstack::common::keystone': enable_service => true }

  class { '::keystone::cron::token_flush': }
  #class { '::keystone::db::mysql':
  #    password => 'keystone',
  #}

  class { '::keystone::roles::admin':
    email        => $::openstack::config::keystone_admin_email,
    password     => $::openstack::config::keystone_admin_password,
    #admin_tenant => 'admin',
  }

  class { 'keystone::endpoint':
    public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:5000",
    admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357",
    internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    region       => $::openstack::config::region,
# If set to '' then the API version is detected at runtime
    #version      => 'v3',
  }


  if $::openstack::config::keystone_use_httpd == true {
    include ::apache
    class { '::keystone::wsgi::apache':
      ssl             => $::openstack::config::enable_ssl,
      ssl_cert        => $::openstack::config::keystone_ssl_certfile,
      ssl_key         => $::openstack::config::keystone_ssl_keyfile,
      ssl_chain       => $::openstack::config::ssl_chainfile,
      #ssl_ca          => $::openstack::config::ssl_chainfile,
      workers         => 2
    }
  }

  class { '::keystone::disable_admin_token_auth': }

  $domains = $::openstack::config::keystone_domains
  $tenants = $::openstack::config::keystone_tenants
  $users   = $::openstack::config::keystone_users

  create_resources('openstack::resources::domain', $domains)
  create_resources('openstack::resources::tenant', $tenants)
  create_resources('openstack::resources::user', $users)

}
