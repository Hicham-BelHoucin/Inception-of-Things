#! /bin/bash

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110" sh -
while [ ! -d /var/lib/rancher/k3s/server/manifests/ ]; do
    sleep 1
done
cp /vagrant/* /var/lib/rancher/k3s/server/manifests/
