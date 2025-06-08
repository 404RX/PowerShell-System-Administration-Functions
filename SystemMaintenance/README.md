# SystemMaintenance Module

## Overview
The SystemMaintenance module provides comprehensive functions for system maintenance and optimization on Windows 10/11 systems. This module enables administrators to perform disk cleanup, system file integrity checks, and various optimization tasks to maintain system performance and health.

## Functions

### Start-SystemOptimization
Performs comprehensive system optimization tasks including disk defragmentation, service optimization, and startup optimization.

#### Syntax
```powershell
Start-SystemOptimization [[-ComputerName] <string>] [[-Categories] <string[]>] [-Force] [-Detailed]
```

#### Parameters
- **ComputerName** (Optional): The computer to optimize. Defaults to local computer.
- **Categories** (Optional): Specific optimization categories to perform. Valid values:
  - `DiskDefrag`: Optimizes disk drives
  - `ServiceOptimization`: Optimizes Windows services
  - `StartupOptimization`: Optimizes startup items
  - Default: All categories
- **Force** (Optional): Skips confirmation prompts
- **Detailed** (Optional): Returns detailed optimization results

#### Examples
```powershell
# Perform full system optimization
Start-SystemOptimization

# Optimize specific categories without confirmation
Start-SystemOptimization -Categories "DiskDefrag","StartupOptimization" -Force

# Perform detailed optimization on a remote computer
Start-SystemOptimization -ComputerName "Server01" -Detailed

# Optimize only disk defragmentation
Start-SystemOptimization -Categories "DiskDefrag" -Force -Detailed
```

#### Output
Returns custom objects containing:
- **Status**: Overall optimization status
- **Categories**: Categories that were optimized
- **ComputerName**: Target computer name
- **Timestamp**: When optimization was performed (in detailed mode)

### Additional Functions

#### Start-DiskCleanup
Performs comprehensive disk cleanup operations.
```powershell
Start-DiskCleanup [[-ComputerName] <string>] [[-Categories] <string[]>] [-Force] [-Detailed]
```

**Categories:**
- `TempFiles`: Cleans temporary files
- `WindowsUpdate`: Cleans Windows Update cache
- `SystemFiles`: Cleans system files using cleanmgr
- `RecycleBin`: Empties recycle bin

#### Start-SystemFileCheck
Performs system file integrity check and repair using SFC and DISM.
```powershell
Start-SystemFileCheck [[-ComputerName] <string>] [-Repair] [-Offline] [-Detailed]
```

**Parameters:**
- `Repair`: Attempts to repair corrupted files
- `Offline`: Performs offline repair using Windows image
- `Detailed`: Returns detailed check results

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (required)
- Common module dependency

### Import Module
```powershell
Import-Module SystemMaintenance
```

## Usage Examples

### Complete System Maintenance
```powershell
# Perform comprehensive system maintenance
Write-Host "Starting system cleanup..." -ForegroundColor Green
Start-DiskCleanup -Force

Write-Host "Checking system file integrity..." -ForegroundColor Green
Start-SystemFileCheck -Repair

Write-Host "Optimizing system performance..." -ForegroundColor Green
Start-SystemOptimization -Force

Write-Host "System maintenance completed!" -ForegroundColor Green
```

### Scheduled Maintenance Script
```powershell
# Weekly maintenance routine
$maintenanceResults = @{}

# Disk cleanup
$maintenanceResults.Cleanup = Start-DiskCleanup -Categories "TempFiles","RecycleBin" -Force -Detailed

# System optimization
$maintenanceResults.Optimization = Start-SystemOptimization -Categories "DiskDefrag" -Force -Detailed

# Generate report
$maintenanceResults | ConvertTo-Json | Out-File "C:\Logs\MaintenanceReport_$(Get-Date -Format 'yyyyMMdd').json"
```

### Targeted Optimization
```powershell
# Optimize only startup items
Start-SystemOptimization -Categories "StartupOptimization" -Detailed | 
    Format-Table Category, Status, Timestamp -AutoSize

# Clean only Windows Update cache
Start-DiskCleanup -Categories "WindowsUpdate" -Force
```

### System Health Check
```powershell
# Comprehensive system health check with repair
Write-Host "Performing system health check..." -ForegroundColor Yellow

# Check and repair system files
$sfcResults = Start-SystemFileCheck -Repair -Detailed
if ($sfcResults.RepairAttempted) {
    Write-Host "System file repair completed" -ForegroundColor Green
}

# Clean up system
Start-DiskCleanup -Categories "TempFiles","SystemFiles" -Force
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges required
- **Dependencies**: Common module
- **Services**: Required Windows services must be running

## Optimization Categories

### DiskDefrag
- Optimizes all fixed drives
- Uses `Optimize-Volume` cmdlet
- Performs defragmentation on traditional drives
- Performs optimization on SSDs

### ServiceOptimization
- Reviews Windows services
- Optimizes service startup types
- Maintains required services
- Improves boot performance

### StartupOptimization
- Reviews startup programs
- Removes unnecessary startup items
- Preserves essential system startup items
- Improves boot time

## Cleanup Categories

### TempFiles
- Cleans `%TEMP%` directory
- Cleans `%WINDIR%\Temp` directory
- Cleans Windows Prefetch files
- Removes temporary installation files

### WindowsUpdate
- Stops Windows Update service
- Cleans SoftwareDistribution folder
- Restarts Windows Update service
- Frees up significant disk space

### SystemFiles
- Uses Windows Disk Cleanup utility
- Cleans system files and logs
- Removes old Windows installations
- Cleans Windows component store

### RecycleBin
- Empties all recycle bins
- Frees up disk space immediately
- Uses `Clear-RecycleBin` cmdlet

## Safety Considerations
- **Backup Important Data**: Always backup important data before maintenance
- **System Restore Point**: Consider creating a system restore point
- **Service Dependencies**: Some optimizations may affect service dependencies
- **Startup Items**: Review startup optimization results carefully
- **System Files**: System file repairs may require restart

## Error Handling
The module includes comprehensive error handling for:
- Insufficient privileges
- Service access issues
- Disk access problems
- Registry access restrictions
- Remote computer connectivity

## Performance Impact
- Disk operations may temporarily impact system performance
- Service optimization requires careful consideration of dependencies
- Some operations may require system restart
- Network-based operations may affect remote systems

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are required for all maintenance operations.