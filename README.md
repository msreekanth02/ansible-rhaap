# Ansible Automation Platform - Infrastructure Management

This project provides a complete Ansible automation solution for managing infrastructure. It includes **persistent, secure credential management** using SSH keys and Ansible Vault.

## ✨ Features

- **🔐 Secure Authentication**: SSH key-based authentication with Ansible Vault
- **📊 Inventory Management**: Organized host groups with parent-child hierarchy
- **🐍 Python Auto-Discovery**: Supports multiple Python versions (3.9, 3.12)
- **🛡️ Persistent Storage**: All credentials survive container rebuilds
- **📝 Git-Safe**: Sensitive files automatically excluded via `.gitignore`

## 📋 Current Infrastructure Status

**Active Hosts:** 12/13 (92% operational)

- ✅ **Controller:** 192.168.1.200 (Python 3.9)
- ✅ **Workers:** 
  - worker01-06, worker08-09 (Python 3.9)
  - worker10-12 (Python 3.12 - CentOS Stream 10)
- ⏸️ **Temporarily Disabled:** worker07 (192.168.1.198) - SSH service issue

## 🚀 Quick Start

### 1. Open in DevContainer

1. Open this project in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. Wait for container to build

### 2. First-Time Setup

Run the setup script inside the devcontainer:

```bash
./scripts/first-time-setup.sh
```

This will:
- Generate SSH keys (stored in `.ssh/ansible_rsa`)
- Create vault password file (stored in `.vault_password`)
- Create encrypted credentials file (`group_vars/all/vault.yml`)

### 3. Configure Credentials

#### Copy SSH Public Key to Hosts

Display your public key:
```bash
cat .ssh/ansible_rsa.pub
```

Copy it to each inventory host:
```bash
# Option 1: Using ssh-copy-id (if you have password access)
ssh-copy-id -i .ssh/ansible_rsa.pub ansible@192.168.1.200

# Option 2: Manual copy
# On each host, run:
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

#### Update Vault Credentials

Edit the encrypted vault file:
```bash
ansible-vault edit group_vars/all/vault.yml
```

Update these values:
```yaml
vault_ansible_user: ansible              # SSH username
vault_ansible_password: your_password    # SSH password (fallback)
vault_ansible_become_password: your_sudo_password  # Sudo password
```

### 4. Test Connectivity

```bash
ansible-playbook test-connectivity.yml
```

## 🎭 Available Playbooks & Roles

This platform includes **custom roles** for common infrastructure tasks:

### Quick Commands
```bash
# Test connectivity to all hosts
ansible-playbook playbooks/ping.yml

# Collect system information and generate reports
ansible-playbook playbooks/system_info.yml

