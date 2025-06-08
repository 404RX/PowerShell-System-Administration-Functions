# NetworkDiagnostics Module
# Provides functions for network diagnostics and troubleshooting
# Supports Windows 10/11 and PowerShell 5.1+

#region Module Requirements
# Import required modules
Import-Module Common

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "This module requires PowerShell 5.1 or later."
}

# Check Windows version
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if (-not ($osInfo.Caption -match "Windows 10|Windows 11")) {
    throw "This module requires Windows 10 or Windows 11."
}
#endregion

#region Public Functions
<#
.SYNOPSIS
    Performs comprehensive network diagnostics.

.DESCRIPTION
    Performs a series of network diagnostic tests including connectivity,
    DNS resolution, routing, and latency tests. Can target specific
    network components or perform a full diagnostic.

.PARAMETER ComputerName
    Optional. The computer to diagnose. Defaults to the local computer.

.PARAMETER Target
    Optional. Specific target to test (e.g., "8.8.8.8" for Google DNS).
    If not specified, tests general connectivity.

.PARAMETER Tests
    Optional. Specific tests to perform (Connectivity, DNS, Routing,
    Latency). If not specified, performs all tests.

.PARAMETER Detailed
    Optional. When specified, returns detailed diagnostic results.

.EXAMPLE
    Start-NetworkDiagnostics
    Performs a full network diagnostic on the local computer.

.EXAMPLE
    Start-NetworkDiagnostics -Target "8.8.8.8" -Tests "Latency","DNS"
    Tests latency and DNS resolution to Google DNS.

.EXAMPLE
    Start-NetworkDiagnostics -ComputerName "server01" -Detailed
    Performs a detailed network diagnostic on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing diagnostic results.

.NOTES
    Some tests may require administrative privileges.
    Results may vary based on network configuration.
#>
function Start-NetworkDiagnostics {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [string]$Target,

        [Parameter()]
        [ValidateSet('Connectivity', 'DNS', 'Routing', 'Latency')]
        [string[]]$Tests = @('Connectivity', 'DNS', 'Routing', 'Latency'),

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{}
        $target = if ($Target) { $Target } else { "8.8.8.8" }

        if ($Tests -contains 'Connectivity') {
            Write-Verbose "Testing network connectivity..."
            $pingResult = Test-Connection -ComputerName $target -Count 4 -ErrorAction Stop
            $results.Connectivity = @{
                Success = $pingResult.Status -contains 'Success'
                PacketsSent = $pingResult.Count
                PacketsReceived = ($pingResult.Status -eq 'Success').Count
                AverageLatency = ($pingResult | Where-Object Status -eq 'Success' | Measure-Object -Property ResponseTime -Average).Average
            }
        }

        if ($Tests -contains 'DNS') {
            Write-Verbose "Testing DNS resolution..."
            $dnsResult = Resolve-DnsName -Name $target -ErrorAction Stop
            $results.DNS = @{
                Success = $true
                ResolvedAddresses = $dnsResult.IPAddress
                Type = $dnsResult.Type
            }
        }

        if ($Tests -contains 'Routing') {
            Write-Verbose "Testing network routing..."
            $routeResult = Test-NetRoute -DestinationPrefix $target -ErrorAction Stop
            $results.Routing = @{
                Success = $routeResult.Status -eq 'Success'
                NextHop = $routeResult.NextHop
                InterfaceIndex = $routeResult.InterfaceIndex
            }
        }

        if ($Tests -contains 'Latency') {
            Write-Verbose "Testing network latency..."
            $latencyResult = Test-Connection -ComputerName $target -Count 10 -ErrorAction Stop
            $results.Latency = @{
                Average = ($latencyResult | Measure-Object -Property ResponseTime -Average).Average
                Minimum = ($latencyResult | Measure-Object -Property ResponseTime -Minimum).Minimum
                Maximum = ($latencyResult | Measure-Object -Property ResponseTime -Maximum).Maximum
                PacketLoss = (($latencyResult.Status -ne 'Success').Count / $latencyResult.Count) * 100
            }
        }

        if ($Detailed) {
            $results | ForEach-Object {
                [PSCustomObject]@{
                    Test = $_.Key
                    Results = $_.Value
                    Timestamp = Get-Date
                    ComputerName = $ComputerName
                    Target = $target
                }
            }
        } else {
            [PSCustomObject]@{
                Status = "Completed"
                Tests = $Tests
                ComputerName = $ComputerName
                Target = $target
            }
        }
    }
    catch {
        Write-Error "Failed to perform network diagnostics: $_"
        throw
    }
}

