class openstack::profile::haproxy::murano {

  openstack::profile::haproxy::listen { 'murano-api':
    port => 8082,
  }
  openstack::profile::haproxy::listen { 'murano-api_cfn':
    port => 8083,
  }

}