# Fetch reports from controller to local machine
ansible-playbook playbooks/fetch_reports.yml
```

### Custom Roles

#### 1. **Ping Role** - Connectivity Testing
- Tests SSH connectivity to all managed hosts
- Displays success indicators
- Quick health check

#### 2. **System Info Role** - Infrastructure Inventory
- Collects: OS, kernel, Python version, CPU, memory, uptime
- Generates detailed text reports
- Reports stored on controller at `/tmp/ansible-reports/`
- Fetch to local machine with `fetch_reports.yml`

📚 **For detailed documentation**, see [PLAYBOOKS_AND_ROLES.md](PLAYBOOKS_AND_ROLES.md)

## 📁 Project Structure

```
ansible-rhaap/
├── .devcontainer/          # DevContainer configuration
├── .ssh/                   # SSH keys (gitignored, persistent)
├── .vault_password         # Vault password (gitignored, persistent)
├── group_vars/
│   └── all/
│       ├── vars.yml        # Non-encrypted variables (Python auto-discovery, SSH settings)
│       └── vault.yml       # Encrypted credentials
├── playbooks/              # Custom playbooks
│   ├── ping.yml           # Connectivity testing
│   ├── system_info.yml    # System information collection
│   └── fetch_reports.yml  # Fetch reports from controller
├── reports/                # Generated system reports (gitignored)
├── roles/                  # Custom Ansible roles
│   ├── ping/              # Connectivity testing role
│   └── system_info/       # System information collection role
├── scripts/
│   ├── first-time-setup.sh        # Main setup script
│   ├── setup-ssh-keys.sh          # SSH key generation
│   ├── setup-vault.sh             # Vault initialization
│   ├── copy-ssh-key-to-all.sh     # Distribute SSH keys to all hosts
│   ├── install-python-on-workers.sh  # Install Python on worker nodes
│   └── install-python39.sh        # Install Python 3.9 specifically
├── ansible.cfg             # Ansible configuration
├── inventory.yml           # Host inventory (execution_nodes, automationcontroller)
├── test-connectivity.yml   # Connectivity test playbook
├── PLAYBOOKS_AND_ROLES.md  # Detailed playbook and role documentation
└── WORKER07_TROUBLESHOOTING.md  # SSH troubleshooting guide
```

## 🔑 Authentication Methods

The setup supports **multiple authentication methods** with automatic fallback:

### Primary: SSH Key Authentication
- Uses project-specific SSH key: `.ssh/ansible_rsa`
- Most secure and recommended method
- No password needed after initial setup

### Fallback: Password Authentication
- Stored encrypted in Ansible Vault
- Used if SSH key authentication fails
- Uncomment `ansible_password` in `group_vars/all/vars.yml` to enable

### Sudo/Become Password
- Required for privilege escalation
- Stored encrypted in vault as `vault_ansible_become_password`

## 🛠️ Common Commands

### Connectivity Testing
```bash
# Full connectivity test
ansible-playbook test-connectivity.yml

# Quick ping test
ansible all -m ping

# Test specific group
ansible execution_nodes -m ping
```

### Vault Management
```bash
# Edit vault credentials
ansible-vault edit group_vars/all/vault.yml

# View vault contents
ansible-vault view group_vars/all/vault.yml

# Change vault password
ansible-vault rekey group_vars/all/vault.yml
```

### SSH Key Management
```bash
# View public key
cat .ssh/ansible_rsa.pub

# Regenerate SSH keys
./scripts/setup-ssh-keys.sh

# Test SSH connection manually
ssh -i .ssh/ansible_rsa ansible@192.168.1.200
```

### Inventory Management
```bash
# List all hosts
ansible-inventory --list

# View inventory graph
ansible-inventory --graph

