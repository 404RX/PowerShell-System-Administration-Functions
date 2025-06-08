# SoftwareManagement Module

## Overview
The SoftwareManagement module provides comprehensive functions for managing software installation, updates, and removal on Windows 10/11 systems. This module enables administrators to query installed software, manage Windows updates, and perform software installation and removal operations.

## Functions

### Get-SoftwareUpdates
Retrieves information about available or installed Windows updates, providing detailed update management capabilities.

#### Syntax
```powershell
Get-SoftwareUpdates [-Installable] [-Installed]
```

#### Parameters
- **Installable** (Optional): Returns only updates that are downloaded and ready to install
- **Installed** (Optional): Returns the history of installed updates instead of available updates

#### Examples
```powershell
# Get all available Windows updates
Get-SoftwareUpdates

# Get updates that are downloaded and ready to install
Get-SoftwareUpdates -Installable

# Get updates installed in the last 7 days
Get-SoftwareUpdates -Installed | Where-Object { 
    $_.LastDeploymentChangeTime -gt (Get-Date).AddDays(-7) 
}

# Get security updates only
Get-SoftwareUpdates | Where-Object { 
    $_.Categories -contains "Security Updates" 
}
```

#### Output
Returns custom objects containing:
- **Title**: Update title and description
- **Description**: Detailed update description
- **KBArticleIDs**: Knowledge Base article IDs
- **Categories**: Update categories (e.g., "Security Updates", "Critical Updates")
- **IsDownloaded**: Whether the update is downloaded
- **IsInstalled**: Whether the update is installed
- **LastDeploymentChangeTime**: When the update was last modified
- **MaxDownloadSize**: Update size in MB

### Additional Functions

#### Get-InstalledSoftware
Retrieves information about installed software from the Windows registry.
```powershell
Get-InstalledSoftware [[-Name] <string>] [-Detailed]
```

**Examples:**
```powershell
# Get all installed software
Get-InstalledSoftware

# Get Microsoft software with details
Get-InstalledSoftware -Name "Microsoft*" -Detailed

# Find Adobe products
Get-InstalledSoftware -Detailed | Where-Object { $_.Publisher -like "*Adobe*" }
```

#### Install-Software
Installs software from a specified path supporting MSI and executable installers.
```powershell
Install-Software -Path <string> [[-Arguments] <string>] [-WaitForExit] [[-TimeoutSeconds] <int>]
```

**Examples:**
```powershell
# Install MSI package and wait for completion
Install-Software -Path "C:\Installers\app.msi" -WaitForExit

# Install software silently
Install-Software -Path "C:\Installers\setup.exe" -Arguments "/S" -WaitForExit
```

#### Uninstall-Software
Removes installed software by name, supporting both MSI and non-MSI applications.
```powershell
Uninstall-Software -Name <string> [-Force] [-WaitForExit] [[-TimeoutSeconds] <int>]
```

**Examples:**
```powershell
# Uninstall software with prompts
Uninstall-Software -Name "Adobe Reader"

# Force silent uninstallation
Uninstall-Software -Name "Microsoft Office" -Force -WaitForExit
```

#### Install-SoftwareUpdates
Installs Windows updates on a computer.
```powershell
Install-SoftwareUpdates [[-KBArticleIDs] <string[]>] [-All] [-ForceRestart] [[-TimeoutMinutes] <int>]
```

**Examples:**
```powershell
# Install all available updates
Install-SoftwareUpdates -All

# Install specific updates with restart
Install-SoftwareUpdates -KBArticleIDs "KB5005565", "KB5005566" -ForceRestart
```

## Installation

### Prerequisites
- Windows 10 or Windows 11
- PowerShell 5.1 or later
- Administrative privileges (recommended for full functionality)

### Import Module
```powershell
Import-Module SoftwareManagement
```

## Usage Examples

### Software Inventory Management
```powershell
# Generate software inventory report
$inventory = Get-InstalledSoftware -Detailed | 
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object Publisher, DisplayName

$inventory | Export-Csv -Path "C:\Reports\SoftwareInventory.csv" -NoTypeInformation
```

