# NetworkDiagnostics Module

## Overview
The NetworkDiagnostics module provides comprehensive functions for network diagnostics and troubleshooting on Windows 10/11 systems. This module enables administrators to perform network connectivity tests, analyze traffic patterns, and diagnose common network issues with detailed reporting capabilities.

## Functions

### Start-NetworkTrafficAnalysis
Captures and analyzes network traffic patterns including protocol distribution, bandwidth usage, and connection statistics.

#### Syntax
```powershell
Start-NetworkTrafficAnalysis [[-ComputerName] <string>] [[-Interface] <string>] [[-Duration] <int>] [-Detailed]
```

#### Parameters
- **ComputerName** (Optional): The computer to analyze. Defaults to local computer.
- **Interface** (Optional): Specific network interface to monitor. If not specified, monitors all active interfaces.
- **Duration** (Optional): Duration of capture in seconds. Default is 60 seconds.
- **Detailed** (Optional): Returns detailed traffic analysis with interface-specific statistics.

#### Examples
```powershell
# Analyze network traffic on all interfaces for 60 seconds
Start-NetworkTrafficAnalysis

# Analyze traffic on Ethernet interface for 5 minutes
Start-NetworkTrafficAnalysis -Interface "Ethernet" -Duration 300

# Perform detailed traffic analysis on a remote computer
Start-NetworkTrafficAnalysis -ComputerName "Server01" -Detailed

# Quick 30-second traffic analysis
Start-NetworkTrafficAnalysis -Duration 30 -Detailed
```

#### Output
Returns custom objects containing:
- **Status**: Analysis completion status
- **Interfaces**: List of monitored network interfaces
- **Duration**: Analysis duration in seconds
- **ComputerName**: Target computer name
- **StartTime/EndTime**: Analysis time window (in detailed mode)
- **Statistics**: Detailed traffic statistics per interface (in detailed mode)

### Additional Functions

#### Start-NetworkDiagnostics
Performs comprehensive network diagnostic tests including connectivity, DNS, routing, and latency.
```powershell
Start-NetworkDiagnostics [[-ComputerName] <string>] [[-Target] <string>] [[-Tests] <string[]>] [-Detailed]
```

**Test Categories:**
- `Connectivity`: Basic network connectivity tests
- `DNS`: DNS resolution tests
- `Routing`: Network routing analysis
- `Latency`: Network latency measurements

**Examples:**
```powershell
# Perform full network diagnostics
Start-NetworkDiagnostics

# Test specific components to Google DNS
Start-NetworkDiagnostics -Target "8.8.8.8" -Tests "Latency","DNS"

# Detailed diagnostics on remote computer
Start-NetworkDiagnostics -ComputerName "Server01" -Detailed
```

#### Start-NetworkTroubleshooting
Diagnoses common network connectivity issues including DNS problems, routing issues, and firewall restrictions.
```powershell
Start-NetworkTroubleshooting [[-ComputerName] <string>] [[-Target] <string>] [[-Issues] <string[]>] [-Detailed]
```

**Issue Categories:**
- `DNS`: DNS resolution problems
- `Routing`: Network routing issues
- `Firewall`: Firewall configuration problems

**Examples:**
```powershell
# Perform full network troubleshooting
Start-NetworkTroubleshooting

# Diagnose specific issues for a target
Start-NetworkTroubleshooting -Target "server01" -Issues "DNS","Firewall"

# Detailed troubleshooting on remote computer
Start-NetworkTroubleshooting -ComputerName "Server01" -Detailed
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (required for some network operations)
- Common module dependency

### Import Module
```powershell
Import-Module NetworkDiagnostics
```

## Usage Examples

### Comprehensive Network Health Check
```powershell
# Perform complete network health assessment
Write-Host "=== Network Health Assessment ===" -ForegroundColor Cyan

