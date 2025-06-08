# EventLogging Module

## Overview
The EventLogging module provides comprehensive functions for managing and analyzing Windows Event Logs on Windows 10/11 systems. This module enables administrators to retrieve, filter, export, and analyze various types of system events including security logs, system events, and application logs.

## Functions

### Export-EventLogs
Exports Windows Event Logs to various formats for analysis, reporting, and archival purposes.

#### Syntax
```powershell
Export-EventLogs -LogName <string> -OutputPath <string> [[-StartTime] <datetime>] [[-EndTime] <datetime>] [[-MaxEvents] <int>] [[-Format] <string>]
```

#### Parameters
- **LogName** (Required): The name of the event log to export (e.g., "System", "Application", "Security")
- **OutputPath** (Required): The file path where the exported log will be saved
- **StartTime** (Optional): Start time for filtering events
- **EndTime** (Optional): End time for filtering events
- **MaxEvents** (Optional): Maximum number of events to export. Default is 1000
- **Format** (Optional): Export format - "CSV", "XML", or "JSON". Default is "CSV"

#### Examples
```powershell
# Export System log to CSV
Export-EventLogs -LogName "System" -OutputPath "C:\Logs\SystemEvents.csv"

# Export Security log with date range to JSON
Export-EventLogs -LogName "Security" -OutputPath "C:\Logs\SecurityEvents.json" -Format "JSON" -StartTime (Get-Date).AddDays(-7) -EndTime (Get-Date)

# Export Application log with limited events to XML
Export-EventLogs -LogName "Application" -OutputPath "C:\Logs\AppEvents.xml" -Format "XML" -MaxEvents 500

# Export PowerShell operational log
Export-EventLogs -LogName "Microsoft-Windows-PowerShell/Operational" -OutputPath "C:\Logs\PSEvents.csv" -MaxEvents 100
```

#### Output
The function exports events to the specified file format and displays a success message with the number of events exported.

### Additional Functions

#### Get-SystemEventLogs
Retrieves system event logs with advanced filtering capabilities.
```powershell
Get-SystemEventLogs [[-LogName] <string>] [[-MaxEvents] <int>] [[-StartTime] <datetime>] [[-EndTime] <datetime>] [[-FilterMessage] <string>] [[-EventID] <int[]>]
```

**Examples:**
```powershell
# Get last 100 system events
Get-SystemEventLogs -LogName "System" -MaxEvents 100

# Get error events from the last 24 hours
Get-SystemEventLogs -LogName "System" -StartTime (Get-Date).AddDays(-1) -EventID @(1001, 1002)

# Filter events by message content
Get-SystemEventLogs -LogName "Application" -FilterMessage "error" -MaxEvents 50
```

#### Get-SecurityLogonEvents
Retrieves successful logon events from the Security log.
```powershell
Get-SecurityLogonEvents [[-MaxEvents] <int>] [[-StartTime] <datetime>] [[-EndTime] <datetime>]
```

#### Get-SystemShutdownEvents
Retrieves system shutdown and restart events.
```powershell
Get-SystemShutdownEvents [[-MaxEvents] <int>]
```

#### Get-SystemRebootEvents
Retrieves system reboot events using WMI.
```powershell
Get-SystemRebootEvents [[-MaxEvents] <int>]
```

#### Get-PowerShellOperationalLogs
Retrieves PowerShell operational logs with filtering.
```powershell
Get-PowerShellOperationalLogs [[-MaxEvents] <int>] [[-StartTime] <datetime>] [[-FilterExpression] <string>]
```

#### Get-ChkdskResults
Retrieves disk check (chkdsk) results from event logs.
```powershell
Get-ChkdskResults [[-OutputFile] <string>]
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (required for Security event log access)

### Import Module
```powershell
Import-Module EventLogging
```

## Usage Examples

### Security Monitoring and Analysis
```powershell
# Comprehensive security event analysis
Write-Host "=== Security Event Analysis ===" -ForegroundColor Cyan

