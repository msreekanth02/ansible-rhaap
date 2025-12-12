#!/bin/bash
# Install Python on worker nodes that don't have it
# This script uses raw SSH commands since Ansible requires Python to be present

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.ssh/ansible_rsa"

# Array of hosts that need Python installed
HOSTS=(
    "192.168.1.10"   # worker01
    "192.168.1.11"   # worker02
    "192.168.1.12"   # worker03
    "192.168.1.14"   # worker04
)

echo "=========================================="
echo "Python Installation on Worker Nodes"
echo "=========================================="
echo ""
echo "This script will install Python 3 on worker nodes"
echo "that don't currently have it installed."
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
    
    # First, check if Python is already installed
    echo "Checking for Python..."
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "which python3" &>/dev/null; then
        PYTHON_VERSION=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version" 2>&1)
        echo "✓ Python already installed: $PYTHON_VERSION"
        ((SKIP_COUNT++))
        echo ""
        continue
    fi
    
    echo "Python not found. Installing..."
    
    # Detect the OS and install Python accordingly
    OS_TYPE=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "cat /etc/os-release | grep '^ID=' | cut -d= -f2 | tr -d '\"'" 2>/dev/null)
    
    echo "Detected OS: $OS_TYPE"
    
    case "$OS_TYPE" in
        rhel|centos|rocky|almalinux|fedora)
            echo "Installing Python using dnf/yum..."
            if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "echo 'Installing Python...' && sudo dnf install -y python3 || sudo yum install -y python3"; then
                echo "✓ Python installed successfully"
                ((SUCCESS_COUNT++))
            else
                echo "✗ Failed to install Python"
                ((FAIL_COUNT++))
            fi
            ;;
        ubuntu|debian)
            echo "Installing Python using apt..."
            if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "sudo apt-get update && sudo apt-get install -y python3"; then
                echo "✓ Python installed successfully"
                ((SUCCESS_COUNT++))
            else
                echo "✗ Failed to install Python"
                ((FAIL_COUNT++))
            fi
            ;;
        *)
            echo "⚠ Unknown OS type: $OS_TYPE"
            echo "Trying dnf/yum first..."
            if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "sudo dnf install -y python3 2>/dev/null || sudo yum install -y python3 2>/dev/null"; then
                echo "✓ Python installed successfully"
                ((SUCCESS_COUNT++))
            else
                echo "✗ Failed to install Python"
                ((FAIL_COUNT++))
            fi
            ;;
    esac
    
    # Verify installation
    if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version" &>/dev/null; then
        PYTHON_VERSION=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ansible@$host "python3 --version" 2>&1)
        echo "✓ Verified: $PYTHON_VERSION"
    fi
    
    echo ""
done

echo "=========================================="
echo "Summary"
echo "=========================================="
echo "✓ Successfully installed: $SUCCESS_COUNT"
echo "⊘ Already had Python:     $SKIP_COUNT"
echo "✗ Failed:                 $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All worker nodes now have Python! 🎉"
    echo ""
    echo "Next step: Test Ansible connectivity with:"
    echo "  ansible all -m ping"
else
    echo "Some installations failed. Check the errors above."
    echo "You may need to install Python manually on those hosts."
fi
