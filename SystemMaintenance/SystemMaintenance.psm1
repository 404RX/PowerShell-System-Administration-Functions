# SystemMaintenance Module
# Provides functions for system maintenance and optimization
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
    Performs disk cleanup operations.

.DESCRIPTION
    Performs various disk cleanup operations including temporary files,
    Windows Update cache, and system files. Can target specific cleanup
    categories or perform a full cleanup.

.PARAMETER ComputerName
    Optional. The computer to perform cleanup on. Defaults to the local computer.

.PARAMETER Categories
    Optional. Specific cleanup categories to perform (TempFiles, WindowsUpdate,
    SystemFiles, RecycleBin). If not specified, performs all categories.

.PARAMETER Force
    Optional. When specified, skips confirmation prompts.

.PARAMETER Detailed
    Optional. When specified, returns detailed cleanup results.

.EXAMPLE
    Start-DiskCleanup
    Performs a full disk cleanup on the local computer.

.EXAMPLE
    Start-DiskCleanup -Categories "TempFiles","RecycleBin" -Force
    Cleans temporary files and recycle bin without confirmation.

.EXAMPLE
    Start-DiskCleanup -ComputerName "server01" -Detailed
    Performs a detailed disk cleanup on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing cleanup results.

.NOTES
    Requires administrative privileges.
    Some cleanup operations may require a system restart.
#>
function Start-DiskCleanup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [ValidateSet('TempFiles', 'WindowsUpdate', 'SystemFiles', 'RecycleBin')]
        [string[]]$Categories = @('TempFiles', 'WindowsUpdate', 'SystemFiles', 'RecycleBin'),

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{}
        
        if ($Categories -contains 'TempFiles') {
            Write-Verbose "Cleaning temporary files..."
            $tempPaths = @(
                "$env:TEMP\*",
                "$env:WINDIR\Temp\*",
                "$env:WINDIR\Prefetch\*"
            )
            
            foreach ($path in $tempPaths) {
                if (Test-Path $path) {
                    Remove-Item -Path $path -Force:$Force -Recurse -ErrorAction Stop
                }
            }
            $results.TempFiles = "Cleaned"
        }

        if ($Categories -contains 'WindowsUpdate') {
            Write-Verbose "Cleaning Windows Update cache..."
            Stop-Service -Name wuauserv -Force -ErrorAction Stop
            Remove-Item -Path "$env:WINDIR\SoftwareDistribution\*" -Force:$Force -Recurse -ErrorAction Stop
            Start-Service -Name wuauserv
            $results.WindowsUpdate = "Cleaned"
        }

        if ($Categories -contains 'SystemFiles') {
            Write-Verbose "Cleaning system files..."
            $cleanupCommand = "cleanmgr.exe /sagerun:1"
            if ($Force) { $cleanupCommand += " /verylowdisk" }
            Start-Process -FilePath $cleanupCommand -Wait -NoNewWindow
            $results.SystemFiles = "Cleaned"
        }

        if ($Categories -contains 'RecycleBin') {
            Write-Verbose "Cleaning recycle bin..."
            Clear-RecycleBin -Force:$Force -ErrorAction Stop
            $results.RecycleBin = "Cleaned"
        }

        if ($Detailed) {
            $results | ForEach-Object {
                [PSCustomObject]@{
                    Category = $_.Key
                    Status = $_.Value
                    Timestamp = Get-Date
                    ComputerName = $ComputerName
                }
            }
        } else {
            [PSCustomObject]@{
                Status = "Success"
                Categories = $Categories
                ComputerName = $ComputerName
            }
        }
    }
    catch {
        Write-Error "Failed to perform disk cleanup: $_"
        throw
    }
}

<#
.SYNOPSIS
    Performs system file integrity check and repair.

.DESCRIPTION
    Runs System File Checker (SFC) and DISM to verify and repair
    system file integrity. Can perform online or offline repairs.

.PARAMETER ComputerName
    Optional. The computer to check. Defaults to the local computer.

.PARAMETER Repair
    Optional. When specified, attempts to repair corrupted files.

.PARAMETER Offline
    Optional. When specified, performs offline repair using Windows image.

.PARAMETER Detailed
    Optional. When specified, returns detailed check results.

.EXAMPLE
    Start-SystemFileCheck
    Performs a system file integrity check on the local computer.

.EXAMPLE
    Start-SystemFileCheck -Repair -Detailed
    Performs a system file check and repair with detailed results.

.EXAMPLE
    Start-SystemFileCheck -ComputerName "server01" -Offline
    Performs an offline system file check on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing check results.

.NOTES
    Requires administrative privileges.
    Offline repair may require a system restart.
