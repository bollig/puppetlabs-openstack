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
      $gnocchi_enabled = true
      class { '::openstack::profile::ceilometer::aodh': gnocchi_enabled => $gnocchi_enabled }
      class { '::openstack::profile::ceilometer::gnocchi': enabed => $gnocchi_enabled }
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
