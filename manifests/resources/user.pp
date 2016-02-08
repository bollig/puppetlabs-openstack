define openstack::resources::user (
  $tenant = undef,
  $email = undef,
  $password = undef,
  $admin   = false,
  $enabled = true,
  $domain  = 'Default',
) {
# TODO: add domains
# NOTE: tenant is assumed to be created before this. See hiera(openstack::keystone::tenants)
  keystone_user { "${name}::${domain}":
    ensure   => present,
    enabled  => $enabled,
    password => $password,
    email    => $email,
  }


# NOTE: tenants are paired with users here
  if $admin == true {
    ensure_resource( 'keystone_role', '_member_', { 'ensure' => 'present' } )
    keystone_user_role { "${name}::${domain}@${tenant}::${domain}":
      ensure => present,
      roles  => ['_member_', 'admin'],
    }
  } else {
    keystone_user_role { "${name}::${domain}@${tenant}::${domain}":
      ensure => present,
      roles  => ['_member_'],
    }
  }
}
