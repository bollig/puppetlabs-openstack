#
class openstack::profile::nova::auth (
) {
  openstack::resources::database { 'nova': }

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


  $controller_management_address = $::openstack::config::controller_address_management

  class { '::nova::keystone::auth':
      password         => $::openstack::config::nova_password,
  # TODO: in subsequent versions of the puppet nova module we wont be able to
  # specify public_address. Use public_uri, or public_url and ec2_public_url
      #public_address   => $::openstack::config::controller_address_api,
      #internal_address => $::openstack::config::controller_address_management,
      #admin_address    => $::openstack::config::controller_address_management,
  # TODO: if needed replace the following 3 lines with public_uri
      #public_protocol  => $::openstack::config::http_protocol, 
      #admin_protocol  => $::openstack::config::http_protocol, 
      #internal_protocol  => $::openstack::config::http_protocol, 
      public_url_v3    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v3",
      internal_url_v3  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      admin_url_v3     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      public_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v2",
      internal_url  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2",
      admin_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2",
      region           => $::openstack::config::region,
  }
}