# Basic connectivity diagnostics
Write-Host "`nRunning connectivity diagnostics..." -ForegroundColor Yellow
$connectivityResults = Start-NetworkDiagnostics -Tests "Connectivity","DNS","Latency" -Detailed

# Traffic analysis
Write-Host "`nAnalyzing network traffic (60 seconds)..." -ForegroundColor Yellow
$trafficResults = Start-NetworkTrafficAnalysis -Duration 60 -Detailed

# Troubleshooting common issues
Write-Host "`nTroubleshooting potential issues..." -ForegroundColor Yellow
$troubleshootResults = Start-NetworkTroubleshooting -Detailed

# Generate summary report
Write-Host "`n=== Network Health Summary ===" -ForegroundColor Green
Write-Host "Diagnostics completed: $($connectivityResults.Status)" -ForegroundColor White
Write-Host "Traffic analysis completed: $($trafficResults.Status)" -ForegroundColor White
Write-Host "Troubleshooting completed: $($troubleshootResults.Status)" -ForegroundColor White
```

### Network Performance Monitoring
```powershell
# Monitor network performance over time
function Start-NetworkPerformanceMonitoring {
    param(
        [int]$Intervals = 12,
        [int]$IntervalDuration = 300  # 5 minutes
    )
    
    Write-Host "Starting network performance monitoring..." -ForegroundColor Cyan
    Write-Host "Monitoring for $($Intervals * $IntervalDuration / 60) minutes with $($IntervalDuration/60)-minute intervals" -ForegroundColor Yellow
    
    $performanceData = @()
    
    for ($i = 1; $i -le $Intervals; $i++) {
        Write-Host "`nInterval $i of $Intervals - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
        
        # Perform latency test
        $latencyTest = Start-NetworkDiagnostics -Tests "Latency" -Target "8.8.8.8" -Detailed
        
        # Analyze traffic
        $trafficAnalysis = Start-NetworkTrafficAnalysis -Duration $IntervalDuration -Detailed
        
        # Store results
        $performanceData += [PSCustomObject]@{
            Timestamp = Get-Date
            Interval = $i
            LatencyResults = $latencyTest
            TrafficResults = $trafficAnalysis
        }
        
        Write-Host "Interval $i completed" -ForegroundColor Green
    }
    
    # Export results
    $performanceData | ConvertTo-Json -Depth 5 | Out-File "C:\Reports\NetworkPerformance_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Write-Host "`nPerformance monitoring completed. Results saved to C:\Reports\" -ForegroundColor Cyan
    
    return $performanceData
}

# Start monitoring
Start-NetworkPerformanceMonitoring -Intervals 6 -IntervalDuration 600  # 1 hour total, 10-minute intervals
```

### Network Troubleshooting Workflow
```powershell
# Automated network troubleshooting workflow
function Start-NetworkTroubleshootingWorkflow {
    param([string]$TargetHost = "8.8.8.8")
    
    Write-Host "=== Network Troubleshooting Workflow ===" -ForegroundColor Cyan
    Write-Host "Target: $TargetHost" -ForegroundColor White
    
    # Step 1: Basic connectivity test
    Write-Host "`nStep 1: Testing basic connectivity..." -ForegroundColor Yellow
    $connectivityTest = Start-NetworkDiagnostics -Target $TargetHost -Tests "Connectivity" -Detailed
    
    if ($connectivityTest.Status -eq "Completed") {
        Write-Host "✓ Basic connectivity test completed" -ForegroundColor Green
    } else {
        Write-Warning "✗ Basic connectivity test failed"
        return
    }
    
    # Step 2: DNS resolution test
    Write-Host "`nStep 2: Testing DNS resolution..." -ForegroundColor Yellow
    $dnsTest = Start-NetworkDiagnostics -Target $TargetHost -Tests "DNS" -Detailed
    
    if ($dnsTest.Status -eq "Completed") {
        Write-Host "✓ DNS resolution test completed" -ForegroundColor Green
    } else {
        Write-Warning "✗ DNS resolution issues detected"
        
        # Perform DNS troubleshooting
        Write-Host "Running DNS troubleshooting..." -ForegroundColor Yellow
        $dnsTroubleshooting = Start-NetworkTroubleshooting -Target $TargetHost -Issues "DNS" -Detailed
    }
    
    # Step 3: Routing analysis
    Write-Host "`nStep 3: Analyzing network routing..." -ForegroundColor Yellow
    $routingTest = Start-NetworkDiagnostics -Target $TargetHost -Tests "Routing" -Detailed
    
    # Step 4: Latency analysis
    Write-Host "`nStep 4: Measuring network latency..." -ForegroundColor Yellow
    $latencyTest = Start-NetworkDiagnostics -Target $TargetHost -Tests "Latency" -Detailed
    
    # Step 5: Traffic analysis
    Write-Host "`nStep 5: Analyzing network traffic..." -ForegroundColor Yellow
    $trafficAnalysis = Start-NetworkTrafficAnalysis -Duration 120 -Detailed
    
    # Step 6: Comprehensive troubleshooting
    Write-Host "`nStep 6: Running comprehensive troubleshooting..." -ForegroundColor Yellow
    $comprehensiveTroubleshooting = Start-NetworkTroubleshooting -Target $TargetHost -Detailed
    
    # Generate report
    $report = @{
        Target = $TargetHost
        Timestamp = Get-Date
        ConnectivityTest = $connectivityTest
        DNSTest = $dnsTest
        RoutingTest = $routingTest
        LatencyTest = $latencyTest
        TrafficAnalysis = $trafficAnalysis
        Troubleshooting = $comprehensiveTroubleshooting
    }
    
    # Export detailed report
    $report | ConvertTo-Json -Depth 5 | Out-File "C:\Reports\NetworkTroubleshooting_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    
    Write-Host "`n=== Troubleshooting Workflow Completed ===" -ForegroundColor Green
    Write-Host "Detailed report saved to C:\Reports\" -ForegroundColor Cyan
    
    return $report
}

