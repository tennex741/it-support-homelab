# Screenshots

Evidence from each phase of the build, in build order. Screenshots that showed passwords were left out.

## Firewall (pfSense)

| | |
| --- | --- |
| ![](01-pfsense-interfaces.png) | **01** – WAN plus the SERVERS, STAFF and GUEST interfaces with their addresses |
| ![](02-pfsense-staff-rules.png) | **02** – STAFF rules: DC01, helpdesk web ports, block internal, internet |
| ![](03-pfsense-guest-rules.png) | **03** – GUEST rules: DNS only to the firewall, block internal, internet |
| ![](04-pfsense-dns-domain-override.png) | **04** – DNS override sending `ad.moonlab.internal` to DC01 |

## Domain controller (DC01)

| | |
| --- | --- |
| ![](05-dc01-domain-dns-check.png) | **05** – Domain created; internal and external DNS resolution working |
| ![](06-dc01-dns-forwarder-reverse-zones.png) | **06** – DNS forwarder to pfSense and AD-integrated reverse zones |
| ![](07-dhcp-scopes.png) | **07** – STAFF (8-day) and GUEST (1-day) DHCP scopes active |
| ![](08-ad-ou-structure-and-users.png) | **08** – OU structure and staff accounts |
| ![](09-ad-user-titles-departments.png) | **09** – Titles and departments populated (data quality fix for one user) |
| ![](10-file-shares-and-printer.png) | **10** – Five department shares and the shared parts printer |
| ![](11-gpo-drive-maps.png) | **11** – MMG - Drive Maps: P, S, W, Q, F |
| ![](12-gpo-printer-targeting.png) | **12** – Printer targeted to GG_Parts OR GG_Service |

## Staff workstation (WS01)

| | |
| --- | --- |
| ![](13-ws01-dhcp-via-relay.png) | **13** – WS01 gets 10.10.20.100 from DC01 across the pfSense DHCP relay |
| ![](18-finance-user-drives.png) | **18** – Finance user on the same PC gets only P: and F: |

## Ticket 001 – Missing department drives

| | |
| --- | --- |
| ![](14-ticket001-jake-drives-before.png) | **14** – Before: Service Advisor only has P: |
| ![](15-ticket001-empty-groups-and-fix.png) | **15** – All six department groups empty; members added |
| ![](16-ticket001-jake-groups-after.png) | **16** – After sign-out/in: GG_Service and the DL groups in the token |
| ![](17-ticket001-jake-drives-after.png) | **17** – After: P:, W: and Q: mapped |

## Ticket 002 – Helpdesk server had no IP

| | |
| --- | --- |
| ![](19-ticket002-no-ip-diagnosis.png) | **19** – No IPv4 address or route; network unreachable |
| ![](20-ticket002-netplan-fixed.png) | **20** – Static IP applied; gateway and internet reachable |

## Helpdesk (GLPI)

| | |
| --- | --- |
| ![](21-glpi-requirements-1.png) | **21** – Requirements check passed |
| ![](22-glpi-requirements-2-security.png) | **22** – Security and suggested checks passed |
| ![](23-glpi-ldap-test.png) | **23** – LDAP connection to Active Directory succeeded |
| ![](26-glpi-ticket-list.png) | **26** – Ticket logged, categorised and closed |

## Ticket 003 – Account disabled at creation

| | |
| --- | --- |
| ![](24-ticket003-disabled-account-found.png) | **24** – One account Enabled = False; GLPI service account created |
| ![](25-ticket003-passwordlastset-check.png) | **25** – Password set at creation, so the account was disabled at creation |

## Asset management and automation

| | |
| --- | --- |
| ![](27-glpi-agent-inventory-log.png) | **27** – Agent authenticates and sends inventory; next run scheduled |
| ![](28-glpi-ws01-inventory-tabs.png) | **28** – WS01 hardware, software (122) and processes collected automatically |
| ![](29-glpi-asset-lifecycle.png) | **29** – In use, In stock and Retired assets |
| ![](30-scripts-audit-logs.png) | **30** – Onboarding and offboarding audit logs |
