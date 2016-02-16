node 'puppet' {

    package {'git': 
        ensure => latest, 
    }

#  include ::ntp
#  class { '::puppetdb':
#    listen_address     => '0.0.0.0',
#    ssl_listen_address => '0.0.0.0'
#  }->
#  class { '::puppetdb::master::config':
#    puppetdb_server => 'puppet'
#  }
}

node 'control.msi.umn.edu' {
  $node_type = 'control|network|storage'
  class { '::openstack::role::common': }
  class { '::openstack::role::controller': }
#  class { '::openstack::role::network': }
  class { '::openstack::role::storage': } 
}

node 'storage.msi.umn.edu' {
  $node_type = 'storage'
  class { '::openstack::role::common': }
  class { '::openstack::role::storage': }
}

node 'network.msi.umn.edu' {
  $node_type = "network"
  class { '::openstack::role::common': }
  class { '::openstack::role::network': }
}

node 'compute01.msi.umn.edu' {
  $node_type = 'compute'
  class { '::openstack::role::common': }
  class { '::openstack::role::compute': }
}

node 'compute02.msi.umn.edu' {
  $node_type = 'compute'
  class { '::openstack::role::common': }
  class { '::openstack::role::compute': }
}

node 'swiftstore1.msi.umn.edu' {
  class { '::openstack::role::swiftstorage':
    zone => '1'
  }
}

node 'swiftstore2.msi.umn.edu' {
  class { '::openstack::role::swiftstorage':
    zone => '2'
  }
}

node 'swiftstore3.msi.umn.edu' {
  class { '::openstack::role::swiftstorage':
    zone => '3'
  }
}

node 'tempest.msi.umn.edu' {
  class { '::openstack::role::tempest': }
}

