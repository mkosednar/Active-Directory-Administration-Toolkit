[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Identity
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\Private\Initialize-ADAdministrationModule.ps1')
Initialize-ADAdministrationModule
$account = Get-ADUser -Identity $Identity -Properties LockedOut

if (-not $account.LockedOut) {
    Write-Information "Account '$($account.SamAccountName)' is not locked." -InformationAction Continue
    return
}

if ($PSCmdlet.ShouldProcess($account.SamAccountName, 'Unlock Active Directory account')) {
    Unlock-ADAccount -Identity $account.DistinguishedName
    Write-Information "Unlocked account '$($account.SamAccountName)'." -InformationAction Continue
}
