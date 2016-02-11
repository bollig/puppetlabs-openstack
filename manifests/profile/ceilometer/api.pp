# The profile to set up the Ceilometer API
# For co-located api and worker nodes this appear
# after openstack::profile::ceilometer::agent
class openstack::profile::ceilometer::api {

  $mongo_username                = $::openstack::config::ceilometer_mongo_username
  $mongo_password                = $::openstack::config::ceilometer_mongo_password

  $ceilometer_management_address = $::openstack::config::ceilometer_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  openstack::resources::firewall { 'Ceilometer API': port => '8777' }

  include ::openstack::common::ceilometer

  # Setup the ceilometer user in keystone and register endpoints (control)
  class { '::ceilometer::keystone::auth':
    password         => $::openstack::config::ceilometer_password,
    public_url   => "http://${::openstack::config::controller_address_api}:8777",
    admin_url    => "http://${::openstack::config::controller_address_management}:8777",
    internal_url => "http://${::openstack::config::controller_address_management}:8777",
    region           => $::openstack::config::region,
  }

  # Setup ceilometer API service (control)
  class { '::ceilometer::api':
# TODO: drop update this to handle SSL
    keystone_protocol	  => 'http', 
    keystone_password     => $::openstack::config::ceilometer_password,
    keystone_identity_uri => "http://${controller_management_address}:35357/",
    keystone_auth_uri     => "http://${controller_management_address}:5000/",
    #service_name          => 'httpd',
# TODO: on new version of ceilometer puppet module we should be able to track
# the httpd service (see aodh below). Until then, assume that ceilometer will
# follow httpd cycles
    manage_service        => true,
    enabled               => true,
  }

  # Install polling agent (control)
  # Can be used instead of central, compute or ipmi agent
  # As default use central and compute polling namespaces
  class { '::ceilometer::agent::polling':
    central_namespace => true,
    compute_namespace => true,
    ipmi_namespace    => true,
  }

  # Install compute agent (deprecated)
  # default: enable
  # class { 'ceilometer::agent::compute':
  # }

  # Install central agent (deprecated)
  # class { 'ceilometer::agent::central':
  # }

  # CRITICAL: The collector service sends data to mongodb
  class { '::ceilometer::collector': }                                                                                                         

  # Purge 1 month old meters (wherever mongo service is (control))
  class { '::ceilometer::expirer':
    time_to_live => '2592000'
  }

  # Install notification agent (with API (control))
  class { '::ceilometer::agent::notification':
  }

  #class { '::ceilometer::wsgi::apache':
  #     ssl => false,
  #}

    # See http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty2&f=13
    # auth_strategy is not set by any parameter in the ceilometer puppet module
  ceilometer_config {
    'DEFAULT/auth_strategy': value => 'keystone';
  }

  # For the time being no upstart script are provided
  # in Ubuntu 12.04 Cloud Archive. Bug report filed
  # https://bugs.launchpad.net/cloud-archive/+bug/1281722
  # https://bugs.launchpad.net/ubuntu/+source/ceilometer/+bug/1250002/comments/5
  case $::osfamily {
    'Debian': {
      class { '::ceilometer::alarm::notifier':
      }

      class { '::ceilometer::alarm::evaluator':
      }
    }
    'RedHat': {

      $management_address  = $::openstack::config::controller_address_management
      $user                = $::openstack::config::mysql_user_aodh
      $pass                = $::openstack::config::mysql_pass_aodh
      $database_connection = "mysql://${user}:${pass}@${management_address}/aodh"
      
	# Make the mysql db user 'aodh' exists
      openstack::resources::database { 'aodh': }
      openstack::resources::firewall { 'AODH API': port => '8042', }

      class { '::aodh':
        rabbit_userid       => $::openstack::config::rabbitmq_user,
        rabbit_password     => $::openstack::config::rabbitmq_password,
        verbose             => true,
        debug               => true,
        rabbit_hosts         => $::openstack::config::rabbitmq_hosts,
# TODO: update to mongo when possible
	database_connection => $database_connection,
      }
	# Make the 'aodh' user in keystone: 
      class { '::aodh::keystone::auth':
        password => $::openstack::config::aodh_password,
	public_url   => "http://${::openstack::config::controller_address_api}:8042",
	admin_url    => "http://${::openstack::config::controller_address_management}:8042",
	internal_url => "http://${::openstack::config::controller_address_management}:8042",
	region           => $::openstack::config::region,
      }
        # Setup the aodh api endpoint
      class { '::aodh::api':
        enabled               => true,
        keystone_password     => $::openstack::config::aodh_password,
        keystone_identity_uri => "http://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "http://${::openstack::config::controller_address_management}:35357/",
        service_name          => 'httpd',
      }
        # Setup the aodh service behind apache wsgi
      class { '::aodh::wsgi::apache':
        ssl => false,
      }
	# Configure aodh to point to keystone
      class { '::aodh::auth':
        auth_url      => "http://${::openstack::config::controller_address_management}:5000/v2.0",
        auth_password => $::openstack::config::aodh_password,
      }
      class { '::aodh::client': }
      class { '::aodh::notifier': }
      class { '::aodh::listener': }
      class { '::aodh::evaluator': }
      class { '::aodh::db::sync': }
    }
    default: {
      fail("Unsupported osfamily (${::osfamily})")
    }
  }

  mongodb_database { 'ceilometer':
    ensure  => present,
    tries   => 20,
    require => Class['mongodb::server'],
  }

  if $mongo_username and $mongo_password {
    mongodb_user { $mongo_username:
      ensure        => present,
      password_hash => mongodb_password($mongo_username, $mongo_password),
      database      => 'ceilometer',
      roles         => ['readWrite', 'dbAdmin'],
      tries         => 10,
      require       => [Class['mongodb::server'], Class['mongodb::client']],
      before        => Exec['ceilometer-dbsync'],
    }
  }


  Class['::mongodb::server'] -> Class['::mongodb::client'] -> Exec['ceilometer-dbsync']
}
