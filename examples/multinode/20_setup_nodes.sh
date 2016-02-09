#!/bin/bash

CMDS="sudo yum update -y; \
sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm; \
sudo yum update -y; \
sudo yum update -y; \
sudo yum remove -y firewalld; \
sudo puppet agent -t;"

# Connect the agents to the master
vagrant ssh control -c "$CMDS"
vagrant ssh network -c "$CMDS"
vagrant ssh storage -c "$CMDS"
vagrant ssh compute -c "$CMDS"

# sign the certs
vagrant ssh puppet -c "sudo puppet cert sign --all"
