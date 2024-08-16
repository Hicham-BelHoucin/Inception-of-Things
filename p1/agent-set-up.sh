#!/bin/bash

# Install k3s as a server with flannel backend none
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://k3s.example.com --token mypassword" sh -s -

# changing the permission to avoid using sudo for kubectl
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
