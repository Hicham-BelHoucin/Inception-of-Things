#!/bin/bash

# Update package list and install necessary dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl
sudo apt-get install -y net-tools

# Install K3s in controller mode
curl -sfL https://get.k3s.io | sh -

# Install kubectl
sudo snap install kubectl --classic

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

sudo chmod 777 /var/lib/rancher/k3s/server/node-token

# move token to shared folder
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/shared

# Set up passwordless SSH (if not already done)
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo kubectl apply -f /vagrant/shared/app2.yaml
sudo kubectl apply -f /vagrant/shared/app1.yaml
sudo kubectl apply -f /vagrant/shared/app3.yaml