### Update Management
```powershell
# Check for and install security updates
$securityUpdates = Get-SoftwareUpdates | 
    Where-Object { $_.Categories -contains "Security Updates" }

if ($securityUpdates) {
    Write-Host "Installing $($securityUpdates.Count) security updates..." -ForegroundColor Yellow
    $kbIds = $securityUpdates | ForEach-Object { $_.KBArticleIDs }
    Install-SoftwareUpdates -KBArticleIDs $kbIds -ForceRestart
}
```

### Automated Software Deployment
```powershell
# Deploy software to multiple computers
$computers = @("PC001", "PC002", "PC003")
$installerPath = "\\Server\Share\Software\app.msi"

foreach ($computer in $computers) {
    Write-Host "Installing software on $computer..." -ForegroundColor Green
    Invoke-Command -ComputerName $computer -ScriptBlock {
        Install-Software -Path $using:installerPath -Arguments "/quiet" -WaitForExit
    }
}
```

### Software Cleanup
```powershell
# Remove outdated software
$outdatedSoftware = @("Adobe Flash Player", "Java 8", "Old Antivirus")

foreach ($software in $outdatedSoftware) {
    $installed = Get-InstalledSoftware -Name "*$software*"
    if ($installed) {
        Write-Host "Removing $software..." -ForegroundColor Red
        Uninstall-Software -Name $installed.DisplayName -Force -WaitForExit
    }
}
```

### Update Monitoring
```powershell
# Monitor update installation status
$pendingUpdates = Get-SoftwareUpdates -Installable
if ($pendingUpdates) {
    Write-Warning "$($pendingUpdates.Count) updates are ready for installation"
    $pendingUpdates | Format-Table Title, @{Name="Size(MB)";Expression={$_.MaxDownloadSize}}
}

# Check recently installed updates
$recentUpdates = Get-SoftwareUpdates -Installed | 
    Where-Object { $_.LastDeploymentChangeTime -gt (Get-Date).AddDays(-7) }
Write-Host "Updates installed in the last 7 days: $($recentUpdates.Count)"
```

## Requirements
- **Operating System**: Windows 10/11
- **PowerShell Version**: 5.1+
- **Privileges**: Administrative privileges recommended
- **Services**: Windows Update service, Windows Installer service
- **Network**: Internet connectivity for update operations

## Dependencies
- Windows Update Agent
- Windows Installer service
- Microsoft Update COM objects
- Windows Registry access

## Software Installation Support

### Supported Installer Types
- **MSI Packages**: Full support with custom arguments
- **Executable Installers**: Support with command-line arguments
- **Silent Installation**: Support for unattended installations

### Installation Arguments
- **MSI**: Standard MSI arguments (e.g., `/quiet`, `/norestart`, `TARGETDIR=path`)
- **EXE**: Installer-specific arguments (e.g., `/S`, `/silent`, `/verysilent`)

## Update Categories
The module recognizes various Windows Update categories:
- **Critical Updates**: Essential system updates
- **Security Updates**: Security-related patches
- **Update Rollups**: Cumulative updates
- **Service Packs**: Major update collections
- **Feature Packs**: New feature additions
- **Tools**: Administrative and diagnostic tools
- **Drivers**: Hardware driver updates

## Error Handling
The module includes comprehensive error handling for:
- Installation file access issues
- Insufficient privileges
- Service availability problems
- Network connectivity issues
- Timeout scenarios
- Installation failures

## Security Considerations
- Verify software sources before installation
- Use digital signatures when available
- Test installations in non-production environments
- Monitor installation logs for security events
- Implement proper access controls for installation sources

## Performance Considerations
- Large updates may require significant time and bandwidth
- Multiple simultaneous installations may impact system performance
- Consider scheduling updates during maintenance windows
- Monitor disk space during installations

## Support
This module supports Windows 10 and Windows 11 systems with PowerShell 5.1 or later. Administrative privileges are recommended for full functionality including software installation and Windows Update management.