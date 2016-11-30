# Adds gnocchi to the stack
# 
# http://www.slideshare.net/GordonChung/gnocchi-v3-brownbag
# 
class openstack::profile::ceilometer::gnocchi_api ( 
  $enable_grafana_support = false,
  $storage_type = 'file',
) {
      # Make the mysql db user 'gnocchi' exists
      openstack::resources::database { 'gnocchi': }
      openstack::resources::firewall { 'GNOCCHI API': port => '8041', }
# NOTE: set the ceilometer polling interval to 20 seconds:
# /etc/ceilometer/pipeline.yaml (:%s/600/20/g)

    if $enable_grafana_support { 
    # Used some tips from https://blog.sileht.net/configuring-cors-for-gnocchi-and-keystone.html
  # NOTE: Grafana is not installed by default. Setup manually: 
  # sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-3.1.1-1470047149.x86_64.rpm
  # sudo grafana-cli plugins install sileht-gnocchi-datasource 
  # sudo systemctl start grafana-server
      notify { "NOTE:   Grafana is not installed by default. Setup manually: 
         sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-3.1.1-1470047149.x86_64.rpm
         sudo grafana-cli plugins install sileht-gnocchi-datasource 
         sudo systemctl start grafana-server
     ": }

      keystone_config { 
        "cors/allowed_origin": value => 'http://atmosphere1.msi.umn.edu:3000';
      }
      gnocchi_config {
        "cors/allowed_origin": value => 'http://atmosphere1.msi.umn.edu:3000';
        "cors/allow_headers": value => 'Content-Type,Cache-Control,Content-Language,Expires,Last-Modified,Pragma,X-Auth-Token';
      }
      #NOTE: unfortunately we cant override this here: 
      #gnocchi_api_paste_ini {
      #  "pipeline:main/pipeline": value => 'cors gnocchi+auth'; 
      #}
      #so I have notify: 
      notify { "NOTE: manually add cors to /etc/gnocchi/api-paste.ini to enable Grafana Keystone auth:
        
         [pipeline:main]
         pipeline = cors gnocchi+auth
      ": }
      openstack::resources::firewall { 'GRAFANA PORTAL': port => '3000', }
    } 

    # Setup the gnocchi api endpoint
    class { '::gnocchi::api':
        keystone_password     => $::openstack::config::gnocchi_password,
        keystone_identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        keystone_auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        service_name          => 'httpd',
        #manage_service        => false,
        enabled               => true,
    }
    include ::apache
    class { '::gnocchi::wsgi::apache':
	  ssl             => $::openstack::config::enable_ssl,
	  ssl_cert        => $::openstack::config::keystone_ssl_certfile,
	  ssl_key         => $::openstack::config::keystone_ssl_keyfile,
	  ssl_chain       => $::openstack::config::ssl_chainfile,
	  #ssl_ca          => $::openstack::config::ssl_chainfile,
	  workers         => 3
    }

    class { '::gnocchi::db::sync': }
    class { '::gnocchi::storage': }
    #class { '::gnocchi::storage::file': }
    #class { '::gnocchi::storage::ceph': }
    class { "::gnocchi::storage::${storage_type}": }
    gnocchi_config { 
      "storage/aggregation_workers_number": value => $::processorcount;
    }


    require ::openstack::profile::ceilometer::gnocchi
}
