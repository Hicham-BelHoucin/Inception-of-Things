#! /bin/bash

VM_NAME="Inception-Of-Things"
VM_PATH="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}"
CI_PATH="${VM_PATH}/ubuntu-autoinstall.iso"

# Stop the VM
echo "Stopping the VM..."
VBoxManage controlvm "${VM_NAME}" poweroff

# Remove the VM
echo "Removing the VM..."
VBoxManage unregistervm "${VM_NAME}" --delete

# Remove the cloud-init ISO
rm -f "${CI_PATH}"

# Remove ssh keys for ip 192.168.55.100 from known_hosts
ssh-keygen -R 192.168.55.100
