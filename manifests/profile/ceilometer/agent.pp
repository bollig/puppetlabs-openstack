class openstack::profile::ceilometer::agent {
  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::ceilometer

    # install the ceilometer-compute service
    # see http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty2&f=14
  class { '::ceilometer::agent::compute': }
}