# Get recent logon events
$logonEvents = Get-SecurityLogonEvents -MaxEvents 50 -StartTime (Get-Date).AddHours(-24)
Write-Host "`nSuccessful Logons (Last 24 Hours): $($logonEvents.Count)" -ForegroundColor Green

# Group by user and show top users
$topUsers = $logonEvents | Group-Object UserName | Sort-Object Count -Descending | Select-Object -First 5
Write-Host "`nTop Users by Logon Count:" -ForegroundColor Yellow
$topUsers | Format-Table Name, Count -AutoSize

# Export security events for compliance
$startDate = (Get-Date).AddDays(-30)
Export-EventLogs -LogName "Security" -OutputPath "C:\Reports\SecurityAudit_$(Get-Date -Format 'yyyyMMdd').csv" -StartTime $startDate -MaxEvents 5000
```

### System Health Monitoring
```powershell
# Monitor system health through event logs
Write-Host "=== System Health Event Analysis ===" -ForegroundColor Cyan

# Check for system errors
$systemErrors = Get-SystemEventLogs -LogName "System" -MaxEvents 100 | Where-Object { $_.LevelDisplayName -eq "Error" }
if ($systemErrors) {
    Write-Warning "System errors detected in recent events:"
    $systemErrors | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap
}

# Check shutdown events
$shutdownEvents = Get-SystemShutdownEvents -MaxEvents 10
Write-Host "`nRecent Shutdown Events:" -ForegroundColor Green
$shutdownEvents | Format-Table TimeCreated, EventID, Level, Message -AutoSize

# Check reboot events
$rebootEvents = Get-SystemRebootEvents -MaxEvents 5
Write-Host "`nRecent Reboot Events:" -ForegroundColor Green
$rebootEvents | Format-Table ComputerName, EventCode, TimeWritten -AutoSize
```

### PowerShell Activity Monitoring
```powershell
# Monitor PowerShell activity
Write-Host "=== PowerShell Activity Monitoring ===" -ForegroundColor Cyan

# Get recent PowerShell operational events
$psEvents = Get-PowerShellOperationalLogs -MaxEvents 50 -StartTime (Get-Date).AddHours(-12)

