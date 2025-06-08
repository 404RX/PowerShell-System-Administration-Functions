# SystemMonitoring Module
# Provides functions for monitoring system performance and health
# Supports Windows 10/11 and PowerShell 5.1+

#region Module Requirements
# Import required modules
Import-Module Common
#endregion

#region Public Functions
<#
.SYNOPSIS
    Gets system performance metrics.

.DESCRIPTION
    Retrieves real-time system performance metrics including CPU, memory,
    disk, and network usage. Can monitor specific components or all metrics.

.PARAMETER ComputerName
    Optional. The computer to monitor. Defaults to the local computer.

.PARAMETER Metrics
    Optional. Specific metrics to retrieve (CPU, Memory, Disk, Network).
    If not specified, returns all metrics.

.PARAMETER SampleInterval
    Optional. Time between samples in seconds. Defaults to 1 second.

.PARAMETER SampleCount
    Optional. Number of samples to collect. Defaults to 1.

.EXAMPLE
    Get-SystemPerformance
    Gets all performance metrics for the local computer.

.EXAMPLE
    Get-SystemPerformance -ComputerName "server01" -Metrics "CPU","Memory"
    Gets CPU and memory metrics for a remote computer.

.EXAMPLE
    Get-SystemPerformance -SampleInterval 5 -SampleCount 3
    Gets performance metrics every 5 seconds for 3 samples.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing performance metrics.

.NOTES
    Requires appropriate permissions for remote monitoring.
    Some metrics may require administrative privileges.
#>
function Get-SystemPerformance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$Counters = @('Memory', 'CPU', 'Disk', 'Network')
    )
    
    try {
        Write-LogMessage -Message "Retrieving system performance metrics" -Level Info
        
        $result = @{}
        
        foreach ($counter in $Counters) {
            switch ($counter) {
                'Memory' {
                    $result.Memory = Get-MemoryUsage -Detailed
                }
                'CPU' {
                    $result.CPU = Get-CPUUsage -Top 5
                }
                'Disk' {
                    $disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
                    $result.Disk = $disks | ForEach-Object {
                        [PSCustomObject]@{
                            Drive = $_.DeviceID
                            TotalSizeGB = [math]::Round($_.Size / 1GB, 2)
                            FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)
                            UsedSpaceGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
                            FreeSpacePercent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                        }
                    }
                }
                'Network' {
                    $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
                    $result.Network = $networkAdapters | ForEach-Object {
                        [PSCustomObject]@{
                            Name = $_.Name
                            InterfaceDescription = $_.InterfaceDescription
                            Status = $_.Status
                            Speed = $_.Speed
                            MacAddress = $_.MacAddress
                            IPAddresses = (Get-NetIPAddress -InterfaceIndex $_.ifIndex).IPAddress
                        }
                    }
                }
            }
        }
        
        $result.TimeStamp = Get-Date
        Write-LogMessage -Message "Successfully collected performance metrics" -Level Info
        return [PSCustomObject]$result
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve system performance: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

<#
.SYNOPSIS
    Gets system health status.

.DESCRIPTION
    Performs a comprehensive system health check including hardware status,
    service health, and system stability. Can check specific components
    or perform a full system check.

.PARAMETER ComputerName
    Optional. The computer to check. Defaults to the local computer.

.PARAMETER Components
    Optional. Specific components to check (Hardware, Services, Stability).
    If not specified, checks all components.

.PARAMETER Detailed
    Optional. When specified, returns additional health information.

.EXAMPLE
    Get-SystemHealth
    Performs a full system health check on the local computer.

.EXAMPLE
    Get-SystemHealth -ComputerName "server01" -Components "Services"
    Checks service health on a remote computer.

.EXAMPLE
    Get-SystemHealth -Detailed
    Gets detailed health information for all components.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing health status information.

.NOTES
    Requires appropriate permissions for remote health checks.
    Some checks may require administrative privileges.
#>
function Get-SystemHealth {
    # ... existing code ...
}

<#
.SYNOPSIS
    Gets system event log information.

.DESCRIPTION
    Retrieves and analyzes system event logs for errors, warnings,
    and other significant events. Can filter by event type, source,
    or time period.

