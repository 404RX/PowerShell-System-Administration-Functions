# NetworkManagement Module
# Provides functions for managing network operations and monitoring
# Supports Windows 10/11 and PowerShell 5.1+

#region Module Requirements
$requiredPSVersion = '5.1'
$requiredOSVersion = '10.0.0.0'

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt [version]$requiredPSVersion.Split('.')[0] -or 
    $PSVersionTable.PSVersion.Minor -lt [version]$requiredPSVersion.Split('.')[1]) {
    throw "This module requires PowerShell version $requiredPSVersion or higher"
}

# Check OS version
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if ([version]$osInfo.Version -lt [version]$requiredOSVersion) {
    throw "This module requires Windows 10 or higher"
}
#endregion

#region Public Functions
<#
.SYNOPSIS
    Tests network connectivity to a specific port on a target computer.

.DESCRIPTION
    Tests TCP connectivity to a specified port on a target computer or IP address.
    Can test multiple ports and provide detailed connection information.

.PARAMETER ComputerName
    The target computer name or IP address to test. Required.

.PARAMETER Port
    The port number(s) to test. Can be a single port or an array of ports. Required.

.PARAMETER TimeoutSeconds
    Optional. Maximum time to wait for connection. Defaults to 5 seconds.

.PARAMETER Detailed
    Optional. When specified, returns additional connection information.

.EXAMPLE
    Test-NetworkPort -ComputerName "server01" -Port 80
    Tests connectivity to port 80 on server01.

.EXAMPLE
    Test-NetworkPort -ComputerName "192.168.1.1" -Port @(80, 443, 3389) -TimeoutSeconds 10
    Tests connectivity to multiple ports with a 10-second timeout.

.EXAMPLE
    Test-NetworkPort -ComputerName "server01" -Port 3389 -Detailed
    Gets detailed connection information for port 3389.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing port test results.

.NOTES
    Uses Test-NetConnection for port testing.
    Some ports may be blocked by firewalls.
#>
function Test-NetworkPort {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        
        [Parameter(Mandatory)]
        [int[]]$Port,
        
        [Parameter()]
        [int]$Timeout = 1000
    )
    
    $results = @()
    
    foreach ($p in $Port) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connection = $tcpClient.BeginConnect($ComputerName, $p, $null, $null)
            $wait = $connection.AsyncWaitHandle.WaitOne($Timeout, $false)
            
            if ($wait) {
                $tcpClient.EndConnect($connection)
                $status = 'Open'
            }
            else {
                $status = 'Closed'
            }
            
            $results += [PSCustomObject]@{
                'ComputerName' = $ComputerName
                'Port' = $p
                'Status' = $status
            }
        }
        catch {
            $results += [PSCustomObject]@{
                'ComputerName' = $ComputerName
                'Port' = $p
                'Status' = 'Error'
                'Error' = $_.Exception.Message
            }
        }
        finally {
            if ($tcpClient) { $tcpClient.Close() }
        }
    }
    
    return $results
}

<#
.SYNOPSIS
    Gets active network connections on a computer.

.DESCRIPTION
    Retrieves information about active network connections including
    local and remote addresses, ports, and connection state.
    Can filter by process, port, or connection state.

.PARAMETER ComputerName
    Optional. The computer to query. Defaults to the local computer.

.PARAMETER ProcessName
    Optional. Filter connections by process name.

.PARAMETER Port
    Optional. Filter connections by port number.

.PARAMETER State
    Optional. Filter connections by state (e.g., "Established", "Listening").

.PARAMETER Detailed
    Optional. When specified, returns additional connection information.

.EXAMPLE
    Get-NetworkConnections
    Gets all active network connections on the local computer.

.EXAMPLE
    Get-NetworkConnections -ProcessName "chrome" -State "Established"
    Gets established connections for Chrome processes.

.EXAMPLE
    Get-NetworkConnections -Port 3389 -Detailed
    Gets detailed information about connections on port 3389.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing connection information.

.NOTES
    Requires administrative privileges for some connection information.
    Some connections may not show process information.
