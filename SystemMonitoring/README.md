# System Monitoring PowerShell Module

This module provides comprehensive system monitoring and performance tracking capabilities for Windows systems.

## Requirements

- PowerShell 5.1 or later
- Windows 10/Server 2016 or later
- Administrative privileges for some functions
- Common module (automatically imported as a dependency)

## Functions

### Get-SystemEventLogs
Retrieves and filters system event logs with customizable time ranges and event types.

```powershell
# Get system events from the last 12 hours
Get-SystemEventLogs -Hours 12

# Get specific event types
Get-SystemEventLogs -EventType Error,Warning -Hours 24
```

### Get-MemoryUsage
Monitors system memory usage and provides detailed statistics.

```powershell
# Get current memory usage
Get-MemoryUsage

# Get memory usage with threshold alert
Get-MemoryUsage -Threshold 90
```

### Get-CPUUsage
Monitors CPU usage and provides process-level statistics.

```powershell
# Get current CPU usage
Get-CPUUsage

# Get top CPU consuming processes
Get-CPUUsage -Top 10
```

### Get-HighMemoryProcesses
Identifies processes consuming excessive memory.

```powershell
# Get processes using more than 5% memory
Get-HighMemoryProcesses -Threshold 5

# Get top memory consuming processes
Get-HighMemoryProcesses -Top 10
```

### Get-SystemServices
Monitors system services status and health.

```powershell
# Get all services
Get-SystemServices

# Get services with specific status
Get-SystemServices -Status Running
```

### Get-SystemPerformance
Provides comprehensive system performance metrics.

```powershell
# Get all performance metrics
Get-SystemPerformance

# Get specific performance counters
Get-SystemPerformance -Counters 'Memory', 'CPU', 'Disk'
```

## Usage

Import the module in your scripts:

```powershell
Import-Module .\SystemMonitoring
```

## Examples

### Basic System Health Check
```powershell
# Check system health
$health = @{
    Memory = Get-MemoryUsage
    CPU = Get-CPUUsage
    Services = Get-SystemServices -Status Running
    Events = Get-SystemEventLogs -Hours 1 -EventType Error,Warning
}

# Export to CSV
$health | Export-Csv -Path "SystemHealth_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
```

### Performance Monitoring Script
```powershell
# Monitor system performance every 5 minutes
while ($true) {
    $performance = Get-SystemPerformance
    Write-LogMessage -Message "Performance metrics collected" -Level Info
    Start-Sleep -Seconds 300
}
```

## Error Handling

All functions include:
- Proper error handling and logging
- Input validation
- Detailed error messages
- Logging through the Common module

## Contributing

When adding new monitoring functions:
1. Add the function to SystemMonitoring.psm1
2. Update the FunctionsToExport list in SystemMonitoring.psd1
3. Update this README with function documentation
4. Include appropriate error handling and logging
5. Add parameter validation
6. Include examples in the function comment-based help 