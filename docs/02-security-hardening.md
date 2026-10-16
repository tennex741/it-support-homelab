# Security Hardening

The security controls applied in the lab, and the reason for each. As a cybersecurity student, I treated security as part of the support role rather than a separate project.

## Network

| Control | Why |
| --- | --- |
| Three segmented networks (Servers, Staff, Guest) | A compromised staff PC or visitor device cannot freely reach every system |
| Guest network blocked from all private ranges, including the firewall admin page | Visitors get internet only |
| Staff can reach only the domain controller and the helpdesk web ports | Limits lateral movement between internal systems |
| Rule order: specific allows → internal block → internet allow | First match wins in pfSense, so order is part of the policy |
| Guests use pfSense for DNS, never the domain controller | Guests cannot enumerate internal names |
| Servers on static IPs with no DHCP on that subnet | Rogue or unexpected devices don't silently get an address next to the servers |

## Identity and access

| Control | Why |
| --- | --- |
| Separate admin account (`adm.cmoon`) from the daily account (`cmoon`) | Email and browsing never run with domain admin rights |
| Built-in Administrator not used day to day | Reduces exposure of the most targeted account |
| AGDLP group model; permissions only on resource groups | Access is consistent, auditable and removed in one step |
| Access-based enumeration on shares | Staff can't even see folders they can't open |
| Password policy: 12 characters minimum with complexity | Raises the cost of guessing attacks |
| Account lockout: 5 attempts, 15 minutes | Stops brute force while auto-recovering from typos |
| New accounts require a password change at first logon | IT never knows a user's working password |
| Offboarding resets to a random password, removes groups, disables and moves the account | A leaver's account can't be reused, and removal is logged |

## Endpoints

| Control | Why |
| --- | --- |
| Logon banner ("Authorised use only") | Sets expectations and supports acceptable-use policy |
| Screen lock after 15 minutes of inactivity | Protects unattended PCs on the sales floor and workshop |
| All removable storage denied by GPO | Prevents data leaving on USB and malware arriving on USB |
| UAC kept enabled; admin tasks run in an elevated session only | Admin rights are used deliberately, not by default |
| Windows 11 with UEFI, Secure Boot and TPM 2.0 | Modern boot integrity |

## Helpdesk server

| Control | Why |
| --- | --- |
| All four GLPI default passwords changed on day one | Default credentials are one of the most common audit findings |
| `install/install.php` removed after setup | The installer can't be rerun to take over the application |
| Dedicated database user limited to the GLPI database | The web app can't read or change other databases |
| `session.cookie_httponly = On` | Browser scripts can't steal session cookies |
| LDAP bind via a non-admin service account | If the GLPI server is compromised, the AD credential it holds has no admin rights |
| LDAP filter excludes disabled accounts | Disabling a leaver in AD also blocks their helpdesk access |
| Inventory agents must authenticate | Nobody can inject fake assets into the register |
| Technician profile does not include financial data by default | Purchase costs follow least privilege |

## Known lab limitations

These were accepted for the lab and are documented in [Lab vs Production](03-lab-vs-production.md):

- GLPI served over HTTP, and agent authentication uses Basic Auth over HTTP.
- LDAP uses port 389 (unencrypted) rather than LDAPS on 636.
- The staff → DC01 firewall rule allows all ports rather than only the AD ports.
- Single domain controller with no backups.
