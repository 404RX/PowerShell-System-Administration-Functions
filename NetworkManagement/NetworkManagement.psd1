@{
    ModuleVersion = '1.0.0'
    GUID = '45678901-4567-4567-4567-456789012345'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Provides functions for managing network operations'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = @(
        'Test-NetworkPort',
        'Get-NetworkConnections',
        'Resolve-NetworkAddress',
        'Get-NetworkIssues',
        'Send-WakeOnLAN'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'Network', 'Management')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 