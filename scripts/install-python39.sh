#!/bin/bash
# Install Python 3.9 on CentOS 8 worker nodes
# Python 3.6 is too old for modern Ansible

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.ssh/ansible_rsa"

# Array of hosts that need Python 3.9
HOSTS=(
    "192.168.1.10"   # worker01
    "192.168.1.11"   # worker02
    "192.168.1.12"   # worker03
    "192.168.1.14"   # worker04
)

echo "=========================================="
echo "Python 3.9 Installation on CentOS 8"
echo "=========================================="
echo ""
echo "Modern Ansible requires Python 3.8+."
echo "This script will install Python 3.9 on CentOS 8 hosts."
echo ""
echo "Hosts to process:"
for host in "${HOSTS[@]}"; do
    echo "  - ansible@$host"
done
echo ""
read -p "Press Enter to continue..."
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

for host in "${HOSTS[@]}"; do
    echo "=========================================="
    echo "Host: ansible@$host"
    echo "=========================================="
    
    # Check current Python version
    echo "Checking Python version..."
    CURRENT_PYTHON=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version 2>&1 | grep -oP '3\.\d+'" 2>/dev/null || echo "0.0")
    echo "Current Python: $CURRENT_PYTHON"
    
    # Check if Python 3.9+ is already installed
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "which python3.9" &>/dev/null; then
        PY39_VERSION=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3.9 --version" 2>&1)
        echo "✓ Python 3.9+ already installed: $PY39_VERSION"
        ((SKIP_COUNT++))
        echo ""
        continue
    fi
    
    echo "Installing Python 3.9..."
    
    # Install Python 3.9 on CentOS 8
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "
        echo 'Installing Python 3.9...' && \
        sudo dnf install -y python39 python39-pip && \
        echo 'Setting Python 3.9 as default python3...' && \
        sudo alternatives --set python3 /usr/bin/python3.9 || \
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    "; then
        echo "✓ Python 3.9 installed successfully"
        ((SUCCESS_COUNT++))
    else
        echo "✗ Failed to install Python 3.9"
        ((FAIL_COUNT++))
    fi
    
    # Verify installation
    echo -n "Verifying installation... "
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version" &>/dev/null; then
        PYTHON_VERSION=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version" 2>&1)
        echo "✓ $PYTHON_VERSION"
    else
        echo "✗ Python verification failed"
    fi
    
    echo ""
done

echo "=========================================="
echo "Summary"
echo "=========================================="
echo "✓ Successfully installed: $SUCCESS_COUNT"
echo "⊘ Already had Python 3.9+: $SKIP_COUNT"
echo "✗ Failed:                  $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All worker nodes now have Python 3.9+! 🎉"
    echo ""
    echo "Next step: Test Ansible connectivity with:"
    echo "  cd /workspaces/ansible-rhaap"
    echo "  ansible all -m ping"
else
    echo "Some installations failed. Check the errors above."
fi
