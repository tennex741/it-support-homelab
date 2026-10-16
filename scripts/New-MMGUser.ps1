<#
.SYNOPSIS
    Creates a new Moon Motor Group staff account with the correct OU, groups and attributes.
.DESCRIPTION
    Builds the username, creates the account enabled with "must change password at next logon",
    adds the department group, then verifies the account is enabled and in its group before
    reporting success. Every run is appended to C:\Scripts\Logs\onboarding-log.csv.
.EXAMPLE
    .\New-MMGUser.ps1 -FirstName Priya -LastName Sharma -Department Sales -Title "Sales Consultant" -TicketNumber "#009"
#>
param(
    [Parameter(Mandatory)][string]$FirstName,
    [Parameter(Mandatory)][string]$LastName,
    [Parameter(Mandatory)][ValidateSet('Sales','Service','Parts','Finance','Management','IT')][string]$Department,
    [Parameter(Mandatory)][string]$Title,
    [string]$Manager = 'kmitchell',
    [string]$TicketNumber = 'N/A'
)

Import-Module ActiveDirectory
$domain  = 'ad.moonlab.internal'
$usersOU = 'OU=Users,OU=MoonMotorGroup,DC=ad,DC=moonlab,DC=internal'
$logFile = 'C:\Scripts\Logs\onboarding-log.csv'

# Build username: first initial + surname, lowercase, letters/numbers only (handles O'Brien etc.)
$sam = (($FirstName.Substring(0,1) + $LastName).ToLower()) -replace '[^a-z0-9]', ''

if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
    throw "Username '$sam' already exists. Check for a returning staff member or choose a different username."
}

$tempPassword = Read-Host -AsSecureString "Temporary password for $sam (12+ chars)"

New-ADUser -Name "$FirstName $LastName" `
    -GivenName $FirstName -Surname $LastName `
    -SamAccountName $sam -UserPrincipalName "$sam@$domain" -DisplayName "$FirstName $LastName" `
    -Title $Title -Department $Department -Company 'Moon Motor Group' `
    -Manager $Manager `
    -Path "OU=$Department,$usersOU" `
    -AccountPassword $tempPassword -ChangePasswordAtLogon $true -Enabled $true `
    -Description "Created $(Get-Date -Format 'yyyy-MM-dd') - Ticket $TicketNumber"

Add-ADGroupMember -Identity "GG_$Department" -Members $sam

# Verify everything the earlier tickets taught us to check
$u       = Get-ADUser $sam -Properties Enabled, Title, Department, Manager
$inGroup = (Get-ADGroupMember "GG_$Department").SamAccountName -contains $sam

$result = [pscustomobject]@{
    Date        = Get-Date -Format 'yyyy-MM-dd HH:mm'
    Ticket      = $TicketNumber
    Username    = $sam
    Name        = "$FirstName $LastName"
    Department  = $Department
    Title       = $Title
    Enabled     = $u.Enabled
    InDeptGroup = $inGroup
    CreatedBy   = $env:USERNAME
}
$result | Format-List
$result | Export-Csv -Path $logFile -Append -NoTypeInformation

if (-not $u.Enabled -or -not $inGroup) {
    Write-Warning "Verification FAILED - check the account before handing over."
} else {
    Write-Host "Account $sam created and verified. User must change password at first PC login." -ForegroundColor Green
}
