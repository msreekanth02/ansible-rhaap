#!/bin/bash
# Ansible Vault Setup Script
# This script initializes Ansible Vault for secure credential storage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VAULT_PASSWORD_FILE="$PROJECT_DIR/.vault_password"
VAULT_FILE="$PROJECT_DIR/group_vars/all/vault.yml"

echo "==================================="
echo "Ansible Vault Setup"
echo "==================================="

# Create vault password file
if [ -f "${VAULT_PASSWORD_FILE}" ]; then
    echo "✓ Vault password file already exists"
else
    echo "Creating vault password file..."
    read -sp "Enter vault password (will be saved for future use): " VAULT_PASS
    echo
    echo "${VAULT_PASS}" > "${VAULT_PASSWORD_FILE}"
    chmod 600 "${VAULT_PASSWORD_FILE}"
    echo "✓ Vault password file created at ${VAULT_PASSWORD_FILE}"
fi

# Create group_vars directory structure
mkdir -p "$PROJECT_DIR/group_vars/all"

# Create vault file if it doesn't exist
if [ -f "${VAULT_FILE}" ]; then
    echo "✓ Vault file already exists at ${VAULT_FILE}"
    read -p "Do you want to edit it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ansible-vault edit "${VAULT_FILE}" --vault-password-file="${VAULT_PASSWORD_FILE}"
    fi
else
    echo "Creating encrypted vault file..."
    
    # Create temporary file with default content
    cat > /tmp/vault_template.yml << 'EOF'
---
# Encrypted credentials for Ansible
# These variables are encrypted with Ansible Vault

# SSH connection credentials
vault_ansible_user: ansible
vault_ansible_password: changeme

# Sudo/become password
vault_ansible_become_password: changeme

# Optional: SSH private key passphrase (if your key has one)
# vault_ssh_key_passphrase: changeme
EOF
    
    # Encrypt the file
    ansible-vault encrypt /tmp/vault_template.yml --vault-password-file="${VAULT_PASSWORD_FILE}" --output="${VAULT_FILE}" --encrypt-vault-id default
    rm /tmp/vault_template.yml
    
    echo "✓ Vault file created at ${VAULT_FILE}"
    echo ""
    echo "IMPORTANT: Edit the vault file to set your actual credentials:"
    echo "  ansible-vault edit ${VAULT_FILE}"
fi

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Vault password is saved in: ${VAULT_PASSWORD_FILE}"
echo "This file is gitignored and will persist in your workspace."
echo ""
echo "To edit vault variables:"
echo "  ansible-vault edit ${VAULT_FILE}"
echo ""
