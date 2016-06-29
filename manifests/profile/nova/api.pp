# The profile to set up the Nova controller (several services)
class openstack::profile::nova::api (
	$nova_use_httpd = true,
) {

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

  include ::openstack::common::nova


 # NOTE: (from Upgrade Notes on
 # http://docs.openstack.org/releasenotes/nova/unreleased.html): During an
 # upgrade to Mitaka, operators must create and initialize a database for the
 # API service. Configure this in [api_database]/connection, and then run
 # nova-manage api_db sync

  class { '::nova::db::mysql_api':
    user 	  => "${::openstack::config::mysql_user_nova}_api",
    dbname 	  => "${::openstack::config::mysql_user_nova}_api",
    password 	  => $::openstack::config::mysql_pass_nova,
    allowed_hosts => $::openstack::config::mysql_allowed_hosts,
  } 

  #openstack::resources::database_grant { $real_allowed_hosts:
#	user => 'nova',
# 	password_hash => $::openstack::config::nova_password,	
#	dbname => "nova_api",
#	require       => Anchor['database-service'],
#  }

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    identity_uri                         => "${::openstack::config::http_protocol}://${controller_management_address}:35357/",
    auth_uri                             => "${::openstack::config::http_protocol}://${controller_management_address}:5000/",
    osapi_v3                             => true,
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    default_floating_pool                => 'public',
    sync_db_api                          => true,
    service_name                         => 'httpd',
    enabled                              => true,
  }

  if $nova_use_httpd == true {
    include ::apache
    class { '::nova::wsgi::apache':
      ssl             => $::openstack::config::enable_ssl,
      ssl_cert        => $::openstack::config::nova_ssl_certfile,
      ssl_key         => $::openstack::config::nova_ssl_keyfile,
      ssl_chain       => $::openstack::config::ssl_chainfile,
      #ssl_ca          => $::openstack::config::ssl_chainfile,
    }
  }

  class { '::nova::client': }
  class { '::nova::conductor': }
  class { '::nova::consoleauth': }
  class { '::nova::cron::archive_deleted_rows': }

  class { '::nova::compute::neutron': }

  class { '::nova::vncproxy':
    host    => $::openstack::controller_address_api,
    enabled => true,
  }

  class { [
    'nova::scheduler',
# As of Mitaka: objectstore is longer used due to changing EC2 support
    #'nova::objectstore',
    'nova::cert'
  ]:
    enabled => true
  }
  class { 'nova::scheduler::filter': 
	cpu_allocation_ratio => "4.0",
	ram_allocation_ratio => "1.2",
  }
}
