# Active Directory Administration Toolkit

A collection of practical PowerShell scripts for routine Microsoft Active Directory Domain Services administration and reporting.

The scripts follow the numbered-folder style used by the Windows System Toolkit. Reports are written to a local `Reports` folder and are excluded from version control because they can contain personal and directory information.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7 on Windows
- A domain joined computer or a management host with network access to the domain
- RSAT Active Directory Domain Services tools and the `ActiveDirectory` PowerShell module
- Read permissions for reporting scripts; delegated permissions for account operations
- Pester 5 or later to run the automated test suite

Check that the module is available:

```powershell
Get-Module -ListAvailable ActiveDirectory
Import-Module ActiveDirectory
```

## Project structure

### 01 – User Administration
- `Get-ADUserInventory.ps1` – exports useful account, sign-in, password, and organizational attributes for a domain or OU.

### 02 – Group Administration
- `Export-ADGroupMembers.ps1` – exports direct or recursive membership of a specified security or distribution group.

### 03 – Computer Administration
- `Find-StaleADComputers.ps1` – reports computer accounts that have been inactive for a configurable period. It does not disable or delete accounts.

### 04 – Account Operations
- `Unlock-ADAccount.ps1` – unlocks one named account after confirmation. Supports `-WhatIf` and `-Confirm`.

### 05 – Directory Reporting
- `Get-ADPasswordPolicyReport.ps1` – reports the default domain password policy and any fine-grained password policies.

## Examples

Export users from the whole domain:

```powershell
.\01-User-Administration\Get-ADUserInventory.ps1
```

Limit the inventory to an OU (use its distinguished name):

```powershell
.\01-User-Administration\Get-ADUserInventory.ps1 -SearchBase 'OU=Staff,DC=example,DC=com'
```

Export nested membership of a group:

```powershell
.\02-Group-Administration\Export-ADGroupMembers.ps1 -GroupIdentity 'IT Support' -Recursive
```

Find computer accounts with no recent logon:

```powershell
.\03-Computer-Administration\Find-StaleADComputers.ps1 -InactiveDays 90
```

Preview an account unlock, then run it after reviewing the target:

```powershell
.\04-Account-Operations\Unlock-ADAccount.ps1 -Identity 'jdoe' -WhatIf
.\04-Account-Operations\Unlock-ADAccount.ps1 -Identity 'jdoe'
```

The unlock operation uses `SupportsShouldProcess` with high confirmation impact, so it prompts by default. Always preview with `-WhatIf` first. Use `-Confirm` to request confirmation explicitly; avoid `-Confirm:$false` unless running a reviewed, controlled automation.

## Safety and privacy

- Review each script and test it in a non-production environment before use.
- Use a least-privilege account. Read-only reports should not need Domain Admin rights.
- Inventory and membership exports may contain personal information and sensitive organizational details. Store them securely, limit access, and delete them when no longer needed.
- The stale computer report is informational. It never disables or deletes accounts.
- The unlock script only targets the identity supplied by the operator and uses PowerShell's confirmation and `-WhatIf` conventions.
- Scripts do not contain domain names, credentials, or other environment-specific secrets.

## Tests

Run the Pester 5 test suite from the repository root:

```powershell
Invoke-Pester -Path .\tests -Output Detailed
```

The suite includes PowerShell parser checks and focused mocked tests. It does not replace testing against a disposable Active Directory test domain.

## Operational notes

- The scripts require the ActiveDirectory module; they now check that it is available and report an actionable error before importing it.
- `Find-StaleADComputers.ps1` uses directory-maintained logon metadata. Treat results as candidates for review, not proof that a device is decommissioned.
- Review custom `-OutputPath` destinations and protect generated reports as sensitive directory data.

## Language

Documentation, code comments, and user-facing messages are maintained in English for consistency with the other toolkits.

## License

No open-source license has been selected for this project yet. Until a license is added, use, modification, and redistribution are not automatically permitted.
