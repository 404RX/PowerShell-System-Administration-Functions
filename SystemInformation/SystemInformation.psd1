@{
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024 Organization. All rights reserved.'
    Description = 'Provides functions for managing system information and monitoring'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = @(
        'Get-SystemInfo',
        'Get-MemoryUsage',
        'Get-CPUUsage',
        'Get-DriveStatus',
        'Get-SystemVersion',
        'Get-DefenderStatus'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('System', 'Information', 'Monitoring', 'Performance')
            ProjectUri = ''
            LicenseUri = ''
            ReleaseNotes = 'Initial release'
        }
    }
} 