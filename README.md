# PowerShell System Administration Functions

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2B%20%7C%20Server%202016%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A comprehensive collection of PowerShell functions designed for Windows system administration, monitoring, and management tasks. This documentation covers 9 essential functions that provide IT professionals with powerful tools for managing Windows systems, network operations, security monitoring, and system maintenance.

## Table of Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Function Documentation](#function-documentation)
  - [Get-WindowsUpdateHistory](#get-windowsupdatehistory)
  - [Get-FailedLogons](#get-failedlogons)
  - [Start-SystemOptimization](#start-systemoptimization)
  - [Get-SoftwareUpdates](#get-softwareupdates)
  - [Get-DefenderStatus](#get-defenderstatus)
  - [Get-ServiceList](#get-servicelist)
  - [Export-EventLogs](#export-eventlogs)
  - [Start-NetworkTrafficAnalysis](#start-networktrafficanalysis)
  - [Send-WakeOnLAN](#send-wakeonlan)
- [Installation](#installation)
- [Usage Examples](#usage-examples)
- [Error Handling](#error-handling)
- [Contributing](#contributing)
- [License](#license)

## Overview

This collection provides essential PowerShell functions for:

- **Windows Update Management**: Track and monitor Windows update history
- **Security Monitoring**: Monitor failed logon attempts and security events
- **System Optimization**: Perform comprehensive system maintenance and optimization
- **Software Management**: Monitor and manage software updates
- **Security Status**: Check Windows Defender protection status
- **Service Management**: List and monitor Windows services
- **Event Log Management**: Export and analyze Windows event logs
- **Network Diagnostics**: Analyze network traffic and performance
- **Network Management**: Send Wake-on-LAN packets for remote system management

## System Requirements

| Component | Requirement |
|-----------|-------------|
| **PowerShell Version** | 5.1 or later |
| **Operating System** | Windows 10 (1809+) / Windows Server 2016+ |
| **Execution Policy** | RemoteSigned or Unrestricted |
| **Administrator Rights** | Required for most operations |
| **Network Access** | Required for network-related functions |

## Function Documentation

### Get-WindowsUpdateHistory

**Module**: [`WindowsUpdateManagement`](WindowsUpdateManagement/WindowsUpdateManagement.psm1)

**Purpose**: Retrieves Windows update history from the system, providing detailed information about installed updates, their status, and installation dates.

#### Syntax
```powershell
Get-WindowsUpdateHistory [[-MaxResults] <Int32>]
```

#### Parameters
- **MaxResults** (Int32, Optional)
  - Default: 100
  - Description: Maximum number of update records to retrieve
  - Range: 1-1000

#### Return Values
Returns an array of objects containing:
- `Title`: Update title/name
- `Date`: Installation date
- `Result`: Installation result (Succeeded, Failed, etc.)
- `Description`: Update description
- `SupportUrl`: Microsoft support URL for the update

#### Requirements/Dependencies
- Windows Update service must be running
- Administrator privileges recommended
- Windows 10/Server 2016 or later

#### Usage Examples
```powershell
# Get last 50 Windows updates
Get-WindowsUpdateHistory -MaxResults 50

# Get all available update history (up to default 100)
Get-WindowsUpdateHistory

# Filter for failed updates
Get-WindowsUpdateHistory | Where-Object { $_.Result -eq "Failed" }
```

#### Error Handling
- Handles Windows Update service unavailability
- Validates MaxResults parameter range
- Provides detailed error messages for access denied scenarios

---

### Get-FailedLogons

**Module**: [`UserSessionManagement`](UserSessionManagement/UserSessionManagement.psm1)

**Purpose**: Retrieves failed logon attempts from the Windows Security event log, helping identify potential security threats and authentication issues.

#### Syntax
```powershell
Get-FailedLogons [[-ComputerName] <String>] [[-Username] <String>] [[-Hours] <Int32>]
```

#### Parameters
- **ComputerName** (String, Optional)
  - Default: Local computer
  - Description: Target computer name for remote query
  
- **Username** (String, Optional)
  - Default: All users
  - Description: Specific username to filter results
  
- **Hours** (Int32, Optional)
  - Default: 24
  - Description: Number of hours to look back for failed logons
  - Range: 1-8760 (1 year)

#### Return Values
Returns an array of objects containing:
- `TimeCreated`: When the failed logon occurred
- `Username`: Account that failed to log on
- `ComputerName`: Source computer
- `IPAddress`: Source IP address (if available)
- `LogonType`: Type of logon attempt
- `FailureReason`: Reason for logon failure

#### Requirements/Dependencies
- Security event log access
- Administrator privileges required
- Event ID 4625 logging must be enabled

#### Usage Examples
```powershell
# Get failed logons in last 24 hours
Get-FailedLogons

# Get failed logons for specific user in last 48 hours
Get-FailedLogons -Username "john.doe" -Hours 48

# Get failed logons from remote computer
Get-FailedLogons -ComputerName "SERVER01" -Hours 12
```

#### Error Handling
- Validates computer connectivity for remote queries
- Handles insufficient privileges gracefully
- Provides meaningful error messages for event log access issues

---

### Start-SystemOptimization

**Module**: [`SystemMaintenance`](SystemMaintenance/SystemMaintenance.psm1)

**Purpose**: Performs comprehensive system optimization including disk cleanup, temporary file removal, registry optimization, and system file integrity checks.

#### Syntax
```powershell
Start-SystemOptimization [[-Categories] <String[]>] [-Force] [-Detailed]
```

#### Parameters
- **Categories** (String[], Optional)
  - Default: All categories
  - Description: Specific optimization categories to run
  - Valid values: "DiskCleanup", "TempFiles", "Registry", "SystemFiles", "Services"
  
- **Force** (Switch, Optional)
  - Description: Skip confirmation prompts
  
- **Detailed** (Switch, Optional)
  - Description: Provide detailed progress and results

#### Return Values
Returns an object containing:
- `OptimizationResults`: Array of results for each category
- `TotalSpaceFreed`: Total disk space freed (in MB)
- `Duration`: Time taken for optimization
- `Errors`: Any errors encountered during optimization

#### Requirements/Dependencies
- Administrator privileges required
- Sufficient disk space for temporary operations
- Windows 10/Server 2016 or later

#### Usage Examples
```powershell
# Run full system optimization with prompts
Start-SystemOptimization

# Run specific optimization categories without prompts
Start-SystemOptimization -Categories "DiskCleanup", "TempFiles" -Force

# Run detailed optimization with progress information
Start-SystemOptimization -Detailed
```

#### Error Handling
- Validates administrator privileges before starting
- Handles disk space constraints
- Provides rollback capabilities for registry changes
- Detailed logging of all operations

---

### Get-SoftwareUpdates

**Module**: [`SoftwareManagement`](SoftwareManagement/SoftwareManagement.psm1)

**Purpose**: Retrieves available software updates using the Windows Update API, providing information about both installable and already installed updates.

#### Syntax
```powershell
Get-SoftwareUpdates [-Installable] [-Installed]
```

#### Parameters
- **Installable** (Switch, Optional)
  - Description: Show only updates available for installation
  
- **Installed** (Switch, Optional)
  - Description: Show only already installed updates

#### Return Values
Returns an array of objects containing:
- `Title`: Update title
- `Description`: Update description
- `Size`: Download size in bytes
- `IsInstalled`: Installation status
- `IsDownloaded`: Download status
- `Categories`: Update categories
- `Severity`: Update severity level
- `RebootRequired`: Whether reboot is required

#### Requirements/Dependencies
- Windows Update service must be running
- Internet connectivity for update checks
- Administrator privileges recommended

#### Usage Examples
```powershell
# Get all available updates
Get-SoftwareUpdates

# Get only installable updates
Get-SoftwareUpdates -Installable

# Get only installed updates
Get-SoftwareUpdates -Installed

# Get critical updates only
Get-SoftwareUpdates -Installable | Where-Object { $_.Severity -eq "Critical" }
```

#### Error Handling
- Handles Windows Update service connectivity issues
- Validates internet connectivity
- Provides detailed error information for API failures

---

### Get-DefenderStatus

**Module**: [`SystemInformation`](SystemInformation/SystemInformation.psm1)

**Purpose**: Retrieves the current status of Windows Defender antivirus protection, including real-time protection status, definition versions, and scan information.

#### Syntax
```powershell
Get-DefenderStatus
```

#### Parameters
None

#### Return Values
Returns an object containing:
- `AntivirusEnabled`: Whether antivirus protection is enabled
- `RealTimeProtectionEnabled`: Real-time protection status
- `DefinitionVersion`: Current definition version
- `DefinitionLastUpdated`: Last definition update date
- `LastFullScan`: Date of last full scan
- `LastQuickScan`: Date of last quick scan
- `ThreatDetectionEnabled`: Threat detection status
- `CloudProtectionEnabled`: Cloud-based protection status

#### Requirements/Dependencies
- Windows Defender must be installed
- Windows 10/Server 2016 or later
- WMI access required

#### Usage Examples
```powershell
# Get current Defender status
$DefenderStatus = Get-DefenderStatus
Write-Host "Real-time Protection: $($DefenderStatus.RealTimeProtectionEnabled)"

# Check if definitions are up to date
$Status = Get-DefenderStatus
if ($Status.DefinitionLastUpdated -lt (Get-Date).AddDays(-7)) {
    Write-Warning "Defender definitions are more than 7 days old"
}
```

#### Error Handling
- Handles cases where Windows Defender is not installed
- Provides fallback for third-party antivirus software
- Validates WMI connectivity

---

### Get-ServiceList

**Module**: [`ServiceManagement`](ServiceManagement/ServiceManagement.psm1)

**Purpose**: Retrieves a comprehensive list of Windows services with their current status, startup type, and additional service information.

#### Syntax
```powershell
Get-ServiceList [[-Filter] <String>]
```

#### Parameters
- **Filter** (String, Optional)
  - Description: Filter services by name, status, or startup type
  - Examples: "Running", "Stopped", "Automatic", "Manual", "Disabled"

#### Return Values
Returns an array of objects containing:
- `Name`: Service name
- `DisplayName`: Service display name
- `Status`: Current service status
- `StartType`: Service startup type
- `Description`: Service description
- `ProcessId`: Process ID (if running)
- `DependentServices`: Services that depend on this service
- `ServicesDependedOn`: Services this service depends on

#### Requirements/Dependencies
- Service Control Manager access
- Administrator privileges for detailed information

#### Usage Examples
```powershell
# Get all services
Get-ServiceList

# Get only running services
Get-ServiceList -Filter "Running"

# Get services with automatic startup
Get-ServiceList -Filter "Automatic"

# Get specific service by name pattern
Get-ServiceList | Where-Object { $_.Name -like "*Windows*" }
```

#### Error Handling
- Handles service access permission issues
- Validates filter parameters
- Provides detailed error messages for service enumeration failures

---

### Export-EventLogs

**Module**: [`EventLogging`](EventLogging/EventLogging.psm1)

**Purpose**: Exports Windows event logs to various formats for analysis, archiving, or compliance purposes.

#### Syntax
```powershell
Export-EventLogs [-LogName] <String> [-OutputPath] <String> [[-StartTime] <DateTime>] [[-EndTime] <DateTime>] [[-MaxEvents] <Int32>] [[-Format] <String>]
```

#### Parameters
- **LogName** (String, Mandatory)
  - Description: Name of the event log to export
  - Examples: "System", "Application", "Security"
  
- **OutputPath** (String, Mandatory)
  - Description: Full path for the exported file
  
- **StartTime** (DateTime, Optional)
  - Description: Start time for event filtering
  
- **EndTime** (DateTime, Optional)
  - Description: End time for event filtering
  
- **MaxEvents** (Int32, Optional)
  - Default: 1000
  - Description: Maximum number of events to export
  
- **Format** (String, Optional)
  - Default: "CSV"
  - Valid values: "CSV", "XML", "JSON", "TXT"

#### Return Values
Returns an object containing:
- `ExportPath`: Path to exported file
- `EventCount`: Number of events exported
- `FileSize`: Size of exported file
- `Duration`: Time taken for export
- `Format`: Export format used

#### Requirements/Dependencies
- Event log access permissions
- Write permissions to output directory
- Sufficient disk space for export file

#### Usage Examples
```powershell
# Export System log to CSV
Export-EventLogs -LogName "System" -OutputPath "C:\Logs\system_events.csv"

# Export Security log for last 24 hours
$StartTime = (Get-Date).AddDays(-1)
Export-EventLogs -LogName "Security" -OutputPath "C:\Logs\security.csv" -StartTime $StartTime

# Export Application log to JSON format
Export-EventLogs -LogName "Application" -OutputPath "C:\Logs\app_events.json" -Format "JSON" -MaxEvents 500
```

#### Error Handling
- Validates log name existence
- Checks output path permissions
- Handles large log file exports with progress indication
- Provides detailed error messages for access denied scenarios

---

### Start-NetworkTrafficAnalysis

**Module**: [`NetworkDiagnostics`](NetworkDiagnostics/NetworkDiagnostics.psm1)

**Purpose**: Analyzes network traffic patterns, bandwidth utilization, and connection statistics for network troubleshooting and performance monitoring.

#### Syntax
```powershell
Start-NetworkTrafficAnalysis [[-ComputerName] <String>] [[-Interface] <String>] [[-Duration] <Int32>] [-Detailed]
```

#### Parameters
- **ComputerName** (String, Optional)
  - Default: Local computer
  - Description: Target computer for analysis
  
- **Interface** (String, Optional)
  - Default: All interfaces
  - Description: Specific network interface to analyze
  
- **Duration** (Int32, Optional)
  - Default: 60
  - Description: Analysis duration in seconds
  - Range: 10-3600
  
- **Detailed** (Switch, Optional)
  - Description: Provide detailed traffic breakdown by protocol and port

#### Return Values
Returns an object containing:
- `InterfaceStatistics`: Per-interface traffic statistics
- `TopConnections`: Most active network connections
- `ProtocolBreakdown`: Traffic breakdown by protocol
- `BandwidthUtilization`: Bandwidth usage statistics
- `Duration`: Actual analysis duration
- `Timestamp`: Analysis timestamp

#### Requirements/Dependencies
- Network interface access
- Performance counter access
- Administrator privileges for detailed analysis
- Windows 10/Server 2016 or later

#### Usage Examples
```powershell
# Analyze network traffic for 60 seconds
Start-NetworkTrafficAnalysis

# Analyze specific interface with detailed breakdown
Start-NetworkTrafficAnalysis -Interface "Ethernet" -Duration 120 -Detailed

# Analyze remote computer network traffic
Start-NetworkTrafficAnalysis -ComputerName "SERVER01" -Duration 300
```

#### Error Handling
- Validates network interface availability
- Handles remote computer connectivity issues
- Provides progress indication for long-running analysis
- Validates duration parameters

---

### Send-WakeOnLAN

**Module**: [`NetworkManagement`](NetworkManagement/NetworkManagement.psm1)

**Purpose**: Sends Wake-on-LAN (WOL) magic packets to remotely wake up network-connected computers that support WOL functionality.

#### Syntax
```powershell
Send-WakeOnLAN [-MACAddress] <String> [[-Port] <Int32>]
```

#### Parameters
- **MACAddress** (String, Mandatory)
  - Description: Target computer's MAC address
  - Format: "XX:XX:XX:XX:XX:XX" or "XX-XX-XX-XX-XX-XX"
  
- **Port** (Int32, Optional)
  - Default: 9
  - Description: UDP port for WOL packet
  - Common values: 7, 9

#### Return Values
Returns an object containing:
- `MACAddress`: Target MAC address
- `Port`: Port used for transmission
- `PacketSent`: Whether packet was sent successfully
- `Timestamp`: When packet was sent
- `BroadcastAddress`: Broadcast address used

#### Requirements/Dependencies
- Network connectivity
- UDP port access
- Target computer must support Wake-on-LAN
- Target computer must be configured for WOL

#### Usage Examples
```powershell
# Send WOL packet to specific MAC address
Send-WakeOnLAN -MACAddress "00:1B:44:11:3A:B7"

# Send WOL packet using custom port
Send-WakeOnLAN -MACAddress "00-1B-44-11-3A-B7" -Port 7

# Wake multiple computers
$MACAddresses = @("00:1B:44:11:3A:B7", "00:1B:44:11:3A:B8")
foreach ($MAC in $MACAddresses) {
    Send-WakeOnLAN -MACAddress $MAC
    Start-Sleep -Seconds 2
}
```

#### Error Handling
- Validates MAC address format
- Handles network connectivity issues
- Provides detailed error messages for packet transmission failures
- Validates port range (1-65535)

## Installation

### Prerequisites
1. **PowerShell 5.1 or later**
2. **Administrator privileges** (for most functions)
3. **Appropriate Windows version** (Windows 10/Server 2016+)

### Module Import
```powershell
# Import individual modules as needed
Import-Module .\WindowsUpdateManagement\WindowsUpdateManagement.psm1
Import-Module .\UserSessionManagement\UserSessionManagement.psm1
Import-Module .\SystemMaintenance\SystemMaintenance.psm1
Import-Module .\SoftwareManagement\SoftwareManagement.psm1
Import-Module .\SystemInformation\SystemInformation.psm1
Import-Module .\ServiceManagement\ServiceManagement.psm1
Import-Module .\EventLogging\EventLogging.psm1
Import-Module .\NetworkDiagnostics\NetworkDiagnostics.psm1
Import-Module .\NetworkManagement\NetworkManagement.psm1
```

### Execution Policy
```powershell
# Set execution policy to allow module imports
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Usage Examples

### System Health Check Script
```powershell
# Comprehensive system health check
Import-Module .\SystemInformation\SystemInformation.psm1
Import-Module .\SystemMaintenance\SystemMaintenance.psm1
Import-Module .\WindowsUpdateManagement\WindowsUpdateManagement.psm1

Write-Host "=== System Health Check ===" -ForegroundColor Green

# Check Windows Defender status
$DefenderStatus = Get-DefenderStatus
Write-Host "Defender Real-time Protection: $($DefenderStatus.RealTimeProtectionEnabled)" -ForegroundColor $(if($DefenderStatus.RealTimeProtectionEnabled) {"Green"} else {"Red"})

# Check recent Windows updates
$RecentUpdates = Get-WindowsUpdateHistory -MaxResults 10
Write-Host "Recent Windows Updates: $($RecentUpdates.Count)" -ForegroundColor Blue

# Check for available software updates
$AvailableUpdates = Get-SoftwareUpdates -Installable
Write-Host "Available Updates: $($AvailableUpdates.Count)" -ForegroundColor $(if($AvailableUpdates.Count -eq 0) {"Green"} else {"Yellow"})
```

### Security Monitoring Script
```powershell
# Security monitoring and alerting
Import-Module .\UserSessionManagement\UserSessionManagement.psm1
Import-Module .\EventLogging\EventLogging.psm1

Write-Host "=== Security Monitoring ===" -ForegroundColor Red

# Check for failed logons in last 24 hours
$FailedLogons = Get-FailedLogons -Hours 24
if ($FailedLogons.Count -gt 0) {
    Write-Warning "Found $($FailedLogons.Count) failed logon attempts in the last 24 hours"
    $FailedLogons | Select-Object TimeCreated, Username, IPAddress | Format-Table
}

# Export security events for analysis
$OutputPath = "C:\SecurityLogs\security_$(Get-Date -Format 'yyyyMMdd').csv"
Export-EventLogs -LogName "Security" -OutputPath $OutputPath -MaxEvents 1000
Write-Host "Security events exported to: $OutputPath" -ForegroundColor Green
```

### Network Diagnostics Script
```powershell
# Network diagnostics and management
Import-Module .\NetworkDiagnostics\NetworkDiagnostics.psm1
Import-Module .\NetworkManagement\NetworkManagement.psm1

Write-Host "=== Network Diagnostics ===" -ForegroundColor Cyan

# Analyze network traffic
Write-Host "Starting network traffic analysis..." -ForegroundColor Yellow
$TrafficAnalysis = Start-NetworkTrafficAnalysis -Duration 120 -Detailed
Write-Host "Analysis complete. Top bandwidth usage:" -ForegroundColor Green
$TrafficAnalysis.TopConnections | Select-Object -First 5 | Format-Table

# Wake up remote computers (example)
$RemoteMACs = @("00:1B:44:11:3A:B7", "00:1B:44:11:3A:B8")
foreach ($MAC in $RemoteMACs) {
    $Result = Send-WakeOnLAN -MACAddress $MAC
    Write-Host "WOL packet sent to $MAC`: $($Result.PacketSent)" -ForegroundColor $(if($Result.PacketSent) {"Green"} else {"Red"})
}
```

## Error Handling

All functions implement comprehensive error handling including:

- **Parameter Validation**: Input parameters are validated for type, range, and format
- **Permission Checks**: Functions verify required permissions before execution
- **Service Availability**: Checks for required Windows services and features
- **Network Connectivity**: Validates network access for remote operations
- **Graceful Degradation**: Provides fallback options when possible
- **Detailed Error Messages**: Clear, actionable error information
- **Logging**: Error events are logged for troubleshooting

### Common Error Scenarios

1. **Access Denied**: Run PowerShell as Administrator
2. **Service Unavailable**: Ensure required Windows services are running
3. **Network Timeout**: Check firewall settings and network connectivity
4. **Invalid Parameters**: Verify parameter format and valid ranges
5. **Insufficient Disk Space**: Ensure adequate space for operations

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Code Standards**: Follow PowerShell best practices and approved verbs
2. **Documentation**: Include comprehensive help documentation
3. **Error Handling**: Implement robust error handling and validation
4. **Testing**: Test thoroughly on supported Windows versions
5. **Examples**: Provide clear usage examples

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**Note**: These functions require appropriate permissions and are designed for Windows environments. Always test in a non-production environment before deploying to production systems.