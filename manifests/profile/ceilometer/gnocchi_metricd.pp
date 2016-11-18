# Stands up a gnocchi metricd service (standalone)
class openstack::profile::ceilometer::gnocchi_metricd ( 
) {
    require ::openstack::profile::ceilometer::gnocchi

#    Class['openstack::common::gnocchi'] -> Class['openstack::profile::ceilometer::gnocchi']
#    Class['openstack::profile::ceilometer::gnocchi'] -> Class['openstack::profile::ceilometer::gnocchi_metricd']

    class { '::gnocchi::metricd': }
    gnocchi_config { 
      "metricd/workers": value => $::processorcount ;
    }

}
