# UserSessionManagement Module

## Overview
The UserSessionManagement module provides comprehensive functions for managing user sessions, monitoring logon activities, and tracking failed authentication attempts on Windows 10/11 systems. This module is essential for system administrators who need to monitor user access and session management.

## Functions

### Get-FailedLogons
Retrieves failed logon attempts from the Security event log, providing detailed information about authentication failures.

#### Syntax
```powershell
Get-FailedLogons [[-ComputerName] <string>] [[-Username] <string>] [[-Hours] <int>]
```

#### Parameters
- **ComputerName** (Optional): The computer to query. Defaults to local computer.
- **Username** (Optional): Filter failed logons by specific username.
- **Hours** (Optional): Number of hours to look back for failed logon events. Default is 24 hours.

#### Examples
```powershell
# Get all failed logons in the last 24 hours
Get-FailedLogons

# Get failed logons for a specific user in the last 48 hours
Get-FailedLogons -Username "JohnDoe" -Hours 48

# Get failed logons on a remote computer
Get-FailedLogons -ComputerName "Server01"

# Get failed logons and filter by failure reason
Get-FailedLogons | Where-Object { $_.FailureReason -like "*password*" }
```

#### Output
Returns custom objects containing:
- **Username**: The username that failed to log on
- **Domain**: The domain of the user account
- **FailureReason**: Human-readable failure reason (e.g., "Bad password", "Account locked out")
- **FailureTime**: When the failed logon occurred
- **WorkstationName**: The workstation where the logon was attempted
- **IPAddress**: The IP address of the logon attempt

### Additional Functions
This module also includes comprehensive session management functions:

#### Get-UserSessions
Retrieves information about active user sessions.
```powershell
Get-UserSessions [-ComputerName <string>] [-Username <string>] [-Detailed]
```

#### Disconnect-UserSession
Disconnects user sessions by username or session ID.
```powershell
Disconnect-UserSession -ComputerName <string> -Username <string> [-Force]
Disconnect-UserSession -ComputerName <string> -SessionId <int> [-Force]
```

#### Get-LastLogon
Retrieves successful logon history from the Security event log.
```powershell
Get-LastLogon [-ComputerName <string>] [-Username <string>] [-Days <int>]
```

#### Get-LockedAccounts
Retrieves information about locked user accounts.
```powershell
Get-LockedAccounts [-ComputerName <string>] [-Username <string>]
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (required for Security event log access)

### Import Module
```powershell
Import-Module UserSessionManagement
```

## Usage Examples

### Monitor Failed Logons
```powershell
# Get recent failed logons and group by username
$failedLogons = Get-FailedLogons -Hours 12
$failedLogons | Group-Object Username | Sort-Object Count -Descending
```

### Security Monitoring
```powershell
# Monitor for potential brute force attacks
$suspiciousActivity = Get-FailedLogons -Hours 1 | 
    Group-Object Username | 
    Where-Object { $_.Count -gt 5 }

if ($suspiciousActivity) {
    Write-Warning "Potential brute force attack detected!"
    $suspiciousActivity | Format-Table Name, Count
}
```

### Session Management
```powershell
# Get all active sessions with details
Get-UserSessions -Detailed | Format-Table Username, LogonType, StartTime

# Disconnect idle sessions (example)
$idleSessions = Get-UserSessions | Where-Object { 
    $_.StartTime -lt (Get-Date).AddHours(-8) 
}
```

### Account Security
```powershell
# Check for locked accounts
$lockedAccounts = Get-LockedAccounts
if ($lockedAccounts) {
    Write-Host "Locked accounts found:" -ForegroundColor Yellow
    $lockedAccounts | Format-Table Username, Domain, Lockout
}
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges required for Security event log access
- **Services**: Windows Event Log service must be running

## Dependencies
- Windows Security event log
- Windows Management Framework
- CIM/WMI services

## Security Considerations
- Requires administrative privileges to access Security event logs
- Failed logon monitoring can help detect security threats
- Use responsibly and in compliance with organizational security policies
- Consider log retention policies when analyzing historical data

## Failure Reason Codes
The module translates Windows error codes to human-readable messages:
- **0xC0000064**: Unknown username or bad password
- **0xC000006A**: Bad password
- **0xC000006C**: Password expired
- **0xC000006D**: Account disabled
- **0xC000006E**: Account locked out
- **0xC000006F**: Account expired
- **0xC0000070**: Logon type not granted
- **0xC0000071**: Account restricted
- **0xC0000072**: Time restriction

## Error Handling
The module includes comprehensive error handling with warning messages for:
- Event log access issues
- Remote computer connectivity problems
- Insufficient privileges
- Service availability

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are required for full functionality.