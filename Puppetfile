forge "http://forge.puppetlabs.com"

# THIS MODULE
mod "puppetlabs-openstack",
	:git => "git://github.com/bollig/puppetlabs-openstack",
	:ref => "ssl"


## The core OpenStack modules

mod "openstack-ceph",
	:git => "git://github.com/openstack/puppet-ceph",
	:ref => "master"


mod "openstack-ec2api",
	:git => "git://github.com/openstack/puppet-ec2api",
	:ref => "master"

mod "openstack-keystone",
	:git => "git://github.com/openstack/puppet-keystone",
	:ref => "stable/mitaka"

mod "openstack-aodh",
	:git => "git://github.com/openstack/puppet-aodh",
	:ref => "stable/mitaka"

mod "openstack-trove",
	:git => "git://github.com/openstack/puppet-trove",
	:ref => "stable/mitaka"

mod "openstack-gnocchi",
	:git => "git://github.com/openstack/puppet-gnocchi",
	:ref => "stable/mitaka"

mod "openstack-swift",
	:git => "git://github.com/openstack/puppet-swift",
	:ref => "stable/mitaka"

mod "openstack-glance",
	:git => "git://github.com/openstack/puppet-glance",
	:ref => "stable/mitaka"

mod "openstack-cinder",
	:git => "git://github.com/openstack/puppet-cinder",
	:ref => "stable/mitaka"

mod "openstack-neutron",
	:git => "git://github.com/openstack/puppet-neutron",
	:ref => "stable/mitaka"

mod "openstack-nova",
	:git => "git://github.com/openstack/puppet-nova",
	:ref => "stable/mitaka"

mod "openstack-heat",
	:git => "git://github.com/openstack/puppet-heat",
	:ref => "stable/mitaka"

mod "openstack-ceilometer",
	:git => "git://github.com/openstack/puppet-ceilometer",
	:ref => "stable/mitaka"

mod "openstack-horizon",
	:git => "git://github.com/openstack/puppet-horizon",
	:ref => "stable/mitaka"

mod "openstack-openstacklib",
	:git => "git://github.com/openstack/puppet-openstacklib",
	:ref => "stable/mitaka"

mod "openstack-openstack_extras",
	:git => "git://github.com/openstack/puppet-openstack_extras",
	:ref => "stable/mitaka"

mod "openstack-tempest",
	:git => "git://github.com/openstack/puppet-tempest",
	:ref => "stable/mitaka"

mod "openstack-vswitch",
	:git => "git://github.com/openstack/puppet-vswitch",
	:ref => "stable/mitaka"

## R10K doesn't handle dependencies, so let's handle them here
# pointing to as many stable projects as possible
# TODO automate this dependency list

mod "puppetlabs/apache", :latest
mod "stahnma/epel", :latest
mod "garethr/erlang", :latest
mod "puppetlabs/inifile", :latest
mod "puppetlabs/mysql", "3.7.0"
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

mod "jdowning/statsd", :latest
