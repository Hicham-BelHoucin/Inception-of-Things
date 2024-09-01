#!/bin/bash

set -e

# Update and install essential packages
apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    virtualbox

# Add Docker GPG key and repository
DOCKER_GPG_KEYRING="/usr/share/keyrings/docker.gpg"
DOCKER_REPO="https://download.docker.com/linux/ubuntu"
curl -fsSL "$DOCKER_REPO/gpg" | gpg --dearmor -o "$DOCKER_GPG_KEYRING"
echo "deb [arch=$(dpkg --print-architecture) signed-by=$DOCKER_GPG_KEYRING] $DOCKER_REPO $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

# Add HashiCorp GPG key and repository
HASHICORP_GPG_KEYRING="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
HASHICORP_REPO="https://apt.releases.hashicorp.com"
curl -fsSL "$HASHICORP_REPO/gpg" | gpg --dearmor -o "$HASHICORP_GPG_KEYRING"
echo "deb [arch=$(dpkg --print-architecture) signed-by=$HASHICORP_GPG_KEYRING] $HASHICORP_REPO $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

# Add Kubernetes GPG key and repository
K8S_GPG_KEYRING="/usr/share/keyrings/kubernetes-apt-keyring.gpg"
K8S_REPO="https://pkgs.k8s.io/core:/stable:/v1.31/deb"
curl -fsSL "$K8S_REPO/Release.key" | gpg --dearmor -o "$K8S_GPG_KEYRING"
echo "deb [arch=$(dpkg --print-architecture) signed-by=$K8S_GPG_KEYRING] $K8S_REPO/ /" | tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

# Install Docker, Vagrant and Kubectl
apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    vagrant \
    kubectl

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install ArgoCD-CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Create a k3d cluster and setup Argo CD
k3d cluster create sel-mars --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer"
kubectl create namespace argocd
curl -sSL -o /home/ubuntu/p3/confs/argocd.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
csplit -sf part_ -n 1 /home/ubuntu/p3/confs/argocd.yaml '/app.kubernetes.io\/name: argocd-cmd-params-cm/'
csplit -sf part_ -n 2 part_1 '/---/'
cat part_0 part_00 <(echo -e "data:\n  server.insecure: \"true\"") part_01 >/home/ubuntu/p3/confs/argocd.yaml
rm -f part_0 part_1 part_00 part_01
kubectl -n argocd apply -f /home/ubuntu/p3/confs/argocd.yaml

# Wait for Argo CD to be ready
echo "=> Waiting for ArgoCD to be ready..."
sleep 5
kubectl -n argocd wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s
echo "=> ArgoCD is ready!"

# Configure Argo CD
kubectl -n argocd apply -f /home/ubuntu/p3/confs/argocd-ingress.yaml
PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
argocd login localhost --insecure --grpc-web --username admin --password "$PASSWORD"

# Deploy the application
kubectl create namespace dev
argocd app create wil-playground --repo https://github.com/soofiane262/sel-mars.git --path wil-playground --dest-namespace dev --dest-server https://kubernetes.default.svc --sync-policy auto --revision main

# Wait for the application service to be ready
sleep 5
kubectl -n dev wait --for=condition=ready pod -l app=wil-playground --timeout=60s
echo "=> Wil-playground is ready!"

# Port-forward the application
kubectl -n dev port-forward svc/wil-playground 8888:8888 &

# Display the ArgoCD admin password
echo -e "=> ArgoCD password: \033[1;31m$PASSWORD\033[0m"
