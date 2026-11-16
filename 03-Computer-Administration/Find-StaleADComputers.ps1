[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(1, 3650)]
    [int]$InactiveDays = 90,

    [Parameter()]
    [string]$SearchBase,

    [Parameter()]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\Private\Initialize-ADAdministrationModule.ps1')
Initialize-ADAdministrationModule

$searchParameters = @{
    AccountInactive = $true
    ComputersOnly   = $true
    TimeSpan        = [TimeSpan]::FromDays($InactiveDays)
}
if ($SearchBase) { $searchParameters.SearchBase = $SearchBase }

$computers = Search-ADAccount @searchParameters | Select-Object -Property @(
    'Name', 'SamAccountName', 'Enabled', 'LastLogonDate', 'PasswordLastSet',
    'DNSHostName', 'OperatingSystem', 'DistinguishedName'
)

if (-not $OutputPath) {
    $reportDirectory = Join-Path $PSScriptRoot '..\..\Reports'
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
    $OutputPath = Join-Path $reportDirectory ("AD-Stale-Computers-{0}d-{1:yyyyMMdd-HHmmss}.csv" -f $InactiveDays, (Get-Date))
}

$computers | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
Write-Information "Found $($computers.Count) computer accounts inactive for at least $InactiveDays days. Report: $OutputPath" -InformationAction Continue
