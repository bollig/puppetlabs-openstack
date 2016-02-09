#!/bin/bash
# Set up the tempest box

CMDS="sudo yum update -y; \
sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm; \
sudo yum update -y; \
sudo yum update -y; \
sudo yum remove -y firewalld; \
sudo puppet agent -t;"

vagrant up tempest --provider virtualbox
vagrant ssh tempest -c "$CMDS"
vagrant ssh puppet -c "sudo puppet cert sign --all"
vagrant ssh tempest -c "sudo puppet agent -t"
