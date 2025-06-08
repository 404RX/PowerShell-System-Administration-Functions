@{
    ModuleVersion = '1.0.0'
    GUID = '9aab6214-c579-422a-bbec-5d3a62e96685'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for gathering system information and hardware details'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = '@('Get-SystemInfo', 'Get-HardwareInfo', 'Get-DiskInfo', 'Get-MemoryInfo', 'Get-ProcessorInfo', 'Get-NetworkInfo')'
        'Get-SystemInfo',
        'Get-MemoryUsage',
        'Get-CPUUsage',
        'Get-DriveStatus',
        'Get-SystemVersion',
        'Get-DefenderStatus'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('System', 'Information', 'Monitoring', 'Performance')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/SystemInformation/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
            ReleaseNotes = 'Initial release'
        }
    }
} 
