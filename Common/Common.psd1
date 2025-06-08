@{
    ModuleVersion = '1.0.0'
    RequiredOSVersion = '10.0.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'Common utilities and helper functions for PowerShell modules'
    PowerShellVersion = '5.1'
    FunctionsToExport = '@('Write-LogMessage', 'Test-AdminPrivileges', 'Get-ConfigValue', 'Set-ConfigValue', 'Invoke-SafeCommand')'
        'Write-LogMessage',
        'Test-Administrator',
        'Get-ErrorDetails',
        'Test-RequiredModule'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Common', 'Utility', 'Logging')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/Common/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
