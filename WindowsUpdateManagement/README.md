# WindowsUpdateManagement Module

## Overview
The WindowsUpdateManagement module provides comprehensive functions for managing Windows Updates on Windows 10/11 systems. This module enables administrators to retrieve update history, check update status, and monitor Windows Update services.

## Functions

### Get-WindowsUpdateHistory
Retrieves the Windows Update installation history from the system.

#### Syntax
```powershell
Get-WindowsUpdateHistory [[-MaxResults] <int>]
```

#### Parameters
- **MaxResults** (Optional): Maximum number of update records to return. Default is 100.

#### Examples
```powershell
# Get the last 100 installed updates
Get-WindowsUpdateHistory

# Get the last 50 installed updates
Get-WindowsUpdateHistory -MaxResults 50

# Get all updates and sort by installation date
Get-WindowsUpdateHistory -MaxResults 1000 | Sort-Object InstalledOn -Descending
```

#### Output
Returns hotfix objects containing update information including:
- HotFixID
- Description
- InstalledBy
- InstalledOn

### Additional Functions
This module also includes the following helper functions:
- **Get-WindowsUpdateServiceInfo**: Retrieves Windows Update service information
- **Get-WindowsUpdateStatus**: Checks for pending reboot status
- **Get-WindowsUpdateLogs**: Retrieves Windows Update logs

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (recommended)

### Import Module
```powershell
Import-Module WindowsUpdateManagement
```

## Usage Examples

### Basic Update History
```powershell
# Get recent update history
$updates = Get-WindowsUpdateHistory -MaxResults 20
$updates | Format-Table HotFixID, Description, InstalledOn -AutoSize
```

### Filter Updates by Date
```powershell
# Get updates installed in the last 30 days
$recentUpdates = Get-WindowsUpdateHistory | Where-Object { 
    $_.InstalledOn -gt (Get-Date).AddDays(-30) 
}
```

### Export Update History
```powershell
# Export update history to CSV
Get-WindowsUpdateHistory | Export-Csv -Path "C:\Reports\UpdateHistory.csv" -NoTypeInformation
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Standard user (Administrative privileges recommended for full functionality)

## Dependencies
- Windows Management Framework
- Windows Update service

## Notes
- The module uses the `Get-Hotfix` cmdlet to retrieve update information
- Some update details may not be available for all installed updates
- Administrative privileges may be required for accessing certain update information

## Error Handling
The module includes comprehensive error handling with warning messages for common issues:
- Service access problems
- Registry access issues
- Event log access restrictions

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later.