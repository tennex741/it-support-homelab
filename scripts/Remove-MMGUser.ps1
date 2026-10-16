<#
.SYNOPSIS
    Securely offboards a Moon Motor Group staff member: removes access, disables, and archives the account.
.DESCRIPTION
    Requires typed confirmation. Records and removes group memberships, resets the password to a
    random value, disables the account, stamps the description, and moves it to the Disabled Users OU
    (out of the helpdesk LDAP scope and drive-map policies). Every run is appended to
    C:\Scripts\Logs\offboarding-log.csv.
.EXAMPLE
    .\Remove-MMGUser.ps1 -SamAccountName ptest -TicketNumber "#010"
#>
param(
    [Parameter(Mandatory)][string]$SamAccountName,
    [string]$TicketNumber = 'N/A'
)

Import-Module ActiveDirectory
Add-Type -AssemblyName System.Web
$disabledOU = 'OU=Disabled Users,OU=MoonMotorGroup,DC=ad,DC=moonlab,DC=internal'
$logFile    = 'C:\Scripts\Logs\offboarding-log.csv'

$user = Get-ADUser $SamAccountName -Properties MemberOf, DisplayName
Write-Host "About to offboard: $($user.DisplayName) ($SamAccountName)" -ForegroundColor Yellow
$confirm = Read-Host "Type YES to continue"
if ($confirm -ne 'YES') { Write-Host "Cancelled."; return }

# 1. Record and remove group memberships (keeps Domain Users, which is the primary group)
$groupNames = @()
foreach ($groupDN in $user.MemberOf) {
    $groupNames += (Get-ADGroup $groupDN).Name
    Remove-ADGroupMember -Identity $groupDN -Members $user -Confirm:$false
}

# 2. Reset to a random password nobody knows
$randomPassword = [System.Web.Security.Membership]::GeneratePassword(24, 6)
Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString $randomPassword -AsPlainText -Force)

# 3. Disable and label the account
Disable-ADAccount -Identity $user
Set-ADUser -Identity $user -Description "Disabled $(Get-Date -Format 'yyyy-MM-dd') - Ticket $TicketNumber - by $env:USERNAME"

# 4. Move to Disabled Users OU (out of GLPI's LDAP scope and drive-map GPOs)
Move-ADObject -Identity $user.DistinguishedName -TargetPath $disabledOU

$result = [pscustomobject]@{
    Date          = Get-Date -Format 'yyyy-MM-dd HH:mm'
    Ticket        = $TicketNumber
    Username      = $SamAccountName
    Name          = $user.DisplayName
    GroupsRemoved = ($groupNames -join '; ')
    DisabledBy    = $env:USERNAME
}
$result | Format-List
$result | Export-Csv -Path $logFile -Append -NoTypeInformation

Write-Host "Offboarding complete. Remember: recover the user's devices and update their assets in GLPI." -ForegroundColor Green
