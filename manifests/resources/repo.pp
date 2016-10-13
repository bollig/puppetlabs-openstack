class openstack::resources::repo(
  $release = 'liberty',
  $enable_cloudkitty = false,
){
  if $::osfamily == 'Debian' {
    if $::operatingsystem == 'Ubuntu' {
      class { '::openstack_extras::repo::debian::ubuntu':
        release         => $release,
        package_require => true,
      }
    } elsif $::operatingsystem == 'Debian' {
      class { '::openstack_extras::repo::debian::debian':
        release         => $release,
        package_require => true,
      }
    } else {
      fail("Operating system ${::operatingsystem} is not supported.")
    }
  } elsif $::osfamily == 'RedHat' {
      class { '::openstack_extras::repo::redhat::redhat':
        release => $release
      }
      # Following: http://docs.openstack.org/developer/cloudkitty/installation.html
      if $enable_cloudkitty == true {
        yumrepo { 'cloudkitty':
          name     => 'cloudkitty',
          baseurl  => "http://archive.objectif-libre.com/cloudkitty/el7/${release}",
          descr    => 'CloudKitty repo for RedHat',
  # TODO: FIX SIGN
          gpgcheck => 0,
          gpgkey   => 'http://archive.objectif-libre.com/ol.asc',
          #gpgkey   => "http://archive.objectif-libre.com/cloudkitty/el7/${release}/repodata/repomd.xml.asc",
          enabled  => 1,
          require  => Anchor['openstack_extras_redhat']
        }
      }
  } else {
      fail("Operating system family ${::osfamily} is not supported.")
  }
}
