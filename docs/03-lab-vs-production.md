# Lab vs Production

Shortcuts taken to keep the lab simple, and what I would do in a real business.

| Area | In the lab | In production |
| --- | --- | --- |
| **Helpdesk web access** | HTTP | HTTPS with a certificate from an internal CA or Let's Encrypt; set `session.cookie_secure = On` |
| **Inventory agent auth** | Basic Auth over HTTP | OAuth client credentials over HTTPS |
| **LDAP** | Port 389 | LDAPS (636) or LDAP with StartTLS |
| **Staff → DC firewall rule** | All ports to DC01 | Only AD ports: 53, 88, 135, 389, 445, 464, 636, 3268 and the RPC dynamic range |
| **Domain controllers** | One | At least two, so authentication and DNS survive a server failure |
| **Backups** | VirtualBox snapshots | Scheduled system-state and file backups, an offsite or immutable copy, and regular test restores |
| **Segmentation** | VirtualBox internal networks | VLANs on managed switches, with Wi-Fi SSIDs mapped to VLANs |
| **Email and identity** | Not built (no tenant) | Microsoft 365 with Entra ID Connect, MFA enforced through Conditional Access |
| **Device management** | Group Policy only | Intune for laptops and mobile phones (compliance, app deployment, remote wipe) |
| **Patching** | Manual Windows Update | WSUS or Intune update rings with a pilot group before company-wide rollout |
| **Passwords for admins** | A text file kept off GitHub | A password manager (e.g. Bitwarden or KeePass) and Windows LAPS for local admin passwords |
| **Monitoring** | Weekly AD report | Centralised logging (event forwarding or a SIEM), alerts on lockouts, admin group changes and failed logins |
| **Printer** | Virtual printer on a NUL port | Real printer with vendor driver, deployed by GPO or Intune |
| **Licensing** | Evaluation editions | Licensed Windows Server and Windows 11, with CALs |

## Why this matters

The lab proves I can build and support each piece. This list shows I understand where a small business's real risks are, and what to prioritise first:

1. **MFA on Microsoft 365** (most breaches start with a stolen password)
2. **Tested backups** (ransomware and accidental deletion)
3. **A second domain controller** (nobody can log in if the only one fails)
4. **HTTPS and LDAPS** (credentials in transit)
