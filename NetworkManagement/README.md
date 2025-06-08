# NetworkManagement Module

## Overview
The NetworkManagement module provides comprehensive functions for managing network operations and monitoring on Windows 10/11 systems. This module enables administrators to test network connectivity, manage network connections, resolve network addresses, diagnose network issues, and perform Wake-on-LAN operations.

## Functions

### Send-WakeOnLAN
Sends a Wake-on-LAN magic packet to wake up a computer that is in sleep or hibernate state.

#### Syntax
```powershell
Send-WakeOnLAN -MACAddress <string> [[-Port] <int>]
```

#### Parameters
- **MACAddress** (Required): The MAC address of the target computer. Can be in any common MAC address format (e.g., "00:11:22:33:44:55", "00-11-22-33-44-55", "001122334455").
- **Port** (Optional): The UDP port to send the packet to. Default is 9.

#### Examples
```powershell
# Send Wake-on-LAN packet using standard format
Send-WakeOnLAN -MACAddress "00:11:22:33:44:55"

# Send Wake-on-LAN packet using dash format
Send-WakeOnLAN -MACAddress "00-11-22-33-44-55"

# Send Wake-on-LAN packet using compact format with custom port
Send-WakeOnLAN -MACAddress "001122334455" -Port 7

# Wake multiple computers
$computers = @(
    "00:11:22:33:44:55",
    "AA:BB:CC:DD:EE:FF",
    "12:34:56:78:90:AB"
)
$computers | ForEach-Object { Send-WakeOnLAN -MACAddress $_ }
```

#### Output
Displays a success message indicating the Wake-on-LAN packet was sent to the specified MAC address.

### Additional Functions

#### Test-NetworkPort
Tests TCP connectivity to specific ports on target computers.
```powershell
Test-NetworkPort -ComputerName <string> -Port <int[]> [[-Timeout] <int>]
```

**Examples:**
```powershell
# Test single port
Test-NetworkPort -ComputerName "server01" -Port 80

# Test multiple ports
Test-NetworkPort -ComputerName "192.168.1.1" -Port @(80, 443, 3389) -Timeout 2000

# Test RDP connectivity
Test-NetworkPort -ComputerName "server01" -Port 3389
```

#### Get-NetworkConnections
Retrieves active network connections with filtering options.
```powershell
Get-NetworkConnections [-ShowEstablished] [-ShowListening]
```

**Examples:**
```powershell
# Get all network connections
Get-NetworkConnections

# Get only established connections
Get-NetworkConnections -ShowEstablished

# Get only listening connections
Get-NetworkConnections -ShowListening
```

#### Resolve-NetworkAddress
Performs DNS resolution between hostnames and IP addresses.
```powershell
Resolve-NetworkAddress -IPAddress <string>
Resolve-NetworkAddress -Hostname <string>
```

**Examples:**
```powershell
# Resolve hostname to IP
Resolve-NetworkAddress -Hostname "server01"

# Reverse DNS lookup
Resolve-NetworkAddress -IPAddress "192.168.1.1"

# Resolve external hostname
Resolve-NetworkAddress -Hostname "google.com"
```

#### Get-NetworkIssues
Retrieves network-related issues from event logs.
```powershell
Get-NetworkIssues [[-MaxEvents] <int>]
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Network connectivity for remote operations
- Target computers must have Wake-on-LAN enabled (for WoL functionality)

### Import Module
```powershell
Import-Module NetworkManagement
```

## Usage Examples

### Wake-on-LAN Management
```powershell
# Wake-on-LAN computer inventory management
$computerInventory = @(
    @{ Name = "Workstation01"; MAC = "00:11:22:33:44:55"; IP = "192.168.1.100" },
    @{ Name = "Workstation02"; MAC = "AA:BB:CC:DD:EE:FF"; IP = "192.168.1.101" },
    @{ Name = "Server01"; MAC = "12:34:56:78:90:AB"; IP = "192.168.1.10" }
)

# Function to wake computers by name
function Wake-ComputerByName {
    param([string]$ComputerName)
    
    $computer = $computerInventory | Where-Object { $_.Name -eq $ComputerName }
    if ($computer) {
        Write-Host "Waking up $($computer.Name) ($($computer.MAC))..." -ForegroundColor Yellow
        Send-WakeOnLAN -MACAddress $computer.MAC
        
        # Wait and test connectivity
        Start-Sleep -Seconds 30
        $connectivity = Test-NetworkPort -ComputerName $computer.IP -Port 135 -Timeout 5000
        
        if ($connectivity.Status -eq "Open") {
            Write-Host "✓ $($computer.Name) is now online" -ForegroundColor Green
        } else {
            Write-Warning "✗ $($computer.Name) may still be starting up"
        }
    } else {
        Write-Warning "Computer '$ComputerName' not found in inventory"
    }
}

