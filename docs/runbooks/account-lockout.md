# Runbook: Account Lockout

**Symptom:** user sees *"The referenced account is currently locked out and may not be logged on to."*
**Policy:** 5 failed attempts → locked for 15 minutes, then unlocks automatically.
**Priority:** High if the user can't work or a customer is waiting.

## 1. Verify identity

Before unlocking anything, confirm the person is who they say they are: ask their manager, call them back on their known extension, or check in person. Never unlock based on an email alone.

## 2. Confirm the lockout

On DC01 (elevated PowerShell):

```powershell
Get-ADUser <username> -Properties LockedOut, BadLogonCount, LastBadPasswordAttempt |
    Select-Object Name, LockedOut, BadLogonCount, LastBadPasswordAttempt
```

## 3. Find where the bad attempts came from

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4740} -MaxEvents 10 |
    Where-Object { $_.Message -match '<username>' } |
    Format-List TimeCreated, Message
```

Look for **Caller Computer Name**.

| Caller computer | Likely cause | Action |
| --- | --- | --- |
| The user's own PC | Mistyped password | Unlock; remind about Caps Lock |
| A different PC | Still signed in elsewhere with an old password | Sign out of that PC |
| Blank or a phone/server name | Old password saved on a phone (email) or a mapped drive | Update the saved password on that device |
| Many different computers | Possible password-guessing attack | **Do not just unlock.** Escalate as a Security ticket and reset the password |

## 4. Unlock

```powershell
Unlock-ADAccount <username>
Get-ADUser <username> -Properties LockedOut | Select-Object Name, LockedOut
```

- [ ] `LockedOut` is **False**
- [ ] User logs in successfully

## 5. If the user has forgotten the password

```powershell
Set-ADAccountPassword <username> -Reset -NewPassword (Read-Host -AsSecureString "Temporary password")
Set-ADUser <username> -ChangePasswordAtLogon $true
```

Give the temporary password verbally, never by email.

## 6. Log it

Ticket category *Accounts & Access*. Record the caller computer found in step 3. Repeated lockouts for the same user should be raised as a **Problem** in GLPI, not just closed each time.
