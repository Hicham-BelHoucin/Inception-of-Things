#! /bin/bash

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110" sh -
cp /var/lib/rancher/k3s/server/node-token /vagrant/