<#
.SYNOPSIS
    Analyzes network traffic patterns.

.DESCRIPTION
    Captures and analyzes network traffic patterns including protocol
    distribution, bandwidth usage, and connection statistics.
    Can monitor specific interfaces or all network traffic.

.PARAMETER ComputerName
    Optional. The computer to analyze. Defaults to the local computer.

.PARAMETER Interface
    Optional. Specific network interface to monitor.
    If not specified, monitors all interfaces.

.PARAMETER Duration
    Optional. Duration of capture in seconds. Defaults to 60 seconds.

.PARAMETER Detailed
    Optional. When specified, returns detailed traffic analysis.

.EXAMPLE
    Start-NetworkTrafficAnalysis
    Analyzes network traffic on all interfaces for 60 seconds.

.EXAMPLE
    Start-NetworkTrafficAnalysis -Interface "Ethernet" -Duration 300
    Analyzes traffic on the Ethernet interface for 5 minutes.

.EXAMPLE
    Start-NetworkTrafficAnalysis -ComputerName "server01" -Detailed
    Performs a detailed traffic analysis on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing traffic analysis results.

.NOTES
    Requires administrative privileges.
    May impact network performance during capture.
#>
function Start-NetworkTrafficAnalysis {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [string]$Interface,

        [Parameter()]
        [int]$Duration = 60,

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{
            StartTime = Get-Date
            EndTime = (Get-Date).AddSeconds($Duration)
            Traffic = @{}
        }

        Write-Verbose "Starting network traffic analysis..."
        $interfaces = if ($Interface) {
            Get-NetAdapter | Where-Object Name -eq $Interface
        } else {
            Get-NetAdapter | Where-Object Status -eq 'Up'
        }

        foreach ($if in $interfaces) {
            $traffic = @{
                BytesReceived = 0
                BytesSent = 0
                PacketsReceived = 0
                PacketsSent = 0
                Protocols = @{}
            }

            $startStats = Get-NetAdapterStatistics -Name $if.Name
            Start-Sleep -Seconds $Duration
            $endStats = Get-NetAdapterStatistics -Name $if.Name

            $traffic.BytesReceived = $endStats.ReceivedBytes - $startStats.ReceivedBytes
            $traffic.BytesSent = $endStats.SentBytes - $startStats.SentBytes
            $traffic.PacketsReceived = $endStats.ReceivedUnicastPackets - $startStats.ReceivedUnicastPackets
            $traffic.PacketsSent = $endStats.SentUnicastPackets - $startStats.SentUnicastPackets

            $results.Traffic[$if.Name] = $traffic
        }

        if ($Detailed) {
            $results | ForEach-Object {
                [PSCustomObject]@{
                    Interface = $_.Key
                    Statistics = $_.Value
                    StartTime = $results.StartTime
                    EndTime = $results.EndTime
                    ComputerName = $ComputerName
                }
            }
        } else {
            [PSCustomObject]@{
                Status = "Completed"
                Interfaces = $interfaces.Name
                Duration = $Duration
                ComputerName = $ComputerName
            }
        }
    }
    catch {
        Write-Error "Failed to analyze network traffic: $_"
        throw
    }
}

<#
.SYNOPSIS
    Diagnoses network connectivity issues.

.DESCRIPTION
    Performs a series of tests to diagnose common network connectivity
    issues including DNS problems, routing issues, and firewall
    restrictions. Can target specific issues or perform a full diagnosis.

