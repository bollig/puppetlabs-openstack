# The profile for instegrating an existing Ceph RGW into OpenStack
class openstack::profile::swift::radosgw (
  $endpoint = 'http://localhost:8080',
) {

  class { 'swift::keystone::auth':
    password         => $::openstack::config::swift_password,
    public_url       => "${endpoint}/swift/v1",
    admin_url        => "${endpoint}/swift/v1",
    internal_url     => "${endpoint}/swift/v1",
    public_url_s3    => "${endpoint}",
    admin_url_s3     => "${endpoint}",
    internal_url_s3  => "${endpoint}",
    region           => $::openstack::config::region,
  }

}
