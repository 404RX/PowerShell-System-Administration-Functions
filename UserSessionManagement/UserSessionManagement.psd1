@{
    ModuleVersion = '1.0.0'
    GUID = 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for user session management and monitoring'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    FunctionsToExport = '@('Get-UserSessions', 'Disconnect-UserSession', 'Get-SessionInfo', 'Lock-UserSession', 'Send-SessionMessage')'
        'Get-UserSessions',
        'Disconnect-UserSession',
        'Get-LastLogon',
        'Get-FailedLogons',
        'Get-LockedAccounts'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('User', 'Session', 'Login', 'Security', 'Management')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/tree/main/UserSessionManagement#readme'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
            ReleaseNotes = 'Initial release'
        }
    }
} 
