define openstack::resources::tenant (
  $description = '',
  $enabled = true,
  $domain = 'Default',
  $is_default = false,
) {

	keystone_tenant { "${name}::${domain}": 
		ensure      => present,
		enabled     => $enabled,
		description => $description, 
	}

}
