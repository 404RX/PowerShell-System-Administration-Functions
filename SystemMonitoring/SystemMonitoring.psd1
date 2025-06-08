@{
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-4b5c-8d9e-0f1a2b3c4d5e'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'System monitoring and performance tracking functions'
    PowerShellVersion = '5.1'
    RequiredModules = @('Common')
    FunctionsToExport = @(
        'Get-SystemEventLogs',
        'Get-MemoryUsage',
        'Get-CPUUsage',
        'Get-HighMemoryProcesses',
        'Get-SystemServices',
        'Get-SystemPerformance'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('System', 'Monitoring', 'Performance', 'EventLogs')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 