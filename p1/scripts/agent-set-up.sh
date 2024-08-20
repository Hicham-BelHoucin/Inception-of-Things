#!/bin/bash

sudo apt-get update
export SERVERIP=https://192.168.56.110:6443
export NODE_TOKEN=$(cat /vagrant/shared/node-token)
curl -sfL https://get.k3s.io | K3S_URL=$SERVERIP K3S_TOKEN=$NODE_TOKEN sh -