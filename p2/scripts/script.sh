#!/bin/bash

# Install k3s
curl -sfL https://get.k3s.io | sh -

#install brew 
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/vagrant/.bashrc
#     eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# sudo apt-get install build-essential -y

# install miniKube && hyperkit

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# brew install minikube hyperkit

sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg


echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

sudo docker --version

sudo usermod -aG docker $USER
