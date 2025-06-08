# PowerShell System Administration Functions

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2B%20%7C%20Server%202016%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A comprehensive collection of PowerShell modules designed for Windows system administration, monitoring, and management tasks. This collection provides IT professionals with powerful tools for managing Windows systems, network operations, security monitoring, and system maintenance.

## Table of Contents

- [Module Overview](#module-overview)
- [Function Quick Reference](#function-quick-reference)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Error Handling](#error-handling)
- [Contributing](#contributing)
- [License](#license)

## Module Overview

| Module | Description | Functions | Links |
|--------|-------------|-----------|-------|
| [ActiveDirectoryManagement](ActiveDirectoryManagement/README.md) | Active Directory user and group management operations | 8+ | [.psm1](ActiveDirectoryManagement/ActiveDirectoryManagement.psm1) |
| [Common](Common/README.md) | Shared utility functions and common operations used across modules | 12+ | [.psm1](Common/Common.psm1) |
| [EventLogging](EventLogging/README.md) | Windows event log export, analysis, and monitoring capabilities | 6+ | [.psm1](EventLogging/EventLogging.psm1) |
| [NetworkDiagnostics](NetworkDiagnostics/README.md) | Network traffic analysis, connectivity testing, and diagnostics | 8+ | [.psm1](NetworkDiagnostics/NetworkDiagnostics.psm1) |
| [NetworkManagement](NetworkManagement/README.md) | Network configuration and Wake-on-LAN functionality | 5+ | [.psm1](NetworkManagement/NetworkManagement.psm1) |
| [ServiceManagement](ServiceManagement/README.md) | Windows service monitoring, control, and status reporting | 7+ | [.psm1](ServiceManagement/ServiceManagement.psm1) |
| [SoftwareManagement](SoftwareManagement/README.md) | Software update detection and management operations | 6+ | [.psm1](SoftwareManagement/SoftwareManagement.psm1) |
| [SystemInformation](SystemInformation/README.md) | System status, hardware details, and Windows Defender monitoring | 10+ | [.psm1](SystemInformation/SystemInformation.psm1) |
| [SystemMaintenance](SystemMaintenance/README.md) | System optimization, cleanup, and maintenance operations | 9+ | [.psm1](SystemMaintenance/SystemMaintenance.psm1) |
| [SystemMonitoring](SystemMonitoring/README.md) | Performance monitoring and system health tracking | 8+ | [.psm1](SystemMonitoring/SystemMonitoring.psm1) |
| [UserSessionManagement](UserSessionManagement/README.md) | User session monitoring and failed logon detection | 6+ | [.psm1](UserSessionManagement/UserSessionManagement.psm1) |
| [WindowsUpdateManagement](WindowsUpdateManagement/README.md) | Windows Update history and status monitoring | 4+ | [.psm1](WindowsUpdateManagement/WindowsUpdateManagement.psm1) |

## Function Quick Reference

| Function | Purpose | Module | Syntax |
|----------|---------|--------|--------|
| `Get-WindowsUpdateHistory` | Retrieve Windows update installation history | [WindowsUpdateManagement](WindowsUpdateManagement/README.md) | `Get-WindowsUpdateHistory [-MaxResults <Int32>]` |
| `Get-FailedLogons` | Monitor failed logon attempts for security analysis | [UserSessionManagement](UserSessionManagement/README.md) | `Get-FailedLogons [-ComputerName <String>] [-Username <String>] [-Hours <Int32>]` |
| `Start-SystemOptimization` | Perform comprehensive system cleanup and optimization | [SystemMaintenance](SystemMaintenance/README.md) | `Start-SystemOptimization [-Categories <String[]>] [-Force] [-Detailed]` |
| `Get-SoftwareUpdates` | Check for available software updates | [SoftwareManagement](SoftwareManagement/README.md) | `Get-SoftwareUpdates [-Installable] [-Installed]` |
| `Get-DefenderStatus` | Check Windows Defender protection status | [SystemInformation](SystemInformation/README.md) | `Get-DefenderStatus` |
| `Get-ServiceList` | List Windows services with status and configuration | [ServiceManagement](ServiceManagement/README.md) | `Get-ServiceList [-Filter <String>]` |
| `Export-EventLogs` | Export Windows event logs to various formats | [EventLogging](EventLogging/README.md) | `Export-EventLogs -LogName <String> -OutputPath <String> [options]` |
| `Start-NetworkTrafficAnalysis` | Analyze network traffic patterns and bandwidth usage | [NetworkDiagnostics](NetworkDiagnostics/README.md) | `Start-NetworkTrafficAnalysis [-ComputerName <String>] [-Interface <String>] [-Duration <Int32>] [-Detailed]` |
| `Send-WakeOnLAN` | Send Wake-on-LAN packets to remote computers | [NetworkManagement](NetworkManagement/README.md) | `Send-WakeOnLAN -MACAddress <String> [-Port <Int32>]` |

## System Requirements

| Component | Requirement |
|-----------|-------------|
| **PowerShell Version** | 5.1 or later |
| **Operating System** | Windows 10 (1809+) / Windows Server 2016+ |
| **Execution Policy** | RemoteSigned or Unrestricted |
| **Administrator Rights** | Required for most operations |
| **Network Access** | Required for network-related functions |

## Installation

### Prerequisites
1. **PowerShell 5.1 or later**
2. **Administrator privileges** (for most functions)
3. **Appropriate Windows version** (Windows 10/Server 2016+)

### Module Import
```powershell
# Import individual modules as needed
Import-Module .\WindowsUpdateManagement\WindowsUpdateManagement.psm1
Import-Module .\SystemInformation\SystemInformation.psm1
Import-Module .\NetworkDiagnostics\NetworkDiagnostics.psm1

# Or import all modules
Get-ChildItem -Path . -Filter "*.psm1" -Recurse | ForEach-Object { Import-Module $_.FullName }
```

### Execution Policy
```powershell
# Set execution policy to allow module imports
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Quick Start

### Basic System Health Check
```powershell
# Import required modules
Import-Module .\SystemInformation\SystemInformation.psm1
Import-Module .\WindowsUpdateManagement\WindowsUpdateManagement.psm1

# Check Windows Defender status
$DefenderStatus = Get-DefenderStatus
Write-Host "Defender Protection: $($DefenderStatus.RealTimeProtectionEnabled)"

# Check recent Windows updates
$RecentUpdates = Get-WindowsUpdateHistory -MaxResults 10
Write-Host "Recent Updates: $($RecentUpdates.Count)"

# Check for available software updates
$AvailableUpdates = Get-SoftwareUpdates -Installable
Write-Host "Available Updates: $($AvailableUpdates.Count)"
```

For comprehensive examples and detailed usage instructions, see the individual module READMEs linked in the [Module Overview](#module-overview) section.

## Error Handling

All functions implement comprehensive error handling including:

- **Parameter Validation**: Input parameters are validated for type, range, and format
- **Permission Checks**: Functions verify required permissions before execution
- **Service Availability**: Checks for required Windows services and features
- **Network Connectivity**: Validates network access for remote operations
- **Graceful Degradation**: Provides fallback options when possible
- **Detailed Error Messages**: Clear, actionable error information

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

For detailed documentation, comprehensive examples, and advanced usage scenarios, please refer to the individual module README files linked in the Module Overview section above.