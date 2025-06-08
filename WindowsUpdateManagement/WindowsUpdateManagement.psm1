# WindowsUpdateManagement Module
# Provides functions for managing Windows Updates

function Get-WindowsUpdateServiceInfo {
    [CmdletBinding()]
    param()
    
    try {
        $MUSM = New-Object -ComObject "Microsoft.Update.ServiceManager"
        $MUSM.Services
    }
    catch {
        Write-Warning -Message "Error getting Windows Update service information. Error details: $_.Exception.Message"
    }
}

function Get-WindowsUpdateStatus {
    [CmdletBinding()]
    param()
    
    $RebootStatus = @{
        'Component Based Servicing' = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')
        'PendingFileRenameOperations' = (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations')
        'Windows Update' = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
    }
    
    return $RebootStatus
}

function Get-WindowsUpdateHistory {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxResults = 100
    )
    
    Get-Hotfix | Sort-Object InstalledOn -Descending | Select-Object -First $MaxResults
}

function Get-WindowsUpdateLogs {
    [CmdletBinding()]
    param()
    
    $updateLogPath = "C:\Windows\Logs\WindowsUpdate\WindowsUpdate.log"
    $eventViewerPath = "Microsoft-Windows-WindowsUpdateClient/Operational"
    
    $results = @{
        'UpdateLog' = $null
        'EventLogs' = $null
    }
    
    if (Test-Path $updateLogPath) {
        $results.UpdateLog = Get-Content $updateLogPath
    }
    
    try {
        $results.EventLogs = Get-WinEvent -LogName $eventViewerPath -MaxEvents 100
    }
    catch {
        Write-Warning -Message "Error getting Windows Update event logs. Error details: $_.Exception.Message"
    }
    
    return $results
}

Export-ModuleMember -Function @(
    'Get-WindowsUpdateServiceInfo',
    'Get-WindowsUpdateStatus',
    'Get-WindowsUpdateHistory',
    'Get-WindowsUpdateLogs'
) 