# The profile for installing the MURANO API
class openstack::profile::murano::api (
  $enabled = false,
  $enable_haproxy = true,
  $bind_address = '127.0.0.1',
  $dashboard_src_path = '/usr/share/openstack-dashboard/murano-dashboard',
  $attempt_app_catalog = false,
  $app_catalog_src_path = '/usr/share/openstack-dashboard/murano-app-catalog-ui',
  $openstack_dashboard_path = '/usr/share/openstack-dashboard/',
) {

  if $enabled == true { 
    # This resources::database call includes a call to  class { '::murano::db::mysql': password => 'murano' }
    openstack::resources::firewall { 'MURANO API': port => '8082', }
    openstack::resources::firewall { 'MURANO CFN API': port => '8083', }

    $controller_management_address  = $::openstack::config::controller_address_management
    $user                = $::openstack::config::mysql_user_murano
    $pass                = $::openstack::config::mysql_pass_murano
    $database_connection = "mysql://${user}:${pass}@${controller_management_address}/murano"

    if $enable_haproxy { 
      include ::openstack::profile::haproxy::murano
    }

    class { '::murano': 
      admin_password      => $::openstack::config::murano_password,
      admin_tenant_name   => 'services',
      service_host        => $bind_address,
      database_connection => $database_connection,
      rabbit_os_host      => $::openstack::config::controller_address_management,
      rabbit_os_user      => $::openstack::config::rabbitmq_user,
      rabbit_os_password  => $::openstack::config::rabbitmq_password,
      auth_uri            => "${::openstack::config::http_protocol}://${controller_management_address}:5000/",
      identity_uri        => "${::openstack::config::http_protocol}://${controller_management_address}:5000/",
    } 

  #TODO: 
  # murano dashboard
  # auth.pp 

    #murano::application { '
    #  package_ensure   => 'present',
    #  package_category => undef,
    #  exists_action    => 's',
    #  public           => true,
    #}

    class { '::murano::engine': } 

    class { '::murano::api': 
      host => $bind_address,
      port => 8082,
    }

    class { '::murano::cfapi': 
      tenant=>'services',
      bind_port => 8083,
      bind_host => $bind_address,
      auth_url => "${::openstack::config::http_protocol}://${controller_management_address}:5000/",
    }

    # CONFLICTS with Horizon: 
    #class { '::murano::dashboard': }
    
    # NO PACKAGE EXISTS YET
    #package { 'murano-dashboard':
    #  ensure => 'installed',
  #    name   => $::murano::params::dashboard_package_name,
    #  name   => 'openstack-murano-dashboard',
    #  tag    => ['openstack', 'murano-packages'],
    #} -> Class['::murano']

    vcsrepo { "$dashboard_src_path":
       ensure => present,
       provider => git,
       source => 'git://git.openstack.org/openstack/murano-dashboard',
       revision => 'master',
       require => Class['::horizon']
    } 

    exec { 'muranodashboard_requirements': 
      command => "/usr/bin/pip install -r requirements.txt",
      cwd => "$dashboard_src_path",
      subscribe => Vcsrepo["$dashboard_src_path"],
      require => Vcsrepo["$dashboard_src_path"],
    }

    exec { 'update_muranodashboard': 
      command => "/usr/bin/python setup.py install",
      cwd => "$dashboard_src_path",
      creates => "/usr/lib/python2.7/site-packages/muranodashboard/__init__.py",
      subscribe => Vcsrepo["$dashboard_src_path"],
      require => [Vcsrepo["$dashboard_src_path"],Exec["muranodashboard_requirements"]],
    }

    # TODO: replace with template upload
    exec { 'update_muranodashboard_3': 
      command => "/usr/bin/ln -s --force $dashboard_src_path/muranodashboard/local/local_settings.d/_50_murano.py $openstack_dashboard_path/openstack_dashboard/local/local_settings.d/_50_murano.py", 
      cwd => "$dashboard_src_path",
      creates => "$openstack_dashboard_path/openstack_dashboard/local/local_settings.d/_50_murano.py",
      subscribe => Vcsrepo["$dashboard_src_path"],
      require => [Vcsrepo["$dashboard_src_path"],Exec["update_muranodashboard"],Exec['update_muranodashboard_2']],
      provider => "shell",
    }

    exec { 'update_muranodashboard_2': 
      command => "/usr/bin/ln -s --force $dashboard_src_path/muranodashboard/conf/murano_policy.json /etc/openstack-dashboard/murano_policy.json", 
      cwd => "$dashboard_src_path",
      creates => "/etc/openstack-dashboard/murano_policy.json",
      subscribe => Vcsrepo["$dashboard_src_path"],
      require => [Vcsrepo["$dashboard_src_path"],Exec["update_muranodashboard"],Exec['update_muranodashboard_1']],
      provider => "shell",
    }
   
    exec { 'update_muranodashboard_1': 
      command => "for file in $dashboard_src_path/muranodashboard/local/enabled/_*[^__]; do ln -s --force \"$dashboard_src_path/muranodashboard/local/enabled/\${file##*/}\" \"$openstack_dashboard_path/openstack_dashboard/local/enabled/\${file##*/}\"; done",
      cwd => "$dashboard_src_path",
      creates => "$dashboard_src_path/openstack_dashboard/local/enabled/_51_muranodashboard.py",
      subscribe => Vcsrepo["$dashboard_src_path"],
      require => [Vcsrepo["$dashboard_src_path"],Exec["update_muranodashboard"]],
      provider => "shell",
      notify => Service['httpd'],
    }

    ### INSTALL THE PUBLIC APP CATALOG ###
    if $attempt_app_catalog == true {
      vcsrepo { "$app_catalog_src_path":
         ensure => present,
         provider => git,
         source => 'git://git.openstack.org/openstack/app-catalog-ui',
         revision => 'master',
         require => Class['::horizon']
      } 

      exec { 'app-catalog-ui_requirements': 
        command => "/usr/bin/pip install -r requirements.txt",
        cwd => "$app_catalog_src_path",
        subscribe => Vcsrepo["$app_catalog_src_path"],
        require => Vcsrepo["$app_catalog_src_path"],
      }

      exec { 'update_app-catalog-ui': 
        command => "/usr/bin/python setup.py install",
        cwd => "$app_catalog_src_path",
        creates => "/usr/lib/python2.7/site-packages/app_catalog/__init__.py",
        subscribe => Vcsrepo["$app_catalog_src_path"],
        require => [Vcsrepo["$app_catalog_src_path"],Exec["app-catalog-ui_requirements"]],
      }

   
      exec { 'update_app-catalog-ui_1': 
        command => "for file in $app_catalog_src_path/app_catalog/enabled/_*[^__]; do ln -s --force \"$app_catalog_src_path/app_catalog/enabled/\${file##*/}\" \"$openstack_dashboard_path/openstack_dashboard/local/enabled/\${file##*/}\"; done",
        cwd => "$app_catalog_src_path",
        creates => "$app_catalog_src_path/openstack_dashboard/local/enabled/_51_app_catalog.py",
        subscribe => Vcsrepo["$app_catalog_src_path"],
        require => [Vcsrepo["$app_catalog_src_path"],Exec["update_app-catalog-ui"]],
        provider => "shell",
        notify => Service['httpd'],
      }
    }


  # TODO: restorecon on directory

    class { '::murano::client': }

    #### auth.pp ####

    openstack::resources::database { 'murano': }
    class { '::murano::keystone::auth':
      password     => $::openstack::config::murano_password,
      public_url   => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_api}:8082",
      admin_url    => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8082",
      internal_url => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:8082",
      region       => $::openstack::config::region,
    }
  }
}
