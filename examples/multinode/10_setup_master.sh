#!/bin/bash
# Set up the Puppet Master

vagrant ssh puppet -c "wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb; \
sudo dpkg -i puppetlabs-release-trusty.deb; \
sudo apt-get update; \
sudo apt-get install -y puppetmaster puppet git; \
sudo apt-get upgrade -y; \
sudo service puppetmaster restart; \
sudo puppet agent --enable; \
sudo puppet agent -t;"



#sudo rmdir /etc/puppet/modules || sudo unlink /etc/puppet/modules; \
#sudo ln -sf /vagrant/modules /etc/puppet/modules; \
