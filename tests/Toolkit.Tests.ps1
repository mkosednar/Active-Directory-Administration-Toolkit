BeforeAll {
    $script:repoRoot = Split-Path -Parent $PSScriptRoot
    $script:scriptPaths = @(
        '01-User-Administration/Get-ADUserInventory.ps1',
        '02-Group-Administration/Export-ADGroupMembers.ps1',
        '03-Computer-Administration/Find-StaleADComputers.ps1',
        '04-Account-Operations/Unlock-ADAccount.ps1',
        '05-Directory-Reporting/Get-ADPasswordPolicyReport.ps1'
    )
}

Describe 'PowerShell source files' {
    It 'parses without syntax errors: <_>' -ForEach $script:scriptPaths {
        $path = Join-Path $script:repoRoot $_
        $tokens = $null
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null
        $errors | Should -BeNullOrEmpty
    }
}

Describe 'Initialize-ADAdministrationModule' {
    BeforeAll {
        . (Join-Path $script:repoRoot 'Private/Initialize-ADAdministrationModule.ps1')
    }

    It 'throws an actionable error when the AD module is missing' {
        Mock Get-Module { $null }
        { Initialize-ADAdministrationModule } | Should -Throw '*ActiveDirectory PowerShell module is not installed*'
    }

    It 'imports the AD module when it is available' {
        Mock Get-Module { [pscustomobject]@{ Name = 'ActiveDirectory' } }
        Mock Import-Module {}
        Initialize-ADAdministrationModule
        Should -Invoke Import-Module -Times 1 -Exactly -ParameterFilter { $Name -eq 'ActiveDirectory' -and $ErrorAction -eq 'Stop' }
    }
}

Describe 'Unlock-ADAccount safety' {
    BeforeEach {
        Mock Get-ADUser { [pscustomobject]@{ SamAccountName='test.user'; DistinguishedName='CN=Test User,OU=Users,DC=example,DC=com'; LockedOut=$true } }
        Mock Unlock-ADAccount {}
    }

    It 'does not unlock an account when WhatIf is used' {
        $path = Join-Path $script:repoRoot '04-Account-Operations/Unlock-ADAccount.ps1'
        & $path -Identity 'test.user' -WhatIf
        Should -Invoke Unlock-ADAccount -Times 0 -Exactly
    }

    It 'does not call unlock when the account is not locked' {
        Mock Get-ADUser { [pscustomobject]@{ SamAccountName='test.user'; DistinguishedName='CN=Test User,OU=Users,DC=example,DC=com'; LockedOut=$false } }
        $path = Join-Path $script:repoRoot '04-Account-Operations/Unlock-ADAccount.ps1'
        & $path -Identity 'test.user' -Confirm:$false
        Should -Invoke Unlock-ADAccount -Times 0 -Exactly
    }
}
