@{
    ModuleVersion = '1.0.0'
    GUID = '23456789-2345-2345-2345-234567890123'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Provides functions for managing Windows Updates'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-WindowsUpdateServiceInfo',
        'Get-WindowsUpdateStatus',
        'Get-WindowsUpdateHistory',
        'Get-WindowsUpdateLogs'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'Update', 'Management')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 