# ServiceManagement Module
# Provides functions for managing Windows services

function Get-ServicePendingStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Start', 'Stop', 'All')]
        [string]$Status = 'All'
    )
    
    switch ($Status) {
        'Start' {
            Get-WmiObject -Class win32_service | Where-Object {$_.state -eq 'start pending'}
        }
        'Stop' {
            Get-WmiObject -Class win32_service | Where-Object {$_.state -eq 'stop pending'}
        }
        'All' {
            Get-WmiObject -Class win32_service | Where-Object {$_.state -match 'pending'}
        }
    }
}

function Stop-PendingServices {
    [CmdletBinding()]
    param()
    
    $Services = Get-WmiObject -Class win32_service -Filter "state = 'stop pending'"
    if ($Services) {
        foreach ($service in $Services) {
            try {
                Stop-Process -Id $service.processid -Force -PassThru -ErrorAction Stop
                Write-Output "Successfully stopped service: $($service.Name)"
            }
            catch {
                Write-Warning -Message "Error stopping service $($service.Name). Error details: $_.Exception.Message"
            }
        }
    }
    else {
        Write-Output "No services with 'Stop Pending' status"
    }
}

function Restart-WMIService {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )
    
    try {
        Restart-Service -Name Winmgmt -Force:$Force -ErrorAction Stop
        Write-Output "Successfully restarted WMI service"
    }
    catch {
        Write-Warning -Message "Error restarting WMI service. Error details: $_.Exception.Message"
    }
}

function Get-ServiceList {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Filter = "*"
    )
    
    Get-CimInstance -Class Win32_Service -Filter "Name like '$Filter'"
}

Export-ModuleMember -Function @(
    'Get-ServicePendingStatus',
    'Stop-PendingServices',
    'Restart-WMIService',
    'Get-ServiceList'
) 