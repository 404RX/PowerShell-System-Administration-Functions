@{
    ModuleVersion = '1.0.0'
    GUID = 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024 Organization. All rights reserved.'
    Description = 'Provides functions for managing user sessions, logins, and related operations'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = @(
        'Get-UserSessions',
        'Disconnect-UserSession',
        'Get-LastLogon',
        'Get-FailedLogons',
        'Get-LockedAccounts'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('User', 'Session', 'Login', 'Security', 'Management')
            ProjectUri = ''
            LicenseUri = ''
            ReleaseNotes = 'Initial release'
        }
    }
} 