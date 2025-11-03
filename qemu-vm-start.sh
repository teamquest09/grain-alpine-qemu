#!/bin/bash
# QEMU Alpine VM startup script with proper networking
# This script boots Alpine from the installed disk (sda)
# Networking is configured with user-mode NAT

VM_DIR="$HOME/VMs"
VM_DISK="$VM_DIR/alpine-vm.qcow2"
# ISO_FILE="$HOME/Downloads/alpine-extended-3.22.2-x86_64.iso"  # Not needed after installation

# Check if VM disk exists
if [ ! -f "$VM_DISK" ]; then
    echo "Creating VM disk image..."
    mkdir -p "$VM_DIR"
    qemu-img create -f qcow2 "$VM_DISK" 10G
    echo "Note: You'll need to install Alpine using setup-alpine first!"
fi

# Start QEMU with user-mode networking (slirp) - works out of the box
# This provides NAT networking and should work immediately
# Boots from hard disk (sda) where Alpine is installed
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -smp 2 \
    -drive file="$VM_DISK",format=qcow2 \
    -boot c \
    -display gtk \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0

# Alternative: If you want to use bridge networking (requires setup):
# qemu-system-x86_64 \
#     -enable-kvm \
#     -m 2048 \
#     -smp 2 \
#     -drive file="$VM_DISK",format=qcow2 \
#     -boot c \
#     -display gtk \
#     -netdev bridge,id=net0,br=virbr0 \
#     -device virtio-net,netdev=net0

# To reinstall Alpine (boot from ISO):
# qemu-system-x86_64 \
#     -enable-kvm \
#     -m 2048 \
#     -smp 2 \
#     -drive file="$VM_DISK",format=qcow2 \
#     -cdrom "$ISO_FILE" \
#     -boot d \
#     -display gtk \
#     -netdev user,id=net0,hostfwd=tcp::2222-:22 \
#     -device virtio-net,netdev=net0