# Wake specific computers
Wake-ComputerByName -ComputerName "Workstation01"
Wake-ComputerByName -ComputerName "Server01"

# Wake all workstations
$computerInventory | Where-Object { $_.Name -like "Workstation*" } | ForEach-Object {
    Send-WakeOnLAN -MACAddress $_.MAC
    Write-Host "Wake-on-LAN sent to $($_.Name)" -ForegroundColor Green
}
```

### Network Connectivity Testing
```powershell
# Comprehensive network connectivity testing
function Test-NetworkConnectivity {
    param(
        [string[]]$Computers = @("server01", "workstation01", "192.168.1.1"),
        [int[]]$CommonPorts = @(80, 443, 135, 139, 445, 3389)
    )
    
    Write-Host "=== Network Connectivity Testing ===" -ForegroundColor Cyan
    
    foreach ($computer in $Computers) {
        Write-Host "`nTesting connectivity to: $computer" -ForegroundColor Yellow
        
        # Test common ports
        $portResults = Test-NetworkPort -ComputerName $computer -Port $CommonPorts
        
        # Display results
        $openPorts = $portResults | Where-Object { $_.Status -eq "Open" }
        $closedPorts = $portResults | Where-Object { $_.Status -eq "Closed" }
        
        Write-Host "  Open ports: $($openPorts.Port -join ', ')" -ForegroundColor Green
        if ($closedPorts) {
            Write-Host "  Closed ports: $($closedPorts.Port -join ', ')" -ForegroundColor Red
        }
        
        # Test specific services
        $serviceTests = @(
            @{ Port = 80; Service = "HTTP" },
            @{ Port = 443; Service = "HTTPS" },
            @{ Port = 3389; Service = "RDP" },
            @{ Port = 135; Service = "RPC" }
        )
        
        foreach ($test in $serviceTests) {
            $result = Test-NetworkPort -ComputerName $computer -Port $test.Port
            $status = if ($result.Status -eq "Open") { "✓" } else { "✗" }
            $color = if ($result.Status -eq "Open") { "Green" } else { "Red" }
            Write-Host "  $status $($test.Service) ($($test.Port))" -ForegroundColor $color
        }
    }
}

Test-NetworkConnectivity
```

### Network Address Resolution
```powershell
# Network address resolution and inventory
function Get-NetworkInventory {
    param([string[]]$Targets)
    
    Write-Host "=== Network Address Resolution ===" -ForegroundColor Cyan
    
    $inventory = @()
    
    foreach ($target in $Targets) {
        Write-Host "`nResolving: $target" -ForegroundColor Yellow
        
        try {
            # Determine if target is IP or hostname
            if ($target -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
                # Target is IP address - perform reverse lookup
                $resolution = Resolve-NetworkAddress -IPAddress $target
                $inventory += [PSCustomObject]@{
                    Target = $target
                    Type = "IP Address"
                    Hostname = $resolution.Hostname
                    IPAddresses = $target
                    Aliases = $resolution.Aliases -join ", "
                }
                Write-Host "  IP: $target → Hostname: $($resolution.Hostname)" -ForegroundColor Green
            } else {
                # Target is hostname - perform forward lookup
                $resolution = Resolve-NetworkAddress -Hostname $target
                $inventory += [PSCustomObject]@{
                    Target = $target
                    Type = "Hostname"
                    Hostname = $target
                    IPAddresses = $resolution.IPAddresses -join ", "
                    Aliases = ""
                }
                Write-Host "  Hostname: $target → IP: $($resolution.IPAddresses -join ', ')" -ForegroundColor Green
            }
        }
        catch {
            Write-Warning "  Failed to resolve $target`: $($_.Exception.Message)"
            $inventory += [PSCustomObject]@{
                Target = $target
                Type = "Unknown"
                Hostname = "Resolution Failed"
                IPAddresses = "N/A"
                Aliases = ""
            }
        }
    }
    
    # Display inventory table
    Write-Host "`n=== Resolution Summary ===" -ForegroundColor Cyan
    $inventory | Format-Table Target, Type, Hostname, IPAddresses -AutoSize
    
    return $inventory
}

