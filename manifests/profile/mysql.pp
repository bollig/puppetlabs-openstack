# The profile to install an OpenStack specific mysql server
class openstack::profile::mysql(
	$bind_address = 'localhost',
        $max_connections = '1024',
        $max_file_limit = '10000',
) {

  $management_network = $::openstack::config::network_management

    file { '/etc/systemd/system/mariadb.service.d':
        ensure => 'directory',
        owner   => '0',
        group   => '0',
        mode    => '0755',
    } ->
    file {'/etc/systemd/system/mariadb.service.d/limits.conf':
        owner   => '0',
        group   => '0',
        mode    => '0644',
        notify  => Service['mysqld'],
        content => "[Service]
LimitNOFILE=${max_file_limit}
"
    }  
 
  if $bind_address == 'ip_address' { 
    $l_bind_address = $::ipaddress
  } else {
    $l_bind_address = $bind_address
  }

  class { '::mysql::server':
    root_password    => $::openstack::config::mysql_root_password,
    restart          => true,
    override_options => {
      'mysqld' => {
                    #'bind_address'           => $::openstack::config::controller_address_management,
                    'bind_address'           => $l_bind_address,
                    'default-storage-engine' => 'innodb',
                    # http://blog.endpoint.com/2013/12/increasing-mysql-55-maxconnections-on.html
                    'open_files_limit' => 8192,
                    'max_connections' => $max_connections,
                    'wait_timeout'    => 60,
# TODO: comment this out when we have a proper set of IPs. Until then, avoid
# DNS resolution from preventing mysql client connections
#		    'skip-name-resolve'      => true,
                    # Alleviate huge ibd files and make it easier to restore individual databases 
                    'innodb_file_per_table' => 1, 
                  }
    }
  }

  class { '::mysql::bindings':
    python_enable => true,
  }

  Service['mysqld'] -> Anchor['database-service']

  class { 'mysql::server::account_security': }

  class { 'mysql::server::backup': 
    backupuser     => 'root',
    backuppassword => $::openstack::config::mysql_root_password,
    backupdir     => '/tmp/backup',
    provider      => 'xtrabackup',
  }
  Class['mysql::server'] -> Class['mysql::server::backup']
}