# Run troubleshooting workflow
Start-NetworkTroubleshootingWorkflow -TargetHost "google.com"
```

### Network Interface Analysis
```powershell
# Analyze all network interfaces
function Get-NetworkInterfaceAnalysis {
    Write-Host "=== Network Interface Analysis ===" -ForegroundColor Cyan
    
    # Get all network adapters
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    Write-Host "`nActive Network Interfaces:" -ForegroundColor Green
    $adapters | Format-Table Name, InterfaceDescription, LinkSpeed, Status -AutoSize
    
    # Analyze traffic on each interface
    foreach ($adapter in $adapters) {
        Write-Host "`nAnalyzing interface: $($adapter.Name)" -ForegroundColor Yellow
        
        try {
            $trafficAnalysis = Start-NetworkTrafficAnalysis -Interface $adapter.Name -Duration 30 -Detailed
            Write-Host "✓ Traffic analysis completed for $($adapter.Name)" -ForegroundColor Green
        }
        catch {
            Write-Warning "✗ Failed to analyze $($adapter.Name): $($_.Exception.Message)"
        }
    }
    
    # Perform diagnostics on primary interface
    $primaryInterface = $adapters | Where-Object { $_.Name -like "*Ethernet*" -or $_.Name -like "*Wi-Fi*" } | Select-Object -First 1
    
    if ($primaryInterface) {
        Write-Host "`nRunning diagnostics on primary interface: $($primaryInterface.Name)" -ForegroundColor Yellow
        $diagnostics = Start-NetworkDiagnostics -Detailed
        Write-Host "✓ Diagnostics completed for primary interface" -ForegroundColor Green
    }
}

