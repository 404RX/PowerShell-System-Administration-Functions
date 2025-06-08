@{
    ModuleVersion = '1.0.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    Author = 'System Administrator'
    CompanyName = 'Organization'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'Provides functions for managing Windows services'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-ServicePendingStatus',
        'Stop-PendingServices',
        'Restart-WMIService',
        'Get-ServiceList'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Services', 'Windows', 'Management')
            ProjectUri = ''
            LicenseUri = ''
        }
    }
} 