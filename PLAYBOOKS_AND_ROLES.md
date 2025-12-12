# Ansible Automation Platform - Playbooks and Roles

This document describes the available playbooks and custom roles in this Ansible automation platform.

## Quick Start

### Run All Tests and Reports
```bash
# Test connectivity to all hosts
ansible-playbook playbooks/ping.yml

# Collect system information (displays on console + generates reports on controller)
ansible-playbook playbooks/system_info.yml

# Fetch reports from controller to local machine
ansible-playbook playbooks/fetch_reports.yml
```

## Available Playbooks

### 1. Connectivity Test (`playbooks/ping.yml`)
Tests basic connectivity to all managed hosts using the ping role.

**Usage:**
```bash
ansible-playbook playbooks/ping.yml
```

**What it does:**
- Tests SSH connectivity to all hosts
- Performs 3 ping attempts per host
- Displays success/failure status

**Output:** Console display with success indicators for each host

---

### 2. System Information Collection (`playbooks/system_info.yml`)
Collects comprehensive system information from all hosts and generates detailed reports.

**Usage:**
```bash
ansible-playbook playbooks/system_info.yml
```

**What it does:**
- Gathers facts from all hosts
- Collects: hostname, IP, OS, kernel, CPU, memory, Python version, uptime
- Displays information in console
- Generates text reports on controller at `/tmp/ansible-reports/`

**Output:**
- Console display of system information
- Individual report files: `<hostname>_system_report.txt` on controller

---

### 3. Fetch Reports (`playbooks/fetch_reports.yml`)
Downloads all system reports from the controller to your local machine.

**Usage:**
```bash
ansible-playbook playbooks/fetch_reports.yml
```

**What it does:**
- Fetches all reports from controller's `/tmp/ansible-reports/`
- Saves to local `reports/` directory

**Output:** 12 report files in `./reports/` directory

---

## Custom Roles

### 1. Ping Role (`roles/ping/`)
Simple connectivity testing role.

**Purpose:** Verify Ansible can reach and authenticate to managed hosts

**Variables:**
- `ping_count`: Number of ping attempts (default: 3)
- `show_success`: Display success messages (default: true)

**Files:**
- `tasks/main.yml` - Main ping task
- `defaults/main.yml` - Default variables
- `meta/main.yml` - Role metadata

---

### 2. System Info Role (`roles/system_info/`)
Comprehensive system information collection and reporting.

**Purpose:** Collect detailed system information and generate reports

**Variables:**
- `system_info_display`: Show info in console (default: true)
- `system_info_generate_report`: Create text reports (default: true)
- `system_info_report_path`: Report storage path (default: "./reports")
- `system_info_collect_summary`: Collect for summary (default: true)

**Information Collected:**
- Hostname and FQDN
- IP addresses (ansible_host and default_ipv4)
- OS distribution, version, family
- Kernel version
- Architecture
- CPU cores
- Total memory
- Python version
- System uptime

**Files:**
- `tasks/main.yml` - Main tasks for info collection
- `defaults/main.yml` - Default variables
- `templates/system_report.j2` - Report template
- `meta/main.yml` - Role metadata

---

## Workflow Examples

### Daily Health Check
```bash
# Quick connectivity test
ansible-playbook playbooks/ping.yml

# Collect current system state
ansible-playbook playbooks/system_info.yml

# Download reports locally
ansible-playbook playbooks/fetch_reports.yml

# View a specific report
cat reports/worker10_system_report.txt
```

### Pre-Maintenance Check
```bash
# Verify all systems are accessible
ansible-playbook playbooks/ping.yml

# Document current state
ansible-playbook playbooks/system_info.yml
ansible-playbook playbooks/fetch_reports.yml

# Archive reports
tar -czf reports-$(date +%Y%m%d).tar.gz reports/
```

### Inventory Validation
```bash
# Test basic connectivity
ansible-playbook playbooks/ping.yml

# Verify Python versions across fleet
ansible-playbook playbooks/system_info.yml | grep "Python Version"
```

---

## Report Locations

