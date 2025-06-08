@{
    ModuleVersion = '1.0.0'
    RequiredOSVersion = '10.0.0.0'
    GUID = 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for system monitoring and performance tracking'
    PowerShellVersion = '5.1'
    RequiredModules = @('Common')
    FunctionsToExport = '@('Get-SystemPerformance', 'Monitor-SystemResources', 'Get-ProcessInfo', 'Monitor-DiskUsage', 'Get-SystemAlerts')'
        'Get-SystemEventLogs',
        'Get-MemoryUsage',
        'Get-CPUUsage',
        'Get-HighMemoryProcesses',
        'Get-SystemServices',
        'Get-SystemPerformance'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('System', 'Monitoring', 'Performance', 'EventLogs')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/tree/main/SystemMonitoring#readme'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
