# EventLogging Module
# Provides functions for managing Windows Event Logs
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

#region Helper Functions
function Test-EventLogAccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogName
    )
    
    try {
        $null = Get-WinEvent -LogName $LogName -MaxEvents 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Cannot access log '$LogName': $($_.Exception.Message)"
        return $false
    }
}

function Get-EventLogProvider {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ProviderName
    )
    
    if ($ProviderName) {
        Get-WinEvent -ListProvider $ProviderName
    }
    else {
        Get-WinEvent -ListProvider
    }
}
#endregion

#region Public Functions
function Get-SystemEventLogs {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Application', 'System', 'Security', 'Setup', 'ForwardedEvents')]
        [string]$LogName = 'System',
        
        [Parameter()]
        [int]$MaxEvents = 100,
        
        [Parameter()]
        [datetime]$StartTime,
        
        [Parameter()]
        [datetime]$EndTime,
        
        [Parameter()]
        [string]$FilterMessage,
        
        [Parameter()]
        [int[]]$EventID
    )
    
    $filterHash = @{
        'LogName' = $LogName
    }
    
    if ($StartTime) { $filterHash['StartTime'] = $StartTime }
    if ($EndTime) { $filterHash['EndTime'] = $EndTime }
    if ($EventID) { $filterHash['ID'] = $EventID }
    
    try {
        $events = Get-WinEvent -FilterHashtable $filterHash -MaxEvents $MaxEvents
        
        if ($FilterMessage) {
            $events = $events | Where-Object { $_.Message -like "*$FilterMessage*" }
        }
        
        return $events
    }
    catch {
        Write-Warning "Error retrieving events from $LogName: $($_.Exception.Message)"
        return $null
    }
}

function Get-SecurityLogonEvents {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxEvents = 100,
        
        [Parameter()]
        [datetime]$StartTime = (Get-Date).AddHours(-24),
        
        [Parameter()]
        [datetime]$EndTime = Get-Date
    )
    
    $filterHash = @{
        'LogName' = 'Security'
        'ID' = 4624  # Successful logon
        'StartTime' = $StartTime
        'EndTime' = $EndTime
    }
    
    try {
        $events = Get-WinEvent -FilterHashtable $filterHash -MaxEvents $MaxEvents
        
        return $events | ForEach-Object {
            [PSCustomObject]@{
                'TimeCreated' = $_.TimeCreated
                'EventID' = $_.Id
                'UserName' = $_.Properties[5].Value
                'Domain' = $_.Properties[6].Value
                'IPAddress' = $_.Properties[18].Value
                'Workstation' = $_.Properties[13].Value
                'LogonType' = $_.Properties[10].Value
            }
        }
    }
    catch {
        Write-Warning "Error retrieving security logon events: $($_.Exception.Message)"
        return $null
    }
}

function Get-SystemShutdownEvents {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxEvents = 100
    )
    
    $filterHash = @{
        'LogName' = 'System'
        'ID' = @(41, 1074, 6006, 6605, 6008)  # Various shutdown event IDs
    }
    
    try {
        $events = Get-WinEvent -FilterHashtable $filterHash -MaxEvents $MaxEvents
        
        return $events | ForEach-Object {
            [PSCustomObject]@{
                'TimeCreated' = $_.TimeCreated
                'EventID' = $_.Id
                'Level' = $_.LevelDisplayName
                'Message' = $_.Message
            }
        }
    }
    catch {
        Write-Warning "Error retrieving system shutdown events: $($_.Exception.Message)"
        return $null
    }
}

function Get-SystemRebootEvents {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxEvents = 100
    )
    
    try {
        $events = Get-WmiObject Win32_NTLogEvent -Filter "LogFile='System' and EventCode=6005" | 
            Select-Object -First $MaxEvents |
            Select-Object ComputerName, EventCode, @{Name='TimeWritten';Expression={$_.ConverttoDateTime($_.TimeWritten)}}
        
        return $events
    }
    catch {
        Write-Warning "Error retrieving system reboot events: $($_.Exception.Message)"
        return $null
    }
}

function Get-PowerShellOperationalLogs {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$MaxEvents = 100,
        
        [Parameter()]
        [datetime]$StartTime = (Get-Date).AddHours(-24),
        
        [Parameter()]
        [string]$FilterExpression
    )
    
    $filterHash = @{
        'LogName' = 'Microsoft-Windows-PowerShell/Operational'
        'StartTime' = $StartTime
    }
    
    try {
        $events = Get-WinEvent -FilterHashtable $filterHash -MaxEvents $MaxEvents
        
        if ($FilterExpression) {
            $events = $events | Where-Object { $_.Message -like "*$FilterExpression*" }
        }
        
        return $events | ForEach-Object {
            [PSCustomObject]@{
                'TimeCreated' = $_.TimeCreated
                'EventID' = $_.Id
                'UserName' = $_.Properties[5].Value
                'Workstation' = $_.Properties[2].Value
                'Message' = $_.Message
            }
        }
    }
    catch {
        Write-Warning "Error retrieving PowerShell operational logs: $($_.Exception.Message)"
        return $null
    }
}

function Get-ChkdskResults {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$OutputFile
    )
    
    try {
        $events = Get-WinEvent -FilterHashtable @{
            'LogName' = 'Application'
            'ID' = 1001
        } | Where-Object { $_.ProviderName -match 'wininit' }
        
        $results = $events | ForEach-Object {
            [PSCustomObject]@{
                'TimeCreated' = $_.TimeCreated
                'Message' = $_.Message
            }
        }
        
        if ($OutputFile) {
            $results | Format-List | Out-File -FilePath $OutputFile
        }
        
        return $results
    }
    catch {
        Write-Warning "Error retrieving chkdsk results: $($_.Exception.Message)"
        return $null
    }
}

function Export-EventLogs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogName,
        
        [Parameter(Mandatory)]
        [string]$OutputPath,
        
        [Parameter()]
        [datetime]$StartTime,
        
        [Parameter()]
        [datetime]$EndTime,
        
        [Parameter()]
        [int]$MaxEvents = 1000,
        
        [Parameter()]
        [ValidateSet('CSV', 'XML', 'JSON')]
        [string]$Format = 'CSV'
    )
    
    $filterHash = @{
        'LogName' = $LogName
    }
    
    if ($StartTime) { $filterHash['StartTime'] = $StartTime }
    if ($EndTime) { $filterHash['EndTime'] = $EndTime }
    
    try {
        $events = Get-WinEvent -FilterHashtable $filterHash -MaxEvents $MaxEvents
        
        switch ($Format) {
            'CSV' {
                $events | Export-Csv -Path $OutputPath -NoTypeInformation
            }
            'XML' {
                $events | Export-Clixml -Path $OutputPath
            }
            'JSON' {
                $events | ConvertTo-Json | Set-Content -Path $OutputPath
            }
        }
        
        Write-Output "Successfully exported $($events.Count) events to $OutputPath"
    }
    catch {
        Write-Warning "Error exporting event logs: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function @(
    'Get-SystemEventLogs',
    'Get-SecurityLogonEvents',
    'Get-SystemShutdownEvents',
    'Get-SystemRebootEvents',
    'Get-PowerShellOperationalLogs',
    'Get-ChkdskResults',
    'Export-EventLogs',
    'Get-EventLogProvider',
    'Test-EventLogAccess'
) 