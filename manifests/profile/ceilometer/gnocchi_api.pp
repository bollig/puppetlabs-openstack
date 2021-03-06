# Adds gnocchi to the stack
# 
# http://www.slideshare.net/GordonChung/gnocchi-v3-brownbag
# 
class openstack::profile::ceilometer::gnocchi_api ( 
  $enable_grafana_support = false,
  $cors_allowed_origin = 'http://localhost:3000',
  $install_grafana = false,
  $storage_type = 'file',
  $storage_endpoint_url = $::os_service_default,
  $storage_region_name = $::os_service_default,
  $storage_access_key_id = $::os_service_default,
  $storage_secret_access_key = $::os_service_default,
  $storage_bucket_prefix = $::os_service_default,
) {
      openstack::resources::firewall { 'GNOCCHI API': port => '8041', }
# NOTE: set the ceilometer polling interval to 20 seconds:
# /etc/ceilometer/pipeline.yaml (:%s/600/20/g)

    if $enable_grafana_support { 
    # Used some tips from https://blog.sileht.net/configuring-cors-for-gnocchi-and-keystone.html
  # NOTE: Grafana is not installed by default. Setup manually: 
  # sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-3.1.1-1470047149.x86_64.rpm
  # sudo grafana-cli plugins install sileht-gnocchi-datasource 
  # sudo systemctl start grafana-server
      if $install_grafana == true { 
        notify { "NOTE:   Grafana is not installed by default. Setup manually: 
           sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-3.1.1-1470047149.x86_64.rpm
           sudo grafana-cli plugins install sileht-gnocchi-datasource 
           sudo systemctl start grafana-server
         ": }
        openstack::resources::firewall { 'GRAFANA PORTAL': port => '3000', }
      }

      keystone_config { 
        "cors/allowed_origin": value => $cors_allowed_origin;
        # Append origin to headers to enable Safari support
        "cors/allow_headers": value => "X-Auth-Token,X-Openstack-Request-Id,X-Subject-Token,X-Project-Id,X-Project-Name,X-Project-Domain-Id,X-Project-Domain-Name,X-Domain-Id,X-Domain-Name,origin";
      }
      gnocchi_config {
        "cors/allowed_origin": value => $cors_allowed_origin;
        # Append origin to headers to enable Safari support
        "cors/allow_headers": value => 'Content-Type,Cache-Control,Content-Language,Expires,Last-Modified,Pragma,X-Auth-Token,origin';
      }
      #NOTE: unfortunately we cant override this here: 
      #gnocchi_api_paste_ini {
      #  "pipeline:main/pipeline": value => 'cors gnocchi+auth'; 
      #}
    } 


    class { '::gnocchi::keystone::authtoken':
      password => $::openstack::config::gnocchi_password, 
      auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
      auth_url     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:5000/",
      region_name         => $::openstack::config::region,
    }

    # Setup the gnocchi api endpoint
    class { '::gnocchi::api':
        #keystone_password     => $::openstack::config::gnocchi_password,
        #keystone_identity_uri => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
        #keystone_auth_uri     => "${::openstack::config::http_protocol}://${::openstack::config::controller_address_management}:35357/",
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

    class { '::gnocchi::storage': }
    #class { '::gnocchi::storage::file': }
    #class { '::gnocchi::storage::ceph': }
  
    if $storage_type == 's3' { 
      gnocchi_config { 
        "storage/driver":               value => 's3';
        "storage/s3_endpoint_url":      value => $storage_endpoint_url;
        "storage/s3_region_name":       value => $storage_region_name;
        "storage/s3_access_key_id":     value => $storage_access_key_id;
        "storage/s3_secret_access_key": value => $storage_secret_access_key;
        "storage/s3_bucket_prefix":     value => $storage_bucket_prefix;
      }
    } else {
      class { "::gnocchi::storage::${storage_type}": }
    }

    gnocchi_config { 
      "storage/aggregation_workers_number": value => $::processorcount;
    }

    class { '::gnocchi::db::sync': }

    require ::openstack::profile::ceilometer::gnocchi
}