.PARAMETER ComputerName
    Optional. The computer to check. Defaults to the local computer.

.PARAMETER LogName
    Optional. Specific event log to check (System, Application, Security).
    If not specified, checks all logs.

.PARAMETER EventType
    Optional. Filter events by type (Error, Warning, Information).

.PARAMETER StartTime
    Optional. Filter events after this time.

.PARAMETER EndTime
    Optional. Filter events before this time.

.EXAMPLE
    Get-SystemEvents
    Gets all recent system events from the local computer.

.EXAMPLE
    Get-SystemEvents -ComputerName "server01" -LogName "System" -EventType "Error"
    Gets system errors from a remote computer.

.EXAMPLE
    Get-SystemEvents -StartTime (Get-Date).AddDays(-1) -EndTime (Get-Date)
    Gets events from the last 24 hours.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing event information.

.NOTES
    Requires appropriate permissions for remote event log access.
    Some event logs may require administrative privileges.
#>
function Get-SystemEvents {
    # ... existing code ...
}

<#
.SYNOPSIS
    Gets system service status.

.DESCRIPTION
    Retrieves the status and configuration of system services.
    Can check specific services or all services, and monitor
    their current state and startup type.

.PARAMETER ComputerName
    Optional. The computer to check. Defaults to the local computer.

.PARAMETER ServiceName
    Optional. Specific service(s) to check.
    If not specified, checks all services.

.PARAMETER Status
    Optional. Filter services by status (Running, Stopped, etc.).

.PARAMETER Detailed
    Optional. When specified, returns additional service information.

.EXAMPLE
    Get-SystemServices
    Gets status of all services on the local computer.

.EXAMPLE
    Get-SystemServices -ComputerName "server01" -ServiceName "Spooler"
    Gets status of a specific service on a remote computer.

.EXAMPLE
    Get-SystemServices -Status "Running" -Detailed
    Gets detailed information about running services.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing service information.

.NOTES
    Requires appropriate permissions for remote service access.
    Some services may require administrative privileges to access.
#>
function Get-SystemServices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('Running', 'Stopped', 'StartPending', 'StopPending')]
        [string]$Status
    )
    
    try {
        Write-LogMessage -Message "Retrieving system services information" -Level Info
        
        $services = Get-CimInstance -ClassName Win32_Service
        if ($Status) {
            $services = $services | Where-Object { $_.State -eq $Status }
        }
        
        $results = $services | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                DisplayName = $_.DisplayName
                State = $_.State
                StartMode = $_.StartMode
                StartName = $_.StartName
                PathName = $_.PathName
            }
        }
        
        Write-LogMessage -Message "Retrieved $($results.Count) services" -Level Info
        return $results
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve system services: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

<#
.SYNOPSIS
    Gets system process information.

.DESCRIPTION
    Retrieves detailed information about running processes.
    Can monitor specific processes or all processes, including
    resource usage and parent-child relationships.

.PARAMETER ComputerName
    Optional. The computer to check. Defaults to the local computer.

.PARAMETER ProcessName
    Optional. Specific process(es) to check.
    If not specified, checks all processes.

.PARAMETER Top
    Optional. Number of top processes to return by resource usage.

.PARAMETER Detailed
    Optional. When specified, returns additional process information.

.EXAMPLE
    Get-SystemProcesses
    Gets information about all processes on the local computer.

.EXAMPLE
    Get-SystemProcesses -ComputerName "server01" -ProcessName "chrome"
    Gets information about Chrome processes on a remote computer.

.EXAMPLE
    Get-SystemProcesses -Top 10 -Detailed
    Gets detailed information about the top 10 processes by CPU usage.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing process information.

.NOTES
    Requires appropriate permissions for remote process access.
    Some process information may require administrative privileges.
#>
function Get-SystemProcesses {
    # ... existing code ...
}

# Export all functions
Export-ModuleMember -Function @(
    'Get-SystemPerformance',
    'Get-SystemHealth',
    'Get-SystemEvents',
    'Get-SystemServices',
    'Get-SystemProcesses'
)
#endregion 