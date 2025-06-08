# SystemInformation Module

## Overview
The SystemInformation module provides comprehensive functions for gathering detailed system information and monitoring on Windows 10/11 systems. This module enables administrators to retrieve hardware details, system status, performance metrics, and security information including Windows Defender status.

## Functions

### Get-DefenderStatus
Retrieves detailed information about Windows Defender including antivirus status, real-time protection, and signature information.

#### Syntax
```powershell
Get-DefenderStatus
```

#### Parameters
This function takes no parameters and queries the local system.

#### Examples
```powershell
# Get all Windows Defender status information
Get-DefenderStatus

# Check if antivirus is enabled
$defenderStatus = Get-DefenderStatus
if (-not $defenderStatus.AntivirusEnabled) {
    Write-Warning "Windows Defender antivirus is disabled!"
}

# Get specific Defender status properties
Get-DefenderStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled

# Check signature update status
$defender = Get-DefenderStatus
if ($defender.AntivirusSignatureLastUpdated -lt (Get-Date).AddDays(-7)) {
    Write-Warning "Antivirus signatures are outdated!"
}
```

#### Output
Returns custom objects containing:
- **AntivirusEnabled**: Whether Windows Defender antivirus is enabled
- **AntispywareEnabled**: Whether Windows Defender antispyware is enabled
- **RealTimeProtectionEnabled**: Whether real-time protection is active
- **AntivirusSignatureVersion**: Current antivirus signature version
- **AntivirusSignatureLastUpdated**: When antivirus signatures were last updated
- **AntispywareSignatureVersion**: Current antispyware signature version
- **AntispywareSignatureLastUpdated**: When antispyware signatures were last updated

### Additional Functions

#### Get-SystemInfo
Retrieves comprehensive system information including hardware and OS details.
```powershell
Get-SystemInfo [-Detailed]
```

**Examples:**
```powershell
# Get basic system information
Get-SystemInfo

# Get all available system information
Get-SystemInfo -Detailed

# Get specific system properties
Get-SystemInfo | Select-Object CsDNSHostName, WindowsProductName, OsLastBootUpTime
```

#### Get-MemoryUsage
Retrieves detailed memory usage information and top memory-consuming processes.
```powershell
Get-MemoryUsage [-TopProcesses] [[-ProcessCount] <int>] [[-Threshold] <int>]
```

**Examples:**
```powershell
# Get basic memory usage
Get-MemoryUsage

# Get memory usage with top 10 processes
Get-MemoryUsage -TopProcesses -ProcessCount 10

# Set memory usage warning threshold to 85%
Get-MemoryUsage -Threshold 85
```

#### Get-CPUUsage
Retrieves detailed CPU information and top CPU-consuming processes.
```powershell
Get-CPUUsage [-TopProcesses] [[-ProcessCount] <int>] [[-Threshold] <int>]
```

#### Get-DriveStatus
Retrieves drive status information including space usage and file system details.
```powershell
Get-DriveStatus [[-DriveLetter] <string>]
```

#### Get-SystemVersion
Retrieves system version information including OS version, build, and .NET Framework.
```powershell
Get-SystemVersion
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Windows Defender (for Get-DefenderStatus function)

### Import Module
```powershell
Import-Module SystemInformation
```

## Usage Examples

### System Health Dashboard
```powershell
# Create a comprehensive system health report
Write-Host "=== System Health Dashboard ===" -ForegroundColor Cyan

# System Information
$sysInfo = Get-SystemInfo
Write-Host "`nSystem: $($sysInfo.CsDNSHostName) - $($sysInfo.WindowsProductName)" -ForegroundColor Green
Write-Host "Last Boot: $($sysInfo.OsLastBootUpTime)" -ForegroundColor Green

# Memory Status
$memory = Get-MemoryUsage -Threshold 80
Write-Host "`nMemory Usage: $($memory.MemoryUsagePercent)% ($($memory.UsedPhysicalMemory)MB / $($memory.TotalPhysicalMemory)MB)" -ForegroundColor Green

# Drive Status
$drives = Get-DriveStatus
Write-Host "`nDrive Status:" -ForegroundColor Green
$drives | Format-Table DriveLetter, VolumeName, @{Name="Used%";Expression={100-$_.FreeSpacePercent}}, @{Name="Free GB";Expression={$_.FreeSpace}}

# Defender Status
$defender = Get-DefenderStatus
Write-Host "`nWindows Defender Status:" -ForegroundColor Green
Write-Host "  Antivirus: $(if($defender.AntivirusEnabled){'Enabled'}else{'Disabled'})" -ForegroundColor $(if($defender.AntivirusEnabled){'Green'}else{'Red'})
Write-Host "  Real-time Protection: $(if($defender.RealTimeProtectionEnabled){'Enabled'}else{'Disabled'})" -ForegroundColor $(if($defender.RealTimeProtectionEnabled){'Green'}else{'Red'})
Write-Host "  Last Signature Update: $($defender.AntivirusSignatureLastUpdated)" -ForegroundColor Green
```

### Security Monitoring
```powershell
# Monitor Windows Defender status
$defenderStatus = Get-DefenderStatus

# Check for security issues
$securityIssues = @()

