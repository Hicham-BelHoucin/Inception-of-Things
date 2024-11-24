#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

# Variables
UBUNTU_VERSION="20.04.6"
ISO_PATH="/Users/sel-mars/Downloads/ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso"
VM_NAME="Inception-Of-Things"
VM_PATH="$1/${VM_NAME}"
VDI_PATH="${VM_PATH}/${VM_NAME}.vdi"
VDI_SIZE=20480
MEMORY_SIZE=5120
CPU_COUNT=3
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

if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
    VBoxManage hostonlyif create
fi
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.57.1 --netmask 255.255.255.0

if VBoxManage list dhcpservers | grep -q "vboxnet0"; then
    VBoxManage dhcpserver remove --interface vboxnet0
fi

# Create VM and configure settings
VBoxManage createvm --name "${VM_NAME}" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "${VM_NAME}" --memory ${MEMORY_SIZE} --cpus ${CPU_COUNT} --vram ${VRAM_SIZE} --nested-hw-virt on --boot1 dvd --boot2 none --boot3 none --boot4 none --nic1 hostonly --hostonlyadapter1 vboxnet0 --nic2 nat --natpf2 "http,tcp,,80,,80" --natpf2 "https,tcp,,443,,443" --clipboard bidirectional --graphicscontroller vmsvga

# Create and attach virtual hard disk
VBoxManage createhd --filename "${VDI_PATH}" --size ${VDI_SIZE} --format VDI
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VDI_PATH}"

# Create and attach cloud-init ISO
hdiutil makehybrid -iso -joliet -default-volume-name cidata -o "${VM_PATH}/ubuntu-autoinstall.iso" ./confs/

# Attach the Ubuntu as Primary Device 0 and cidata as Primary Device 1
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium "${VM_PATH}/ubuntu-autoinstall.iso"

# Start the VM
VBoxManage startvm "${VM_NAME}" --type headless

# Wait for the VM to shutdown and finish installation
START_TIME=$(date +%s)
echo "$(date | awk '{print $4}') - Starting VM installation"
sleep 5
while VBoxManage showvminfo "${VM_NAME}" --machinereadable | grep -q "VMState=\"running\""; do

    echo -n "$(date | awk '{print $4}') - Waiting for VM installtion to finish"

    for _ in {1..10}; do
        echo -n "."
        sleep 3
    done
    echo -ne "\r\033[K"
done
END_TIME=$(date +%s)
SECONDS=$((END_TIME - START_TIME))
echo "$(date | awk '{print $4}') - VM installation finished"
echo -e "==> Total time taken: \033[1;97m$((SECONDS / 60)):$((SECONDS % 60))\033[0m"

sleep 5

# Remove isos and ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium none
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium none
rm -f "${VM_PATH}/ubuntu-autoinstall.iso"
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --remove
VBoxManage modifyvm "${VM_NAME}" --boot1 disk --boot2 none --boot3 none --boot4 none

# Take Snapshot
# VBoxManage snapshot "${VM_NAME}" take "InstallComplete"

VBoxManage startvm "${VM_NAME}" --type headless

echo -e "\033[1;32mVM has been created successfully!\033[0m"
echo -e "=> VM IP: \033[1;97m192.168.57.100\033[0m"
echo -e "=> VM name: \033[1;97m${VM_NAME}\033[0m"
echo -e "=> VM username: \033[1;97m${USERNAME}\033[0m"
echo -e "=> VM password: \033[1;97m${PASSWORD}\033[0m"

echo -e "\033[1;32mVM has been configured successfully!\033[0m"
