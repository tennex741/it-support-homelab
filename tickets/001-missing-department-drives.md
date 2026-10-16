# Ticket 001 – Can't see Workshop and Parts drives

| Field | Value |
| --- | --- |
| Requester | Jake Thompson (Service Advisor) |
| Category | File Shares & Drives |
| Type / Urgency | Incident / High |
| Affected asset | WS01 (MMG-PC-001) |
| Time spent | 20 minutes |

## Reported

> "I logged into the new PC this morning and I only have the P: drive. I need the Workshop drive for job cards and Parts to check stock. Customers are waiting."

## Diagnosis

1. Confirmed the user and their token on WS01:

   ```powershell
   whoami
   whoami /groups | findstr /i "GG_ DL_"
   ```

   The user was only in `DL_Share_Public_Modify` (inherited from Domain Users). No `GG_Service`, so no `DL_Share_Service_Modify` or `DL_Share_Parts_Modify`.

2. Drive maps for W: and Q: use item-level targeting on those `DL_` groups, which explains why only P: applied.

3. **Checked the blast radius** instead of fixing only the reporter. On DC01:

   ```powershell
   "GG_Sales","GG_Service","GG_Parts","GG_Finance","GG_Management","GG_IT" | ForEach-Object {
       "$_ : " + ((Get-ADGroupMember $_).SamAccountName -join ", ")
   }
   ```

   **All six department groups were empty.** Every staff member was affected, not just Jake.

## Fix

```powershell
Add-ADGroupMember GG_Service    -Members jthompson
Add-ADGroupMember GG_Sales      -Members snguyen
Add-ADGroupMember GG_Parts      -Members lobrien
Add-ADGroupMember GG_Finance    -Members dpatel
Add-ADGroupMember GG_Management -Members kmitchell
Add-ADGroupMember GG_IT         -Members cmoon
```

The user then **signed out and back in**. Group membership is captured in the access token at logon, so `gpupdate /force` alone does not apply a group change.

## Verification

- `whoami /groups` now shows `GG_Service`, `DL_Share_Service_Modify`, `DL_Share_Parts_Modify`, `DL_Share_Public_Modify`
- File Explorer shows **P:, W: and Q:**
- A Finance user on the same PC received only **P: and F:**, confirming targeting works per department

## Root cause

Staff accounts were created in ADUC, but the *Member Of* step did not save, so department groups were empty.

## Prevention

- The onboarding script (`New-MMGUser.ps1`) adds the department group and **verifies** membership before reporting success.
- The weekly AD report flags empty department groups and users not in any `GG_` group.
