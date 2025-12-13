# Reboot Role

Gracefully reboot Linux systems with confirmation prompts, user notifications, and automatic reconnection.

## Features
- Configurable reboot delay
- Confirmation prompt before reboot
- Broadcast warnings to logged-in users
- Automatic wait for system to come back online
- Configurable timeout and test commands
- Ability to cancel scheduled reboots

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `reboot_delay` | 10 | Delay in seconds before reboot |
| `reboot_post_delay` | 30 | Delay in seconds after reboot before reconnecting |
| `reboot_timeout` | 600 | Maximum time in seconds to wait for system to reboot |
| `reboot_message` | "System reboot initiated by Ansible" | Message displayed during reboot |
| `reboot_test_command` | "whoami" | Command to test if system is back online |
| `reboot_confirm` | true | Require confirmation before proceeding |
| `reboot_broadcast` | true | Broadcast warning to logged-in users |
| `reboot_cancel` | false | Set to true to cancel a scheduled reboot |

## Example Usage

### Basic reboot with confirmation:
```yaml
- hosts: workers
  roles:
    - reboot
```

### Immediate reboot without confirmation:
```yaml
- hosts: workers
  roles:
    - role: reboot
      vars:
        reboot_confirm: false
        reboot_delay: 0
```

### Reboot with custom timeout:
```yaml
- hosts: workers
  roles:
    - role: reboot
      vars:
        reboot_timeout: 300
        reboot_post_delay: 60
```

### Cancel a scheduled reboot:
```yaml
- hosts: workers
  roles:
    - role: reboot
      vars:
        reboot_cancel: true
```

## Notes
- Requires sudo/root privileges
- Ansible will automatically wait for the system to come back online
- Connection will be re-established after reboot
- Safe for remote execution
