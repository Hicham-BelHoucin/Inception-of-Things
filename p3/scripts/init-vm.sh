#!/bin/bash

# Variables
UBUNTU_VERSION="20.04.6"
ISO_PATH="/Users/sel-mars/goinfre/ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso"
VM_NAME="Inception-Of-Things"
VDI_PATH="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/${VM_NAME}.vdi"
VDI_SIZE=10240
MEMORY_SIZE=4096
CPU_COUNT=2
VRAM_SIZE=16

USERNAME="ubuntu"
PASSWORD="ubuntu"

# Download Ubuntu ISO if it doesn't exist
if [ ! -f "${ISO_PATH}" ]; then
    echo "Downloading Ubuntu ISO..."
    curl -o "${ISO_PATH}" "https://releases.ubuntu.com/${UBUNTU_VERSION}/ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso"
fi

# Check if VM already exists
if VBoxManage list vms | grep -q "\"${VM_NAME}\""; then
    echo "VM already exists"
    exit 1
fi

# Configure hostonly network 192.168.56.1 if it doesn't exist
if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
    VBoxManage hostonlyif create
fi
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

# Create VM and configure settings
VBoxManage createvm --name "${VM_NAME}" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "${VM_NAME}" --memory ${MEMORY_SIZE} --cpus ${CPU_COUNT} --vram ${VRAM_SIZE} --boot1 dvd --boot2 none --boot3 none --boot4 none --nic1 nat --natpf1 "http,tcp,,80,,80" --natpf1 "https,tcp,,443,,443" --nic2 hostonly --hostonlyadapter2 vboxnet0 --clipboard bidirectional

# Create and attach virtual hard disk
VBoxManage createhd --filename "${VDI_PATH}" --size ${VDI_SIZE} --format VDI
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VDI_PATH}"

# Create and attach cloud-init ISO
hdiutil makehybrid -iso -joliet -default-volume-name cidata -o /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.iso ./confs/

# Attach the Ubuntu as Primary Device 0 and cidata as Primary Device 1
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.iso

# Start the VM
VBoxManage startvm "${VM_NAME}" --type headless

# Wait for the VM to shutdown and finish installtion to remove the isos
sleep 5
while VBoxManage showvminfo "${VM_NAME}" --machinereadable | grep -q "VMState=\"running\""; do
    echo -n "$(date | awk '{print $4}') - Waiting for VM installtion to finish"
    for _ in {1..10}; do
        echo -n "."
        sleep 3
    done
    echo -ne "\r\033[K"
done

echo "VM has been shutdown"

# Remove isos and ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium none
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium none
rm -f /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.iso
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --remove
VBoxManage modifyvm "${VM_NAME}" --boot1 disk --boot2 none --boot3 none --boot4 none

# Take Snapshot
VBoxManage snapshot "${VM_NAME}" take "InstallComplete"

VBoxManage startvm "${VM_NAME}" --type headless

echo -e "\033[1;32mVM has been created successfully!\033[0m"
echo -e "=> VM name: \033[1;97m${VM_NAME}\033[0m"
echo -e "=> VM username: \033[1;97m${USERNAME}\033[0m"
echo -e "=> VM password: \033[1;97m${PASSWORD}\033[0m"

echo -e "\033[1;32mVM has been configured successfully!\033[0m"
