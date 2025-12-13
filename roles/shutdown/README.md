# Shutdown Role

Gracefully shut down Linux systems with confirmation prompts and user notifications.

## Features
- Configurable shutdown delay
- Confirmation prompt before shutdown
- Broadcast warnings to logged-in users
- Ability to cancel scheduled shutdowns
- Async execution to avoid connection loss

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `shutdown_delay` | 60 | Delay in seconds before shutdown |
| `shutdown_delay_minutes` | 1 | Delay in minutes (for shutdown command) |
| `shutdown_message` | "System shutdown initiated by Ansible" | Message displayed during shutdown |
| `shutdown_confirm` | true | Require confirmation before proceeding |
| `shutdown_broadcast` | true | Broadcast warning to logged-in users |
| `shutdown_cancel` | false | Set to true to cancel a scheduled shutdown |

## Example Usage

### Basic shutdown with confirmation:
```yaml
- hosts: workers
  roles:
    - shutdown
```

### Immediate shutdown without confirmation:
```yaml
- hosts: workers
  roles:
    - role: shutdown
      vars:
        shutdown_confirm: false
        shutdown_delay: 0
        shutdown_delay_minutes: 0
```

### Schedule shutdown in 5 minutes:
```yaml
- hosts: workers
  roles:
    - role: shutdown
      vars:
        shutdown_delay: 300
        shutdown_delay_minutes: 5
```

### Cancel a scheduled shutdown:
```yaml
- hosts: workers
  roles:
    - role: shutdown
      vars:
        shutdown_cancel: true
```

## Notes
- Requires sudo/root privileges
- Uses async execution to prevent connection loss
- Safe for remote execution
