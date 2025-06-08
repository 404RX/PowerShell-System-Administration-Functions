@{
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024 Organization. All rights reserved.'
    Description = 'Provides functions for network diagnostics and troubleshooting.'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    RequiredModules = @('Common')
    FunctionsToExport = @(
        'Start-NetworkDiagnostics',
        'Start-NetworkTrafficAnalysis',
        'Start-NetworkTroubleshooting'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Network', 'Diagnostics', 'Troubleshooting', 'Analysis')
            ProjectUri = 'https://github.com/organization/NetworkDiagnostics'
            LicenseUri = 'https://github.com/organization/NetworkDiagnostics/blob/main/LICENSE'
            ReleaseNotes = 'Initial release of the NetworkDiagnostics module.'
        }
    }
} 