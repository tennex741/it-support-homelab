# Build Guide

How the Moon Motor Group lab was built, in the order it was built. Each phase ended with a VirtualBox snapshot so any later mistake could be rolled back in seconds.

---

## Phase 1 – Host preparation

- Confirmed CPU virtualisation was enabled in Task Manager.
- Installed Oracle VirtualBox 7.2 and the Extension Pack.
- Downloaded installation media: pfSense CE (AMD64 ISO for virtual machines), Windows Server 2022 evaluation, Windows 11 Enterprise evaluation, Ubuntu Server LTS.
- Planned three VirtualBox internal networks: `lab-servers`, `lab-staff`, `lab-guest`. Only the firewall connects to the outside world.

## Phase 2 – Firewall (FW01, pfSense CE)

**VM:** 1 vCPU, 1 GB RAM, 16 GB disk, four Intel PRO/1000 adapters.

| Adapter | VirtualBox network | pfSense interface | Address |
| --- | --- | --- | --- |
| 1 | NAT | WAN (em0) | DHCP |
| 2 | lab-servers | SERVERS (em1) | 10.10.10.1/24 |
| 3 | lab-staff | STAFF (em2) | 10.10.20.1/24 |
| 4 | lab-guest | GUEST (em3) | 10.10.30.1/24 |

Steps:

1. Installed pfSense CE on ZFS (stripe). Disabled pfSense's own DHCP on all internal interfaces, because DHCP is run centrally on DC01.
2. Assigned interfaces and IPs from the console (options 1 and 2).
3. Completed the web wizard from DC01's browser. Unticked **Block RFC1918 private networks** on WAN, because the VirtualBox NAT address is itself private.
4. Disabled the default DHCPv6 server and Router Advertisements on LAN (the lab is IPv4 only), then renamed interfaces to SERVERS, STAFF and GUEST.
5. Created aliases: `RFC1918`, `DC01`, `HELPDESK01`, `WEB_PORTS`.
6. Created firewall rules (see the README policy table). Rule order matters: specific allows, then the internal block, then the internet allow.
7. Added a DNS Resolver domain override sending `ad.moonlab.internal` to 10.10.10.10.
8. Enabled **DHCP Relay** on STAFF and GUEST, forwarding to 10.10.10.10.
9. Exported the configuration XML as a backup.

## Phase 3 – Domain controller (DC01, Windows Server 2022)

**VM:** 2 vCPU, 4 GB RAM, 60 GB disk, `lab-servers`. Installed **Desktop Experience** edition with unattended install turned off.

### 3.1 Base configuration

```powershell
Set-TimeZone -Id "E. Australia Standard Time"
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.10.10.10 -PrefixLength 24 -DefaultGateway 10.10.10.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.1
Rename-Computer -NewName "DC01" -Restart
```

### 3.2 Active Directory and DNS

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "ad.moonlab.internal" -DomainNetbiosName "MOONLAB" -InstallDns

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10,127.0.0.1
Set-DnsServerForwarder -IPAddress 10.10.10.1
Add-DnsServerPrimaryZone -NetworkId "10.10.10.0/24" -ReplicationScope Forest
Add-DnsServerPrimaryZone -NetworkId "10.10.20.0/24" -ReplicationScope Forest
```

The domain uses a subdomain of a reserved-style name (`ad.moonlab.internal`) rather than a single-label or public domain.

### 3.3 DHCP

```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerSecurityGroup
Add-DhcpServerInDC -DnsName "dc01.ad.moonlab.internal" -IPAddress 10.10.10.10

Add-DhcpServerv4Scope -Name "STAFF" -StartRange 10.10.20.100 -EndRange 10.10.20.200 -SubnetMask 255.255.255.0 -LeaseDuration 8.00:00:00
Set-DhcpServerv4OptionValue -ScopeId 10.10.20.0 -Router 10.10.20.1 -DnsServer 10.10.10.10 -DnsDomain "ad.moonlab.internal"

