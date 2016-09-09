# The profile to install the Keystone service
class openstack::profile::keystone (
  $enable_ldap_domain               = false,
  $ldap_user_domain                 = 'default',
  $ldap_urls                        = undef,
  $ldap_query_scope                 = 'one',
  $ldap_user_tree_dn                = undef,
  $ldap_user_id_attribute           = 'uid',
  $ldap_user_objectclass            = 'person',
  $ldap_user_name_attribute         = 'cn',
  $ldap_user_mail_attribute         = 'mail',
  $ldap_user_desc_attribute         = 'description',
  $ldap_group_tree_dn               = undef,
  $ldap_group_objectclass           = 'posixGroup',
  $ldap_group_id_attribute          = 'gid',
  $ldap_group_name_attribute        = 'cn',
  $ldap_group_member_attribute      = 'member',
  $ldap_group_desc_attribute        = 'description',
  $ldap_use_tls                     = 'True',
  $ldap_tls_req_cert                = 'ask',
  $ldap_use_pool                    = 'True',
  $ldap_use_auth_pool               = 'True',
  $ldap_pool_size                   = 5,
  $ldap_auth_pool_size              = 5,
  $ldap_pool_retry_max              = 3,
  $ldap_pool_connection_timeout     = 120,
) {

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
 
  if $enable_ldap_domain == true {
    keystone_domain { "${ldap_user_domain}": ensure => present }
    keystone::ldap_backend { "${ldap_user_domain}":
      url                          => $ldap_urls,
      #user                         => '',
      #password                     => 'SecretPass',
      #suffix                       => 'dc=example,dc=com',
      query_scope                  => $ldap_query_scope,
      user_tree_dn                 => $ldap_user_tree_dn,
      user_id_attribute            => $ldap_user_id_attribute,
      user_objectclass             => $ldap_user_objectclass,
      user_name_attribute          => $ldap_user_name_attribute,
      user_mail_attribute          => $ldap_user_mail_attribute,
      user_allow_create            => 'False',
      user_allow_update            => 'False',
      user_allow_delete            => 'False',
      user_enabled_emulation       => 'False',
      group_tree_dn                => $ldap_group_tree_dn,
      group_objectclass            => $ldap_group_objectclass,
      group_id_attribute           => $ldap_group_id_attribute,
      group_name_attribute         => $ldap_group_name_attribute,
      group_member_attribute       => $ldap_group_member_attribute,
      group_allow_create           => 'False',
      group_allow_update           => 'False',
      group_allow_delete           => 'False',
      # This sets the default driver
      identity_driver              => 'sql',
      assignment_driver            => 'sql',
      # This conflicts with the ldaps:// in URL
      use_tls                      => $ldap_use_tls,
      tls_req_cert                 => $ldap_tls_req_cert,
      use_pool                     => $ldap_use_pool,
      use_auth_pool                => $ldap_use_auth_pool,
      pool_size                    => $ldap_pool_size,
      auth_pool_size               => $ldap_auth_pool_size,
      pool_retry_max               => $ldap_pool_retry_max,
      pool_connection_timeout      => $ldap_pool_connection_timeout,
    } ->
    # Plus extra configs necessary for Mitaka
    keystone_domain_config {
      # Default domain is defined in SQL: 
      "${ldap_user_domain}::identity/driver": value => 'ldap';
      "${ldap_user_domain}::assignment/driver": value => 'sql';
      "${ldap_user_domain}::ldap/group_members_are_ids": value => 'True';
    }
  }

}
