#!/bin/bash
# QEMU Alpine VM installation script
# This script boots from ISO to install Alpine Linux to disk

VM_DIR="$HOME/VMs"
VM_DISK="$VM_DIR/alpine-vm.qcow2"

# Find the latest Alpine ISO in Downloads
ISO_FILE=$(ls -t ~/Downloads/alpine-extended-*-x86_64.iso 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo "Error: Alpine extended ISO not found in ~/Downloads/"
    echo ""
    echo "Please download the latest Alpine extended ISO from:"
    echo "  https://alpinelinux.org/downloads/"
    echo ""
    echo "Save it to ~/Downloads/alpine-extended-X.X.X-x86_64.iso"
    exit 1
fi

# Create disk if it doesn't exist
if [ ! -f "$VM_DISK" ]; then
    echo "Creating VM disk image..."
    mkdir -p "$VM_DIR"
    qemu-img create -f qcow2 "$VM_DISK" 10G
fi

echo "Booting from ISO: $ISO_FILE"
echo "VM disk: $VM_DISK"
echo ""
echo "When Alpine boots:"
echo "  1. Login as root (no password)"
echo "  2. Run: setup-alpine"
echo "  3. Select sda as the disk"
echo "  4. Choose 'sys' installation type"
echo "  5. After installation, run: poweroff"
echo ""

# Start QEMU with ISO mounted, booting from CD
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -smp 2 \
    -drive file="$VM_DISK",format=qcow2 \
    -cdrom "$ISO_FILE" \
    -boot d \
    -display gtk \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0