# List specific group
ansible-inventory --graph execution_nodes
```

## 🔄 Persistence Across Container Rebuilds

All credentials are stored in the **workspace directory** and persist across container rebuilds:

- ✅ SSH keys: `.ssh/`
- ✅ Vault password: `.vault_password`
- ✅ Encrypted credentials: `group_vars/all/vault.yml`

When you rebuild the container, everything is automatically available!

## 🐛 Troubleshooting

### SSH Connection Issues

#### Problem: SSH Key Not Found or Wrong Path

**Symptom:** `no such identity: /workspaces/ansible-rhaap/.ssh/ansible_rsa: No such file or directory`

**Solution:**
1. Update `group_vars/all/vars.yml` to use dynamic path:
   ```yaml
   ansible_ssh_private_key_file: "{{ playbook_dir }}/.ssh/ansible_rsa"
   ```

2. Verify SSH key exists:
   ```bash
   ls -la .ssh/ansible_rsa*
   ```

3. If missing, regenerate:
   ```bash
   ./scripts/setup-ssh-keys.sh
   ```

#### Problem: Permission Denied (publickey)

**Symptom:** `ansible@192.168.1.xxx: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password)`

**Solution:**
1. Copy SSH public key to the target host:
   ```bash
   ./scripts/copy-ssh-key-to-all.sh
   # OR manually for specific host:
   ssh-copy-id -i .ssh/ansible_rsa.pub ansible@192.168.1.xxx
   ```

2. Verify key is in authorized_keys:
   ```bash
   ssh -i .ssh/ansible_rsa ansible@192.168.1.xxx "cat ~/.ssh/authorized_keys"
   ```

3. Check SSH key permissions on target host:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

#### Problem: SSH Connection Reset by Peer

**Symptom:** `kex_exchange_identification: read: Connection reset by peer`

**Root Causes:**
- SSH MaxStartups limit reached
- TCP wrappers blocking connections
- fail2ban IP ban
- SSH daemon resource exhaustion

**Solution (requires console access):**

1. Access host via console (iLO/iDRAC/KVM)

2. Check SSH daemon logs:
   ```bash
   sudo tail -100 /var/log/secure  # RHEL/CentOS
   sudo tail -100 /var/log/auth.log  # Debian/Ubuntu
   ```

3. Increase SSH connection limits:
   ```bash
   sudo vi /etc/ssh/sshd_config
   # Add or modify:
   MaxStartups 100:30:200
   MaxSessions 100
   LoginGraceTime 120
   
   sudo systemctl restart sshd
   ```

4. Check fail2ban:
   ```bash
   sudo fail2ban-client status sshd
   sudo fail2ban-client unban --all
   ```

5. Check TCP wrappers:
   ```bash
   cat /etc/hosts.deny
   cat /etc/hosts.allow
   echo "sshd: ALL" | sudo tee /etc/hosts.allow
   ```

6. Temporarily comment out the host in `inventory.yml`:
   ```yaml
   # worker07:  # TEMPORARILY DISABLED - SSH issue
   #   ansible_host: 192.168.1.198
   ```

#### Problem: Connection Refused

**Symptom:** `ssh: connect to host 192.168.1.xxx port 22: Connection refused`

**Solution:**
1. Check if SSH service is running:
   ```bash
   # Via another host or console access
   sudo systemctl status sshd
   sudo systemctl start sshd
   sudo systemctl enable sshd
   ```

2. Check firewall:
   ```bash
   sudo firewall-cmd --list-all
   sudo firewall-cmd --add-service=ssh --permanent
   sudo firewall-cmd --reload
   ```

### Python Interpreter Issues

#### Problem: Python Not Found

**Symptom:** `/bin/sh: line 1: /usr/bin/python3.9: No such file or directory`

**Solution:**
1. Install Python on the target host:
   ```bash
   # For RHEL/CentOS Stream 9
   ./scripts/install-python39.sh
   
   # For CentOS Stream 10 or generic
   ./scripts/install-python-on-workers.sh
   ```

2. Or manually:
   ```bash
   # CentOS Stream 9
   ssh ansible@192.168.1.xxx "sudo dnf install -y python39"
   
   # CentOS Stream 10 (uses Python 3.12)
   ssh ansible@192.168.1.xxx "sudo dnf install -y python3"
   ```

3. Update `group_vars/all/vars.yml` for auto-discovery:
   ```yaml
   ansible_python_interpreter: auto_silent
   ```

#### Problem: Different Python Versions Across Hosts

**Solution:**
Already configured! The `ansible_python_interpreter: auto_silent` setting automatically discovers the correct Python version on each host (3.9, 3.12, etc.).

### Ansible Vault Issues

#### Problem: Vault Password Error

**Symptom:** `ERROR! Attempting to decrypt but no vault secrets found`

**Solution:**
1. Verify vault password file exists:
   ```bash
   ls -la .vault_password
   ```

2. Re-run vault setup:
   ```bash
   ./scripts/setup-vault.sh
   ```

3. Edit vault to verify it's working:
   ```bash
   ansible-vault edit group_vars/all/vault.yml
   ```

#### Problem: Permission Denied (Sudo)

**Symptom:** `FAILED! => {"msg": "Missing sudo password"}`

**Solution:**
1. Edit vault and update become password:
   ```bash
   ansible-vault edit group_vars/all/vault.yml
   # Update: vault_ansible_become_password
   ```

2. Verify sudo access on target:
   ```bash
   ssh ansible@192.168.1.200 "sudo whoami"
   ```

3. Check if user is in sudoers:
   ```bash
   sudo grep ansible /etc/sudoers /etc/sudoers.d/*
   ```

### Connectivity Testing

#### Quick Diagnostic Commands

```bash
# Test all hosts
ansible all -m ping

# Test specific group
ansible execution_nodes -m ping

# Check Python interpreter on all hosts
ansible all -m setup -a "filter=ansible_python_version"

# Verify sudo access
ansible all -m shell -a "sudo whoami" --become

# Check disk space before upgrade
ansible all -m shell -a "df -h /"

# Check available memory
ansible all -m shell -a "free -h"
```

## 🔒 Security Best Practices

1. **Never commit sensitive files**:
   - `.vault_password`
   - `.ssh/` directory
   - These are already in `.gitignore`

2. **Use strong vault password**:
   - Store it securely (password manager)
   - Share securely with team members

3. **Rotate credentials regularly**:
   - Regenerate SSH keys periodically
   - Update vault passwords

4. **SSH Security**:
   - Increase MaxStartups in `/etc/ssh/sshd_config` on all hosts
   - Configure fail2ban to whitelist management IPs
   - Use SSH key authentication (no passwords)

5. **Production use**:
   - Enable strict host key checking in production
   - Use separate vault files for different environments
   - Test playbooks in staging first
   - Keep backup of `/etc` before making changes

## 📝 Inventory Management

### Current Inventory Structure

```yaml
all:
  children:
    automationcontroller:
      hosts:
        controller:
          ansible_host: 192.168.1.200
    
    execution_nodes:
      hosts:
        worker01:
          ansible_host: 192.168.1.197
        worker02-12:
          # See inventory.yml for complete list
```

### Adding New Hosts

1. Edit `inventory.yml`:
   ```yaml
   worker13:
     ansible_host: 192.168.1.xxx
   ```

2. Copy SSH key to new host:
   ```bash
   ssh-copy-id -i .ssh/ansible_rsa.pub ansible@192.168.1.xxx
   ```

3. Test connectivity:
   ```bash
   ansible worker13 -m ping
   ```

### Removing/Disabling Hosts

To temporarily disable a host, comment it out:
```yaml
# worker07:  # TEMPORARILY DISABLED - Maintenance
#   ansible_host: 192.168.1.198
```

## 🛠️ Maintenance Tasks

### Regular Health Checks

```bash
# Weekly connectivity check
ansible all -m ping

# Monthly package updates (Stream 9 hosts)
ansible all -m dnf -a "name=* state=latest" --become

# Check disk space
ansible all -m shell -a "df -h"

# Check system load
ansible all -m shell -a "uptime"

# Review failed services
ansible all -m shell -a "systemctl --failed"
```

### Backup Critical Files

```bash
# Backup /etc directory on all hosts
ansible all -m archive -a "path=/etc dest=/tmp/etc-backup-$(date +%Y%m%d).tar.gz" --become

# Copy backups to management host
ansible all -m fetch -a "src=/tmp/etc-backup-*.tar.gz dest=./backups/"
```

## 📚 Additional Resources

### Documentation Files

- `WORKER07_TROUBLESHOOTING.md` - Detailed SSH troubleshooting for problematic hosts
- `.gitignore` - Protected sensitive files

### Useful Commands Reference

```bash
# Ansible ad-hoc commands
ansible all -m shell -a "COMMAND"                    # Run shell command
ansible all -m copy -a "src=FILE dest=DEST"          # Copy files
ansible all -m service -a "name=SERVICE state=STATE" # Manage services
ansible all -m user -a "name=USER state=STATE"       # Manage users

# Inventory management
ansible-inventory --list                              # List all hosts
ansible-inventory --graph                             # Graph view
ansible-inventory --host HOSTNAME                     # Host details

# Playbook execution
ansible-playbook PLAYBOOK.yml --check                 # Dry run
ansible-playbook PLAYBOOK.yml --diff                  # Show changes
ansible-playbook PLAYBOOK.yml --limit HOST            # Specific host
ansible-playbook PLAYBOOK.yml --tags TAG              # Specific tags
ansible-playbook PLAYBOOK.yml --skip-tags TAG         # Skip tags
ansible-playbook PLAYBOOK.yml -vvv                    # Verbose output
```

## 🤝 Contributing

When making changes:
1. Test in non-production environment first
2. Document changes in playbook comments
3. Update README.md if adding new features
4. Keep vault files encrypted
5. Never commit sensitive information

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review `WORKER07_TROUBLESHOOTING.md` for SSH issues
3. Check Ansible logs: `/var/log/ansible.log` (if configured)
4. Use verbose mode: `ansible-playbook -vvv` for detailed output
