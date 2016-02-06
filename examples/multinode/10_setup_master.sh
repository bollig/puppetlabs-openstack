#!/bin/bash
# Set up the Puppet Master

vagrant ssh puppet -c "sudo apt-get update; \
sudo apt-get install -y puppetmaster puppet; \
sudo rmdir /etc/puppet/modules || sudo unlink /etc/puppet/modules; \
sudo ln -sf /vagrant/modules /etc/puppet/modules; \
sudo ln -sf /vagrant/site.pp /etc/puppet/manifests/site.pp; \
sudo service puppetmaster restart; \
sudo puppet agent --enable; \
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb; \
sudo dpkg -i puppetlabs-release-pc1-trusty.deb; \
sudo apt-get update; \
sudo puppet agent -t;"
