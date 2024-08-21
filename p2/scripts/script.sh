#!/bin/bash

# Enable verbose mode
set -x

echo "Starting k3s installation..."
curl -sfL https://get.k3s.io | sh -
if [ $? -eq 0 ]; then
  echo "k3s installation successful."
else
  echo "k3s installation failed." >&2
  exit 1
fi

echo "Setting permissions for k3s.yaml..."
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
if [ $? -eq 0 ]; then
  echo "Permissions set successfully."
else
  echo "Failed to set permissions for k3s.yaml." >&2
  exit 1
fi

echo "Installing dependencies..."
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common -y
if [ $? -eq 0 ]; then
  echo "Dependencies installed successfully."
else
  echo "Failed to install dependencies." >&2
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

echo "Applying Kubernetes configurations..."
kubectl apply -f /vagrant/confs/app-1/service.yml
kubectl apply -f /vagrant/confs/app-2/service.yml
kubectl apply -f /vagrant/confs/app-3/service.yml
kubectl apply -f /vagrant/confs/app-1/deployment.yml
kubectl apply -f /vagrant/confs/app-2/deployment.yml
kubectl apply -f /vagrant/confs/app-3/deployment.yml
kubectl apply -f /vagrant/confs/app-ingress.yml

if [ $? -eq 0 ]; then
  echo "Kubernetes configurations applied successfully."
else
  echo "Failed to apply Kubernetes configurations." >&2
  exit 1
fi

# Disable verbose mode
set +x

echo "Script execution completed."
