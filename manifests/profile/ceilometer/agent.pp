#
class openstack::profile::ceilometer::agent {

  include ::openstack::common::ceilometer

  # systemd drop-in to add dependency on libvirtd...
  file { '/etc/systemd/system/openstack-ceilometer-compute.service.d':
    ensure => 'directory',
    owner   => '0',
    group   => '0',
    mode    => '0755',
  } ->
  file {'/etc/systemd/system/openstack-ceilometer-compute.service.d/after.conf':
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['openstack-ceilometer-compute'],
    content => "[Unit]
After=syslog.target network.target libvirtd.service
"
  }
    # install the ceilometer-compute service
    # see http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty2&f=14
  # http://docs.openstack.org/developer/ceilometer/architecture.html

# NOTE: all details of which polling agents to install are handled in the common "::ceilometer::agent::polling" class call
  
# Control node: 
# 	1 - Polling agent
# 	2 - Notification agent
#	3 - Collector agent (if data/events from 1 and 2 are to be sent to gnocchi)
#	4 - Api agent
#	5 - central agent

# Network node: 
# 

# Compute node: 
# 	- compute agent
  class { '::ceilometer::agent::compute': }

# Compute namespace on each compute server
# http://www.slideshare.net/openstackindia/openstack-ceilometer
  #class { '::ceilometer::agent::polling':
  #  central_namespace => false,
  #  compute_namespace => true,
# NOTE: this might result in errors of the form: "ceilometer.hardware.discovery [-] Couldn't obtain IP address of instance"
  #  ipmi_namespace    => true,
  #}

}
