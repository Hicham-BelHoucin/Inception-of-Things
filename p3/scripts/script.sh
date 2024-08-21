#!/bin/bash

# Check if k3d is already installed
if ! command -v k3d &> /dev/null; then
  echo "Installing k3d..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  if [ $? -eq 0 ]; then
    echo "k3d installed successfully."
  else
    echo "Failed to install k3d." >&2
    exit 1
  fi
else
  echo "k3d is already installed."
fi

# Check if Docker's GPG key is already added
if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
  echo "Adding Docker's official GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  if [ $? -eq 0 ]; then
    echo "Docker GPG key added successfully."
  else
    echo "Failed to add Docker GPG key." >&2
    exit 1
  fi
else
  echo "Docker GPG key is already added."
fi

# Check if Docker repository is already set up
if ! grep -q "^deb .*docker" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
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
else
  echo "Docker repository is already set up."
fi

echo "Updating package list..."
sudo apt-get update
if [ $? -eq 0 ]; then
  echo "Package list updated successfully."
else
  echo "Failed to update package list." >&2
  exit 1
fi

# Check if Docker is already installed
if ! dpkg -l | grep -q docker-ce; then
  echo "Installing Docker..."
  sudo apt-get install docker-ce docker-ce-cli containerd.io -y
  if [ $? -eq 0 ]; then
    echo "Docker installed successfully."
  else
    echo "Failed to install Docker." >&2
    exit 1
  fi
else
  echo "Docker is already installed."
fi

# Check Docker version
sudo docker --version
if [ $? -eq 0 ]; then
  echo "Docker version checked successfully."
else
  echo "Failed to check Docker version." >&2
  exit 1
fi

# Check if user is already in Docker group
if ! groups $USER | grep -q "\bdocker\b"; then
  echo "Adding user to Docker group..."
  sudo usermod -aG docker $USER
  if [ $? -eq 0 ]; then
    echo "User added to Docker group successfully."
  else
    echo "Failed to add user to Docker group." >&2
    exit 1
  fi
else
  echo "User is already in Docker group."
fi

# Check if kubectl is already installed
if ! command -v kubectl &> /dev/null; then
  echo "Installing kubectl..."
  sudo snap install kubectl --classic
  if [ $? -eq 0 ]; then
    echo "kubectl installed successfully."
  else
    echo "Failed to install kubectl." >&2
    exit 1
  fi
else
  echo "kubectl is already installed."
fi

# Check kubectl version
sudo kubectl version --client

# Check if k3d cluster already exists
if ! sudo k3d cluster list | grep -q mycluster; then
  echo "Creating new k3d cluster..."
  sudo k3d cluster create mycluster
  if [ $? -eq 0 ]; then
    echo "k3d cluster created successfully."
  else
    echo "Failed to create k3d cluster." >&2
    exit 1
  fi
else
  echo "k3d cluster 'mycluster' already exists."
fi

# Check if namespaces already exist
if ! sudo kubectl get namespace dev &> /dev/null; then
  echo "Creating 'dev' namespace..."
  sudo kubectl create namespace dev
else
  echo "'dev' namespace already exists."
fi

if ! sudo kubectl get namespace argocd &> /dev/null; then
  echo "Creating 'argocd' namespace..."
  sudo kubectl create namespace argocd
else
  echo "'argocd' namespace already exists."
fi

# Check if ArgoCD is already installed
if ! sudo kubectl get pods -n argocd &> /dev/null; then
  echo "Installing ArgoCD..."
  sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  if [ $? -eq 0 ]; then
    echo "ArgoCD installed successfully."
  else
    echo "Failed to install ArgoCD." >&2
    exit 1
  fi
else
  echo "ArgoCD is already installed."
fi

# Apply the ArgoCD server and UI service
echo "Applying ArgoCD server and UI service..."
sudo kubectl apply -f /home/hbelhou/Desktop/Inception-of-Things/p3/confs/application.yml
if [ $? -eq 0 ]; then
  echo "ArgoCD server and UI service applied successfully."
else
  echo $(pwd)
  echo "Failed to apply ArgoCD server and UI service." >&2
  exit 1
fi

# forward port 
sudo kubectl port-forward svc/argocd-server -n argocd 8080:80 &

echo "Script execution completed."
