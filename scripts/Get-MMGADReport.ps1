<#
.SYNOPSIS
    Weekly Active Directory data-quality report for Moon Motor Group.
.DESCRIPTION
    Flags missing titles, departments and managers; users not in a department group; disabled
    accounts left in the active Users OU or still holding groups; users and computers not seen
    in 30+ days; and empty department groups. Results are saved to a dated CSV in C:\Scripts\Logs.
    Scheduled via Task Scheduler every Monday at 7am.
#>
Import-Module ActiveDirectory
$base     = 'OU=MoonMotorGroup,DC=ad,DC=moonlab,DC=internal'
$staleDay = (Get-Date).AddDays(-30)
$report   = "C:\Scripts\Logs\ad-report-$(Get-Date -Format 'yyyy-MM-dd').csv"

$findings = @()

# Active staff accounts
$users = Get-ADUser -Filter * -SearchBase "OU=Users,$base" -Properties Title, Department, Manager, Enabled, LastLogonDate, MemberOf
foreach ($u in $users) {
    $isAdmin = $u.SamAccountName -like 'adm.*'
    $checks  = @()
    if (-not $u.Enabled)                                         { $checks += 'Disabled account still in active Users OU' }
    if (-not $isAdmin -and -not $u.Title)                        { $checks += 'Missing job title' }
    if (-not $isAdmin -and -not $u.Department)                   { $checks += 'Missing department' }
    if (-not $isAdmin -and -not $u.Manager -and $u.SamAccountName -ne 'kmitchell') { $checks += 'Missing manager' }
    if (-not $isAdmin -and -not ($u.MemberOf -like 'CN=GG_*'))   { $checks += 'Not in a department (GG_) group' }
    if (-not $u.LastLogonDate)                                   { $checks += 'Never logged on' }
    elseif ($u.LastLogonDate -lt $staleDay)                      { $checks += 'No logon in 30+ days' }

    foreach ($c in $checks) {
        $findings += [pscustomobject]@{ Type='User'; Name=$u.SamAccountName; Issue=$c }
    }
}

# Disabled accounts that still hold group memberships
Get-ADUser -Filter 'Enabled -eq $false' -SearchBase $base -Properties MemberOf |
    Where-Object { $_.MemberOf } |
    ForEach-Object { $findings += [pscustomobject]@{ Type='User'; Name=$_.SamAccountName; Issue='Disabled but still in groups' } }

# Computers not seen for 30+ days
Get-ADComputer -Filter * -SearchBase $base -Properties LastLogonDate |
    Where-Object { -not $_.LastLogonDate -or $_.LastLogonDate -lt $staleDay } |
    ForEach-Object { $findings += [pscustomobject]@{ Type='Computer'; Name=$_.Name; Issue='Not seen in 30+ days' } }

# Empty department groups (the root cause of ticket #001)
Get-ADGroup -Filter 'Name -like "GG_*"' | ForEach-Object {
    if (-not (Get-ADGroupMember $_)) {
        $findings += [pscustomobject]@{ Type='Group'; Name=$_.Name; Issue='Department group is empty' }
    }
}

if ($findings) {
    $findings | Sort-Object Type, Name | Format-Table -AutoSize
    $findings | Export-Csv -Path $report -NoTypeInformation
    Write-Host "$($findings.Count) issue(s) found. Report saved to $report" -ForegroundColor Yellow
} else {
    Write-Host "No data-quality issues found." -ForegroundColor Green
}