if (-not $defenderStatus.AntivirusEnabled) {
    $securityIssues += "Windows Defender antivirus is disabled"
}

if (-not $defenderStatus.RealTimeProtectionEnabled) {
    $securityIssues += "Real-time protection is disabled"
}

if ($defenderStatus.AntivirusSignatureLastUpdated -lt (Get-Date).AddDays(-3)) {
    $securityIssues += "Antivirus signatures are outdated (last updated: $($defenderStatus.AntivirusSignatureLastUpdated))"
}

if ($securityIssues.Count -gt 0) {
    Write-Warning "Security issues detected:"
    $securityIssues | ForEach-Object { Write-Warning "  - $_" }
} else {
    Write-Host "No security issues detected" -ForegroundColor Green
}
```

### Performance Monitoring
```powershell
# Monitor system performance
$memory = Get-MemoryUsage -TopProcesses -ProcessCount 5
$cpu = Get-CPUUsage -TopProcesses -ProcessCount 5

Write-Host "=== Performance Report ===" -ForegroundColor Yellow

# Memory analysis
if ($memory.MemoryUsagePercent -gt 90) {
    Write-Warning "High memory usage detected: $($memory.MemoryUsagePercent)%"
    Write-Host "Top memory consumers:" -ForegroundColor Yellow
    $memory.TopProcesses | Format-Table ProcessName, @{Name="Memory(MB)";Expression={$_.MemoryUsage}}, PercentOfTotal
}

# CPU analysis
Write-Host "`nCPU Information:" -ForegroundColor Yellow
Write-Host "Processor: $($cpu.ProcessorName)"
Write-Host "Cores: $($cpu.NumberOfCores) | Logical Processors: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Current Speed: $($cpu.CurrentClockSpeed) MHz | Max Speed: $($cpu.MaxClockSpeed) MHz"
```

### System Inventory
```powershell
# Generate comprehensive system inventory
$inventory = @{
    SystemInfo = Get-SystemInfo
    SystemVersion = Get-SystemVersion
    MemoryUsage = Get-MemoryUsage
    CPUInfo = Get-CPUUsage
    DriveStatus = Get-DriveStatus
    DefenderStatus = Get-DefenderStatus
    Timestamp = Get-Date
}

# Export to JSON for reporting
$inventory | ConvertTo-Json -Depth 3 | Out-File "C:\Reports\SystemInventory_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
```

### Automated Health Checks
```powershell
# Automated system health check script
function Test-SystemHealth {
    $healthReport = @{
        Healthy = $true
        Issues = @()
        Warnings = @()
    }
    
    # Check memory usage
    $memory = Get-MemoryUsage
    if ($memory.MemoryUsagePercent -gt 95) {
        $healthReport.Issues += "Critical memory usage: $($memory.MemoryUsagePercent)%"
        $healthReport.Healthy = $false
    } elseif ($memory.MemoryUsagePercent -gt 85) {
        $healthReport.Warnings += "High memory usage: $($memory.MemoryUsagePercent)%"
    }
    
    # Check drive space
    $drives = Get-DriveStatus
    foreach ($drive in $drives) {
        if ($drive.FreeSpacePercent -lt 5) {
            $healthReport.Issues += "Critical disk space on $($drive.DriveLetter): $($drive.FreeSpacePercent)% free"
            $healthReport.Healthy = $false
        } elseif ($drive.FreeSpacePercent -lt 15) {
            $healthReport.Warnings += "Low disk space on $($drive.DriveLetter): $($drive.FreeSpacePercent)% free"
        }
    }
    
    # Check Defender status
    $defender = Get-DefenderStatus
    if (-not $defender.AntivirusEnabled) {
        $healthReport.Issues += "Windows Defender antivirus is disabled"
        $healthReport.Healthy = $false
    }
    
    return $healthReport
}

# Run health check
$health = Test-SystemHealth
if ($health.Healthy) {
    Write-Host "System health check passed" -ForegroundColor Green
} else {
    Write-Warning "System health issues detected!"
    $health.Issues | ForEach-Object { Write-Error $_ }
}
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Standard user (some functions may require administrative privileges)
- **Services**: Windows Management Instrumentation (WMI), Windows Defender

## Dependencies
- Windows Management Framework
- Get-ComputerInfo cmdlet
- Get-MpComputerStatus cmdlet (for Defender status)
- CIM/WMI services

## Function Details

### Memory Usage Thresholds
- **Default Warning**: 90% memory usage
- **Configurable**: Set custom thresholds via `-Threshold` parameter
- **Process Tracking**: Monitor top memory-consuming processes

### Drive Status Monitoring
- **All Drives**: Monitors all logical drives by default
- **Specific Drive**: Filter by drive letter
- **Space Reporting**: Reports in gigabytes (GB)
- **Percentage Calculations**: Free space percentage calculations

### Defender Status Requirements
- Requires Windows Defender to be installed
- Some properties may not be available if Defender is not the active antivirus
- Administrative privileges may be required for full status information

## Error Handling
The module includes comprehensive error handling for:
- Windows Defender availability issues
- WMI/CIM service problems
- Insufficient privileges
- Service access restrictions

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Windows Defender must be installed for the Get-DefenderStatus function to work properly.