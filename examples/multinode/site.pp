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
  $node_type = 'control, network, storage'
  include ::openstack::role::common
  include ::openstack::role::controller
  include ::openstack::role::network
  include ::openstack::role::storage
}

node 'storage.msi.umn.edu' {
  $node_type = 'storage'
  include ::openstack::role::common
  include ::openstack::role::storage
}

node 'network.msi.umn.edu' {
  $node_type = 'network'
  include ::openstack::role::common
  include ::openstack::role::network
}

node 'compute01.msi.umn.edu' {
  $node_type = 'compute'
  include ::openstack::role::common
  include ::openstack::role::compute
}

node 'compute02.msi.umn.edu' {
  $node_type = 'compute'
  include ::openstack::role::common
  include ::openstack::role::compute
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
  include ::openstack::role::tempest
}

