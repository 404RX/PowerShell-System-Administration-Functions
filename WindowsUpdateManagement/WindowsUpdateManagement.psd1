@{
    ModuleVersion = '1.0.0'
    RequiredOSVersion = '10.0.0.0'
    GUID = '23456789-2345-2345-2345-234567890123'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for Windows Update management and automation'
    PowerShellVersion = '5.1'
    FunctionsToExport = '@('Get-WindowsUpdates', 'Install-WindowsUpdates', 'Get-UpdateHistory', 'Set-UpdateSettings', 'Get-UpdateStatus')'
        'Get-WindowsUpdateServiceInfo',
        'Get-WindowsUpdateStatus',
        'Get-WindowsUpdateHistory',
        'Get-WindowsUpdateLogs'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Windows', 'Update', 'Management')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/WindowsUpdateManagement/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
