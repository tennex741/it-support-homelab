# Runbook: New Starter Onboarding

**Trigger:** a manager raises a GLPI ticket (category *Accounts & Access*, type *Request*) at least two working days before the start date.
**Owner:** IT Support Officer
**Time:** about 45 minutes

## Information needed from the manager

- [ ] Full name and preferred first name
- [ ] Department and job title
- [ ] Start date
- [ ] Manager
- [ ] Device needed (desktop, laptop, phone)
- [ ] Any extra access beyond the department standard (must be approved by the manager in the ticket)

## 1. Create the account

On DC01, in an elevated PowerShell session as the admin account:

```powershell
cd C:\Scripts
.\New-MMGUser.ps1 -FirstName Priya -LastName Sharma -Department Sales -Title "Sales Consultant" -TicketNumber "#009"
```

- [ ] Script reports **created and verified** (Enabled = True, InDeptGroup = True)
- [ ] If the manager is not Karen Mitchell, set it: `Set-ADUser <user> -Manager <managerUsername>`
- [ ] Record the temporary password securely; give it to the starter in person, not by email

## 2. Prepare the device

- [ ] Take a device from stock in GLPI (status **In stock**)
- [ ] Run Windows Update
- [ ] Join the domain (see the [New Device Deployment](new-device-deployment.md) runbook)
- [ ] Confirm the GLPI Agent has reported in

## 3. Update the asset record in GLPI

- [ ] **User:** the new starter
- [ ] **Location:** their work area
- [ ] **Status:** In use
- [ ] Link the asset to the onboarding ticket (**Items** tab)

## 4. Day one with the starter

- [ ] Starter signs in to the PC first and sets their own password
  *(Web apps such as the helpdesk portal cannot prompt for a password change; see [ticket 004](../../tickets/004-must-change-password-web-login.md))*
- [ ] Check drives in File Explorer match their department
- [ ] Check the printer appears (Service and Parts only)
- [ ] Log in to the helpdesk portal with them and show **Create a ticket** and **Browse help articles**
- [ ] Set up work phone if issued (KB article: *Set up work email and Authenticator*)

## 5. Close the ticket

- [ ] Task entry with time spent
- [ ] Solution: what was set up
- [ ] Ask the manager to approve the solution

## Common problems

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Drives missing at first login | User not in their `GG_` group, or token not refreshed | Check `whoami /groups`; add to group; sign out and in |
| Can't log in to the helpdesk portal | Still flagged *must change password* | Starter signs in to a PC first |
| Account not found in GLPI import | Account disabled | `Get-ADUser <user> \| Select Enabled`; `Enable-ADAccount` |
