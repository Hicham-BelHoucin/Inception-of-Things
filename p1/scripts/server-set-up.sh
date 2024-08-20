#!/bin/bash
	
sudo apt-get update
export IPV4=192.168.56.110
curl -sfL https://get.k3s.io | \
INSTALL_K3S_EXEC="--disable servicelb --flannel-backend=wireguard-native \ 
--disable traefik --node-ip $IPV4 --cluster-cidr 10.42.0.0/16 --service-cidr 10.43.0.0/16" sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
chmod 777 /var/lib/rancher/k3s/server/node-token
cp /var/lib/rancher/k3s/server/node-token /vagrant_shared/