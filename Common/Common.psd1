@{
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Common functions used across all PowerShell modules'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Write-LogMessage',
        'Test-Administrator',
        'Get-ErrorDetails',
        'Test-RequiredModule'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Common', 'Utility', 'Logging')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 