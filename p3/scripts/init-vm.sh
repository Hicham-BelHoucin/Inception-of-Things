#!/bin/bash

# Variables
# UBUNTU_VERSION="20.04"
ISO_PATH="/Users/sel-mars/goinfre/ubuntu-20.04.6-live-server-amd64.iso"
VM_NAME="Inception-Of-Things-P3"
SHARED_FOLDER="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/shared"
VDI_PATH="/Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/${VM_NAME}.vdi"
VDI_SIZE=10240
MEMORY_SIZE=4096
CPU_COUNT=2
VRAM_SIZE=16

# Check if VM already exists
if VBoxManage list vms | grep -q "\"${VM_NAME}\""; then
    echo "VM already exists"
    exit 1
fi

# Create VM
VBoxManage createvm --name "${VM_NAME}" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "${VM_NAME}" --memory ${MEMORY_SIZE} --cpus ${CPU_COUNT} --vram ${VRAM_SIZE}

# Create and attach virtual hard disk
VBoxManage createhd --filename "${VDI_PATH}" --size ${VDI_SIZE} --format VDI
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VDI_PATH}"

# Set up shared folder
VBoxManage sharedfolder add "${VM_NAME}" --name "shared" --hostpath "${SHARED_FOLDER}" --automount

# Create and configure Host-Only Network
# VBoxManage hostonlyif create
# VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
# VBoxManage modifyvm "${VM_NAME}" --nic1 hostonly --hostonlyadapter1 vboxnet0

# Set up network port forwarding for SSH, HTTP, and HTTPS
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guest_ssh,tcp,,2222,,22"
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guest_http,tcp,,80,,80"
VBoxManage modifyvm "${VM_NAME}" --natpf1 "guest_https,tcp,,443,,443"

# # Listen for a username and password
# # read -p "Enter a username: " USERNAME
# read -s -p "Enter a password: " PASSWORD
# HASHED_PASSWORD=$(echo -n "$PASSWORD" | openssl dgst -sha512)

# # Copy cloud-init configuration file replacing "password" with the hashed password and
# # copy it to a temporary directory along with meta-data from ./confs

if [ -d /tmp/cloud-init ]; then
    rm -rf /tmp/cloud-init
fi
mkdir /tmp/cloud-init
# cp ./confs/user-data /tmp/cloud-init/user-data
# cp ./confs/meta-data /tmp/cloud-init/meta-data
# sed -i '' "s|passwordPlaceholder|$HASHED_PASSWORD|g" /tmp/cloud-init/user-data

# !tmp
cp ./confs/user-data /tmp/cloud-init/user-data
cp ./confs/meta-data /tmp/cloud-init/meta-data
hdiutil makehybrid -iso -joliet -default-volume-name cidata -o /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.iso /tmp/cloud-init
# END !tmp

# # Create FAT-32 file and convert it to vmdk
# if [ -f /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg ]; then
#     hdiutil detach /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg
#     rm -rf /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg
# fi
# hdiutil create -ov -size 100m -fs fat32 -volname cidata /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg
# DISK_PATH=$(hdiutil attach /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg | grep FDisk_partition_scheme | awk '{print $1}')
# diskutil unmountDisk "${DISK_PATH}"
# sleep 2
# VBoxManage createmedium disk --filename /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.vmdk --format VMDK --variant RawDisk --property RawDrive="${DISK_PATH}"
# diskutil mountDisk "${DISK_PATH}"
# sleep 2

# cp /tmp/cloud-init/user-data /Volumes/cidata/user-data
# cp /tmp/cloud-init/meta-data /Volumes/cidata/meta-data

# Make a FAT-32 formatted disk image and mount it
# hdiutil create -ov -size 100m -fs fat32 -volname cidata /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg
# hdiutil attach /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg

# Create raw disk image
# VBoxManage internalcommands createrawvmdk -filename /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.vmdk -rawdisk /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.dmg

# Attach the Ubuntu to device 0 and cloud-init ISO to device 1
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "${ISO_PATH}"
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium /Users/sel-mars/goinfre/VirtualBox/${VM_NAME}/ubuntu-autoinstall.iso

# Disable Floppy from booting and enable Hard Disk + CD/DVD
VBoxManage modifyvm "${VM_NAME}" --boot1 disk --boot2 dvd --boot3 none --boot4 none

# Start the VM
VBoxManage startvm "${VM_NAME}" --type gui
