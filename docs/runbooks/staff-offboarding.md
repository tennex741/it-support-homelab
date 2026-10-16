# Runbook: Staff Offboarding

**Trigger:** a manager or HR raises a GLPI ticket (category *Accounts & Access*, type *Request*) with the leaver's last working day.
**Owner:** IT Support Officer
**Rule:** for a hostile or urgent departure, disable the account **immediately**, before the person is told.

## Before the last day

- [ ] Confirm the last working day and time in the ticket
- [ ] Ask the manager who should receive the leaver's files and email
- [ ] List the leaver's assets from GLPI (**Assets** filtered by **User**)

## On the last day (end of business)

### 1. Disable the account

On DC01, in an elevated PowerShell session as the admin account:

```powershell
cd C:\Scripts
.\Remove-MMGUser.ps1 -SamAccountName <username> -TicketNumber "#010"
```

The script:

1. Records and removes all group memberships
2. Resets the password to a random value nobody knows
3. Disables the account and stamps the description with date, ticket and technician
4. Moves the account to **Disabled Users**, out of the helpdesk login scope and drive-map policies
5. Writes an entry to `C:\Scripts\Logs\offboarding-log.csv`

- [ ] Script reports **Offboarding complete**

### 2. Recover devices

- [ ] Collect laptop, phone, keys or access cards listed in GLPI
- [ ] Check each item is physically present and undamaged

### 3. Update GLPI assets

For each returned device:

- [ ] Clear the **User** field
- [ ] **Status:** In stock (to reissue) or In repair (if it needs work)
- [ ] Add a comment: date returned and ticket number

### 4. Data and mail

- [ ] Move personal files from the leaver's folders to the manager's chosen location
- [ ] (In a Microsoft 365 environment) convert the mailbox to shared or set forwarding, then remove the licence

## After the last day

- [ ] Wipe and reimage returned PCs before reissuing
- [ ] Phones: remove from device management, factory reset
- [ ] After the retention period (e.g. 90 days), delete the AD account

## Close the ticket

- [ ] Task with time spent
- [ ] Solution: access removed, devices recovered, data handed over
- [ ] Manager approves
