forge "http://forge.puppetlabs.com"

# THIS MODULE
mod "puppetlabs-openstack",
	:git => "git://github.com/bollig/puppetlabs-openstack",
	:ref => "liberty"


## The core OpenStack modules

mod "openstack-keystone",
	:git => "git://github.com/openstack/puppet-keystone",
	:ref => "stable/liberty"

mod "openstack-aodh",
	:git => "git://github.com/openstack/puppet-aodh",
	:ref => "stable/liberty"

mod "openstack-gnocchi",
	:git => "git://github.com/openstack/puppet-gnocchi",
	:ref => "stable/liberty"

mod "openstack-swift",
	:git => "git://github.com/openstack/puppet-swift",
	:ref => "stable/liberty"

mod "openstack-glance",
	:git => "git://github.com/openstack/puppet-glance",
	:ref => "stable/liberty"

mod "openstack-cinder",
	:git => "git://github.com/openstack/puppet-cinder",
	:ref => "stable/liberty"

mod "openstack-neutron",
	:git => "git://github.com/openstack/puppet-neutron",
	:ref => "stable/liberty"

mod "openstack-nova",
	:git => "git://github.com/openstack/puppet-nova",
	:ref => "stable/liberty"

mod "openstack-heat",
	:git => "git://github.com/openstack/puppet-heat",
	:ref => "stable/liberty"

mod "openstack-ceilometer",
	:git => "git://github.com/openstack/puppet-ceilometer",
	:ref => "stable/liberty"

mod "openstack-horizon",
	:git => "git://github.com/openstack/puppet-horizon",
	:ref => "stable/liberty"

mod "openstack-openstacklib",
	:git => "git://github.com/openstack/puppet-openstacklib",
	:ref => "stable/liberty"

mod "openstack-openstack_extras",
	:git => "git://github.com/openstack/puppet-openstack_extras",
	:ref => "stable/liberty"

mod "openstack-tempest",
	:git => "git://github.com/openstack/puppet-tempest",
	:ref => "stable/liberty"

mod "openstack-vswitch",
	:git => "git://github.com/openstack/puppet-vswitch",
	:ref => "stable/liberty"

## R10K doesn't handle dependencies, so let's handle them here
# pointing to as many stable projects as possible
# TODO automate this dependency list

mod "puppetlabs/apache", :latest
mod "stahnma/epel", :latest
mod "garethr/erlang", :latest
mod "puppetlabs/inifile", :latest
mod "puppetlabs/mysql", :latest
mod "puppetlabs/postgresql", "3.4.2"
mod "puppetlabs/stdlib", :latest
mod "puppetlabs/rsync", :latest
mod "puppetlabs/xinetd", :latest
mod "puppetlabs/concat", "1.2.5"
mod "saz/memcached", :latest
mod "dprince/qpid", :latest
mod "duritong/sysctl", :latest 
mod "puppetlabs/rabbitmq", :latest
mod "nanliu/staging", :latest
mod "puppetlabs/vcsrepo", :latest

# indirect dependencies

mod "puppetlabs/firewall", :latest
mod "puppetlabs/apt", "1.8.0"
mod "puppetlabs/corosync", :latest
mod "puppetlabs/mongodb", :latest
mod "puppetlabs/ntp", :latest

