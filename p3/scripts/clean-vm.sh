#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

# Variables
VM_NAME="Inception-Of-Things"
VM_PATH="$1/${VM_NAME}"
CI_PATH="${VM_PATH}/ubuntu-autoinstall.iso"

# Stop the VM
echo "Stopping the VM..."
VBoxManage controlvm "${VM_NAME}" poweroff

sleep 2

# Remove the VM
echo "Removing the VM..."
VBoxManage unregistervm "${VM_NAME}" --delete

# Remove the cloud-init ISO
rm -f "${CI_PATH}"

# Remove ssh keys from known_hosts
ssh-keygen -R 192.168.57.100
