# Profile to install the horizon web service
# user_domain => This is the default domain for users to authenticate. Override with hiera to match the ldap domain 
class openstack::profile::horizon ( 
  $session_timeout = 1800,
  $multi_domain_support = false,
  $user_domain = 'default',
  $enable_shib_openrc = false,
  $shib_ecp_idp_url = 'http://localhost/idp/profile/shibboleth',
) {
  $service_plugins  = $::openstack::config::neutron_service_plugins
  $enable_backups   = pick($::openstack::config::cinder_enable_backup, true)

  if "router" in $service_plugins { $enable_router = true } else { $enable_router = false }
  if "firewall" in $service_plugins { $enable_firewall = true } else { $enable_firewall = false }
   # check for "lbaas" or "neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2"
  if "lbaas" in $service_plugins { $enable_lbaas = true } else { 
  	if "neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2" in $service_plugins { $enable_lbaas = true } else { $enable_lbaas = false } 
  }
  if "vpnaas" in $service_plugins { $enable_vpnaas = true } else { $enable_vpnaas = false }

  if $::openstack::config::enable_ssl {
	$vhost_params = { add_listen => true , ssl_chain => $::openstack::config::ssl_chainfile }
  } else {
	$vhost_params = { }
  }

  class { '::horizon':
    keystone_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000",
    keystone_multidomain_support => $multi_domain_support,
    keystone_default_domain      => $user_domain,
    allowed_hosts   => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_allowed_hosts),
    server_aliases  => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_server_aliases),
    secret_key      => $::openstack::config::horizon_secret_key,
    cache_server_ip => $::openstack::config::controller_address_management,
    cache_backend   => "django.core.cache.backends.memcached.MemcachedCache",
    secure_cookies  => true,
    session_timeout => $session_timeout,
    neutron_options => { 
        'enable_lb'                 => $enable_lbaas,
        'enable_firewall'           => $enable_firewall,
        'enable_vpn'                => $enable_vpnaas,
        'enable_distributed_router' => $enable_router
    },
    cinder_options => {
	'enable_backup'		    => $enable_backups,
    },
    vhost_extra_params    => $vhost_params,
    listen_ssl	    => $::openstack::config::enable_ssl,
    horizon_cert    => $::openstack::config::horizon_ssl_certfile,
    horizon_key     => $::openstack::config::horizon_ssl_keyfile,
    horizon_ca      => $::openstack::config::ssl_chainfile,
  }

  openstack::resources::firewall { 'Apache (Horizon)': port => '80' }
  openstack::resources::firewall { 'Apache SSL (Horizon)': port => '443' }

  if $::selinux and str2bool($::selinux) != false {
    exec { "fcontext_openstack-dashboard":
        command => "semanage fcontext -a -t httpd_var_run_t '/usr/share/openstack-dashboard(/.*)?' && restorecon -R /usr/share/openstack-dashboard",
        path    => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        require => [Package['openstack-selinux'],Package['horizon'],Package['policycoreutils-python']],
        before  => Exec['refresh_horizon_django_cache'],
        unless  => "test -b /usr/share/openstack-dashboard || (semanage fcontext -l | grep /usr/share/openstack-dashboard)",
    }
  }

  # Override the openrc to get OS_TOKEN support out of box
  file { 'V3 OpenRC':
    path    => '/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/access_and_security/templates/access_and_security/api_access/openrc.sh.template',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    #source  => "puppet:///modules/openstack/openrc.sh.template",
    content => template('openstack/openrc_shib.sh.erb'),
    require => Class['::horizon']
  } 

  # Override the openrc to get OS_TOKEN support out of box
  # NOTE: v2 is no longer truly V2 authentication. In order to support domains,
  # we have to bump everything to v3. This override intentionally uses the same
  # template as the v3 version
  #file { 'V2 OpenRC':
  #  path    => '/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/access_and_security/templates/access_and_security/api_access/openrc_v2.sh.template',
  #  owner   => 'root',
  #  group   => 'root',
  #  mode    => '0644',
  #  content => template('openstack/openrc.sh.erb'),
  #  before => Exec['refresh_horizon_django_cache'],
  #} 


  # Disable v2.0 OpenRC files. This is to guarantee all users authenticate with v3 and the right domains
  file_line { 'Disable OpenStack RC File v2.0':
    path => '/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/access_and_security/api_access/tables.py',
    match => '        table_actions = \(DownloadOpenRCv2, DownloadOpenRC, DownloadEC2,.*',
    line => '        table_actions = ( DownloadOpenRC, DownloadEC2, ',
    require => Class['::horizon']
  } 



  # NOTE: this removes the Consistency Groups tab which is a feature not supported by CEPH RBD 
  file_line { 'Disable consistency groups tab':
    path => '/usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/volumes/tabs.py',
    match => '.*, CGroupsTab\)',
    line => '    tabs = (VolumeTab, SnapshotTab, BackupsTab) #, CGroupsTab)',
    require => Class['::horizon']
  }

}