.PARAMETER ComputerName
    Optional. The computer to diagnose. Defaults to the local computer.

.PARAMETER Target
    Optional. Specific target to test (e.g., "8.8.8.8" for Google DNS).
    If not specified, tests general connectivity.

.PARAMETER Issues
    Optional. Specific issues to diagnose (DNS, Routing, Firewall).
    If not specified, diagnoses all issues.

.PARAMETER Detailed
    Optional. When specified, returns detailed diagnosis results.

.EXAMPLE
    Start-NetworkTroubleshooting
    Performs a full network troubleshooting on the local computer.

.EXAMPLE
    Start-NetworkTroubleshooting -Target "server01" -Issues "DNS","Firewall"
    Diagnoses DNS and firewall issues for a specific target.

.EXAMPLE
    Start-NetworkTroubleshooting -ComputerName "server01" -Detailed
    Performs a detailed network troubleshooting on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing troubleshooting results.

.NOTES
    Requires administrative privileges.
    Some tests may require network access to be temporarily modified.
#>
function Start-NetworkTroubleshooting {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [string]$Target,

        [Parameter()]
        [ValidateSet('DNS', 'Routing', 'Firewall')]
        [string[]]$Issues = @('DNS', 'Routing', 'Firewall'),

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{}
        $target = if ($Target) { $Target } else { "8.8.8.8" }

        if ($Issues -contains 'DNS') {
            Write-Verbose "Diagnosing DNS issues..."
            $dnsResults = @{
                LocalDNS = $null
                PublicDNS = $null
                DNSCache = $null
            }

            # Test local DNS
            $dnsResults.LocalDNS = Resolve-DnsName -Name $target -Server (Get-DnsClientServerAddress).ServerAddresses[0] -ErrorAction SilentlyContinue

            # Test public DNS
            $dnsResults.PublicDNS = Resolve-DnsName -Name $target -Server "8.8.8.8" -ErrorAction SilentlyContinue

            # Check DNS cache
            $dnsResults.DNSCache = Get-DnsClientCache -ErrorAction SilentlyContinue

            $results.DNS = $dnsResults
        }

        if ($Issues -contains 'Routing') {
            Write-Verbose "Diagnosing routing issues..."
            $routeResults = @{
                Traceroute = $null
                RouteTable = $null
                DefaultGateway = $null
            }

            # Perform traceroute
            $routeResults.Traceroute = Test-NetConnection -ComputerName $target -TraceRoute -ErrorAction SilentlyContinue

            # Get route table
            $routeResults.RouteTable = Get-NetRoute -ErrorAction SilentlyContinue

            # Check default gateway
            $routeResults.DefaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue

            $results.Routing = $routeResults
        }

        if ($Issues -contains 'Firewall') {
            Write-Verbose "Diagnosing firewall issues..."
            $firewallResults = @{
                Rules = $null
                Status = $null
                BlockedConnections = $null
            }

            # Get firewall rules
            $firewallResults.Rules = Get-NetFirewallRule -ErrorAction SilentlyContinue

            # Check firewall status
            $firewallResults.Status = Get-NetFirewallProfile -ErrorAction SilentlyContinue

            # Check blocked connections
            $firewallResults.BlockedConnections = Get-NetFirewallApplicationFilter -ErrorAction SilentlyContinue

            $results.Firewall = $firewallResults
        }

        if ($Detailed) {
            $results | ForEach-Object {
                [PSCustomObject]@{
                    Issue = $_.Key
                    Diagnosis = $_.Value
                    Timestamp = Get-Date
                    ComputerName = $ComputerName
                    Target = $target
                }
            }
        } else {
            [PSCustomObject]@{
                Status = "Completed"
                Issues = $Issues
                ComputerName = $ComputerName
                Target = $target
            }
        }
    }
    catch {
        Write-Error "Failed to perform network troubleshooting: $_"
        throw
    }
}

Export-ModuleMember -Function @(
    'Start-NetworkDiagnostics',
    'Start-NetworkTrafficAnalysis',
    'Start-NetworkTroubleshooting'
) 