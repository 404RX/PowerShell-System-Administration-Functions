@{
    ModuleVersion = '1.0.0'
    GUID = 'fa082b1c-6406-498b-a6e4-ba4ebf46adfe'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for system maintenance and cleanup tasks'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    RequiredModules = @('Common')
    FunctionsToExport = '@('Clear-TempFiles', 'Clear-RecycleBin', 'Optimize-SystemPerformance', 'Update-SystemDrivers', 'Repair-SystemFiles')'
        'Start-DiskCleanup',
        'Start-SystemFileCheck',
        'Start-SystemOptimization'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('System', 'Maintenance', 'Optimization', 'Cleanup')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/tree/main/SystemMaintenance#readme'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
            ReleaseNotes = 'Initial release of the SystemMaintenance module.'
        }
    }
} 
