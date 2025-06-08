@{
    ModuleVersion = '1.0.0'
    RequiredOSVersion = '10.0.0.0'
    GUID = '0a4bba5d-11b2-4537-895a-3f2166888881'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for Windows service management and monitoring'
    PowerShellVersion = '5.1'
    FunctionsToExport = '@('Get-ServiceStatus', 'Start-ServiceSafe', 'Stop-ServiceSafe', 'Restart-ServiceSafe', 'Set-ServiceStartupType', 'Get-ServiceDependencies')'
        'Get-ServicePendingStatus',
        'Stop-PendingServices',
        'Restart-WMIService',
        'Get-ServiceList'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Services', 'Windows', 'Management')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/ServiceManagement/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
        }
    }
} 
