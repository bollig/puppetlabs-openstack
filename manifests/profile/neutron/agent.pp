# The profile to set up a neutron agent
class openstack::profile::neutron::agent {
  include ::openstack::common::neutron

# Installs the L2 Agent (See http://www.server-world.info/en/note?os=CentOS_7&p=openstack_liberty&f=14)
  case $::openstack::config::neutron_core_plugin {
    'plumgrid': { include ::openstack::common::plumgrid }
    default:    { include ::openstack::common::ml2::ovs }
  }

}
