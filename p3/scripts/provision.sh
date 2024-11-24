#!/bin/bash

set -e

# Add Docker GPG key and repository
DOCKER_GPG_KEYRING="/usr/share/keyrings/docker.gpg"
DOCKER_REPO="https://download.docker.com/linux/ubuntu"
curl -fsSL "$DOCKER_REPO/gpg" | gpg --dearmor -o "$DOCKER_GPG_KEYRING"
echo "deb [arch=$(dpkg --print-architecture) signed-by=$DOCKER_GPG_KEYRING] $DOCKER_REPO $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

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
    kubectl

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install ArgoCD-CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
