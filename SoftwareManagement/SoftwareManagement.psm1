# SoftwareManagement Module
# Provides functions for managing software installation, updates, and removal
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
    Gets information about installed software on a computer.

.DESCRIPTION
    Retrieves a list of installed software from the Windows registry, including
    version information, publisher, and installation details. Can filter by name
    and provide basic or detailed output.

.PARAMETER Name
    Optional. Filter software by name using wildcard matching.

.PARAMETER Detailed
    Optional. When specified, returns additional software information including
    installation location, uninstall string, and size.

.EXAMPLE
    Get-InstalledSoftware
    Gets basic information about all installed software.

.EXAMPLE
    Get-InstalledSoftware -Name "Microsoft*" -Detailed
    Gets detailed information about all Microsoft software.

.EXAMPLE
    Get-InstalledSoftware -Detailed | Where-Object { $_.Publisher -like "*Adobe*" }
    Gets detailed information about all software and filters for Adobe products.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing software information.

.NOTES
    Searches both 32-bit and 64-bit registry locations.
    Some software may not be listed if it doesn't register in the standard locations.
#>
function Get-InstalledSoftware {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name,
        
        [Parameter()]
        [switch]$Detailed
    )
    
    try {
        $software = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                    'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' |
                    Where-Object { $_.DisplayName -ne $null }
        
        if ($Name) {
            $software = $software | Where-Object { $_.DisplayName -like "*$Name*" }
        }
        
        if ($Detailed) {
            return $software | Select-Object -Property @(
                'DisplayName',
                'DisplayVersion',
                'Publisher',
                'InstallDate',
                'InstallLocation',
                'UninstallString',
                'EstimatedSize',
                'SystemComponent',
                'WindowsInstaller'
            )
        }
        else {
            return $software | Select-Object -Property @(
                'DisplayName',
                'DisplayVersion',
                'Publisher',
                'InstallDate'
            )
        }
    }
    catch {
        Write-Warning "Error getting installed software: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Installs software on a computer.

.DESCRIPTION
    Installs software from a specified path, supporting both MSI and executable
    installers. Can capture installation output and handle timeouts.

.PARAMETER Path
    The full path to the installation file. Required.

.PARAMETER Arguments
    Optional. Command-line arguments to pass to the installer.

.PARAMETER WaitForExit
    Optional. When specified, waits for the installation to complete before returning.

.PARAMETER TimeoutSeconds
    Optional. Maximum time to wait for installation completion. Defaults to 300 seconds.

.EXAMPLE
    Install-Software -Path "C:\Installers\app.msi" -WaitForExit
    Installs an MSI package and waits for completion.

.EXAMPLE
    Install-Software -Path "C:\Installers\setup.exe" -Arguments "/S" -WaitForExit
    Installs software silently and waits for completion.

.EXAMPLE
    Install-Software -Path "C:\Installers\app.msi" -Arguments "TARGETDIR=C:\Program Files\App"
    Installs software to a specific directory.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns an object containing installation results or process information.

.NOTES
    Requires appropriate permissions to install software.
    Some installers may require elevation.
#>
function Install-Software {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter()]
        [string]$Arguments,
        
        [Parameter()]
        [switch]$WaitForExit,
        
        [Parameter()]
        [int]$TimeoutSeconds = 300
    )
    
    try {
        if (-not (Test-Path $Path)) {
            throw "Installation file not found at: $Path"
        }
        
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $Path
        $startInfo.Arguments = $Arguments
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        
        Write-Verbose "Starting installation from: $Path"
        $process.Start() | Out-Null
        
        if ($WaitForExit) {
            $completed = $process.WaitForExit($TimeoutSeconds * 1000)
            if (-not $completed) {
                throw "Installation timed out after $TimeoutSeconds seconds"
            }
            
            $output = $process.StandardOutput.ReadToEnd()
            $errorOutput = $process.StandardError.ReadToEnd()
            
            if ($process.ExitCode -ne 0) {
                throw "Installation failed with exit code $($process.ExitCode). Error: $errorOutput"
            }
            
            return [PSCustomObject]@{
                'Success' = $true
                'ExitCode' = $process.ExitCode
                'Output' = $output
                'Error' = $errorOutput
            }
        }
        else {
            return [PSCustomObject]@{
                'ProcessId' = $process.Id
                'StartTime' = $process.StartTime
            }
        }
    }
    catch {
        Write-Warning "Error installing software: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Uninstalls software from a computer.

.DESCRIPTION
    Removes installed software by name, supporting both MSI and non-MSI applications.
    Can perform forced uninstallation and handle timeouts.

.PARAMETER Name
    The name of the software to uninstall. Required.

.PARAMETER Force
    Optional. When specified, performs a silent uninstallation.

.PARAMETER WaitForExit
    Optional. When specified, waits for the uninstallation to complete before returning.

.PARAMETER TimeoutSeconds
    Optional. Maximum time to wait for uninstallation completion. Defaults to 300 seconds.

.EXAMPLE
    Uninstall-Software -Name "Microsoft Office"
    Uninstalls Microsoft Office with normal prompts.

.EXAMPLE
    Uninstall-Software -Name "Adobe Reader" -Force -WaitForExit
    Forces silent uninstallation of Adobe Reader and waits for completion.

.EXAMPLE
    Get-InstalledSoftware | Where-Object { $_.Publisher -like "*Adobe*" } | 
    ForEach-Object { Uninstall-Software -Name $_.DisplayName -Force }
    Uninstalls all Adobe software silently.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns an object containing uninstallation results or process information.

.NOTES
    Requires appropriate permissions to uninstall software.
    Some uninstallers may require elevation.
#>
function Uninstall-Software {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter()]
        [switch]$Force,
        
        [Parameter()]
        [switch]$WaitForExit,
        
        [Parameter()]
        [int]$TimeoutSeconds = 300
    )
    
    try {
        $software = Get-InstalledSoftware -Name $Name -Detailed
        
        if (-not $software) {
            throw "Software '$Name' not found"
        }
        
        if ($software.Count -gt 1) {
            Write-Warning "Multiple matches found for '$Name'. Please be more specific."
            return $software
        }
        
        $uninstallString = $software.UninstallString
        
        if ($uninstallString -like "msiexec*") {
            $productCode = $uninstallString -replace ".*({[A-Z0-9-]+}).*", '$1'
            $arguments = "/x $productCode"
            if ($Force) { $arguments += " /qn" }
            $uninstallString = "msiexec.exe"
        }
        else {
            $arguments = if ($Force) { "/S" } else { "" }
        }
        
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $uninstallString
        $startInfo.Arguments = $arguments
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        
        Write-Verbose "Starting uninstallation of: $Name"
        $process.Start() | Out-Null
        
        if ($WaitForExit) {
            $completed = $process.WaitForExit($TimeoutSeconds * 1000)
            if (-not $completed) {
                throw "Uninstallation timed out after $TimeoutSeconds seconds"
            }
            
            $output = $process.StandardOutput.ReadToEnd()
            $errorOutput = $process.StandardError.ReadToEnd()
            
            if ($process.ExitCode -ne 0) {
                throw "Uninstallation failed with exit code $($process.ExitCode). Error: $errorOutput"
            }
            
            return [PSCustomObject]@{
                'Success' = $true
                'ExitCode' = $process.ExitCode
                'Output' = $output
                'Error' = $errorOutput
            }
        }
        else {
            return [PSCustomObject]@{
                'ProcessId' = $process.Id
                'StartTime' = $process.StartTime
            }
        }
    }
    catch {
        Write-Warning "Error uninstalling software: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Gets information about available or installed Windows updates.

.DESCRIPTION
    Retrieves information about Windows updates, including available updates,
    installed updates, and update details. Can filter by installation status.

.PARAMETER Installable
    Optional. When specified, returns only updates that are downloaded and ready to install.

.PARAMETER Installed
    Optional. When specified, returns the history of installed updates instead of available updates.

.EXAMPLE
    Get-SoftwareUpdates
    Gets all available Windows updates.

.EXAMPLE
    Get-SoftwareUpdates -Installable
    Gets updates that are downloaded and ready to install.

.EXAMPLE
    Get-SoftwareUpdates -Installed | Where-Object { $_.LastDeploymentChangeTime -gt (Get-Date).AddDays(-7) }
    Gets updates installed in the last 7 days.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing update information.

.NOTES
    Requires Windows Update service to be running.
    May require administrative privileges.
#>
function Get-SoftwareUpdates {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Installable,
        
        [Parameter()]
        [switch]$Installed
    )
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        
        if ($Installed) {
            $updates = $updateSearcher.QueryHistory(0, $updateSearcher.GetTotalHistoryCount())
        }
        else {
            $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
        }
        
        if ($Installable) {
            $updates = $updates | Where-Object { $_.IsDownloaded -eq $true }
        }
        
        return $updates | ForEach-Object {
            [PSCustomObject]@{
                'Title' = $_.Title
                'Description' = $_.Description
                'KBArticleIDs' = $_.KBArticleIDs
                'Categories' = $_.Categories | ForEach-Object { $_.Name }
                'IsDownloaded' = $_.IsDownloaded
                'IsInstalled' = $_.IsInstalled
                'LastDeploymentChangeTime' = $_.LastDeploymentChangeTime
                'MaxDownloadSize' = [math]::Round($_.MaxDownloadSize / 1MB, 2)
            }
        }
    }
    catch {
        Write-Warning "Error getting software updates: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Installs Windows updates on a computer.

.DESCRIPTION
    Installs available Windows updates, supporting installation of specific updates
    by KB article ID or all available updates. Can handle restarts and timeouts.

.PARAMETER KBArticleIDs
    Optional. Array of KB article IDs to install. If not specified, requires -All parameter.

.PARAMETER All
    Optional. When specified, installs all available updates.

.PARAMETER ForceRestart
    Optional. When specified, allows the system to restart if required by updates.

.PARAMETER TimeoutMinutes
    Optional. Maximum time to wait for update installation. Defaults to 30 minutes.

.EXAMPLE
    Install-SoftwareUpdates -All
    Installs all available Windows updates.

.EXAMPLE
    Install-SoftwareUpdates -KBArticleIDs "KB5005565", "KB5005566" -ForceRestart
    Installs specific updates and allows restart if needed.

.EXAMPLE
    Get-SoftwareUpdates -Installable | 
    Where-Object { $_.Categories -contains "Security Updates" } |
    ForEach-Object { $_.KBArticleIDs } |
    Install-SoftwareUpdates
    Installs all available security updates.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns an object containing installation results.

.NOTES
    Requires administrative privileges.
    May require system restart after installation.
    Some updates may require multiple installation attempts.
#>
function Install-SoftwareUpdates {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$KBArticleIDs,
        
        [Parameter()]
        [switch]$All,
        
        [Parameter()]
        [switch]$ForceRestart,
        
        [Parameter()]
        [int]$TimeoutMinutes = 30
    )
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        if ($KBArticleIDs) {
            $updates = $updates | Where-Object { $_.KBArticleIDs -in $KBArticleIDs }
        }
        elseif (-not $All) {
            Write-Warning "No updates specified. Use -All to install all available updates."
            return $null
        }
        
        if (-not $updates) {
            Write-Verbose "No updates found to install"
            return $null
        }
        
        $updateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
        $updates | ForEach-Object { $updateCollection.Add($_) | Out-Null }
        
        $installer = $updateSession.CreateUpdateInstaller()
        $installer.Updates = $updateCollection
        $installer.AllowSourcePrompts = $false
        $installer.ForceQuiet = $true
        
        Write-Verbose "Starting installation of $($updates.Count) updates"
        $result = $installer.Install()
        
        return [PSCustomObject]@{
            'ResultCode' = $result.ResultCode
            'RebootRequired' = $result.RebootRequired
            'UpdatesInstalled' = $result.UpdatesInstalled.Count
            'UpdatesFailed' = $result.UpdatesFailed.Count
        }
    }
    catch {
        Write-Warning "Error installing software updates: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-InstalledSoftware',
    'Install-Software',
    'Uninstall-Software',
    'Get-SoftwareUpdates',
    'Install-SoftwareUpdates'
) 