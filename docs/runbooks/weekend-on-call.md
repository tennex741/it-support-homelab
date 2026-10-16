# Runbook: Weekend On-Call

Moon Motor Group trades on Saturday mornings (sales and service). On-call IT covers **Saturday 7:00am – Sunday 6:00pm**.

## What counts as on-call

| Respond now | Wait until Monday |
| --- | --- |
| Nobody can log in | One user's non-urgent request |
| Shared drives or printer down for a whole team | A single printer jam with a working alternative |
| Internet down at the site | Software install requests |
| Suspected security incident (phishing clicked, ransomware note, account abuse) | Password reset when the person isn't working this weekend |
| Server unreachable | Asset updates, reports |

**Target response:** acknowledge within 30 minutes, update the reporter every hour until resolved or stable.

## First 10 minutes: triage checklist

Work from the outside in. Most outages are one of these.

1. **Is it one person or everyone?**
   One person → treat it as a normal user issue. Everyone → keep going.
2. **Is the firewall up?**
   Can a staff PC ping `10.10.20.1`? Is the pfSense dashboard reachable from a server?
3. **Is the internet up?**
   From pfSense: *Diagnostics > Ping* `8.8.8.8`. If it fails, check the ISP modem and call the ISP.
4. **Is DC01 up?**
   `ping dc01.ad.moonlab.internal`. If down, nobody can log in, get an IP (DHCP) or resolve names.
5. **Is DNS answering?**
   `Resolve-DnsName google.com` and `Resolve-DnsName dc01.ad.moonlab.internal` from a staff PC.
6. **Is DHCP handing out addresses?**
   A PC with a `169.254.x.x` address means DHCP failed. Check the DHCP service on DC01 and the DHCP Relay on pfSense.

## Common weekend fixes

| Problem | Fix |
| --- | --- |
| Staff locked out | [Account Lockout runbook](account-lockout.md) |
| Printer queue stuck | On DC01: `Restart-Service Spooler`; clear stuck jobs in Print Management |
| Drives missing for everyone | Check DC01 is up; check the Server service and shares with `Get-SmbShare` |
| Helpdesk portal down | SSH to HELPDESK01: `systemctl status apache2 mariadb`; restart the failed service |
| Phishing link clicked | Reset the user's password immediately, check for forwarding rules or unusual sign-ins, raise a Security ticket |

## Escalation

| Situation | Escalate to |
| --- | --- |
| Not resolved within 1 hour and a team can't work | IT Manager / Dealer Principal (Karen Mitchell) |
| Internet outage | ISP support line |
| Hardware failure under warranty | Coast IT Supplies (supplier record in GLPI) |
| Confirmed security incident | IT Manager immediately; do **not** wipe affected devices, preserve evidence |

## Logging

Every on-call action goes in GLPI, even if fixed in two minutes:

- Ticket with the real reporter as requester
- Task with time spent and what was checked
- Solution with root cause
- If the same issue happened before, link it to a **Problem**

## Handover on Monday

Send a short summary to the team: what happened, what was fixed, anything still open, and anything that needs a permanent fix.
