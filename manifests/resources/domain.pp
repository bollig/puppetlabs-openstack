define openstack::resources::domain (
  $description = '',
  $enabled = true,
  $is_default = false,
) {

	keystone_domain { "${name}":
		ensure      => present,
		enabled     => $enabled,
		description => $description, 
		is_default  => $is_default,
	}

}
