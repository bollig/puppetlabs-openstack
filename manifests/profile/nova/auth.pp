#
class openstack::profile::nova::auth (
) {
  openstack::resources::database { 'nova': }

  $user                = $::openstack::config::mysql_user_nova
  $pass                = $::openstack::config::mysql_pass_nova
  $controller_management_address = $::openstack::config::controller_address_management

  # Cells are required for Ocata
  # cell0 is auto-created. cell1 is the nova database
  # high-level API db:  "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova_api",
  # cell0 db:           "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova_cell0",
  # cell1 db:           "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova",
  #class {'::nova::cell_v2::simple_setup':
  #  database_connection => "mysql+pymysql://${user}:${pass}@${controller_management_address}/nova",
  #  transport_url => "rabbit://${openstack::config::rabbitmq_user}:${openstack::config::rabbitmq_password}@${controller_management_address}:5672/",
  #} 
  # Discover new compute nodes every XX seconds
  #nova_config {
  #  'scheduler/discover_hosts_in_cells_interval': value => '60';
  #}

  #class { '::nova::cells':
  #  cell_type => 'parent', 
  #  cell_name => 'default',
  #}

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

  #class { '::nova::db::mysql_placement':
  #  #user 	  => "${::openstack::config::mysql_user_nova}_placement",
  #  user 	  => "placement",
  #  dbname 	  => "${::openstack::config::mysql_user_nova}_cell0",
  #  password 	  => $::openstack::config::mysql_pass_nova,
  #  allowed_hosts => $::openstack::config::mysql_allowed_hosts,
  #} 

  #openstack::resources::database_grant { $real_allowed_hosts:
#	user => 'nova',
# 	password_hash => $::openstack::config::nova_password,	
#	dbname => "nova_api",
#	require       => Anchor['database-service'],
#  }



  class { '::nova::keystone::auth':
      password         => $::openstack::config::nova_password,
      public_url_v3    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v3",
      internal_url_v3  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      admin_url_v3     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v3",
      public_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8774/v2.1",
      internal_url  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2.1",
      admin_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8774/v2.1",
      region           => $::openstack::config::region,
  }

  #class { '::nova::keystone::auth_placement':
  #    password         => $::openstack::config::nova_password,
  #    public_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8778/placement",
  #    internal_url  => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8778/placement",
  #    admin_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8778/placement",
  #    region           => $::openstack::config::region,
  #}
}

