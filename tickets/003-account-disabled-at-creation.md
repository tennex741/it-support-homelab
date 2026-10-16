# Ticket 003 – Liam can't log in to the helpdesk

| Field | Value |
| --- | --- |
| Requester | Karen Mitchell (Dealer Principal), on behalf of Liam O'Brien (Parts Interpreter) |
| Category | Accounts & Access |
| Type / Urgency | Incident / Medium |
| Time spent | 10 minutes |

## Reported

> "Liam from the Parts counter started this week and says he can't log in to the IT helpdesk. Could you please check his account?"

## Diagnosis

1. The GLPI LDAP directory test returned **6 entries** where 7 staff accounts exist in the Users OU.

2. Compared enabled status across all staff on DC01:

   ```powershell
   Get-ADUser -Filter * -SearchBase "OU=Users,OU=MoonMotorGroup,DC=ad,DC=moonlab,DC=internal" |
       Select-Object SamAccountName, Enabled
   ```

   `lobrien` showed **Enabled = False**. The GLPI LDAP filter deliberately excludes disabled accounts, so he was invisible to the helpdesk.

3. Determined *when* and *why* it was disabled, rather than just re-enabling it:

   ```powershell
   Get-ADUser lobrien -Properties PasswordLastSet, whenCreated |
       Select-Object Name, Enabled, PasswordLastSet, whenCreated
   ```

   `PasswordLastSet` matched `whenCreated` exactly, so the password was set correctly at creation. That ruled out the most common cause (ADUC creating a disabled account when it can't set a password).

   The replication metadata for `userAccountControl` also matched the creation time, confirming the account was **disabled at creation**, not by someone later.

## Fix

```powershell
Enable-ADAccount lobrien
```

No password reset needed.

## Verification

- `Get-ADUser lobrien` → Enabled = True
- GLPI LDAP test → **7 entries found**
- Liam imported into GLPI

## Root cause

Account created in ADUC with **"Account is disabled"** ticked.

## Prevention

- The onboarding script creates accounts with `-Enabled $true` and verifies the result.
- The weekly AD report flags disabled accounts that are still in the active Users OU.
