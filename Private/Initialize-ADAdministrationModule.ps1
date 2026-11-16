function Initialize-ADAdministrationModule {
    [CmdletBinding()]
    param()

    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "The ActiveDirectory PowerShell module is not installed. Install the RSAT Active Directory tools and try again."
    }

    Import-Module -Name ActiveDirectory -ErrorAction Stop
}
