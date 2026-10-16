# Automation Scripts

PowerShell scripts run on DC01 from an elevated session as the admin account. Each script writes a CSV audit log to `C:\Scripts\Logs`, recording what was done, when, for which ticket, and by whom.

| Script | Purpose | Prevents |
| --- | --- | --- |
| [`New-MMGUser.ps1`](New-MMGUser.ps1) | Create a staff account in the right OU with title, department, manager and department group, then **verify** it's enabled and in the group | Tickets 001 and 003 (empty groups, disabled account) |
| [`Remove-MMGUser.ps1`](Remove-MMGUser.ps1) | Offboard a leaver: remove groups, random password, disable, label, move to Disabled Users | Leavers keeping access |
| [`Get-MMGADReport.ps1`](Get-MMGADReport.ps1) | Weekly data-quality report: missing attributes, users outside department groups, stale accounts and computers, empty groups | Data drifting out of date unnoticed |

## Usage

```powershell
cd C:\Scripts

# Onboard
.\New-MMGUser.ps1 -FirstName Priya -LastName Sharma -Department Sales -Title "Sales Consultant" -TicketNumber "#009"

# Offboard (asks you to type YES)
.\Remove-MMGUser.ps1 -SamAccountName psharma -TicketNumber "#010"

# Report
.\Get-MMGADReport.ps1
```

## Schedule the weekly report

```powershell
$action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\Get-MMGADReport.ps1'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 7am
Register-ScheduledTask -TaskName 'MMG Weekly AD Report' -Action $action -Trigger $trigger -User 'SYSTEM' -RunLevel Highest
```

## Tested

All three scripts were tested end to end with a temporary account (`tstarter`): created and verified, reported on, then offboarded, with both runs appearing in the audit logs.