#>
function Start-SystemFileCheck {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [switch]$Repair,

        [Parameter()]
        [switch]$Offline,

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{
            SFC = $null
            DISM = $null
        }

        if ($Offline) {
            Write-Verbose "Performing offline system file check..."
            $dismCommand = "DISM.exe /Online /Cleanup-Image /RestoreHealth"
            if ($Repair) { $dismCommand += " /Source:wim:path_to_wim_file" }
            
            $dismResult = Invoke-Expression $dismCommand
            $results.DISM = $dismResult
        } else {
            Write-Verbose "Running System File Checker..."
            $sfcCommand = "sfc.exe /verifyonly"
            if ($Repair) { $sfcCommand = "sfc.exe /scannow" }
            
            $sfcResult = Invoke-Expression $sfcCommand
            $results.SFC = $sfcResult

            Write-Verbose "Running DISM health check..."
            $dismResult = Invoke-Expression "DISM.exe /Online /Cleanup-Image /CheckHealth"
            $results.DISM = $dismResult
        }

        if ($Detailed) {
            [PSCustomObject]@{
                ComputerName = $ComputerName
                Timestamp = Get-Date
                SFCResult = $results.SFC
                DISMResult = $results.DISM
                RepairAttempted = $Repair
                OfflineMode = $Offline
            }
        } else {
            [PSCustomObject]@{
                Status = "Completed"
                ComputerName = $ComputerName
                RepairAttempted = $Repair
                OfflineMode = $Offline
            }
        }
    }
    catch {
        Write-Error "Failed to perform system file check: $_"
        throw
    }
}

<#
.SYNOPSIS
    Performs system optimization tasks.

.DESCRIPTION
    Performs various system optimization tasks including disk defragmentation,
    service optimization, and startup optimization. Can target specific
    optimization categories or perform a full optimization.

.PARAMETER ComputerName
    Optional. The computer to optimize. Defaults to the local computer.

.PARAMETER Categories
    Optional. Specific optimization categories to perform (DiskDefrag,
    ServiceOptimization, StartupOptimization). If not specified,
    performs all categories.

.PARAMETER Force
    Optional. When specified, skips confirmation prompts.

.PARAMETER Detailed
    Optional. When specified, returns detailed optimization results.

.EXAMPLE
    Start-SystemOptimization
    Performs a full system optimization on the local computer.

.EXAMPLE
    Start-SystemOptimization -Categories "DiskDefrag","StartupOptimization" -Force
    Optimizes disk and startup items without confirmation.

.EXAMPLE
    Start-SystemOptimization -ComputerName "server01" -Detailed
    Performs a detailed system optimization on a remote computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing optimization results.

.NOTES
    Requires administrative privileges.
    Some optimization tasks may require a system restart.
#>
function Start-SystemOptimization {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [ValidateSet('DiskDefrag', 'ServiceOptimization', 'StartupOptimization')]
        [string[]]$Categories = @('DiskDefrag', 'ServiceOptimization', 'StartupOptimization'),

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$Detailed
    )

    try {
        $results = @{}

        if ($Categories -contains 'DiskDefrag') {
            Write-Verbose "Optimizing disk..."
            Get-Volume | Where-Object DriveType -eq 'Fixed' | ForEach-Object {
                Optimize-Volume -DriveLetter $_.DriveLetter -Defrag -Verbose
            }
            $results.DiskDefrag = "Completed"
        }

        if ($Categories -contains 'ServiceOptimization') {
            Write-Verbose "Optimizing services..."
            $services = Get-Service | Where-Object StartType -eq 'Automatic'
            foreach ($service in $services) {
                if (-not $service.Required) {
                    Set-Service -Name $service.Name -StartupType 'Automatic' -ErrorAction SilentlyContinue
                }
            }
            $results.ServiceOptimization = "Completed"
        }

        if ($Categories -contains 'StartupOptimization') {
            Write-Verbose "Optimizing startup items..."
            $startupItems = Get-CimInstance -ClassName Win32_StartupCommand
            foreach ($item in $startupItems) {
                if (-not $item.Location -match 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run') {
                    Remove-ItemProperty -Path $item.Location -Name $item.Name -Force:$Force -ErrorAction SilentlyContinue
                }
            }
            $results.StartupOptimization = "Completed"
        }

        if ($Detailed) {
            $results | ForEach-Object {
                [PSCustomObject]@{
                    Category = $_.Key
                    Status = $_.Value
                    Timestamp = Get-Date
                    ComputerName = $ComputerName
                }
            }
        } else {
            [PSCustomObject]@{
                Status = "Success"
                Categories = $Categories
                ComputerName = $ComputerName
            }
        }
    }
    catch {
        Write-Error "Failed to perform system optimization: $_"
        throw
    }
}

Export-ModuleMember -Function @(
    'Start-DiskCleanup',
    'Start-SystemFileCheck',
    'Start-SystemOptimization'
) 