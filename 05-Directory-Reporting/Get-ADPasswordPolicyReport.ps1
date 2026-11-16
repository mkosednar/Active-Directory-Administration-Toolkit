[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\Private\Initialize-ADAdministrationModule.ps1')
Initialize-ADAdministrationModule

$domainPolicy = Get-ADDefaultDomainPasswordPolicy
$rows = @(
    [pscustomobject]@{
        PolicyType                     = 'Default domain'
        Name                           = $domainPolicy.Name
        MinPasswordLength              = $domainPolicy.MinPasswordLength
        ComplexityEnabled              = $domainPolicy.ComplexityEnabled
        ReversibleEncryptionEnabled    = $domainPolicy.ReversibleEncryptionEnabled
        MaxPasswordAge                 = $domainPolicy.MaxPasswordAge
        MinPasswordAge                 = $domainPolicy.MinPasswordAge
        PasswordHistoryCount           = $domainPolicy.PasswordHistoryCount
        LockoutThreshold               = $domainPolicy.LockoutThreshold
        LockoutDuration                = $domainPolicy.LockoutDuration
        LockoutObservationWindow       = $domainPolicy.LockoutObservationWindow
        AppliesTo                      = $domainPolicy.DistinguishedName
    }
)

foreach ($policy in (Get-ADFineGrainedPasswordPolicy -Filter *)) {
    $rows += [pscustomobject]@{
        PolicyType                     = 'Fine-grained'
        Name                           = $policy.Name
        MinPasswordLength              = $policy.MinPasswordLength
        ComplexityEnabled              = $policy.ComplexityEnabled
        ReversibleEncryptionEnabled    = $policy.ReversibleEncryptionEnabled
        MaxPasswordAge                 = $policy.MaxPasswordAge
        MinPasswordAge                 = $policy.MinPasswordAge
        PasswordHistoryCount           = $policy.PasswordHistoryCount
        LockoutThreshold               = $policy.LockoutThreshold
        LockoutDuration                = $policy.LockoutDuration
        LockoutObservationWindow       = $policy.LockoutObservationWindow
        AppliesTo                      = ($policy.AppliesTo -join '; ')
    }
}

if (-not $OutputPath) {
    $reportDirectory = Join-Path $PSScriptRoot '..\..\Reports'
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
    $OutputPath = Join-Path $reportDirectory ("AD-Password-Policies-{0:yyyyMMdd-HHmmss}.csv" -f (Get-Date))
}

$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
Write-Information "Exported $($rows.Count) password policy records to $OutputPath" -InformationAction Continue
