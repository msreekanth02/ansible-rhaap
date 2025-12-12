#!/bin/bash
# Copy SSH key to all inventory hosts
# This script will prompt for password for each host that doesn't have the key yet

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.ssh/ansible_rsa.pub"

# Array of all hosts from inventory
HOSTS=(
    "192.168.1.200"  # controller
    "192.168.1.10"   # worker01
    "192.168.1.11"   # worker02
    "192.168.1.12"   # worker03
    "192.168.1.14"   # worker04
    "192.168.1.206"  # worker06
)

echo "=========================================="
echo "Copying SSH Key to All Inventory Hosts"
echo "=========================================="
echo ""
echo "SSH Key: $SSH_KEY"
echo "Target User: ansible"
echo ""
echo "You will be prompted for the password for each host"
echo "that doesn't already have this key installed."
echo ""
read -p "Press Enter to continue..."
echo ""

SUCCESS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

for host in "${HOSTS[@]}"; do
    echo "=========================================="
    echo "Host: ansible@$host"
    echo "=========================================="
    
    # Run ssh-copy-id and capture output
    if ssh-copy-id -i "$SSH_KEY" ansible@$host 2>&1 | tee /tmp/ssh-copy-id.log; then
        if grep -q "All keys were skipped" /tmp/ssh-copy-id.log; then
            echo "✓ Key already exists on this host"
            ((SKIP_COUNT++))
        else
            echo "✓ Key successfully copied"
            ((SUCCESS_COUNT++))
        fi
    else
        # Check if it's just the "already exists" warning (exit code 1)
        if grep -q "All keys were skipped" /tmp/ssh-copy-id.log; then
            echo "✓ Key already exists on this host"
            ((SKIP_COUNT++))
        else
            echo "✗ Failed to copy key"
            ((FAIL_COUNT++))
        fi
    fi
    echo ""
done

echo "=========================================="
echo "Summary"
echo "=========================================="
echo "✓ Successfully copied: $SUCCESS_COUNT"
echo "⊘ Already existed:     $SKIP_COUNT"
echo "✗ Failed:              $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All hosts are configured! 🎉"
    echo ""
    echo "Next step: Test connectivity with:"
    echo "  ansible all -m ping"
else
    echo "Some hosts failed. Check the errors above."
fi