# Example usage
$targets = @("server01", "192.168.1.1", "google.com", "workstation01", "8.8.8.8")
$networkInventory = Get-NetworkInventory -Targets $targets
```

### Network Connection Monitoring
```powershell
# Monitor network connections
function Monitor-NetworkConnections {
    param(
        [int]$MonitoringDurationMinutes = 10,
        [int]$SampleIntervalSeconds = 30
    )
    
    Write-Host "=== Network Connection Monitoring ===" -ForegroundColor Cyan
    Write-Host "Duration: $MonitoringDurationMinutes minutes" -ForegroundColor White
    Write-Host "Sample interval: $SampleIntervalSeconds seconds" -ForegroundColor White
    
    $endTime = (Get-Date).AddMinutes($MonitoringDurationMinutes)
    $sampleCount = 0
    $connectionHistory = @()
    
    while ((Get-Date) -lt $endTime) {
        $sampleCount++
        $currentTime = Get-Date
        
        Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] Sample #$sampleCount" -ForegroundColor Green
        
        # Get current connections
        $establishedConnections = Get-NetworkConnections -ShowEstablished
        $listeningConnections = Get-NetworkConnections -ShowListening
        
        # Parse and count connections (simplified - actual parsing would depend on netstat output format)
        $establishedCount = if ($establishedConnections) { $establishedConnections.Count } else { 0 }
        $listeningCount = if ($listeningConnections) { $listeningConnections.Count } else { 0 }
        
        Write-Host "  Established connections: $establishedCount" -ForegroundColor White
        Write-Host "  Listening connections: $listeningCount" -ForegroundColor White
        
        # Store sample data
        $connectionHistory += [PSCustomObject]@{
            Timestamp = $currentTime
            Sample = $sampleCount
            EstablishedConnections = $establishedCount
            ListeningConnections = $listeningCount
        }
        
        # Wait for next sample
        if ((Get-Date) -lt $endTime) {
            Start-Sleep -Seconds $SampleIntervalSeconds
        }
    }
    
    # Generate summary
    Write-Host "`n=== Monitoring Summary ===" -ForegroundColor Cyan
    Write-Host "Total samples: $sampleCount" -ForegroundColor White
    
    if ($connectionHistory.Count -gt 0) {
        $avgEstablished = ($connectionHistory | Measure-Object EstablishedConnections -Average).Average
        $avgListening = ($connectionHistory | Measure-Object ListeningConnections -Average).Average
        
        Write-Host "Average established connections: $([math]::Round($avgEstablished, 1))" -ForegroundColor White
        Write-Host "Average listening connections: $([math]::Round($avgListening, 1))" -ForegroundColor White
        
        # Export detailed data
        $connectionHistory | Export-Csv -Path "C:\Reports\NetworkConnections_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
        Write-Host "Detailed data exported to C:\Reports\" -ForegroundColor Green
    }
    
    return $connectionHistory
}

# Start monitoring
Monitor-NetworkConnections -MonitoringDurationMinutes 5 -SampleIntervalSeconds 15
```

### Network Issue Analysis
```powershell
# Analyze network issues from event logs
function Analyze-NetworkIssues {
    Write-Host "=== Network Issue Analysis ===" -ForegroundColor Cyan
    
    # Get network-related issues
    $networkIssues = Get-NetworkIssues -MaxEvents 100
    
    if ($networkIssues.NCSI) {
        Write-Host "`nNetwork Connectivity Status Indicator (NCSI) Events:" -ForegroundColor Yellow
        $recentNCSI = $networkIssues.NCSI | Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-1) }
        
        if ($recentNCSI) {
            Write-Host "Recent NCSI events (last 24 hours): $($recentNCSI.Count)" -ForegroundColor White
            $recentNCSI | Select-Object TimeCreated, Id, Message | Format-Table -Wrap
        } else {
            Write-Host "No recent NCSI events found" -ForegroundColor Green
        }
    }
    
    if ($networkIssues.RDP) {
        Write-Host "`nRemote Desktop Connection Events:" -ForegroundColor Yellow
        $recentRDP = $networkIssues.RDP | Where-Object { $_.TimeCreated -gt (Get-Date).AddDays(-1) }
        
        if ($recentRDP) {
            Write-Host "Recent RDP events (last 24 hours): $($recentRDP.Count)" -ForegroundColor White
            $recentRDP | Select-Object TimeCreated, Id, Message | Format-Table -Wrap
        } else {
            Write-Host "No recent RDP events found" -ForegroundColor Green
        }
    }
    
    # Additional network diagnostics
    Write-Host "`nPerforming additional network diagnostics..." -ForegroundColor Yellow
    
    # Test connectivity to common services
    $connectivityTests = @(
        @{ Target = "8.8.8.8"; Port = 53; Service = "Google DNS" },
        @{ Target = "1.1.1.1"; Port = 53; Service = "Cloudflare DNS" },
        @{ Target = "google.com"; Port = 80; Service = "Google HTTP" },
        @{ Target = "microsoft.com"; Port = 443; Service = "Microsoft HTTPS" }
    )
    
    foreach ($test in $connectivityTests) {
        $result = Test-NetworkPort -ComputerName $test.Target -Port $test.Port -Timeout 5000
        $status = if ($result.Status -eq "Open") { "✓" } else { "✗" }
        $color = if ($result.Status -eq "Open") { "Green" } else { "Red" }
        Write-Host "  $status $($test.Service): $($result.Status)" -ForegroundColor $color
    }
}

