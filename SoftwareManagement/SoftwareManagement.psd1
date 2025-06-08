@{
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for software installation and management'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = '@('Get-InstalledSoftware', 'Install-Software', 'Uninstall-Software', 'Update-Software', 'Get-SoftwareInfo')'
        'Get-InstalledSoftware',
        'Install-Software',
        'Uninstall-Software',
        'Get-SoftwareUpdates',
        'Install-SoftwareUpdates'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Software', 'Installation', 'Updates', 'Management')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/SoftwareManagement/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
            ReleaseNotes = 'Initial release'
        }
    }
} 
