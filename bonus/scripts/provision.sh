#!/bin/bash

set -e
# ## tmp
# apt-get update && apt-get install -y \
#     curl \
#     ca-certificates \
#     gnupg

# # Add Docker GPG key and repository
# DOCKER_GPG_KEYRING="/usr/share/keyrings/docker.gpg"
# DOCKER_REPO="https://download.docker.com/linux/ubuntu"
# curl -fsSL "$DOCKER_REPO/gpg" | gpg --dearmor -o "$DOCKER_GPG_KEYRING"
# echo "deb [arch=$(dpkg --print-architecture) signed-by=$DOCKER_GPG_KEYRING] $DOCKER_REPO $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

# # Add Kubernetes GPG key and repository
# K8S_GPG_KEYRING="/usr/share/keyrings/kubernetes-apt-keyring.gpg"
# K8S_REPO="https://pkgs.k8s.io/core:/stable:/v1.31/deb"
# curl -fsSL "$K8S_REPO/Release.key" | gpg --dearmor -o "$K8S_GPG_KEYRING"
# echo "deb [arch=$(dpkg --print-architecture) signed-by=$K8S_GPG_KEYRING] $K8S_REPO/ /" | tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

# # Install Docker and Kubectl
# apt-get update && apt-get install -y \
#     docker-ce \
#     docker-ce-cli \
#     containerd.io \
#     docker-buildx-plugin \
#     docker-compose-plugin \
#     kubectl

# # Install k3d
# curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# ## tmp

# # Add Helm GPG key and repository
# HELM_GPG_KEYRING="/usr/share/keyrings/helm.gpg"
# HELM_REPO="https://baltocdn.com/helm"
# curl -fsSL "$HELM_REPO/signing.asc" | gpg --dearmor -o "$HELM_GPG_KEYRING"
# echo "deb [arch=$(dpkg --print-architecture) signed-by=$HELM_GPG_KEYRING] $HELM_REPO/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list >/dev/null

# # Update and install Helm
# apt-get update && apt-get install -y helm

# Add GitLab Helm repository
# k3d cluster create sel-mars --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer"
# kubectl create namespace gitlab
# helm repo add gitlab https://charts.gitlab.io
# export "KUBECONFIG=$(kubectl get pods -v=6 2>&1 | grep "Config loaded from file" | awk -F': ' '{print $2}')"
# helm repo update
# helm upgrade --install gitlab gitlab/gitlab --namespace gitlab --timeout 600s --set global.hosts.domain=sel-mars.com --set global.hosts.externalIP=192.168.57.100 --set certmanager-issuer.email=sel-mars@student.1337.ma
sudo helm upgrade --install gitlab gitlab/gitlab -n gitlab -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml --set global.hosts.domain=192.168.57.100.nip.io --set global.hosts.externalIP=192.168.57.100 --set global.edition=ce --timeout 600s
sudo kubectl wait --for=condition=available deployments --all -n gitlab
echo "=> GitLab is being installed..."
sleep 10
kubectl wait --for=condition=ready pod --all -n gitlab --timeout=15m
echo "=> GitLab is ready!"
