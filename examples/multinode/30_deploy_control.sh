#!/bin/bash

# Kick off the puppet runs, control is first for databases
vagrant ssh control -c "sudo service firewalld stop; sudo yum remove -y firewalld; sudo puppet agent -t"