### On Controller Node
- **Path:** `/tmp/ansible-reports/`
- **Files:** `<hostname>_system_report.txt` (one per host)
- **Purpose:** Centralized storage on Ansible controller

### On Local Machine
- **Path:** `./reports/`
- **Files:** `<hostname>_system_report.txt` (one per host)
- **Purpose:** Local copies for analysis and archival

---

## Report Format

Each report contains:
```
================================================================================
SYSTEM INFORMATION REPORT
================================================================================
Generated: <ISO8601 timestamp>

HOST INFORMATION
--------------------------------------------------------------------------------
Hostname, IP Address, FQDN

OPERATING SYSTEM
--------------------------------------------------------------------------------
OS Distribution, Version, Family, Kernel, Architecture

HARDWARE
--------------------------------------------------------------------------------
CPU Cores, Total Memory

SOFTWARE
--------------------------------------------------------------------------------
Python Version

UPTIME
--------------------------------------------------------------------------------
Uptime in seconds
```

---

## Infrastructure Overview

### Active Hosts: 12/13 (92%)

**Controller:**
- `controller` (192.168.1.200) - CentOS 9, Python 3.9.21, 3655 MB RAM

**Workers (CentOS 8.5, Python 3.9.6):**
- `worker01` (192.168.1.197)
- `worker02` (192.168.1.11)
- `worker03` (192.168.1.12)
- `worker04` (192.168.1.14)

**Workers (CentOS 9, Python 3.9.9-3.9.16):**
- `worker05` (192.168.1.199)
- `worker06` (192.168.1.206)
- `worker08` (192.168.1.194)
- `worker09` (192.168.1.195)

**Workers (CentOS 10, Python 3.12.12):**
- `worker10` (192.168.1.196)
- `worker11` (192.168.1.201)
- `worker12` (192.168.1.178)

**Disabled:**
- `worker07` (192.168.1.198) - SSH daemon issue (see WORKER07_TROUBLESHOOTING.md)

---

## Adding New Roles

To create a new role:

```bash
# Create role structure
ansible-galaxy init roles/your_role_name

# Edit role files
vi roles/your_role_name/tasks/main.yml
vi roles/your_role_name/defaults/main.yml

# Create playbook
cat > playbooks/your_role_name.yml <<EOF
---
- name: Your role description
  hosts: all
  gather_facts: true
  become: false

  roles:
    - role: your_role_name
EOF

# Test the playbook
ansible-playbook playbooks/your_role_name.yml
```

---

## Troubleshooting

### Playbook Fails with SSH Errors
```bash
# Test connectivity first
ansible all -m ping

# Check specific host
ansible worker10 -m ping -vvv
```

### Reports Not Generated
```bash
# Check controller directory permissions
ssh ansible@192.168.1.200 "ls -la /tmp/ansible-reports/"

# Run with verbose output
ansible-playbook playbooks/system_info.yml -vv
```

### Fetch Reports Fails
```bash
# Ensure reports directory exists locally
mkdir -p reports/

# Verify reports exist on controller
ssh ansible@192.168.1.200 "ls -lh /tmp/ansible-reports/"
```

---

## Best Practices

1. **Always test connectivity first** - Run `playbooks/ping.yml` before other playbooks
2. **Archive reports regularly** - Use `tar` to compress and date reports
3. **Review reports for anomalies** - Check Python versions, uptime, memory usage
4. **Document changes** - Update this file when adding new playbooks/roles
5. **Use tags for selective runs** - Add tags to tasks for partial execution

---

## Next Steps

### Potential Role Ideas:
- **Package Management** - Install/update packages across fleet
- **Security Hardening** - Apply security configurations
- **Log Collection** - Gather logs from all hosts
- **Service Management** - Start/stop/restart services
- **User Management** - Create/modify/delete users
- **Firewall Configuration** - Manage firewalld/iptables
- **Certificate Management** - Deploy and renew certificates
- **Backup/Restore** - Automate backup procedures
- **Monitoring Setup** - Deploy monitoring agents

---

**Last Updated:** December 12, 2025
**Platform Version:** 1.0
**Active Hosts:** 12/13
