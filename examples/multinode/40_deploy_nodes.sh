#!/bin/bash

# Remainder of nodes follow
vagrant ssh network -c "sudo service firewalld stop; sudo yum remove -y firewalld; sudo puppet agent -t"
vagrant ssh storage -c "sudo service firewalld stop; sudo yum remove -y firewalld; sudo puppet agent -t"
vagrant ssh compute -c "sudo service firewalld stop; sudo yum remove -y firewalld; sudo puppet agent -t"

wait
