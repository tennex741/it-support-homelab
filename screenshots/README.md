# Screenshots

Evidence from each phase of the build. Suggested file names, in build order:

| File | Shows |
| --- | --- |
| `01-pfsense-interfaces.png` | Console with WAN, SERVERS, STAFF and GUEST addresses |
| `02-pfsense-staff-rules.png` | STAFF firewall rules in order |
| `03-pfsense-guest-rules.png` | GUEST firewall rules in order |
| `04-dc01-domain-dns-check.png` | `Get-ADDomain` and `Resolve-DnsName` results |
| `05-dhcp-scopes.png` | STAFF and GUEST scopes active |
| `06-aduc-ou-structure.png` | MoonMotorGroup OU tree |
| `07-gpo-drive-maps.png` | Five drive maps in MMG - Drive Maps |
| `08-gpo-printer-targeting.png` | GG_Parts OR GG_Service targeting |
| `09-ws01-ipconfig.png` | WS01 receiving an address via DHCP relay |
| `10-jake-drives-before.png` | Ticket 001: only P: mapped |
| `11-jake-groups-after.png` | Ticket 001: `whoami /groups` after the fix |
| `12-jake-drives-after.png` | Service user: P:, W:, Q: |
| `13-david-drives.png` | Finance user: P:, F: |
| `14-gpresult-dpatel.png` | Applied GPOs and groups |
| `15-helpdesk01-netplan-fix.png` | Ticket 002: static IP applied |
| `16-glpi-requirements.png` | All GLPI requirement and security checks passed |
| `17-glpi-ldap-test.png` | LDAP connection test |
| `18-glpi-ticket-timeline.png` | Full ticket lifecycle |
| `19-glpi-ws01-inventory.png` | Hardware and software collected by the agent |
| `20-glpi-assets-lifecycle.png` | In use, In stock and Retired assets |
| `21-scripts-audit-logs.png` | Onboarding and offboarding log entries |

Before uploading, check that no screenshot shows a password, and crop out anything from the host PC that isn't part of the lab.
