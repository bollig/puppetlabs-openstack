forge "http://forge.puppetlabs.com"

# THIS MODULE
mod "puppetlabs-openstack",
	:git => "git://github.com/bollig/puppetlabs-openstack",
	#:ref => "master"
	:ref => "ed9223f"


## The core OpenStack modules

mod 'oslo',
        :git => 'https://git.openstack.org/openstack/puppet-oslo',
        #:ref => 'master'
        :ref => '712515a'

mod "openstack-ceph",
	:git => "git://github.com/openstack/puppet-ceph",
	#:ref => "master"
	:ref => "4e73520"

mod "openstack-ec2api",
	:git => "git://github.com/openstack/puppet-ec2api",
	#:ref => "master"
	:ref => "b1bafda"

mod "openstack-keystone",
	:git => "git://github.com/openstack/puppet-keystone",
	#:ref => "stable/mitaka"
	:ref => "f7d6d81"

mod "openstack-aodh",
	:git => "git://github.com/openstack/puppet-aodh",
	#:ref => "stable/mitaka"
	:ref => "d958b17"

mod "openstack-trove",
	:git => "git://github.com/openstack/puppet-trove",
	#:ref => "stable/mitaka"
	:ref => "706e354"

mod "openstack-gnocchi",
	:git => "git://github.com/openstack/puppet-gnocchi",
	#:ref => "stable/mitaka"
	:ref => "132c85f"

mod "openstack-swift",
	:git => "git://github.com/openstack/puppet-swift",
	#:ref => "stable/mitaka"
	:ref => "b61475a"

mod "openstack-glance",
	:git => "git://github.com/openstack/puppet-glance",
	#:ref => "stable/mitaka"
	:ref => "659f1de"

mod "openstack-cinder",
	:git => "git://github.com/openstack/puppet-cinder",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "bf971fd"
	#:ref => "master"

mod "openstack-neutron",
	:git => "git://github.com/openstack/puppet-neutron",
	#:ref => "stable/mitaka"
	:ref => "3af5e9a"

mod "openstack-nova",
	:git => "git://github.com/openstack/puppet-nova",
	#:ref => "stable/mitaka"
	:ref => "fc2cd20"

mod "openstack-heat",
	:git => "git://github.com/openstack/puppet-heat",
	#:ref => "stable/mitaka"
	:ref => "2c5dc33"

mod "openstack-ceilometer",
	:git => "git://github.com/openstack/puppet-ceilometer",
	#:ref => "stable/mitaka"
	:ref => "ebc384a"

mod "openstack-horizon",
	:git => "git://github.com/openstack/puppet-horizon",
	#:ref => "stable/mitaka"
	:ref => "4e9c6ef"

mod "openstack-openstacklib",
	:git => "git://github.com/openstack/puppet-openstacklib",
	#:ref => "master"
	:ref => "a5f39c6"

mod "openstack-openstack_extras",
	:git => "git://github.com/openstack/puppet-openstack_extras",
	#:ref => "stable/mitaka"
	:ref => "c4692d5"

mod "openstack-tempest",
	:git => "git://github.com/openstack/puppet-tempest",
	#:ref => "stable/mitaka"
	:ref => "64afed1"

mod "openstack-vswitch",
	:git => "git://github.com/openstack/puppet-vswitch",
	#:ref => "stable/mitaka"
	:ref => "c64d07a"

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
mod "puppetlabs/haproxy", :latest
mod "dobbymoodge/acl", :latest
mod 'spiette-selinux', :latest
# indirect dependencies

mod "puppetlabs/firewall", :latest
mod "puppetlabs/apt", "1.8.0"
mod "puppetlabs/corosync", :latest
mod "puppetlabs/mongodb", :latest
mod "puppetlabs/ntp", '4.2.0'

mod "jdowning/statsd", :latest

