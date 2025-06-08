@{
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-5b6c-9d8e-0f1a2b3c4d5e'
    Author = 'C. Miller'
    CompanyName = '200rx'
    Copyright = '(c) 2024 Corey Miller. All rights reserved.'
    Description = 'PowerShell module for network diagnostics and troubleshooting'
    PowerShellVersion = '5.1'
    RequiredOSVersion = '10.0.0.0'
    RequiredModules = @('Common')
    FunctionsToExport = '@('Test-NetworkConnectivity', 'Get-NetworkLatency', 'Test-PortConnectivity', 'Get-DNSResolution', 'Test-NetworkPath')'
        'Start-NetworkDiagnostics',
        'Start-NetworkTrafficAnalysis',
        'Start-NetworkTroubleshooting'
    )
    CmdletsToExport = '@()'
    VariablesToExport = ''*''
    AliasesToExport = '@()'
    PrivateData = System.Collections.Hashtable
        PSData = @{
            Tags = @('Network', 'Diagnostics', 'Troubleshooting', 'Analysis')
    ProjectUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/NetworkDiagnostics/README.md'
    LicenseUri = 'https://github.com/404RX/PowerShell-System-Administration-Functions/blob/main/LICENSE'
            ReleaseNotes = 'Initial release of the NetworkDiagnostics module.'
        }
    }
} 
