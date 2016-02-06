node 'puppet' {
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
  include ::openstack::role::controller
}

node 'storage.msi.umn.edu' {
  include ::openstack::role::storage
}

node 'network.msi.umn.edu' {
  include ::openstack::role::network
}

node 'compute.msi.umn.edu' {
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

