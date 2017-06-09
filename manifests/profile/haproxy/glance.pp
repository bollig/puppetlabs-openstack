class openstack::profile::haproxy::glance (
) {

  openstack::profile::haproxy::listen { 'glance-api':
    port => 9292,
  }
  openstack::profile::haproxy::listen { 'glance-registry':
    port => 9191,
  }
}
