# Profile to install the cloudkitty web service into Horizon
# NOTE: This is expected to significantly change when a puppet-cloudkitty module becomes available. 
# ALSO: refer to the manifests/resources/repo.pp for the yum repo changes
class openstack::profile::cloudkitty (
  $enable = false,
  $verbose = true,
  $collector = 'ceilometer', 
  $log_dir = '/var/log/cloudkitty',
  $service_port = 8889,
  $mysql_password = 'fuva-wax',
  $mysql_host = 'localhost',
  $mysql_user = 'cloudkitty',
  $mysql_type = 'mysql+pymysql',
  $mysql_database = 'cloudkitty',
  $admin_password='',
  $admin_user='cloudkitty',
  $admin_tenant_name='admin',
) {
# http://docs.openstack.org/developer/cloudkitty/installation.html
# 1) Install package
  if $enable == true {
    package { 'openstack-cloudkitty-api': ensure => 'installed' }
    package { 'openstack-cloudkitty-processor': ensure => 'installed' }
    package { 'openstack-cloudkitty-dashboard': ensure => 'installed' }

    notify { 'PLEASE INSTALL THE LATEST CLOUDKITTY FROM GIT: 

git clone git://git.openstack.org/openstack/cloudkitty
cd cloudkitty
python setup.py install

cloudkitty-dbsync upgrade
cloudkitty-storage-init

systemctl restart openstack-cloudkitty-*
': } 

  }
# 2) Configure services
# I wont have full control over the ini until cloudkitty releases a puppet module
  $storage_management_address = $::openstack::config::storage_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  $rabbit_hosts = $::openstack::config::controller_address_management
  $rabbit_user = $::openstack::config::rabbitmq_user
  $rabbit_password = $::openstack::config::rabbitmq_password

  $database_connection = "${mysql_type}://${mysql_user}:${mysql_password}@${mysql_host}/${mysql_database}"
  $memcached_servers = "${controller_management_address}:11211"

  $auth_uri = "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/v2.0"
  $identity_uri = "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/v2.0"
  $public_url_real = "http://${::openstack::config::controller_address_management}:${service_port}"
  $internal_url_real = "http://${::openstack::config::controller_address_management}:${service_port}"
  $admin_url_real = "http://${::openstack::config::controller_address_management}:${service_port}"

  $region = "${::openstack::region}"

  file { '/etc/cloudkitty/cloudkitty.conf':
    content => template('openstack/etc__cloudkitty__cloudkitty.erb'),
    owner   => 'root',
    group   => 'cloudkitty',
    mode    => 640,
  }
  file { '/etc/cloudkitty/api_paste.ini': 
      source => 'puppet:///modules/openstack/etc__cloudkitty__api_paste.ini',
      ensure => 'present',
      owner   => 'root',
      group   => 'cloudkitty',
      mode => 640,
  }


# MANUALLY CREATED: 
# 
#  1) connection: 
#     mysql -uroot -p << EOF
#     CREATE DATABASE cloudkitty;
#     GRANT ALL PRIVILEGES ON cloudkitty.* TO 'cloudkitty'@'localhost' IDENTIFIED BY 'CK_DBPASS';
#     EOF
#  2) cloudkitty-dbsync upgrade
#  3) cloudkitty-storage-init

#    cloudkitty collector-state-get --name gnocchi
#    cloudkitty collector-state-get --name ceilometer

# Create user directly without a cloudkitty::db::mysql defined
  #openstack::resources::database { 'cloudkitty': }
  

  openstack::resources::firewall { 'CloudKitty API': port => "${service_port}", }

  Keystone_endpoint["${region}/cloudkitty::rating"] ~> Service <| name == 'cloudkitty-api' |>
  Service <| name == 'ceilometer-api' |> ~> Service <| name == 'cloudkitty-api' |>

  ::openstacklib::db::mysql { 'cloudkitty':
    user          => $mysql_user,
    password_hash => mysql_password($mysql_password),
    dbname        => $mysql_database,
    host          => $mysql_host,
    charset       => 'utf8',
    collate       => 'utf8_general_ci',
    allowed_hosts => $::openstack::config::mysql_allowed_hosts,
    require       => Anchor['database-service'],
  } 

  exec { 'cloudkitty-db-sync':
    command     => "/usr/bin/cloudkitty-dbsync upgrade",
    refreshonly => true,
    #logoutput   => on_failure,
  } ->
  exec { 'cloudkitty-storage-init':
    command     => "/usr/bin/cloudkitty-storage-init",
    refreshonly => true,
    #logoutput   => on_failure,
  }

  keystone::resource::service_identity { "cloudkitty":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    service_type        => 'rating',
    service_description => 'CloudKitty Rating Service',
    service_name        => 'cloudkitty',
    region              => $region,
    auth_name           => $admin_name,
    password            => $admin_password,
    email               => 'cloudkitty@localhost',
    tenant              => $admin_tenant_name,
    public_url          => $public_url_real,
    admin_url           => $admin_url_real,
    internal_url        => $internal_url_real,
    require       =>  Anchor['database-service'] ,
  }


      if $enable {
        $service_ensure = 'running'
        #$service_ensure = 'stopped'

        File['/etc/cloudkitty/cloudkitty.conf'] -> Service['openstack-cloudkitty-api']
        File['/etc/cloudkitty/cloudkitty.conf'] -> Service['openstack-cloudkitty-proc']
        File['/etc/cloudkitty/cloudkitty.conf'] ~> Service['openstack-cloudkitty-api']
        File['/etc/cloudkitty/cloudkitty.conf'] ~> Service['openstack-cloudkitty-proc']
      } else {
        $service_ensure = 'stopped'
      }

    file { '/etc/systemd/system/openstack-cloudkitty-api.service': 
      source => 'puppet:///modules/openstack/openstack-cloudkitty-api.service',
      ensure => 'present',
      mode => '0664',
    } ~> Exec['systemctl daemon-reload'] 

    service { 'openstack-cloudkitty-api':
      ensure    => $service_ensure,
      name      => 'openstack-cloudkitty-api',
      enable    => $enable,
      hasstatus => true,
      tag       => 'cloudkitty-service',
    }

    file { '/etc/systemd/system/openstack-cloudkitty-proc.service': 
      source => 'puppet:///modules/openstack/openstack-cloudkitty-proc.service',
      ensure => 'present',
      mode => '0664',
      notify => Exec['systemctl daemon-reload'] 
    } 

    exec { 'systemctl daemon-reload':
      command     => "/usr/bin/systemctl daemon-reload",
    } 

    service { 'openstack-cloudkitty-proc':
      ensure    => $service_ensure,
      name      => 'openstack-cloudkitty-proc',
      enable    => $enable,
      hasstatus => true,
      tag       => 'cloudkitty-service',
    }

# NOTE: encrypt password with "eyaml encrypt -s 'string'"


} 
