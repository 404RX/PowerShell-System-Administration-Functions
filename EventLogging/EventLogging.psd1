@{
    ModuleVersion = '1.0.0'
    GUID = '34567890-3456-3456-3456-345678901234'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Provides functions for managing Windows Event Logs'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = @(
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
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'EventLogs', 'Monitoring')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 