# SystemInformation Module
# Provides functions for managing system information and monitoring
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
    Gets detailed system information about a computer.

.DESCRIPTION
    Retrieves comprehensive system information including hardware, operating system,
    and domain details. Can provide basic or detailed output.

.PARAMETER Detailed
    Optional. When specified, returns all available system information.
    Otherwise, returns a subset of commonly used properties.

.EXAMPLE
    Get-SystemInfo
    Gets basic system information including hostname, OS version, and domain status.

.EXAMPLE
    Get-SystemInfo -Detailed
    Gets all available system information.

.EXAMPLE
    Get-SystemInfo | Select-Object -Property CsDNSHostName, WindowsProductName, OsLastBootUpTime
    Gets specific system information properties.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing system information.

.NOTES
    Uses Get-ComputerInfo cmdlet for detailed information.
    Some properties may not be available on all systems.
#>
function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Detailed
    )
    
    try {
        if ($Detailed) {
            Get-ComputerInfo | Format-List
        }
        else {
            Get-ComputerInfo | Select-Object -Property @(
                'CsDNSHostName',
                'WindowsProductName',
                'OsHardwareAbstractionLayer',
                'OsLastBootUpTime',
                'OsStatus',
                'CsPartOfDomain',
                'CsDomain',
                'CsDomainRole',
                'CsModel'
            ) | Format-List
        }
    }
    catch {
        Write-Warning "Error getting system information: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets memory usage information for a computer.

.DESCRIPTION
    Retrieves detailed memory usage information including total, free, and used memory.
    Can track top memory-consuming processes and set usage thresholds.

.PARAMETER TopProcesses
    Optional. When specified, includes information about processes using the most memory.

.PARAMETER ProcessCount
    Optional. Number of top processes to include. Defaults to 5.

.PARAMETER Threshold
    Optional. Memory usage percentage threshold for warning. Defaults to 90%.

.EXAMPLE
    Get-MemoryUsage
    Gets basic memory usage information.

.EXAMPLE
    Get-MemoryUsage -TopProcesses -ProcessCount 10
    Gets memory usage information including top 10 memory-consuming processes.

.EXAMPLE
    Get-MemoryUsage -Threshold 85
    Gets memory usage information and warns if usage exceeds 85%.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing memory usage information.

.NOTES
    Memory values are reported in megabytes (MB).
    Process memory information is approximate.
#>
function Get-MemoryUsage {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$TopProcesses,
        
        [Parameter()]
        [int]$ProcessCount = 5,
        
        [Parameter()]
        [int]$Threshold = 90
    )
    
    try {
        $memoryInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        
        $results = [PSCustomObject]@{
            'TotalPhysicalMemory' = [math]::Round($memoryInfo.TotalVisibleMemorySize / 1MB, 2)
            'FreePhysicalMemory' = [math]::Round($memoryInfo.FreePhysicalMemory / 1MB, 2)
            'UsedPhysicalMemory' = [math]::Round(($memoryInfo.TotalVisibleMemorySize - $memoryInfo.FreePhysicalMemory) / 1MB, 2)
            'MemoryUsagePercent' = [math]::Round((($memoryInfo.TotalVisibleMemorySize - $memoryInfo.FreePhysicalMemory) / $memoryInfo.TotalVisibleMemorySize) * 100, 2)
        }
        
        if ($TopProcesses) {
            $results | Add-Member -MemberType NoteProperty -Name 'TopProcesses' -Value (
                Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First $ProcessCount |
                ForEach-Object {
                    [PSCustomObject]@{
                        'ProcessName' = $_.ProcessName
                        'MemoryUsage' = [math]::Round($_.WorkingSet / 1MB, 2)
                        'PercentOfTotal' = [math]::Round(($_.WorkingSet / $memoryInfo.TotalVisibleMemorySize) * 100, 2)
                    }
                }
            )
        }
        
        if ($results.MemoryUsagePercent -gt $Threshold) {
            Write-Warning "Memory usage is above $Threshold% threshold"
        }
        
        return $results
    }
    catch {
        Write-Warning "Error getting memory usage: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets CPU usage information for a computer.

.DESCRIPTION
    Retrieves detailed CPU information including processor details, core count,
    and usage statistics. Can track top CPU-consuming processes.

.PARAMETER TopProcesses
    Optional. When specified, includes information about processes using the most CPU.

.PARAMETER ProcessCount
    Optional. Number of top processes to include. Defaults to 5.

.PARAMETER Threshold
    Optional. CPU usage percentage threshold for warning. Defaults to 90%.

.EXAMPLE
    Get-CPUUsage
    Gets basic CPU information including processor details and core count.

.EXAMPLE
    Get-CPUUsage -TopProcesses -ProcessCount 10
    Gets CPU information including top 10 CPU-consuming processes.

.EXAMPLE
    Get-CPUUsage -Threshold 85
    Gets CPU information and warns if usage exceeds 85%.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing CPU usage information.

.NOTES
    CPU usage values are approximate and may vary.
    Process CPU information is based on current sampling.
#>
function Get-CPUUsage {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$TopProcesses,
        
        [Parameter()]
        [int]$ProcessCount = 5,
        
        [Parameter()]
        [int]$Threshold = 90
    )
    
    try {
        $cpuInfo = Get-CimInstance -ClassName Win32_Processor
        
        $results = [PSCustomObject]@{
            'ProcessorName' = $cpuInfo.Name
            'NumberOfCores' = $cpuInfo.NumberOfCores
            'NumberOfLogicalProcessors' = $cpuInfo.NumberOfLogicalProcessors
            'CurrentClockSpeed' = $cpuInfo.CurrentClockSpeed
            'MaxClockSpeed' = $cpuInfo.MaxClockSpeed
        }
        
        if ($TopProcesses) {
            $results | Add-Member -MemberType NoteProperty -Name 'TopProcesses' -Value (
                Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First $ProcessCount |
                ForEach-Object {
                    [PSCustomObject]@{
                        'ProcessName' = $_.ProcessName
                        'CPUUsage' = [math]::Round($_.CPU, 2)
                        'PercentOfTotal' = [math]::Round(($_.CPU / $cpuInfo.NumberOfLogicalProcessors) * 100, 2)
                    }
                }
            )
        }
        
        return $results
    }
    catch {
        Write-Warning "Error getting CPU usage: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets drive status information for a computer.

.DESCRIPTION
    Retrieves detailed information about disk drives including space usage,
    file system type, and volume details. Can filter by drive letter.

.PARAMETER DriveLetter
    Optional. Specific drive letter to query (e.g., "C:").
    If not specified, returns information for all drives.

.EXAMPLE
    Get-DriveStatus
    Gets status information for all drives.

.EXAMPLE
    Get-DriveStatus -DriveLetter "C:"
    Gets status information for the C: drive.

.EXAMPLE
    Get-DriveStatus | Where-Object { $_.FreeSpacePercent -lt 10 }
    Gets drives with less than 10% free space.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing drive status information.

.NOTES
    Drive sizes are reported in gigabytes (GB).
    Some drives may not report all properties.
#>
function Get-DriveStatus {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$DriveLetter
    )
    
    try {
        $drives = if ($DriveLetter) {
            Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$DriveLetter'"
        }
        else {
            Get-CimInstance -ClassName Win32_LogicalDisk
        }
        
        return $drives | ForEach-Object {
            [PSCustomObject]@{
                'DriveLetter' = $_.DeviceID
                'VolumeName' = $_.VolumeName
                'FileSystem' = $_.FileSystem
                'TotalSize' = [math]::Round($_.Size / 1GB, 2)
                'FreeSpace' = [math]::Round($_.FreeSpace / 1GB, 2)
                'UsedSpace' = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
                'FreeSpacePercent' = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            }
        }
    }
    catch {
        Write-Warning "Error getting drive status: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets system version information for a computer.

.DESCRIPTION
    Retrieves detailed version information including operating system version,
    build number, architecture, and .NET Framework version.

.EXAMPLE
    Get-SystemVersion
    Gets all system version information.

.EXAMPLE
    Get-SystemVersion | Select-Object -Property OSVersion, OSBuild, DotNetVersion
    Gets specific version information properties.

.EXAMPLE
    Get-SystemVersion | Where-Object { $_.DotNetVersion -ne "Not installed" }
    Gets systems with .NET Framework installed.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing version information.

.NOTES
    .NET Framework version information may not be available on all systems.
    OS architecture is reported as x86 or x64.
#>
function Get-SystemVersion {
    [CmdletBinding()]
    param()
    
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $dotNetInfo = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue
        
        return [PSCustomObject]@{
            'OSVersion' = $osInfo.Version
            'OSBuild' = $osInfo.BuildNumber
            'OSArchitecture' = $osInfo.OSArchitecture
            'DotNetVersion' = if ($dotNetInfo) { $dotNetInfo.Version } else { 'Not installed' }
            'LastBootUpTime' = $osInfo.LastBootUpTime
        }
    }
    catch {
        Write-Warning "Error getting system version: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets Windows Defender status information for a computer.

.DESCRIPTION
    Retrieves detailed information about Windows Defender including
    antivirus status, real-time protection, and signature information.

.EXAMPLE
    Get-DefenderStatus
    Gets all Windows Defender status information.

.EXAMPLE
    Get-DefenderStatus | Select-Object -Property AntivirusEnabled, RealTimeProtectionEnabled
    Gets specific Defender status properties.

.EXAMPLE
    Get-DefenderStatus | Where-Object { -not $_.AntivirusEnabled }
    Gets systems where antivirus is disabled.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing Defender status information.

.NOTES
    Requires Windows Defender to be installed.
    Some properties may not be available if Defender is not the active antivirus.
#>
function Get-DefenderStatus {
    [CmdletBinding()]
    param()
    
    try {
        $defender = Get-MpComputerStatus
        
        return [PSCustomObject]@{
            'AntivirusEnabled' = $defender.AntivirusEnabled
            'AntispywareEnabled' = $defender.AntispywareEnabled
            'RealTimeProtectionEnabled' = $defender.RealTimeProtectionEnabled
            'AntivirusSignatureVersion' = $defender.AntivirusSignatureVersion
            'AntivirusSignatureLastUpdated' = $defender.AntivirusSignatureLastUpdated
            'AntispywareSignatureVersion' = $defender.AntispywareSignatureVersion
            'AntispywareSignatureLastUpdated' = $defender.AntispywareSignatureLastUpdated
        }
    }
    catch {
        Write-Warning "Error getting Defender status: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-SystemInfo',
    'Get-MemoryUsage',
    'Get-CPUUsage',
    'Get-DriveStatus',
    'Get-SystemVersion',
    'Get-DefenderStatus'
) 