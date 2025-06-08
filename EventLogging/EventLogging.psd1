@{
    ModuleVersion = '1.0.0'
    GUID = '34567890-3456-3456-3456-345678901234'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for Windows Event Log management and analysis'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = '@('Get-EventLogSummary', 'Search-EventLogs', 'Export-EventLogs', 'Clear-EventLogs', 'Get-EventLogStatistics')'
        'Get-SystemEventLogs',
        'Get-SecurityLogonEvents',
        'Get-SystemShutdownEvents',
        'Get-SystemRebootEvents',
        'Get-PowerShellOperationalLogs',
        'Get-ChkdskResults',
        'Export-EventLogs',
        'Get-EventLogProvider',
        'Test-EventLogAccess'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Windows', 'EventLogs', 'Monitoring')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/tree/main/EventLogging#readme'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