Add-DhcpServerv4Scope -Name "GUEST" -StartRange 10.10.30.100 -EndRange 10.10.30.200 -SubnetMask 255.255.255.0 -LeaseDuration 1.00:00:00
Set-DhcpServerv4OptionValue -ScopeId 10.10.30.0 -Router 10.10.30.1 -DnsServer 10.10.30.1 -Force
```

Staff get an 8-day lease (stable devices). Guests get a 1-day lease (transient devices) and use pfSense for DNS so they never query the domain controller.

### 3.4 Directory structure

```
MoonMotorGroup
├── Users
│   ├── Sales  ├── Service  ├── Parts
│   ├── Finance  ├── Management  └── IT
├── Computers
│   ├── Workstations (default for new domain joins via redircmp)
│   ├── Laptops  └── Tablets
├── Groups
├── Disabled Users
└── Service Accounts
```

### 3.5 Groups (AGDLP)

- **Global groups** by department: `GG_Sales`, `GG_Service`, `GG_Parts`, `GG_Finance`, `GG_Management`, `GG_IT`
- **Domain local groups** by resource: `DL_Share_<Name>_Modify` for Sales, Service, Parts, Finance and Public
- Nesting: department groups go into resource groups; permissions are only granted to resource groups. Service is nested into Parts because workshop staff look up parts.

### 3.6 Users

Six staff accounts were created in ADUC with title, department, company and manager populated, plus a separate administrator account (`adm.cmoon`) in Domain Admins. Day-to-day work uses the standard account; the admin account is used only for administration.

### 3.7 File shares

Five shares under `C:\Shares` with access-based enumeration. Share permissions are broad (Authenticated Users: Change); NTFS permissions do the real restriction (only the matching `DL_` group has Modify).

### 3.8 Print server

`PARTS-Printer-01` was created on a `NUL` port with the Generic / Text Only driver. This allows printer deployment and print-queue tickets to be practised without hardware.

### 3.9 Group Policy

| GPO | Linked to | Settings |
| --- | --- | --- |
| Default Domain Policy | Domain | Min password length 12, complexity on, lockout after 5 attempts for 15 minutes |
| MMG - Drive Maps | Users OU | P: for everyone; S:, W:, Q:, F: with item-level targeting on the `DL_` groups |
| MMG - Printers | Users OU | PARTS-Printer-01 for `GG_Parts` OR `GG_Service` |
| MMG - Workstation Security | Computers OU | Logon banner, 15-minute inactivity lock, deny all removable storage |

## Phase 4 – Staff workstation (WS01, Windows 11 Enterprise)

**VM:** 2 vCPU, 4 GB RAM, 64 GB disk, UEFI + Secure Boot + TPM 2.0, 128 MB video memory, `lab-staff`.

1. Installed Windows 11 Enterprise Evaluation with a local emergency account.
2. Confirmed DHCP across the relay: received 10.10.20.100, gateway 10.10.20.1, DNS 10.10.10.10, DHCP server 10.10.10.10.
3. Joined the domain:

```powershell
Add-Computer -DomainName "ad.moonlab.internal" -NewName "WS01" -Credential "MOONLAB\adm.cmoon" -Restart
```

4. Verified per user: logon banner displayed, password policy enforced, correct drives and printer per department, policies confirmed with `gpresult /r`.

## Phase 5 – Helpdesk server (HELPDESK01, Ubuntu Server)

**VM:** 2 vCPU, 2 GB RAM, 25 GB disk, `lab-servers`, OpenSSH enabled.

### 5.1 Static networking (`/etc/netplan/00-installer-config.yaml`)

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [10.10.10.20/24]
      routes:
        - to: default
          via: 10.10.10.1
      nameservers:
        addresses: [10.10.10.10]
        search: [ad.moonlab.internal]
```

A DNS A and PTR record was added on DC01 so staff reach the portal by name.

### 5.2 GLPI

- Installed Apache, MariaDB and PHP with the extensions GLPI requires; all GLPI requirement checks passed, including the security checks.
- Created a dedicated `glpi` database user with rights only on the `glpi` database, plus read access to the timezone table.
- Deployed the latest GLPI release with Apache's document root set to `/var/www/glpi/public`, as GLPI recommends.
- Set `session.cookie_httponly = On`.
- Changed all four default GLPI account passwords and deleted `install/install.php`.

### 5.3 Active Directory integration

- Created a non-admin service account `svc_glpi` in the Service Accounts OU for LDAP lookups.
- Configured the LDAP directory with a filter returning only enabled user accounts, so disabled leavers cannot log in.
- Mapped AD attributes for title, department and manager.
- Imported staff; staff receive the Self-Service profile and IT staff the Technician profile.

### 5.4 Helpdesk configuration

- Ten ITIL categories (Accounts & Access, File Shares & Drives, Printing, Network & Connectivity, Hardware, Software, Mobile Devices, Email & Microsoft 365, Security, Server & Infrastructure).
- Six staff knowledge-base articles published as FAQ to the root entity.

## Phase 6 – Asset management

- Enabled GLPI inventory with Basic Authentication for agents.
- Installed GLPI Agent on WS01 and DC01; the agents report daily and populated hardware, software, volumes and antivirus automatically.
- Added locations, lifecycle statuses (In stock, In use, In repair, Retired), a supplier and warranty data.
- Recorded a printer, a staff mobile phone, a spare laptop (In stock) and a retired PC (Retired) to show the full asset lifecycle.
- Linked tickets to affected assets so each device carries its own issue history.

## Phase 7 – Automation

See [`scripts/`](../scripts/). All three were tested end to end with a temporary test account, and every run writes to a CSV audit log in `C:\Scripts\Logs`. The AD report is scheduled to run every Monday at 7am.