#>
function Get-NetworkConnections {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$ShowEstablished,
        
        [Parameter()]
        [switch]$ShowListening
    )
    
    $filter = ""
    if ($ShowEstablished) { $filter += "ESTABLISHED" }
    if ($ShowListening) { $filter += "LISTENING" }
    
    try {
        $connections = netstat -ano | Where-Object { $_ -match $filter }
        return $connections
    }
    catch {
        Write-Warning "Error getting network connections: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Resolves network addresses between hostnames and IP addresses.

.DESCRIPTION
    Performs DNS resolution between hostnames and IP addresses.
    Can resolve both forward (hostname to IP) and reverse (IP to hostname) lookups.

.PARAMETER Address
    The hostname or IP address to resolve. Required.

.PARAMETER Type
    Optional. Type of resolution to perform: "Forward" or "Reverse".
    If not specified, automatically determines the type.

.PARAMETER Detailed
    Optional. When specified, returns additional DNS information.

.EXAMPLE
    Resolve-NetworkAddress -Address "server01"
    Resolves the IP address for server01.

.EXAMPLE
    Resolve-NetworkAddress -Address "192.168.1.1" -Type "Reverse"
    Performs a reverse DNS lookup for the IP address.

.EXAMPLE
    Resolve-NetworkAddress -Address "server01" -Detailed
    Gets detailed DNS resolution information.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing resolution information.

.NOTES
    Uses DNS resolution for lookups.
    Some addresses may not have reverse DNS records.
#>
function Resolve-NetworkAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = 'IP')]
        [string]$IPAddress,
        
        [Parameter(Mandatory, ParameterSetName = 'Hostname')]
        [string]$Hostname
    )
    
    try {
        if ($IPAddress) {
            $result = [System.Net.Dns]::GetHostEntry($IPAddress)
            return [PSCustomObject]@{
                'IPAddress' = $IPAddress
                'Hostname' = $result.HostName
                'Aliases' = $result.Aliases
            }
        }
        else {
            $result = [System.Net.Dns]::GetHostAddresses($Hostname)
            return [PSCustomObject]@{
                'Hostname' = $Hostname
                'IPAddresses' = $result.IPAddressToString
            }
        }
    }
    catch {
        Write-Warning "Error resolving network address: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets information about network issues on a computer.

.DESCRIPTION
    Performs various network diagnostics including connectivity tests,
    DNS resolution, and route analysis. Can identify common network problems.

.PARAMETER ComputerName
    Optional. The computer to diagnose. Defaults to the local computer.

.PARAMETER Target
    Optional. Specific target to test (e.g., "8.8.8.8" for Google DNS).
    If not specified, tests general connectivity.

.PARAMETER Detailed
    Optional. When specified, performs additional diagnostic tests.

.EXAMPLE
    Get-NetworkIssues
    Performs basic network diagnostics on the local computer.

.EXAMPLE
    Get-NetworkIssues -ComputerName "server01" -Target "8.8.8.8"
    Tests connectivity from server01 to Google DNS.

.EXAMPLE
    Get-NetworkIssues -Detailed
    Performs comprehensive network diagnostics.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing diagnostic information.

.NOTES
    Some tests may require administrative privileges.
    Results may vary based on network configuration.
#>
function Get-NetworkIssues {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxEvents = 100
    )
    
    $results = @{
        'NCSI' = $null
        'RDP' = $null
    }
    
    try {
        # Get NCSI events
        $results.NCSI = Get-WinEvent -LogName 'Microsoft-Windows-NCSI/Operational' -MaxEvents $MaxEvents |
            Select-Object TimeCreated, Id, Message
        
        # Get RDP connection events
        $results.RDP = Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' -MaxEvents $MaxEvents |
            Select-Object TimeCreated, Id, Message
    }
    catch {
        Write-Warning "Error getting network issues: $($_.Exception.Message)"
    }
    
    return $results
}

<#
.SYNOPSIS
    Sends a Wake-on-LAN magic packet to a target computer.

.DESCRIPTION
    Sends a Wake-on-LAN magic packet to wake up a computer that is
    in sleep or hibernate state. Requires Wake-on-LAN to be enabled
    on the target computer.

.PARAMETER MacAddress
    The MAC address of the target computer. Required.
    Can be in any common MAC address format.

.PARAMETER IPAddress
    Optional. The IP address to send the packet to.
    If not specified, sends to the broadcast address.

.PARAMETER Port
    Optional. The UDP port to send the packet to. Defaults to 9.

.EXAMPLE
    Send-WakeOnLAN -MacAddress "00:11:22:33:44:55"
    Sends a Wake-on-LAN packet to the specified MAC address.

.EXAMPLE
    Send-WakeOnLAN -MacAddress "00-11-22-33-44-55" -IPAddress "192.168.1.255"
    Sends a Wake-on-LAN packet to a specific subnet.

.EXAMPLE
    Send-WakeOnLAN -MacAddress "001122334455" -Port 7
    Sends a Wake-on-LAN packet using an alternative port.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns an object containing the operation result.

.NOTES
    Requires Wake-on-LAN to be enabled on the target computer.
    Some networks may block Wake-on-LAN packets.
#>
function Send-WakeOnLAN {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MACAddress,
        
        [Parameter()]
        [int]$Port = 9
    )
    
    try {
        $macBytes = $MACAddress -split '[:-]' | ForEach-Object { [byte]::Parse($_, 'HexNumber') }
        $packet = [byte[]](,0xFF * 6) + ($macBytes * 16)
        
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $udpClient.Connect([System.Net.IPAddress]::Broadcast, $Port)
        $udpClient.Send($packet, $packet.Length)
        $udpClient.Close()
        
        Write-Output "Wake-on-LAN packet sent to $MACAddress"
    }
    catch {
        Write-Warning "Error sending Wake-on-LAN packet: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function @(
    'Test-NetworkPort',
    'Get-NetworkConnections',
    'Resolve-NetworkAddress',
    'Get-NetworkIssues',
    'Send-WakeOnLAN'
) 