#!/bin/bash

# Enable verbose mode
set -x

# install k3d using curl
echo "Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
if [ $? -eq 0 ]; then
  echo "k3d installed successfully."
else
  echo "Failed to install k3d." >&2
  exit 1
fi

echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
if [ $? -eq 0 ]; then
  echo "Docker GPG key added successfully."
else
  echo "Failed to add Docker GPG key." >&2
  exit 1
fi

echo "Setting up Docker repository..."
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
if [ $? -eq 0 ]; then
  echo "Docker repository set up successfully."
else
  echo "Failed to set up Docker repository." >&2
  exit 1
fi

echo "Updating package list..."
sudo apt-get update
if [ $? -eq 0 ]; then
  echo "Package list updated successfully."
else
  echo "Failed to update package list." >&2
  exit 1
fi

echo "Installing Docker..."
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
if [ $? -eq 0 ]; then
  echo "Docker installed successfully."
else
  echo "Failed to install Docker." >&2
  exit 1
fi

echo "Checking Docker version..."
sudo docker --version
if [ $? -eq 0 ]; then
  echo "Docker version checked successfully."
else
  echo "Failed to check Docker version." >&2
  exit 1
fi

echo "Adding user to Docker group..."
sudo usermod -aG docker $USER
if [ $? -eq 0 ]; then
  echo "User added to Docker group successfully."
else
  echo "Failed to add user to Docker group." >&2
  exit 1
fi

# install kubectl using snap
echo "Installing kubectl..."
sudo snap install kubectl --classic
if [ $? -eq 0 ]; then
  echo "kubectl installed successfully."
else
  echo "Failed to install kubectl." >&2
  exit 1
fi

echo "Checking kubectl version..."
kubectl version --client

# create new cluster using k3d
echo "Creating new k3d cluster..."
k3d cluster create mycluster
if [ $? -eq 0 ]; then
  echo "k3d cluster created successfully."
else
  echo "Failed to create k3d cluster." >&2
  exit 1
fi

# createtwo name spaces one dev and one argocd
echo "Creating two namespaces..."
sudo kubectl create namespace dev
sudo kubectl create namespace argocd
if [ $? -eq 0 ]; then
  echo "Namespaces created successfully."
else
  echo "Failed to create namespaces." >&2
  exit 1
fi

# install argocd using kubectl
echo "Installing ArgoCD..."
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
if [ $? -eq 0 ]; then
  echo "ArgoCD installed successfully."
else
  echo "Failed to install ArgoCD." >&2
  exit 1
fi

#apply the argocd server and ui service
echo "Applying ArgoCD server and UI service..."
sudo kubectl apply -f /vagrant/confs/application.yml
if [ $? -eq 0 ]; then
  echo "ArgoCD server and UI service applied successfully."
else
  echo "Failed to apply ArgoCD server and UI service." >&2
  exit 1
fi

# Disable verbose mode
set +x

echo "Script execution completed."
