@{
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024 Organization. All rights reserved.'
    Description = 'Provides functions for managing software installation, updates, and removal'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = @(
        'Get-InstalledSoftware',
        'Install-Software',
        'Uninstall-Software',
        'Get-SoftwareUpdates',
        'Install-SoftwareUpdates'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Software', 'Installation', 'Updates', 'Management')
            ProjectUri = ''
            LicenseUri = ''
            ReleaseNotes = 'Initial release'
        }
    }
} 