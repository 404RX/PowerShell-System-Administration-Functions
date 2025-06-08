# UserSessionManagement Module
# Provides functions for managing user sessions, logins, and related operations
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
    Gets information about active user sessions on a local or remote computer.

.DESCRIPTION
    Retrieves detailed information about user sessions, including logon type, start time,
    and session ID. Can filter by username and provide basic or detailed output.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.PARAMETER Username
    Optional. Filter sessions by username.

.PARAMETER Detailed
    Optional. When specified, returns additional session information including
    authentication package and logon server.

.EXAMPLE
    Get-UserSessions
    Gets basic information about all active user sessions on the local computer.

.EXAMPLE
    Get-UserSessions -ComputerName "Server01" -Detailed
    Gets detailed information about all active user sessions on Server01.

.EXAMPLE
    Get-UserSessions -Username "JohnDoe" -Detailed
    Gets detailed information about active sessions for user JohnDoe on the local computer.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing session information.

.NOTES
    Requires administrative privileges for remote computer access.
    Logon types 2 (Interactive) and 10 (RemoteInteractive) are considered user sessions.
#>
function Get-UserSessions {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter()]
        [string]$Username,
        
        [Parameter()]
        [switch]$Detailed
    )
    
    try {
        $sessions = Get-CimInstance -ClassName Win32_LogonSession -ComputerName $ComputerName
        
        if ($Username) {
            $sessions = $sessions | Where-Object { 
                $_.LogonType -in @(2, 10) -and 
                (Get-CimInstance -ClassName Win32_LoggedOnUser -ComputerName $ComputerName |
                 Where-Object { $_.Antecedent -like "*$Username*" }).Dependent -contains $_.LogonId
            }
        }
        
        if ($Detailed) {
            return $sessions | ForEach-Object {
                $session = $_
                $user = Get-CimInstance -ClassName Win32_LoggedOnUser -ComputerName $ComputerName |
                        Where-Object { $_.Dependent -eq $session.LogonId } |
                        Select-Object -First 1
                
                [PSCustomObject]@{
                    'LogonId' = $session.LogonId
                    'Username' = if ($user) { $user.Antecedent -replace '.*Name="([^"]+)".*', '$1' } else { 'Unknown' }
                    'LogonType' = switch ($session.LogonType) {
                        2 { 'Interactive' }
                        3 { 'Network' }
                        4 { 'Batch' }
                        5 { 'Service' }
                        7 { 'Unlock' }
                        8 { 'NetworkCleartext' }
                        9 { 'NewCredentials' }
                        10 { 'RemoteInteractive' }
                        11 { 'CachedInteractive' }
                        default { "Unknown ($($session.LogonType))" }
                    }
                    'StartTime' = $session.StartTime
                    'AuthenticationPackage' = $session.AuthenticationPackage
                    'LogonServer' = $session.LogonServer
                    'SessionId' = (Get-CimInstance -ClassName Win32_Process -ComputerName $ComputerName |
                                 Where-Object { $_.SessionId -ne 0 } |
                                 Group-Object SessionId |
                                 Where-Object { $_.Group[0].LogonId -eq $session.LogonId }).Name
                }
            }
        }
        else {
            return $sessions | ForEach-Object {
                $session = $_
                $user = Get-CimInstance -ClassName Win32_LoggedOnUser -ComputerName $ComputerName |
                        Where-Object { $_.Dependent -eq $session.LogonId } |
                        Select-Object -First 1
                
                [PSCustomObject]@{
                    'Username' = if ($user) { $user.Antecedent -replace '.*Name="([^"]+)".*', '$1' } else { 'Unknown' }
                    'LogonType' = switch ($session.LogonType) {
                        2 { 'Interactive' }
                        10 { 'RemoteInteractive' }
                        default { "Other" }
                    }
                    'StartTime' = $session.StartTime
                    'SessionId' = (Get-CimInstance -ClassName Win32_Process -ComputerName $ComputerName |
                                 Where-Object { $_.SessionId -ne 0 } |
                                 Group-Object SessionId |
                                 Where-Object { $_.Group[0].LogonId -eq $session.LogonId }).Name
                }
            }
        }
    }
    catch {
        Write-Warning "Error getting user sessions: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Disconnects user sessions from a local or remote computer.

.DESCRIPTION
    Allows disconnection of user sessions either by username or session ID.
    Can perform forced disconnection if necessary.

.PARAMETER ComputerName
    The name of the computer to target. Defaults to the local computer.

.PARAMETER Username
    The username whose sessions should be disconnected.
    Cannot be used with SessionId parameter.

.PARAMETER SessionId
    The specific session ID to disconnect.
    Cannot be used with Username parameter.

.PARAMETER Force
    Optional. When specified, forces the session disconnection without user confirmation.

.EXAMPLE
    Disconnect-UserSession -Username "JohnDoe"
    Disconnects all sessions for user JohnDoe on the local computer.

.EXAMPLE
    Disconnect-UserSession -ComputerName "Server01" -SessionId 2 -Force
    Forces disconnection of session ID 2 on Server01.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns an object containing the operation result.

.NOTES
    Requires administrative privileges.
    Use with caution, especially with the Force parameter.
#>
function Disconnect-UserSession {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Mandatory, ParameterSetName = 'ByUsername')]
        [string]$Username,
        
        [Parameter(Mandatory, ParameterSetName = 'BySessionId')]
        [int]$SessionId,
        
        [Parameter()]
        [switch]$Force
    )
    
    try {
        if ($Username) {
            $sessions = Get-UserSessions -ComputerName $ComputerName -Username $Username
            if (-not $sessions) {
                throw "No active sessions found for user '$Username'"
            }
            $sessionIds = $sessions.SessionId | Where-Object { $_ -ne $null }
        }
        else {
            $sessionIds = @($SessionId)
        }
        
        foreach ($id in $sessionIds) {
            if ($Force) {
                $result = Invoke-CimMethod -ClassName Win32_OperatingSystem -MethodName Win32Shutdown -Arguments @{
                    Flags = 4  # Logoff
                    Reserved = 0
                } -ComputerName $ComputerName
                
                if ($result.ReturnValue -ne 0) {
                    throw "Failed to force logoff session $id. Return code: $($result.ReturnValue)"
                }
            }
            else {
                $result = Invoke-CimMethod -ClassName Win32_OperatingSystem -MethodName Win32Shutdown -Arguments @{
                    Flags = 0  # Logoff
                    Reserved = 0
                } -ComputerName $ComputerName
                
                if ($result.ReturnValue -ne 0) {
                    throw "Failed to logoff session $id. Return code: $($result.ReturnValue)"
                }
            }
        }
        
        return [PSCustomObject]@{
            'Success' = $true
            'SessionsDisconnected' = $sessionIds.Count
            'ComputerName' = $ComputerName
        }
    }
    catch {
        Write-Warning "Error disconnecting user session: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves successful logon history from the Security event log.

.DESCRIPTION
    Gets information about successful user logons, including logon type,
    workstation name, and IP address. Can filter by username and time period.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.PARAMETER Username
    Optional. Filter logons by username.

.PARAMETER Days
    Optional. Number of days to look back for logon events. Defaults to 30 days.

.EXAMPLE
    Get-LastLogon
    Gets all successful logons in the last 30 days on the local computer.

.EXAMPLE
    Get-LastLogon -Username "JohnDoe" -Days 7
    Gets successful logons for user JohnDoe in the last 7 days.

.EXAMPLE
    Get-LastLogon -ComputerName "Server01" -Days 90
    Gets all successful logons in the last 90 days on Server01.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing logon information.

.NOTES
    Requires administrative privileges for remote computer access.
    Requires Security event log access.
#>
function Get-LastLogon {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter()]
        [string]$Username,
        
        [Parameter()]
        [int]$Days = 30
    )
    
    try {
        $cutoffDate = (Get-Date).AddDays(-$Days)
        
        $events = Get-WinEvent -FilterHashtable @{
            LogName = 'Security'
            ID = 4624  # Successful logon
            StartTime = $cutoffDate
        } -ComputerName $ComputerName -ErrorAction SilentlyContinue
        
        if ($Username) {
            $events = $events | Where-Object { 
                $_.Properties[5].Value -like "*$Username*" -or 
                $_.Properties[1].Value -like "*$Username*"
            }
        }
        
        return $events | ForEach-Object {
            [PSCustomObject]@{
                'Username' = $_.Properties[5].Value
                'Domain' = $_.Properties[6].Value
                'LogonType' = switch ($_.Properties[10].Value) {
                    2 { 'Interactive' }
                    3 { 'Network' }
                    4 { 'Batch' }
                    5 { 'Service' }
                    7 { 'Unlock' }
                    8 { 'NetworkCleartext' }
                    9 { 'NewCredentials' }
                    10 { 'RemoteInteractive' }
                    11 { 'CachedInteractive' }
                    default { "Unknown ($($_.Properties[10].Value))" }
                }
                'LogonTime' = $_.TimeCreated
                'WorkstationName' = $_.Properties[13].Value
                'IPAddress' = $_.Properties[18].Value
            }
        } | Sort-Object -Property LogonTime -Descending
    }
    catch {
        Write-Warning "Error getting last logon information: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves failed logon attempts from the Security event log.

.DESCRIPTION
    Gets information about failed logon attempts, including failure reason,
    workstation name, and IP address. Can filter by username and time period.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.PARAMETER Username
    Optional. Filter failed logons by username.

.PARAMETER Hours
    Optional. Number of hours to look back for failed logon events. Defaults to 24 hours.

.EXAMPLE
    Get-FailedLogons
    Gets all failed logon attempts in the last 24 hours on the local computer.

.EXAMPLE
    Get-FailedLogons -Username "JohnDoe" -Hours 48
    Gets failed logon attempts for user JohnDoe in the last 48 hours.

.EXAMPLE
    Get-FailedLogons -ComputerName "Server01"
    Gets all failed logon attempts in the last 24 hours on Server01.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing failed logon information.

.NOTES
    Requires administrative privileges for remote computer access.
    Requires Security event log access.
    Failure reasons are translated from Windows error codes to human-readable messages.
#>
function Get-FailedLogons {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter()]
        [string]$Username,
        
        [Parameter()]
        [int]$Hours = 24
    )
    
    try {
        $cutoffDate = (Get-Date).AddHours(-$Hours)
        
        $events = Get-WinEvent -FilterHashtable @{
            LogName = 'Security'
            ID = 4625  # Failed logon
            StartTime = $cutoffDate
        } -ComputerName $ComputerName -ErrorAction SilentlyContinue
        
        if ($Username) {
            $events = $events | Where-Object { 
                $_.Properties[5].Value -like "*$Username*" -or 
                $_.Properties[1].Value -like "*$Username*"
            }
        }
        
        return $events | ForEach-Object {
            [PSCustomObject]@{
                'Username' = $_.Properties[5].Value
                'Domain' = $_.Properties[6].Value
                'FailureReason' = switch ($_.Properties[8].Value) {
                    0xC0000064 { 'Unknown username or bad password' }
                    0xC000006A { 'Bad password' }
                    0xC000006C { 'Password expired' }
                    0xC000006D { 'Account disabled' }
                    0xC000006E { 'Account locked out' }
                    0xC000006F { 'Account expired' }
                    0xC0000070 { 'Logon type not granted' }
                    0xC0000071 { 'Account restricted' }
                    0xC0000072 { 'Time restriction' }
                    default { "Unknown ($($_.Properties[8].Value))" }
                }
                'FailureTime' = $_.TimeCreated
                'WorkstationName' = $_.Properties[13].Value
                'IPAddress' = $_.Properties[19].Value
            }
        } | Sort-Object -Property FailureTime -Descending
    }
    catch {
        Write-Warning "Error getting failed logon information: $($_.Exception.Message)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves information about locked user accounts.

.DESCRIPTION
    Gets detailed information about locked user accounts, including account status,
    password settings, and account properties. Can filter by username.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.PARAMETER Username
    Optional. Filter locked accounts by username.

.EXAMPLE
    Get-LockedAccounts
    Gets all locked accounts on the local computer.

.EXAMPLE
    Get-LockedAccounts -Username "JohnDoe"
    Gets locked account information for user JohnDoe.

.EXAMPLE
    Get-LockedAccounts -ComputerName "Server01"
    Gets all locked accounts on Server01.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    Returns custom objects containing account information.

.NOTES
    Requires administrative privileges for remote computer access.
    Works with both local and domain accounts.
#>
function Get-LockedAccounts {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter()]
        [string]$Username
    )
    
    try {
        $accounts = Get-CimInstance -ClassName Win32_UserAccount -ComputerName $ComputerName |
                   Where-Object { $_.Lockout -eq $true }
        
        if ($Username) {
            $accounts = $accounts | Where-Object { $_.Name -like "*$Username*" }
        }
        
        return $accounts | ForEach-Object {
            [PSCustomObject]@{
                'Username' = $_.Name
                'Domain' = $_.Domain
                'FullName' = $_.FullName
                'Description' = $_.Description
                'Disabled' = $_.Disabled
                'Lockout' = $_.Lockout
                'PasswordRequired' = $_.PasswordRequired
                'PasswordChangeable' = $_.PasswordChangeable
                'PasswordExpires' = $_.PasswordExpires
            }
        }
    }
    catch {
        Write-Warning "Error getting locked accounts: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-UserSessions',
    'Disconnect-UserSession',
    'Get-LastLogon',
    'Get-FailedLogons',
    'Get-LockedAccounts'
) 