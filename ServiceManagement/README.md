# ServiceManagement Module

## Overview
The ServiceManagement module provides essential functions for managing Windows services on Windows 10/11 systems. This module enables administrators to monitor service status, manage pending services, restart critical services, and retrieve comprehensive service information.

## Functions

### Get-ServiceList
Retrieves a filtered list of Windows services with comprehensive service information.

#### Syntax
```powershell
Get-ServiceList [[-Filter] <string>]
```

#### Parameters
- **Filter** (Optional): Service name filter using wildcard matching. Default is "*" (all services).

#### Examples
```powershell
# Get all Windows services
Get-ServiceList

# Get services with names containing "Windows"
Get-ServiceList -Filter "*Windows*"

# Get services starting with "Win"
Get-ServiceList -Filter "Win*"

# Get specific service
Get-ServiceList -Filter "Spooler"

# Get services and filter by status
Get-ServiceList | Where-Object { $_.State -eq "Running" }
```

#### Output
Returns Win32_Service CIM objects containing comprehensive service information:
- **Name**: Service name
- **DisplayName**: Service display name
- **State**: Current service state (Running, Stopped, etc.)
- **StartMode**: Service startup type (Automatic, Manual, Disabled)
- **ProcessId**: Process ID of the service
- **PathName**: Executable path
- **Description**: Service description
- **StartName**: Account the service runs under

### Additional Functions

#### Get-ServicePendingStatus
Retrieves services that are in pending states (start pending, stop pending).
```powershell
Get-ServicePendingStatus [[-Status] <string>]
```

**Parameters:**
- `Status`: Filter by pending status ("Start", "Stop", "All"). Default is "All".

**Examples:**
```powershell
# Get all services in pending states
Get-ServicePendingStatus

# Get only services with start pending status
Get-ServicePendingStatus -Status "Start"

# Get only services with stop pending status
Get-ServicePendingStatus -Status "Stop"
```

#### Stop-PendingServices
Forcefully stops services that are stuck in "stop pending" state.
```powershell
Stop-PendingServices
```

**Examples:**
```powershell
# Stop all services stuck in stop pending state
Stop-PendingServices
```

#### Restart-WMIService
Restarts the Windows Management Instrumentation (WMI) service.
```powershell
Restart-WMIService [-Force]
```

**Parameters:**
- `Force`: Forces the restart without confirmation

**Examples:**
```powershell
# Restart WMI service with confirmation
Restart-WMIService

# Force restart WMI service without confirmation
Restart-WMIService -Force
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (required for service management operations)

### Import Module
```powershell
Import-Module ServiceManagement
```

## Usage Examples

### Service Status Monitoring
```powershell
# Monitor critical services
$criticalServices = @("Spooler", "BITS", "Winmgmt", "EventLog", "Themes")

Write-Host "=== Critical Service Status ===" -ForegroundColor Cyan
foreach ($serviceName in $criticalServices) {
    $service = Get-ServiceList -Filter $serviceName
    if ($service) {
        $status = if ($service.State -eq "Running") { "✓" } else { "✗" }
        $color = if ($service.State -eq "Running") { "Green" } else { "Red" }
        Write-Host "$status $($service.DisplayName): $($service.State)" -ForegroundColor $color
    }
}
```

### Service Troubleshooting
```powershell
# Check for problematic services
Write-Host "Checking for service issues..." -ForegroundColor Yellow

# Check for pending services
$pendingServices = Get-ServicePendingStatus
if ($pendingServices) {
    Write-Warning "Services in pending state detected:"
    $pendingServices | Format-Table Name, State, ProcessId -AutoSize
    
    # Attempt to resolve stop pending services
    $stopPending = Get-ServicePendingStatus -Status "Stop"
    if ($stopPending) {
        Write-Host "Attempting to resolve stop pending services..." -ForegroundColor Yellow
        Stop-PendingServices
    }
}

# Check for stopped critical services
$stoppedCritical = Get-ServiceList | Where-Object { 
    $_.Name -in @("Spooler", "BITS", "Winmgmt") -and $_.State -ne "Running" 
}

