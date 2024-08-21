#!/bin/bash
echo "Provisioning started" >> /vagrant/provision.log
sudo apt-get update >> /vagrant/provision.log
sudo apt-get install -y net-tools >> /vagrant/provision.log
echo "Provisioning finished" >> /vagrant/provision.log
