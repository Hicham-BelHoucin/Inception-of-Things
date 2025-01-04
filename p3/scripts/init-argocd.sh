#!/bin/bash

set -e

# Create a k3d cluster and setup Argo CD
k3d cluster create sel-mars --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer"
kubectl create namespace argocd
curl -sSL -o /root/p3/confs/argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
csplit -sf part_ -n 1 /root/p3/confs/argocd.yaml '/app.kubernetes.io\/name: argocd-cmd-params-cm/'
csplit -sf part_ -n 2 part_1 '/---/'
cat part_0 part_00 <(echo -e "data:\n  server.insecure: \"true\"") part_01 >/root/p3/confs/argocd.yaml
rm -f part_0 part_1 part_00 part_01
kubectl -n argocd apply -f /root/p3/confs/argocd.yaml

# Wait for Argo CD to be ready
echo "=> Waiting for ArgoCD to be ready..."
sleep 5
kubectl -n argocd wait --for=condition=ready pod --all --timeout=300s
echo "=> ArgoCD is ready!"

# Configure Argo CD
kubectl -n argocd apply -f /root/p3/confs/argocd-ingress.yaml
PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
argocd login localhost --insecure --grpc-web --username admin --password "$PASSWORD"

# Deploy the application
kubectl create namespace dev
argocd app create wil-playground --repo https://github.com/soofiane262/sel-mars.git --path wil-playground --dest-namespace dev --dest-server https://kubernetes.default.svc --sync-policy auto --revision HEAD

# Wait for the application service to be ready
sleep 5
kubectl -n dev wait --for=condition=ready pod --all --timeout=60s
echo "=> Wil-playground is ready!"

# Port-forward the application
kubectl -n dev port-forward svc/wil-playground 8888:8888 &>/dev/null &

# Display the ArgoCD admin password
echo -e "=> ArgoCD password: \033[0;31m$PASSWORD\033[0m"
