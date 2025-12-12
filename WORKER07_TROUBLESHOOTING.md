# Worker07 Troubleshooting Guide

## Issue Summary
Worker07 (192.168.1.198) is experiencing SSH connection reset issues during key exchange phase.

**Status:** Temporarily disabled in inventory.yml  
**Date:** December 11, 2025

## Symptoms
- Host is reachable via ping
- SSH port 22 is open and listening
- SSH connection fails with: `kex_exchange_identification: read: Connection reset by peer`
- Connection resets immediately after SSH version string exchange
- Issue occurs from multiple sources (management host and other workers)

## Diagnostic Results
```bash
# Ping test - SUCCESSFUL
ping -c 3 192.168.1.198
# Result: Host is reachable, 0% packet loss

# Port check - SUCCESSFUL
nc -zv 192.168.1.198 22
# Result: Connection to 192.168.1.198 port 22 [tcp/ssh] succeeded!

# SSH connection - FAILED
ssh ansible@192.168.1.198
# Result: kex_exchange_identification: read: Connection reset by peer
```

## Likely Causes

### 1. SSH MaxStartups Limit Reached
The SSH daemon may be rejecting new connections due to too many simultaneous connection attempts.

**Check:**
```bash
grep MaxStartups /etc/ssh/sshd_config
```

**Fix:**
```bash
sudo sed -i 's/^#MaxStartups.*/MaxStartups 100:30:200/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### 2. TCP Wrappers Blocking Connections
The host may have TCP wrappers configured to deny connections.

**Check:**
```bash
cat /etc/hosts.deny
cat /etc/hosts.allow
```

**Fix:**
```bash
# Remove restrictions or add your IP to hosts.allow
echo "sshd: ALL" | sudo tee -a /etc/hosts.allow
```

### 3. Fail2ban IP Ban
Your IP may have been banned by fail2ban after multiple connection attempts.

**Check:**
```bash
sudo fail2ban-client status sshd
```

**Fix:**
```bash
# Unban your IP (replace with actual IP)
sudo fail2ban-client set sshd unbanip <YOUR_IP>
```

### 4. Resource Exhaustion
The host may be running out of resources (memory, file descriptors, processes).

**Check:**
```bash
free -h
df -h
ulimit -a
ps aux | wc -l
```

**Fix:**
```bash
# Restart SSH service
sudo systemctl restart sshd

# If that doesn't work, reboot the host
sudo reboot
```

## How to Fix (Requires Console Access)

Since SSH is not working, you'll need **physical console access** or **remote console** (iLO, iDRAC, IPMI, KVM) to access worker07.

### Step 1: Access Console
- Use iLO/iDRAC/IPMI console
- OR use physical keyboard/monitor access

### Step 2: Login as root or ansible user

### Step 3: Check SSH Logs
```bash
# Check for SSH errors
sudo tail -100 /var/log/secure
# OR on some systems
sudo tail -100 /var/log/auth.log

# Look for:
# - "Connection reset" messages
# - "Too many authentication failures"
# - fail2ban bans
# - Resource exhaustion errors
```

### Step 4: Check and Fix SSH Configuration
```bash
# Backup current config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Increase connection limits
sudo vi /etc/ssh/sshd_config

# Add or modify these lines:
MaxStartups 100:30:200
MaxSessions 100
LoginGraceTime 120

# Test configuration
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd
```

### Step 5: Check fail2ban
```bash
# Check if fail2ban is running
sudo systemctl status fail2ban

# Check banned IPs
sudo fail2ban-client status sshd

# Unban all IPs if needed
sudo fail2ban-client unban --all

# Or temporarily stop fail2ban
sudo systemctl stop fail2ban
```

### Step 6: Check TCP Wrappers
```bash
# Review restrictions
cat /etc/hosts.deny
cat /etc/hosts.allow

# Temporarily allow all SSH
echo "sshd: ALL" | sudo tee /etc/hosts.allow
```

### Step 7: Restart SSH Service
```bash
sudo systemctl restart sshd
sudo systemctl status sshd
```

### Step 8: Test from Management Host
From your Mac, try connecting again:
```bash
ssh -i /Users/sreekanthmatturthi/sree/projects/ansible-rhaap/.ssh/ansible_rsa ansible@192.168.1.198
```

## Re-enabling Worker07 in Inventory

Once fixed, uncomment worker07 in `inventory.yml`:

```yaml
# Before (currently disabled):
# worker07:  # TEMPORARILY DISABLED - SSH connection reset issue
#   ansible_host: 192.168.1.198

# After (re-enabled):
worker07:
  ansible_host: 192.168.1.198
```

Then test connectivity:
```bash
cd /Users/sreekanthmatturthi/sree/projects/ansible-rhaap
ansible worker07 -i inventory.yml -m ping
```

## Prevention

To prevent this issue in the future:

1. **Increase SSH connection limits** on all workers:
   ```yaml
   # In /etc/ssh/sshd_config
   MaxStartups 100:30:200
   MaxSessions 100
   ```

2. **Configure fail2ban properly** to not ban management hosts:
   ```ini
   # In /etc/fail2ban/jail.local
   [sshd]
   ignoreip = 127.0.0.1/8 ::1 <YOUR_MANAGEMENT_IP>
   ```

3. **Adjust Ansible fork settings** to reduce parallel connections:
   ```ini
   # In ansible.cfg
   forks = 5  # Already set, but could be reduced if needed
   ```

## Quick Reference

**Current Status:** Worker07 is commented out in inventory.yml  
**Affected Host:** worker07 (192.168.1.198)  
**Issue:** SSH connection reset during key exchange  
**Access Method Required:** Console access (physical or remote)  
**Priority:** Medium (11 of 12 workers are operational)

## Contact Information
If you need assistance, note that this is an SSH daemon configuration issue on the worker07 host itself, not an Ansible or network connectivity issue.
