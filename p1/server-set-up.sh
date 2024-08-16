#!/bin/bash

# Install k3s as a server with flannel backend none
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --flannel-backend none" K3S_TOKEN=12345 sh -s -


# changing the permission to avoid using sudo for kubectl
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
