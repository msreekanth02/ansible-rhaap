# Ansible Role: System Info

## Description
Collects and reports system information including OS details, IP addresses, version information, and hardware specifications.

## Requirements
- Ansible 2.9 or higher
- SSH access to target hosts
- Python on target hosts

## Role Variables

Available variables with default values (see `defaults/main.yml`):

```yaml
# Display system info in console
system_info_display: true

# Generate individual report files
system_info_generate_report: true

# Path to store reports
system_info_report_path: "./reports"

# Collect summary for all hosts
system_info_collect_summary: true

# Generate consolidated summary report
system_info_generate_summary: true
```

## Information Collected

The role collects the following information:
- Hostname
- IP Address (inventory and default IPv4)
- FQDN
- OS Distribution and Version
- OS Family
- Kernel Version
- Architecture
- CPU Cores
- Total Memory
- Python Version
- System Uptime

## Dependencies
None

## Example Playbook

```yaml
---
- name: Collect system information
  hosts: all
  roles:
    - system_info
```

### Custom Configuration

```yaml
---
- name: Collect system information with custom settings
  hosts: all
  vars:
    system_info_display: true
    system_info_generate_report: true
    system_info_report_path: "./my_reports"
  roles:
    - system_info
```

## Example Usage

```bash
# Collect info from all hosts
ansible-playbook playbooks/system_info.yml

# Collect info from specific group
ansible-playbook playbooks/system_info.yml --limit execution_nodes

# Collect info without generating reports
ansible-playbook playbooks/system_info.yml -e "system_info_generate_report=false"
```

## Output

### Console Output
System information is displayed in the console during playbook execution.

### Report Files
Individual report files are generated in the `reports/` directory:
- `<hostname>_system_report.txt`

Example:
```
reports/
├── controller_system_report.txt
├── worker01_system_report.txt
├── worker02_system_report.txt
└── ...
```

## License
MIT

## Author Information
Created for infrastructure management and inventory reporting.
