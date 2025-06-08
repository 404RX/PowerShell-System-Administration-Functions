# Common functions used across all modules

function Write-LogMessage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory=$false)]
        [string]$LogFile = ".\logs\$(Get-Date -Format 'yyyy-MM-dd').log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Ensure log directory exists
    $logDir = Split-Path -Parent $LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logMessage
    
    # Also write to console with appropriate color
    switch ($Level) {
        'Info'    { Write-Host $logMessage -ForegroundColor White }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
    }
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ErrorDetails {
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    $errorDetails = @{
        ExceptionType = $ErrorRecord.Exception.GetType().FullName
        ExceptionMessage = $ErrorRecord.Exception.Message
        ScriptStackTrace = $ErrorRecord.ScriptStackTrace
        Line = $ErrorRecord.InvocationInfo.Line
        Position = $ErrorRecord.InvocationInfo.PositionMessage
        Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    return $errorDetails
}

function Test-RequiredModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory=$false)]
        [string]$MinimumVersion
    )
    
    $module = Get-Module -Name $ModuleName -ListAvailable
    if (-not $module) {
        Write-LogMessage -Message "Required module '$ModuleName' not found. Please install it using: Install-Module -Name $ModuleName -Force" -Level Error
        return $false
    }
    
    if ($MinimumVersion) {
        $installedVersion = $module.Version
        if ($installedVersion -lt [Version]$MinimumVersion) {
            Write-LogMessage -Message "Module '$ModuleName' version $installedVersion is installed, but version $MinimumVersion is required." -Level Error
            return $false
        }
    }
    
    return $true
}

function Test-OSVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$MinimumVersion = "10.0.17763",  # Windows 10 1809/Server 2019
        
        [Parameter(Mandatory=$false)]
        [switch]$ServerOnly,
        
        [Parameter(Mandatory=$false)]
        [switch]$ClientOnly,
        
        [Parameter(Mandatory=$false)]
        [switch]$LogOnly
    )
    
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $currentVersion = $os.Version
        $isServer = $os.ProductType -ne 1  # 1 = Workstation, 2 = Domain Controller, 3 = Server
        
        $compatibility = @{
            IsCompatible = $true
            CurrentVersion = $currentVersion
            IsServer = $isServer
            Message = "OS Version check passed"
            Details = @{
                OSName = $os.Caption
                Version = $currentVersion
                BuildNumber = $os.BuildNumber
                Architecture = $os.OSArchitecture
                ProductType = if ($isServer) { "Server" } else { "Workstation" }
            }
        }
        
        # Check minimum version
        if ([Version]$currentVersion -lt [Version]$MinimumVersion) {
            $compatibility.IsCompatible = $false
            $compatibility.Message = "OS Version $currentVersion is below minimum required version $MinimumVersion"
        }
        
        # Check server/client requirements
        if ($ServerOnly -and -not $isServer) {
            $compatibility.IsCompatible = $false
            $compatibility.Message = "This operation requires a Windows Server OS"
        }
        elseif ($ClientOnly -and $isServer) {
            $compatibility.IsCompatible = $false
            $compatibility.Message = "This operation requires a Windows Client OS"
        }
        
        if ($LogOnly) {
            Write-LogMessage -Message "OS Version Check: $($compatibility.Message)" -Level Info
            Write-LogMessage -Message "OS Details: $($compatibility.Details | ConvertTo-Json)" -Level Info
            return $true  # Always return true when logging only
        }
        
        if (-not $compatibility.IsCompatible) {
            Write-LogMessage -Message $compatibility.Message -Level Warning
        }
        
        return $compatibility
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to check OS version: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Test-ModuleCompatibility {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Requirements = @{
            MinimumOSVersion = "10.0.17763"  # Windows 10 1809/Server 2019
            ServerOnly = $false
            ClientOnly = $false
            RequiredModules = @()
            RequiredFeatures = @()
        }
    )
    
    try {
        $compatibility = @{
            ModuleName = $ModuleName
            IsCompatible = $true
            Messages = @()
            Details = @{}
        }
        
        # Check OS version
        $osCheck = Test-OSVersion -MinimumVersion $Requirements.MinimumOSVersion `
                                 -ServerOnly:$Requirements.ServerOnly `
                                 -ClientOnly:$Requirements.ClientOnly `
                                 -LogOnly
        
        if (-not $osCheck) {
            $compatibility.IsCompatible = $false
            $compatibility.Messages += "OS version requirements not met"
        }
        
        # Check required modules
        foreach ($module in $Requirements.RequiredModules) {
            if (-not (Get-Module -Name $module -ListAvailable)) {
                $compatibility.IsCompatible = $false
                $compatibility.Messages += "Required module '$module' is not installed"
            }
        }
        
        # Check Windows features
        foreach ($feature in $Requirements.RequiredFeatures) {
            if (-not (Get-WindowsFeature -Name $feature -ErrorAction SilentlyContinue).Installed) {
                $compatibility.IsCompatible = $false
                $compatibility.Messages += "Required Windows feature '$feature' is not installed"
            }
        }
        
        $compatibility.Details = @{
            OSVersion = $osCheck.Details
            InstalledModules = (Get-Module -Name $Requirements.RequiredModules -ListAvailable).Name
            InstalledFeatures = (Get-WindowsFeature -Name $Requirements.RequiredFeatures).Where({$_.Installed}).Name
        }
        
        if (-not $compatibility.IsCompatible) {
            Write-LogMessage -Message "Module '$ModuleName' compatibility check failed: $($compatibility.Messages -join ', ')" -Level Warning
            Write-LogMessage -Message "Compatibility Details: $($compatibility.Details | ConvertTo-Json)" -Level Info
        }
        
        return $compatibility
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to check module compatibility: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

# Export all functions
Export-ModuleMember -Function * 