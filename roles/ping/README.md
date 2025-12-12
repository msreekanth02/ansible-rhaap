# Ansible Role: Ping

## Description
Simple role to test connectivity to hosts using Ansible's ping module.

## Requirements
- Ansible 2.9 or higher
- SSH access to target hosts
- Python on target hosts

## Role Variables

```yaml
ping_display_result: true  # Display ping result (default: true)
```

## Dependencies
None

## Example Playbook

```yaml
---
- name: Test connectivity to all hosts
  hosts: all
  roles:
    - ping
```

## Example Usage

```bash
# Run against all hosts
ansible-playbook playbooks/ping.yml

# Run against specific group
ansible-playbook playbooks/ping.yml --limit execution_nodes

# Run against specific host
ansible-playbook playbooks/ping.yml --limit worker01
```

## License
MIT

## Author Information
Created for infrastructure management automation.
