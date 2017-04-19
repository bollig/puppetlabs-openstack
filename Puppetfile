forge "http://forge.puppetlabs.com"

# THIS MODULE
mod "puppetlabs-openstack",
	:git => "git://github.com/bollig/puppetlabs-openstack",
	#:ref => "master"
	:ref => "newton"

## The core OpenStack modules

mod 'oslo',
        :git => 'https://git.openstack.org/openstack/puppet-oslo',
        #:ref => 'master'
	#:ref => "stable/newton"
        :ref => '8cbfbcf'

mod "openstack-ceph",
	:git => "git://github.com/openstack/puppet-ceph",
	#:ref => "master"
	:ref => "4e73520"

mod "openstack-ec2api",
	:git => "git://github.com/openstack/puppet-ec2api",
	#:ref => "master"
	:ref => "02bacd2"

mod "openstack-keystone",
	:git => "git://github.com/openstack/puppet-keystone",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "e667a45"

mod "openstack-murano",
	:git => "git://github.com/openstack/puppet-murano",
	#:ref => "stable/newton"
	:ref => "ea616d1"
        

mod "openstack-barbican",
	:git => "git://github.com/openstack/puppet-barbican",
	#:ref => "stable/newton"
	:ref => "cefec82"

mod "openstack-aodh",
	:git => "git://github.com/openstack/puppet-aodh",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "a73d235"

mod "openstack-trove",
	:git => "git://github.com/openstack/puppet-trove",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "1fb091b"

mod "openstack-gnocchi",
	:git => "git://github.com/openstack/puppet-gnocchi",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "e45b5d3"

mod "openstack-swift",
	:git => "git://github.com/openstack/puppet-swift",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "1d4afc0"

mod "openstack-glance",
	:git => "git://github.com/openstack/puppet-glance",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "5617abf"

mod "openstack-cinder",
	:git => "git://github.com/openstack/puppet-cinder",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "3f2b95e"

mod "openstack-neutron",
	:git => "git://github.com/openstack/puppet-neutron",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "628fc95"

mod "openstack-nova",
	:git => "git://github.com/openstack/puppet-nova",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "a6c45ec"

mod "openstack-heat",
	:git => "git://github.com/openstack/puppet-heat",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "3081de4"

mod "openstack-ceilometer",
	:git => "git://github.com/openstack/puppet-ceilometer",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "8d2093e"

mod "openstack-horizon",
	:git => "git://github.com/openstack/puppet-horizon",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "c53f2b6"

mod "openstack-openstacklib",
	:git => "git://github.com/openstack/puppet-openstacklib",
	#:ref => "master"
	#:ref => "stable/newton"
	:ref => "b7d9935"

mod "openstack-openstack_extras",
	:git => "git://github.com/openstack/puppet-openstack_extras",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "5ea8ac8"

mod "openstack-tempest",
	:git => "git://github.com/openstack/puppet-tempest",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "83c229f"

mod "openstack-vswitch",
	:git => "git://github.com/openstack/puppet-vswitch",
	#:ref => "stable/mitaka"
	#:ref => "stable/newton"
	:ref => "fc04875"

## R10K doesn't handle dependencies, so let's handle them here
# pointing to as many stable projects as possible
# TODO automate this dependency list

mod "puppetlabs/apache", '1.10.0'
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
#mod 'spiette-selinux', :latest
mod 'jfryman-selinux', :latest
# indirect dependencies

mod "puppetlabs/firewall", '1.8.1'
mod "puppetlabs/apt", "1.8.0"
mod "puppetlabs/corosync", :latest
mod "puppetlabs/mongodb", :latest
mod "puppetlabs/ntp", '4.2.0'

mod "jdowning/statsd", :latest