if ($stoppedCritical) {
    Write-Warning "Critical services are stopped:"
    $stoppedCritical | Format-Table Name, DisplayName, State -AutoSize
}
```

### Service Management Dashboard
```powershell
# Create a comprehensive service management dashboard
function Show-ServiceDashboard {
    Write-Host "=== Windows Service Management Dashboard ===" -ForegroundColor Cyan
    
    # Service count by status
    $allServices = Get-ServiceList
    $serviceStats = $allServices | Group-Object State
    
    Write-Host "`nService Status Summary:" -ForegroundColor Green
    $serviceStats | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
    }
    
    # Automatic services that are stopped
    $stoppedAutoServices = $allServices | Where-Object { 
        $_.StartMode -eq "Auto" -and $_.State -eq "Stopped" 
    }
    
    if ($stoppedAutoServices) {
        Write-Host "`nAutomatic Services That Are Stopped:" -ForegroundColor Yellow
        $stoppedAutoServices | Format-Table Name, DisplayName -AutoSize
    }
    
    # Services in pending states
    $pendingServices = Get-ServicePendingStatus
    if ($pendingServices) {
        Write-Host "`nServices in Pending States:" -ForegroundColor Red
        $pendingServices | Format-Table Name, State, ProcessId -AutoSize
    }
    
    # High memory usage services
    $runningServices = $allServices | Where-Object { $_.State -eq "Running" -and $_.ProcessId -gt 0 }
    if ($runningServices) {
        Write-Host "`nTop 10 Services by Memory Usage:" -ForegroundColor Green
        $serviceProcesses = $runningServices | ForEach-Object {
            $process = Get-Process -Id $_.ProcessId -ErrorAction SilentlyContinue
            if ($process) {
                [PSCustomObject]@{
                    ServiceName = $_.Name
                    DisplayName = $_.DisplayName
                    ProcessId = $_.ProcessId
                    MemoryMB = [math]::Round($process.WorkingSet / 1MB, 2)
                }
            }
        } | Sort-Object MemoryMB -Descending | Select-Object -First 10
        
        $serviceProcesses | Format-Table ServiceName, DisplayName, ProcessId, MemoryMB -AutoSize
    }
}

Show-ServiceDashboard
```

### Automated Service Recovery
```powershell
# Automated service recovery script
function Start-ServiceRecovery {
    param(
        [string[]]$CriticalServices = @("Spooler", "BITS", "Winmgmt", "EventLog")
    )
    
    Write-Host "Starting automated service recovery..." -ForegroundColor Yellow
    
    # Check and restart stopped critical services
    foreach ($serviceName in $CriticalServices) {
        $service = Get-ServiceList -Filter $serviceName
        if ($service -and $service.State -ne "Running") {
            Write-Host "Attempting to start $($service.DisplayName)..." -ForegroundColor Yellow
            try {
                Start-Service -Name $serviceName -ErrorAction Stop
                Write-Host "✓ Successfully started $($service.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "✗ Failed to start $($service.DisplayName): $($_.Exception.Message)"
            }
        }
    }
    
    # Handle pending services
    $pendingServices = Get-ServicePendingStatus
    if ($pendingServices) {
        Write-Host "Resolving pending services..." -ForegroundColor Yellow
        Stop-PendingServices
    }
    
    # Restart WMI if needed
    $wmiService = Get-ServiceList -Filter "Winmgmt"
    if ($wmiService -and $wmiService.State -ne "Running") {
        Write-Host "Restarting WMI service..." -ForegroundColor Yellow
        Restart-WMIService -Force
    }
    
    Write-Host "Service recovery completed." -ForegroundColor Green
}

Start-ServiceRecovery
```

### Service Dependency Analysis
```powershell
# Analyze service dependencies
function Get-ServiceDependencies {
    param([string]$ServiceName)
    
    $service = Get-ServiceList -Filter $ServiceName
    if (-not $service) {
        Write-Warning "Service '$ServiceName' not found"
        return
    }
    
    Write-Host "Service Dependencies for: $($service.DisplayName)" -ForegroundColor Cyan
    
    # Get dependencies using Get-Service
    $serviceObj = Get-Service -Name $ServiceName
    
    if ($serviceObj.ServicesDependedOn) {
        Write-Host "`nServices this service depends on:" -ForegroundColor Green
        $serviceObj.ServicesDependedOn | ForEach-Object {
            $depService = Get-ServiceList -Filter $_.Name
            Write-Host "  - $($_.DisplayName) [$($_.Status)]" -ForegroundColor White
        }
    }
    
    if ($serviceObj.DependentServices) {
        Write-Host "`nServices that depend on this service:" -ForegroundColor Yellow
        $serviceObj.DependentServices | ForEach-Object {
            Write-Host "  - $($_.DisplayName) [$($_.Status)]" -ForegroundColor White
        }
    }
}

# Example usage
Get-ServiceDependencies -ServiceName "Winmgmt"
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges required for service management operations
- **Services**: Windows Management Instrumentation (WMI) service

## Dependencies
- Windows Service Control Manager
- Windows Management Instrumentation (WMI)
- CIM cmdlets

## Service Management Best Practices

### Critical Services
Monitor these essential Windows services:
- **Winmgmt**: Windows Management Instrumentation
- **Spooler**: Print Spooler
- **BITS**: Background Intelligent Transfer Service
- **EventLog**: Windows Event Log
- **Themes**: Themes service for desktop experience

### Service States
- **Running**: Service is active and functioning
- **Stopped**: Service is not running
- **Start Pending**: Service is starting up
- **Stop Pending**: Service is shutting down
- **Pause Pending**: Service is pausing
- **Paused**: Service is paused

### Startup Types
- **Automatic**: Starts automatically at system boot
- **Automatic (Delayed Start)**: Starts automatically after other automatic services
- **Manual**: Starts only when requested
- **Disabled**: Cannot be started

## Error Handling
The module includes comprehensive error handling for:
- Service access permission issues
- Service control manager connectivity
- Process termination failures
- WMI service restart problems

## Security Considerations
- Administrative privileges are required for most service management operations
- Be cautious when stopping or restarting critical system services
- Monitor service account changes and permissions
- Implement proper logging for service management activities

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are required for service management operations.