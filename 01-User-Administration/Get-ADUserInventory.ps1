[CmdletBinding()]
param(
    [Parameter()]
    [string]$SearchBase,

    [Parameter()]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\Private\Initialize-ADAdministrationModule.ps1')
Initialize-ADAdministrationModule

$properties = @(
    'Enabled', 'LastLogonDate', 'PasswordLastSet', 'PasswordNeverExpires',
    'PasswordExpired', 'LockedOut', 'mail', 'Department', 'Title',
    'Manager', 'AccountExpirationDate'
)

$query = @{
    Filter     = '*'
    Properties = $properties
}
if ($SearchBase) { $query.SearchBase = $SearchBase }

$users = Get-ADUser @query | Select-Object -Property @(
    'Name', 'SamAccountName', 'Enabled', 'LockedOut', 'LastLogonDate',
    'PasswordLastSet', 'PasswordNeverExpires', 'PasswordExpired',
    'AccountExpirationDate', 'mail', 'Department', 'Title', 'Manager',
    'DistinguishedName'
)

if (-not $OutputPath) {
    $reportDirectory = Join-Path $PSScriptRoot '..\..\Reports'
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
    $OutputPath = Join-Path $reportDirectory ("AD-User-Inventory-{0:yyyyMMdd-HHmmss}.csv" -f (Get-Date))
}

$users | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
Write-Information "Exported $($users.Count) user records to $OutputPath" -InformationAction Continue
