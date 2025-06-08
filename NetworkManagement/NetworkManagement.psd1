@{
    ModuleVersion = '1.0.0'
    GUID = '45678901-4567-4567-4567-456789012345'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for network configuration and management'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = '@('Get-NetworkAdapterInfo', 'Set-NetworkAdapterSettings', 'Get-IPConfiguration', 'Set-IPConfiguration', 'Get-NetworkProfile', 'Set-NetworkProfile')'
        'Test-NetworkPort',
        'Get-NetworkConnections',
        'Resolve-NetworkAddress',
        'Get-NetworkIssues',
        'Send-WakeOnLAN'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Windows', 'Network', 'Management')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/tree/main/NetworkManagement#readme'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