Analyze-NetworkIssues
```

### Automated Network Management Script
```powershell
# Comprehensive network management automation
function Start-NetworkManagement {
    Write-Host "=== Automated Network Management ===" -ForegroundColor Cyan
    
    # 1. Wake up critical servers
    Write-Host "`n1. Waking up critical infrastructure..." -ForegroundColor Yellow
    $criticalServers = @(
        @{ Name = "FileServer"; MAC = "00:11:22:33:44:55" },
        @{ Name = "PrintServer"; MAC = "AA:BB:CC:DD:EE:FF" }
    )
    
    foreach ($server in $criticalServers) {
        Send-WakeOnLAN -MACAddress $server.MAC
        Write-Host "  Wake-on-LAN sent to $($server.Name)" -ForegroundColor Green
    }
    
    # 2. Wait for servers to start
    Write-Host "`n2. Waiting for servers to start (60 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60
    
    # 3. Test connectivity to critical services
    Write-Host "`n3. Testing connectivity to critical services..." -ForegroundColor Yellow
    $criticalServices = @(
        @{ Host = "fileserver"; Port = 445; Service = "File Sharing" },
        @{ Host = "printserver"; Port = 9100; Service = "Print Service" },
        @{ Host = "domaincontroller"; Port = 389; Service = "LDAP" }
    )
    
    foreach ($service in $criticalServices) {
        $result = Test-NetworkPort -ComputerName $service.Host -Port $service.Port
        $status = if ($result.Status -eq "Open") { "✓" } else { "✗" }
        $color = if ($result.Status -eq "Open") { "Green" } else { "Red" }
        Write-Host "  $status $($service.Service) on $($service.Host):$($service.Port)" -ForegroundColor $color
    }
    
    # 4. Resolve network addresses for inventory
    Write-Host "`n4. Updating network inventory..." -ForegroundColor Yellow
    $networkHosts = @("fileserver", "printserver", "domaincontroller", "gateway")
    $inventory = Get-NetworkInventory -Targets $networkHosts
    
    # 5. Check for network issues
    Write-Host "`n5. Checking for network issues..." -ForegroundColor Yellow
    Analyze-NetworkIssues
    
    # 6. Generate summary report
    Write-Host "`n=== Network Management Summary ===" -ForegroundColor Green
    Write-Host "✓ Wake-on-LAN packets sent to $($criticalServers.Count) servers" -ForegroundColor White
    Write-Host "✓ Connectivity tested for $($criticalServices.Count) services" -ForegroundColor White
    Write-Host "✓ Network inventory updated for $($networkHosts.Count) hosts" -ForegroundColor White
    Write-Host "✓ Network issue analysis completed" -ForegroundColor White
    
    Write-Host "`nNetwork management automation completed successfully!" -ForegroundColor Cyan
}

# Run network management automation
Start-NetworkManagement
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Network**: Active network connectivity
- **Wake-on-LAN**: Target computers must have WoL enabled in BIOS/UEFI and network adapter settings

## Dependencies
- .NET Framework networking classes
- Windows networking subsystem
- UDP networking support (for Wake-on-LAN)
- DNS resolution services

## Wake-on-LAN Requirements

### Target Computer Configuration
- **BIOS/UEFI**: Wake-on-LAN must be enabled
- **Network Adapter**: WoL support must be enabled in driver settings
- **Power Management**: "Allow this device to wake the computer" must be enabled
- **Network**: Computer must be connected to network (even when sleeping)

### Network Configuration
- **Subnet**: WoL packets work best within the same subnet
- **Firewall**: UDP port 9 (or custom port) must be allowed
- **Switches**: Network switches must support Wake-on-LAN forwarding

## Port Testing Capabilities
- **TCP Connectivity**: Tests TCP port connectivity
- **Timeout Control**: Configurable connection timeout
- **Multiple Ports**: Test multiple ports simultaneously
- **Error Handling**: Comprehensive error reporting

## Address Resolution Features
- **Forward DNS**: Hostname to IP address resolution
- **Reverse DNS**: IP address to hostname resolution
- **Multiple IPs**: Support for hosts with multiple IP addresses
- **Alias Support**: DNS alias and CNAME record support

## Error Handling
The module includes comprehensive error handling for:
- Network connectivity issues
- DNS resolution failures
- Invalid MAC address formats
- Port connectivity problems
- Service availability issues

## Security Considerations
- Wake-on-LAN packets are sent unencrypted
- Port scanning may trigger security alerts
- DNS queries may be logged by DNS servers
- Network monitoring may capture sensitive information

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Network connectivity is required for remote operations, and target computers must have Wake-on-LAN properly configured for WoL functionality.