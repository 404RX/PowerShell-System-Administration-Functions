@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'Your Organization'
    CompanyName = 'Your Organization'
    Copyright = '(c) 2024 Your Organization. All rights reserved.'
    Description = 'Active Directory Management module for user and group operations'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{
            ModuleName = 'Common'
            ModuleVersion = '1.0.0'
        },
        @{
            ModuleName = 'ActiveDirectory'
            ModuleVersion = '1.0.0.0'
        }
    )
    RequiredAssemblies = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    NestedModules = @('ActiveDirectoryManagement.psm1')
    FunctionsToExport = @(
        'Get-ADUserAccountInfo',
        'Get-ADInactiveUsers',
        'Get-ADUserLoginStatus',
        'Get-ADLockedOutUsers',
        'Get-ADPasswordStatus',
        'Get-ADGroupMembers'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('ActiveDirectory', 'UserManagement', 'GroupManagement', 'Security')
            ProjectUri = 'https://your-organization.com/ActiveDirectoryManagement'
            LicenseUri = 'https://your-organization.com/license'
            ReleaseNotes = @'
Initial release of ActiveDirectoryManagement module with the following features:
- User account management and reporting
- Group membership management
- Password status monitoring
- Inactive user detection
- Login status tracking
- Account lockout management

Compatibility Requirements:
- Windows Server 2019 (10.0.17763) or later
- Windows 10 1809 (10.0.17763) or later with RSAT tools
- PowerShell 5.1 or later
- Active Directory PowerShell module
- RSAT-AD-PowerShell Windows feature

Note: Some functions may require additional permissions or features depending on the operation.
'@
        }
    }
    CompatiblePSEditions = @('Desktop', 'Core')
    ModuleList = @('ActiveDirectoryManagement.psm1')
    FileList = @(
        'ActiveDirectoryManagement.psd1',
        'ActiveDirectoryManagement.psm1',
        'README.md'
    )
    HelpInfoURI = 'https://your-organization.com/ActiveDirectoryManagement/help'
} 