#!/bin/bash
# First-time setup script for Ansible DevContainer
# Run this script after opening the project in devcontainer for the first time

set -e

echo "=========================================="
echo "Ansible DevContainer - First Time Setup"
echo "=========================================="
echo ""

# Step 1: SSH Keys
echo "Step 1: Setting up SSH keys..."
echo "----------------------------------------"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$PROJECT_DIR/.ssh/ansible_rsa" ]; then
    "$SCRIPT_DIR/setup-ssh-keys.sh"
else
    echo "✓ SSH keys already configured"
fi
echo ""

# Step 2: Ansible Vault
echo "Step 2: Setting up Ansible Vault..."
echo "----------------------------------------"
if [ ! -f "$PROJECT_DIR/.vault_password" ]; then
    "$SCRIPT_DIR/setup-vault.sh"
else
    echo "✓ Ansible Vault already configured"
    echo "  Vault password file: $PROJECT_DIR/.vault_password"
    echo "  Vault file: group_vars/all/vault.yml"
fi
echo ""

# Step 3: Verify setup
echo "Step 3: Verifying setup..."
echo "----------------------------------------"

# Check SSH key
if [ -f "$PROJECT_DIR/.ssh/ansible_rsa" ]; then
    echo "✓ SSH private key exists"
else
    echo "✗ SSH private key missing"
fi

# Check vault password
if [ -f "$PROJECT_DIR/.vault_password" ]; then
    echo "✓ Vault password file exists"
else
    echo "✗ Vault password file missing"
fi

# Check vault file
if [ -f "$PROJECT_DIR/group_vars/all/vault.yml" ]; then
    echo "✓ Vault credentials file exists"
else
    echo "✗ Vault credentials file missing"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Copy your SSH public key to inventory hosts:"
echo "   cat $PROJECT_DIR/.ssh/ansible_rsa.pub"
echo ""
echo "2. Edit vault credentials (update passwords):"
echo "   ansible-vault edit group_vars/all/vault.yml"
echo ""
echo "3. Test connectivity:"
echo "   ansible-playbook test-connectivity.yml"
echo ""
echo "All credentials are stored in /workspace and will"
echo "persist across container rebuilds!"
echo ""
