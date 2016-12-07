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
  $enable_shib_domain               = false,
  $shib_applicationId               = 'default',
  $shib_protocol                    = 'saml2',
  $shib_require_authnContext        = false,
  $shib_authnContext                = $::os_service_default,
  $enable_twofactor                 = false,
  $twofactor_protocol               = $::os_service_default,
  $twofactor_authnContext           = $::os_service_default,
  $trusted_dashboard                = 'http://localhost/dashboard/auth/websso/',
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
    admin_tenant => 'admin',
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
      identity_driver              => 'ldap',
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
      #"${ldap_user_domain}::identity/driver": value => 'ldap';
      #"${ldap_user_domain}::assignment/driver": value => 'sql';
      "${ldap_user_domain}::ldap/group_members_are_ids": value => 'True';
    }
  }

  if $enable_shib_domain == true {

    if $::osfamily == 'Redhat' {
      # Note: The yumrepo part is only necessary if you are using RedHat.
      # Yumrepo begin
      yumrepo { 'shibboleth':
        name     => 'Shibboleth',
        baseurl  => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/',
        descr    => 'Shibboleth repo for RedHat',
        gpgcheck => 1,
        gpgkey   => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/repodata/repomd.xml.key',
        enabled  => 1,
        require  => Anchor['openstack_extras_redhat']
      }
                   
      Yumrepo['shibboleth'] -> Class['::keystone::federation::shibboleth']
      # Yumrepo end
    }


    class { 'keystone::federation::shibboleth': 
      #methods => ['password', 'token', 'oauth1', 'saml2'],
      methods => ['password', 'token', $shib_protocol, $twofactor_protocol],
      main_port => true,
      admin_port => false,
      suppress_warning => true,
      # Match the name of the yumrepo above:
      yum_repo_name => 'shibboleth',
    }

    service { 'shibd': 
      enable => true,
      ensure => 'running', 
      require => Package['shibboleth'],
    }

    # References: http://docs.openstack.org/developer/keystone/federation/websso.html
    keystone_config { 
      'federation/remote_id_attribute': value => 'Shib-Identity-Provider'; 
      'saml2/remote_id_attribute': value => 'Shib-Identity-Provider'; 
      'saml/remote_id_attribute': value => 'Shib-Identity-Provider'; 
      'federation/trusted_dashboard': value => $trusted_dashboard;
    }

    concat::fragment { 'configure_common_saml2_on_port_5000':
        target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        content => template('openstack/shibboleth_common.conf.erb'),
        order   => 331,
    }
   
    concat::fragment { 'configure_saml2_on_port_5000':
        target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
        content => template('openstack/shibboleth.conf.erb'),
        order   => 332,
    }
 
    if $enable_twofactor {   
      concat::fragment { 'configure_twofactor_saml2_on_port_5000':
          target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_main.conf",
          content => template('openstack/shibboleth_twofactor.conf.erb'),
          order   => 333,
      }
      keystone_config { 
        "${twofactor_protocol}/remote_id_attribute": value => 'Shib-Identity-Provider'; 
        "auth/${twofactor_protocol}": value => 'keystone.auth.plugins.mapped.Mapped';
      }
    }

#
#    concat::fragment { 'configure_saml2_on_port_35357':
#        target  => "${keystone::wsgi::apache::priority}-keystone_wsgi_admin.conf",
#        content => template('openstack/shibboleth.conf.erb'),
#        order   => 332,
#    }


    # Once the above runs, to complete shibboleth configuration, we still need
    # to register the ID Provider in Keystone, with a proper Protocol specified
    # (saml2), and associate a proper Mapping of saml user data to keystone user
    # data. 
    # Following  https://bigjools.wordpress.com/2015/05/22/saml-federation-with-openstack/
    # 
    # ## Default group for SAML users to join
    #   openstack group create samlusers
    #   openstack role add --project demo --group samlusers _member_
    # ## ID Provider
    #   openstack identity provider create testshib
    # ## Mapping
    #   group_id=`openstack group list|grep samlusers|awk '{print $2}'`
    #   cat add-mapping.json|sed s^GROUP_ID^$group_id^ > /tmp/mapping.json
    #   openstack mapping create --rules /tmp/mapping.json saml_mapping
    # ## Protocol
    #   openstack federation protocol create --identity-provider testshib --mapping saml_mapping saml2
    # ## Associated Mapping
    #   openstack identity provider set --remote-id <your entity ID /idp/profiles/shibboleth> testshib       
    

  }

}
