#!/bin/bash

set -e

# Update and install essential packages
apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    virtualbox

# Add HashiCorp GPG key and repository
HASHICORP_GPG_KEYRING="/usr/share/keyrings/hashicorp-archive-keyring.gpg"
HASHICORP_REPO="https://apt.releases.hashicorp.com"
curl -fsSL "$HASHICORP_REPO/gpg" | gpg --dearmor -o "$HASHICORP_GPG_KEYRING"
echo "deb [arch=$(dpkg --print-architecture) signed-by=$HASHICORP_GPG_KEYRING] $HASHICORP_REPO $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

# Install Docker, Vagrant and Kubectl
apt-get update && apt-get install -y vagrant
