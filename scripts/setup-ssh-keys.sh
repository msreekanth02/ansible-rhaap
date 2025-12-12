#!/bin/bash
# SSH Key Setup Script for Ansible DevContainer
# This script sets up SSH keys for connecting to inventory hosts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_DIR="$PROJECT_DIR/.ssh"
SSH_KEY_NAME="ansible_rsa"
SSH_KEY_PATH="${SSH_DIR}/${SSH_KEY_NAME}"

echo "==================================="
echo "Ansible SSH Key Setup"
echo "==================================="

# Create .ssh directory if it doesn't exist
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Check if key already exists
if [ -f "${SSH_KEY_PATH}" ]; then
    echo "✓ SSH key already exists at ${SSH_KEY_PATH}"
    read -p "Do you want to regenerate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing SSH key."
        exit 0
    fi
fi

# Generate SSH key
echo "Generating new SSH key..."
ssh-keygen -t rsa -b 4096 -f "${SSH_KEY_PATH}" -N "" -C "ansible-automation"

chmod 600 "${SSH_KEY_PATH}"
chmod 644 "${SSH_KEY_PATH}.pub"

echo ""
echo "✓ SSH key generated successfully!"
echo ""
echo "==================================="
echo "Next Steps:"
echo "==================================="
echo ""
echo "1. Copy the public key to your inventory hosts:"
echo ""
cat "${SSH_KEY_PATH}.pub"
echo ""
echo "2. Run this command on each host (as the ansible user):"
echo "   mkdir -p ~/.ssh && chmod 700 ~/.ssh"
echo "   echo 'YOUR_PUBLIC_KEY_ABOVE' >> ~/.ssh/authorized_keys"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "3. Or use ssh-copy-id (if you have password access):"
echo "   ssh-copy-id -i ${SSH_KEY_PATH}.pub ansible@192.168.1.200"
echo ""
echo "==================================="