Get-NetworkInterfaceAnalysis
```

### Automated Network Monitoring Script
```powershell
# Continuous network monitoring with alerting
function Start-ContinuousNetworkMonitoring {
    param(
        [int]$MonitoringDurationMinutes = 60,
        [int]$CheckIntervalSeconds = 300,
        [string]$AlertThresholdLatency = 100
    )
    
    Write-Host "Starting continuous network monitoring..." -ForegroundColor Cyan
    Write-Host "Duration: $MonitoringDurationMinutes minutes" -ForegroundColor White
    Write-Host "Check interval: $CheckIntervalSeconds seconds" -ForegroundColor White
    Write-Host "Latency alert threshold: $AlertThresholdLatency ms" -ForegroundColor White
    
    $endTime = (Get-Date).AddMinutes($MonitoringDurationMinutes)
    $checkCount = 0
    $alerts = @()
    
    while ((Get-Date) -lt $endTime) {
        $checkCount++
        $currentTime = Get-Date
        
        Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Check #$checkCount" -ForegroundColor Green
        
        # Perform latency test
        $latencyTest = Start-NetworkDiagnostics -Tests "Latency" -Target "8.8.8.8" -Detailed
        
        # Check for alerts (this would need to be implemented based on actual return structure)
        # if ($latencyTest.Results.Latency.Average -gt $AlertThresholdLatency) {
        #     $alert = "High latency detected: $($latencyTest.Results.Latency.Average)ms at $currentTime"
        #     $alerts += $alert
        #     Write-Warning $alert
        # }
        
        # Brief traffic analysis
        $trafficTest = Start-NetworkTrafficAnalysis -Duration 60
        
        Write-Host "✓ Check #$checkCount completed" -ForegroundColor Green
        
        # Wait for next check
        if ((Get-Date) -lt $endTime) {
            Start-Sleep -Seconds $CheckIntervalSeconds
        }
    }
    
    Write-Host "`n=== Monitoring Summary ===" -ForegroundColor Cyan
    Write-Host "Total checks performed: $checkCount" -ForegroundColor White
    Write-Host "Alerts generated: $($alerts.Count)" -ForegroundColor White
    
    if ($alerts.Count -gt 0) {
        Write-Host "`nAlerts:" -ForegroundColor Red
        $alerts | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    }
}

# Start monitoring
Start-ContinuousNetworkMonitoring -MonitoringDurationMinutes 30 -CheckIntervalSeconds 180
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges required for some network operations
- **Dependencies**: Common module
- **Services**: Network-related Windows services must be running

## Dependencies
- Common module
- Windows Network subsystem
- Network adapter drivers
- DNS Client service
- Windows Firewall service (for troubleshooting)

## Diagnostic Test Categories

### Connectivity Tests
- Basic ping connectivity
- Packet loss measurement
- Response time analysis
- Network reachability verification

### DNS Tests
- DNS resolution verification
- DNS server response testing
- DNS cache analysis
- Alternative DNS server testing

### Routing Tests
- Network route verification
- Gateway connectivity
- Route table analysis
- Path determination

### Latency Tests
- Round-trip time measurement
- Packet loss calculation
- Jitter analysis
- Performance baseline establishment

## Traffic Analysis Capabilities
- Bytes sent/received monitoring
- Packet count tracking
- Interface-specific statistics
- Bandwidth utilization measurement
- Protocol distribution analysis

## Troubleshooting Categories

### DNS Issues
- Local DNS server testing
- Public DNS server comparison
- DNS cache examination
- Resolution failure analysis

### Routing Issues
- Traceroute analysis
- Route table verification
- Default gateway validation
- Path optimization

### Firewall Issues
- Firewall rule analysis
- Blocked connection detection
- Profile status verification
- Application filter review

## Error Handling
The module includes comprehensive error handling for:
- Network adapter access issues
- Insufficient privileges
- Service availability problems
- Target unreachability
- Timeout scenarios

## Performance Considerations
- Traffic analysis may impact network performance during capture
- Long-duration monitoring requires adequate system resources
- Multiple simultaneous tests may affect results
- Consider network load when scheduling diagnostics

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are required for comprehensive network diagnostics and troubleshooting operations.