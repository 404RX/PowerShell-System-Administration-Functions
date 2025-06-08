@{
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024 Organization. All rights reserved.'
    Description = 'Provides functions for system maintenance and optimization tasks.'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    RequiredModules = @('Common')
    FunctionsToExport = @(
        'Start-DiskCleanup',
        'Start-SystemFileCheck',
        'Start-SystemOptimization'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('System', 'Maintenance', 'Optimization', 'Cleanup')
            ProjectUri = 'https://github.com/organization/SystemMaintenance'
            LicenseUri = 'https://github.com/organization/SystemMaintenance/blob/main/LICENSE'
            ReleaseNotes = 'Initial release of the SystemMaintenance module.'
        }
    }
} 