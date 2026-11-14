[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$GroupIdentity,

    [Parameter()]
    [switch]$Recursive,

    [Parameter()]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$group = Get-ADGroup -Identity $GroupIdentity -Properties GroupCategory, GroupScope

$memberParameters = @{ Identity = $group.DistinguishedName }
if ($Recursive) { $memberParameters.Recursive = $true }
$members = Get-ADGroupMember @memberParameters |
    Sort-Object ObjectClass, Name |
    Select-Object -Property @(
        @{ Name = 'Group'; Expression = { $group.Name } },
        'Name', 'SamAccountName', 'ObjectClass', 'DistinguishedName'
    )

if (-not $OutputPath) {
    $reportDirectory = Join-Path $PSScriptRoot '..\..\Reports'
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
    $safeGroupName = $group.Name -replace '[^a-zA-Z0-9._-]', '_'
    $OutputPath = Join-Path $reportDirectory ("AD-Group-Members-{0}-{1:yyyyMMdd-HHmmss}.csv" -f $safeGroupName, (Get-Date))
}

$members | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
Write-Information "Exported $($members.Count) members of '$($group.Name)' to $OutputPath" -InformationAction Continue