if ($psEvents) {
    Write-Host "`nPowerShell Events (Last 12 Hours): $($psEvents.Count)" -ForegroundColor Green
    
    # Look for potentially suspicious activity
    $suspiciousEvents = $psEvents | Where-Object { 
        $_.Message -like "*Invoke-Expression*" -or 
        $_.Message -like "*DownloadString*" -or 
        $_.Message -like "*EncodedCommand*" 
    }
    
    if ($suspiciousEvents) {
        Write-Warning "Potentially suspicious PowerShell activity detected:"
        $suspiciousEvents | Select-Object TimeCreated, UserName, Message | Format-List
    }
    
    # Export PowerShell events
    Export-EventLogs -LogName "Microsoft-Windows-PowerShell/Operational" -OutputPath "C:\Reports\PowerShellActivity_$(Get-Date -Format 'yyyyMMdd').json" -Format "JSON" -MaxEvents 1000
}
```

### Automated Event Log Management
```powershell
# Automated event log export and cleanup
function Start-EventLogMaintenance {
    param(
        [string]$ExportPath = "C:\EventLogBackups",
        [int]$RetentionDays = 30
    )
    
    # Create export directory if it doesn't exist
    if (-not (Test-Path $ExportPath)) {
        New-Item -Path $ExportPath -ItemType Directory -Force
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    
    # Export critical logs
    $logsToExport = @("System", "Application", "Security")
    
    foreach ($logName in $logsToExport) {
        Write-Host "Exporting $logName log..." -ForegroundColor Yellow
        $outputFile = Join-Path $ExportPath "$logName`_$timestamp.csv"
        
        try {
            Export-EventLogs -LogName $logName -OutputPath $outputFile -MaxEvents 10000
            Write-Host "✓ Exported $logName to $outputFile" -ForegroundColor Green
        }
        catch {
            Write-Warning "✗ Failed to export $logName`: $($_.Exception.Message)"
        }
    }
    
    # Clean up old exports
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    $oldFiles = Get-ChildItem -Path $ExportPath -Filter "*.csv" | Where-Object { $_.CreationTime -lt $cutoffDate }
    
    if ($oldFiles) {
        Write-Host "Cleaning up $($oldFiles.Count) old export files..." -ForegroundColor Yellow
        $oldFiles | Remove-Item -Force
    }
}

Start-EventLogMaintenance
```

### Event Log Analysis Dashboard
```powershell
# Create comprehensive event log analysis dashboard
function Show-EventLogDashboard {
    Write-Host "=== Windows Event Log Dashboard ===" -ForegroundColor Cyan
    
    # System event summary
    $systemEvents = Get-SystemEventLogs -LogName "System" -MaxEvents 1000 -StartTime (Get-Date).AddDays(-1)
    $systemSummary = $systemEvents | Group-Object LevelDisplayName
    
    Write-Host "`nSystem Events (Last 24 Hours):" -ForegroundColor Green
    $systemSummary | Format-Table Name, Count -AutoSize
    
    # Application event summary
    $appEvents = Get-SystemEventLogs -LogName "Application" -MaxEvents 1000 -StartTime (Get-Date).AddDays(-1)
    $appSummary = $appEvents | Group-Object LevelDisplayName
    
    Write-Host "`nApplication Events (Last 24 Hours):" -ForegroundColor Green
    $appSummary | Format-Table Name, Count -AutoSize
    
    # Security logon summary
    $logonEvents = Get-SecurityLogonEvents -MaxEvents 100 -StartTime (Get-Date).AddDays(-1)
    $logonSummary = $logonEvents | Group-Object LogonType
    
    Write-Host "`nLogon Events by Type (Last 24 Hours):" -ForegroundColor Green
    $logonSummary | Format-Table Name, Count -AutoSize
    
    # Recent critical events
    $criticalEvents = Get-SystemEventLogs -LogName "System" -MaxEvents 100 | Where-Object { $_.LevelDisplayName -eq "Critical" }
    if ($criticalEvents) {
        Write-Host "`nRecent Critical Events:" -ForegroundColor Red
        $criticalEvents | Select-Object TimeCreated, Id, Message | Format-Table -Wrap
    }
    
    # Disk check results
    $chkdskResults = Get-ChkdskResults
    if ($chkdskResults) {
        Write-Host "`nRecent Disk Check Results:" -ForegroundColor Yellow
        $chkdskResults | Select-Object TimeCreated, Message | Format-List
    }
}

Show-EventLogDashboard
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges required for Security event log access
- **Services**: Windows Event Log service must be running

## Dependencies
- Windows Event Log service
- Get-WinEvent cmdlet
- Windows Management Framework

## Supported Event Logs
- **System**: System events and hardware issues
- **Application**: Application events and errors
- **Security**: Security and audit events (requires admin privileges)
- **Setup**: Windows setup and installation events
- **ForwardedEvents**: Events forwarded from other computers
- **Microsoft-Windows-PowerShell/Operational**: PowerShell execution events
- **Microsoft-Windows-NCSI/Operational**: Network connectivity events
- **Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational**: RDP events

## Export Formats

### CSV Format
- Human-readable tabular format
- Easy to import into Excel or other tools
- Good for basic analysis and reporting

### XML Format
- Preserves complete event structure
- Suitable for programmatic processing
- Maintains all event properties and metadata

### JSON Format
- Modern structured format
- Easy to parse with scripts and applications
- Good for integration with modern tools

## Error Handling
The module includes comprehensive error handling for:
- Event log access permission issues
- Invalid log names or paths
- File system access problems
- Event log service availability

## Security Considerations
- Administrative privileges required for Security event log access
- Exported logs may contain sensitive information
- Implement proper access controls for exported files
- Consider encryption for sensitive log exports
- Follow organizational data retention policies

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are required for accessing Security event logs and some system functions.