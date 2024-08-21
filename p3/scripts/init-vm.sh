#!/bin/bash

# Variables
# UBUNTU_VERSION="20.04"
ISO_PATH="/Users/sel-mars/goinfre/ubuntu-20.04.6-live-server-amd64.iso"
VM_NAME="Inception-Of-Things-P3"
SHARED_FOLDER="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/shared"
VDI_PATH="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/${VM_NAME}.vdi"
VDI_SIZE=10240
MEMORY_SIZE=2048
CPU_COUNT=1
VRAM_SIZE=16

# Check if VM already exists
if VBoxManage list vms | grep -q "\"${VM_NAME}\""; then
    echo "VM already exists"
    exit 1
fi

# Create VM
VBoxManage createvm --name "${VM_NAME}" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "${VM_NAME}" --memory ${MEMORY_SIZE} --cpus ${CPU_COUNT} --vram ${VRAM_SIZE}

# Create and attach virtual hard disk and IDE Controller
VBoxManage createhd --filename "${VDI_PATH}" --size ${VDI_SIZE} --format VDI
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VDI_PATH}"
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"

# Set up shared folder
VBoxManage sharedfolder add "${VM_NAME}" --name "shared" --hostpath "${SHARED_FOLDER}" --automount

# Disable Floppy from booting and enable Hard Disk + CD/DVD
VBoxManage modifyvm "${VM_NAME}" --boot1 disk --boot2 dvd --boot3 none --boot4 none

# Set up network port forwarding for SSH, HTTP, and HTTPS
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guestssh,tcp,,2222,,22"
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guesthttp,tcp,,80,,80"
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guesthttps,tcp,,443,,443"

# Listen for a username and password
read -p "Enter a Full Name: " FULL_NAME
read -p "Enter a username: " USERNAME
read -s -p "Enter a password: " PASSWORD

# VBoxManage: error: Incomplete hostname 'Inception-Of-Things-P3' - must include both a name and a domain
VBoxManage unattended install "${VM_NAME}" \
    --full-user-name="${FULL_NAME}" \
    --user="${USERNAME}" \
    --password="${PASSWORD}" \
    --locale=en_US \
    --country=US \
    --time-zone=UTC+1 \
    --hostname="${VM_NAME}.local" \
    --iso="${ISO_PATH}" \
    --install-additions

# Start the VM
VBoxManage startvm "${VM_NAME}" --type gui
