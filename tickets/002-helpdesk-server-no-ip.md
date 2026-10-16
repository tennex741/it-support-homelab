# Ticket 002 – New helpdesk server unreachable after build

| Field | Value |
| --- | --- |
| Requester | IT (internal) |
| Category | Server & Infrastructure |
| Type / Urgency | Incident / Medium |
| Affected asset | HELPDESK01 (MMG-SRV-002) |
| Time spent | 15 minutes |

## Reported

After installing Ubuntu Server on the SERVERS subnet, `apt update` failed with *"Temporary failure resolving 'archive.ubuntu.com'"*.

## Diagnosis

A DNS error was the symptom, but I tested the network from the bottom up rather than assuming DNS was the cause:

| Check | Command | Result |
| --- | --- | --- |
| Link | `ip link` | `enp0s3` UP |
| IPv4 address | `ip -4 addr show enp0s3` | **None** (only an IPv6 link-local address) |
| Default route | `ip route` | **None** |
| Gateway | `ping -c 2 10.10.10.1` | Network is unreachable |

With no IPv4 address, nothing else could work. The static IP entered during installation had not been saved, and the SERVERS subnet intentionally has **no DHCP server**, so the server had no fallback.

## Fix

Rewrote `/etc/netplan/00-installer-config.yaml`:

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

```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

## Verification

- `inet 10.10.10.20/24` assigned
- Ping to pfSense (10.10.10.1) and `google.com` successful
- `apt update` and `apt upgrade` completed
- After adding an A/PTR record on DC01, `helpdesk01.ad.moonlab.internal` resolves

## Root cause

Static network configuration not applied during OS installation on a subnet with no DHCP by design.

## Prevention

Server build checklist now ends with: `ip addr`, ping the gateway, resolve an internal and an external name, before the build is signed off.

## Evidence

![](../screenshots/19-ticket002-no-ip-diagnosis.png)
![](../screenshots/20-ticket002-netplan-fixed.png)
