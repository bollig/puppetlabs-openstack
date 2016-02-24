#!/bin/bash

# Install RDO
# Remove Firewall
# Remove NetworkManager
CMDS="sudo yum update -y; \
sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm; \
sudo yum update -y; \
sudo yum update -y; \
sudo yum remove -y firewalld NetworkManager; \
sudo systemctl stop NetworkManager; \
sudo systemctl disable NetworkManager; \
sudo systemctl start network; \
sudo puppet agent -t;"

# Connect the agents to the master
vagrant ssh control -c "$CMDS"
#vagrant ssh network -c "$CMDS"
#vagrant ssh storage -c "$CMDS"
vagrant ssh compute01 -c "$CMDS"
#vagrant ssh compute02 -c "$CMDS"

# sign the certs
vagrant ssh puppet -c "sudo puppet cert sign --all"

# Gives us a snapshot to roll everything back in time
vagrant sandbox on 
