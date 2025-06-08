# ActiveDirectoryManagement Module
# Provides functions for managing Active Directory operations
# Supports Windows 10/11 and PowerShell 5.1+

# Import required modules
Import-Module Common
Import-Module ActiveDirectory

# Module compatibility requirements
$script:ModuleRequirements = @{
    MinimumOSVersion = "10.0.17763"  # Windows 10 1809/Server 2019
    ServerOnly = $true  # AD operations typically require Server OS
    RequiredModules = @('ActiveDirectory')
    RequiredFeatures = @('RSAT-AD-PowerShell')
}

# Check module compatibility on import
$compatibility = Test-ModuleCompatibility -ModuleName "ActiveDirectoryManagement" -Requirements $script:ModuleRequirements
if (-not $compatibility.IsCompatible) {
    Write-Warning "ActiveDirectoryManagement module may not function correctly on this system. See logs for details."
}

function Test-ADFunctionCompatibility {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FunctionName,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$AdditionalRequirements = @{}
    )
    
    try {
        # Merge module requirements with function-specific requirements
        $requirements = $script:ModuleRequirements.Clone()
        foreach ($key in $AdditionalRequirements.Keys) {
            $requirements[$key] = $AdditionalRequirements[$key]
        }
        
        $compatibility = Test-ModuleCompatibility -ModuleName "ActiveDirectoryManagement.$FunctionName" -Requirements $requirements
        return $compatibility.IsCompatible
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to check function compatibility: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADUserAccountInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Properties = @(
            'Name',
            'SamAccountName',
            'DisplayName',
            'Enabled',
            'LastLogonDate',
            'PasswordLastSet',
            'Description',
            'Department',
            'Title',
            'Manager',
            'MemberOf'
        ),
        
        [Parameter(Mandatory=$false)]
        [string]$Filter,
        
        [Parameter(Mandatory=$false)]
        [string]$SearchBase,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADUserAccountInfo")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving AD user account information" -Level Info
        
        $params = @{
            Properties = $Properties
            ErrorAction = 'Stop'
        }
        
        if ($Identity) {
            $params['Identity'] = $Identity
        }
        elseif ($Filter) {
            $params['Filter'] = $Filter
        }
        else {
            $params['Filter'] = "ObjectClass -eq 'user'"
        }
        
        if ($SearchBase) {
            $params['SearchBase'] = $SearchBase
        }
        
        $users = Get-ADUser @params
        
        $results = $users | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                SamAccountName = $_.SamAccountName
                DisplayName = $_.DisplayName
                Enabled = $_.Enabled
                LastLogonDate = $_.LastLogonDate
                PasswordLastSet = if ($_.PasswordLastSet) { [DateTime]::FromFileTime($_.PasswordLastSet) } else { $null }
                Description = $_.Description
                Department = $_.Department
                Title = $_.Title
                Manager = $_.Manager
                MemberOf = ($_.MemberOf | ForEach-Object { (Get-ADGroup $_).Name }) -join ';'
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved account information for $($results.Count) users" -Level Info
        return $results | Sort-Object -Property Name
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve user account information: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADInactiveUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$Days = 90,
        
        [Parameter(Mandatory=$false)]
        [string]$SearchBase,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeDisabled,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADInactiveUsers")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving inactive users (inactive for $Days days)" -Level Info
        
        $cutoffDate = (Get-Date).AddDays(-$Days)
        $filter = "LastLogonDate -lt '$cutoffDate'"
        
        if (-not $IncludeDisabled) {
            $filter += " -and Enabled -eq `$true"
        }
        
        $params = @{
            Filter = $filter
            Properties = @(
                'Name',
                'SamAccountName',
                'Enabled',
                'LastLogonDate',
                'PasswordLastSet',
                'Description',
                'Department',
                'Title'
            )
            ErrorAction = 'Stop'
        }
        
        if ($SearchBase) {
            $params['SearchBase'] = $SearchBase
        }
        
        $users = Get-ADUser @params
        
        $results = $users | ForEach-Object {
            $lastLogon = if ($_.LastLogonDate) { $_.LastLogonDate } else { "Never" }
            $daysInactive = if ($lastLogon -ne "Never") { [math]::Round((Get-Date - $lastLogon).TotalDays) } else { $null }
            
            [PSCustomObject]@{
                Name = $_.Name
                SamAccountName = $_.SamAccountName
                Enabled = $_.Enabled
                LastLogonDate = $lastLogon
                DaysInactive = $daysInactive
                PasswordLastSet = if ($_.PasswordLastSet) { [DateTime]::FromFileTime($_.PasswordLastSet) } else { $null }
                Description = $_.Description
                Department = $_.Department
                Title = $_.Title
                Status = switch ($true) {
                    ($daysInactive -gt $Days * 2) { 'Long Term Inactive' }
                    ($daysInactive -gt $Days) { 'Inactive' }
                    default { 'Active' }
                }
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Found $($results.Count) inactive users" -Level Info
        return $results | Sort-Object -Property DaysInactive -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve inactive users: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADUserLoginStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [switch]$Detailed,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADUserLoginStatus")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving user login status" -Level Info
        
        $params = @{
            Properties = @(
                'Name',
                'SamAccountName',
                'Enabled',
                'LastLogonDate',
                'LastLogon',
                'LogonCount',
                'Description'
            )
            ErrorAction = 'Stop'
        }
        
        if ($Identity) {
            $params['Identity'] = $Identity
        }
        else {
            $params['Filter'] = "ObjectClass -eq 'user'"
        }
        
        $users = Get-ADUser @params
        
        $results = @()
        
        foreach ($user in $users) {
            $loginInfo = @{
                Name = $user.Name
                SamAccountName = $user.SamAccountName
                Enabled = $user.Enabled
                LastLogonDate = $user.LastLogonDate
                LastLogon = if ($user.LastLogon) { [DateTime]::FromFileTime($user.LastLogon) } else { $null }
                LogonCount = $user.LogonCount
                Description = $user.Description
                Status = if ($user.Enabled) { 'Enabled' } else { 'Disabled' }
                CurrentLogin = $false
                LoginComputers = @()
            }
            
            if ($Detailed -and $ComputerName) {
                foreach ($computer in $ComputerName) {
                    try {
                        $sessions = Get-WmiObject -Class Win32_LogonSession -ComputerName $computer -ErrorAction Stop
                        $userSessions = $sessions | Where-Object { $_.LogonType -in (2, 10) } | ForEach-Object {
                            Get-WmiObject -Class Win32_LoggedOnUser -ComputerName $computer | 
                            Where-Object { $_.Antecedent -like "*$($user.SamAccountName)*" }
                        }
                        
                        if ($userSessions) {
                            $loginInfo.CurrentLogin = $true
                            $loginInfo.LoginComputers += $computer
                        }
                    } catch {
                        Write-LogMessage -Message "Failed to check login status on $computer : $_" -Level Warning
                    }
                }
            }
            
            $results += [PSCustomObject]$loginInfo
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved login status for $($results.Count) users" -Level Info
        return $results | Sort-Object -Property LastLogonDate -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve user login status: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADLockedOutUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$Days = 7,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeHistory,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADLockedOutUsers")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving locked out users" -Level Info
        
        $cutoffDate = (Get-Date).AddDays(-$Days)
        $lockedUsers = Get-ADUser -Filter "LockedOut -eq `$true" -Properties @(
            'Name',
            'SamAccountName',
            'Enabled',
            'LastLogonDate',
            'LockoutTime',
            'Description',
            'Department',
            'Title'
        ) -ErrorAction Stop
        
        $results = @()
        
        foreach ($user in $lockedUsers) {
            $lockoutTime = if ($user.LockoutTime) { [DateTime]::FromFileTime($user.LockoutTime) } else { $null }
            $lockoutDuration = if ($lockoutTime) { [math]::Round((Get-Date - $lockoutTime).TotalHours, 2) } else { $null }
            
            $userInfo = @{
                Name = $user.Name
                SamAccountName = $user.SamAccountName
                Enabled = $user.Enabled
                LastLogonDate = $user.LastLogonDate
                LockoutTime = $lockoutTime
                LockoutDuration = $lockoutDuration
                Description = $user.Description
                Department = $user.Department
                Title = $user.Title
                Status = if ($lockoutTime -gt $cutoffDate) { 'Recently Locked' } else { 'Locked' }
            }
            
            if ($IncludeHistory) {
                try {
                    $dc = Get-ADDomainController -Discover -Service "PrimaryDC" -ErrorAction Stop
                    $events = Get-WinEvent -ComputerName $dc.HostName -FilterHashtable @{
                        LogName = 'Security'
                        ID = 4740
                        StartTime = $cutoffDate
                    } -ErrorAction Stop | Where-Object {
                        $_.Properties[0].Value -eq $user.SamAccountName
                    }
                    
                    $userInfo.LockoutHistory = $events | ForEach-Object {
                        [PSCustomObject]@{
                            Time = $_.TimeCreated
                            Computer = $_.Properties[1].Value
                            Reason = $_.Properties[2].Value
                        }
                    }
                } catch {
                    Write-LogMessage -Message "Failed to retrieve lockout history: $_" -Level Warning
                    $userInfo.LockoutHistory = @()
                }
            }
            
            $results += [PSCustomObject]$userInfo
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Found $($results.Count) locked out users" -Level Info
        return $results | Sort-Object -Property LockoutTime -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve locked out users: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADPasswordStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [int]$ExpiringInDays = 0,
        
        [Parameter(Mandatory=$false)]
        [string]$SearchBase,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeDisabled,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADPasswordStatus")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving AD password status" -Level Info
        
        $params = @{
            Properties = @(
                'Name',
                'SamAccountName',
                'Enabled',
                'PasswordLastSet',
                'PasswordExpired',
                'PasswordNeverExpires',
                'LastLogonDate',
                'Description'
            )
            ErrorAction = 'Stop'
        }
        
        if ($Identity) {
            $params['Identity'] = $Identity
        }
        else {
            $filter = "Enabled -eq `$true"
            if ($IncludeDisabled) {
                $filter = "ObjectClass -eq 'user'"
            }
            
            if ($ExpiringInDays -gt 0) {
                $expiryDate = (Get-Date).AddDays($ExpiringInDays)
                $filter += " -and (PasswordLastSet -lt '$expiryDate')"
            }
            
            $params['Filter'] = $filter
        }
        
        if ($SearchBase) {
            $params['SearchBase'] = $SearchBase
        }
        
        $users = Get-ADUser @params
        
        $results = $users | ForEach-Object {
            $user = $_
            $passwordLastSet = if ($user.PasswordLastSet) { [DateTime]::FromFileTime($user.PasswordLastSet) } else { $null }
            $daysUntilExpiry = if ($passwordLastSet) { 
                $maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
                if ($maxPasswordAge -and -not $user.PasswordNeverExpires) {
                    $expiryDate = $passwordLastSet.AddDays($maxPasswordAge.TotalDays)
                    [math]::Round(($expiryDate - (Get-Date)).TotalDays)
                } else { $null }
            } else { $null }
            
            [PSCustomObject]@{
                Name = $user.Name
                SamAccountName = $user.SamAccountName
                Enabled = $user.Enabled
                PasswordLastSet = $passwordLastSet
                DaysUntilExpiry = $daysUntilExpiry
                PasswordExpired = $user.PasswordExpired
                PasswordNeverExpires = $user.PasswordNeverExpires
                LastLogonDate = $user.LastLogonDate
                Description = $user.Description
                Status = switch ($true) {
                    $user.PasswordExpired { 'Expired' }
                    $user.PasswordNeverExpires { 'Never Expires' }
                    ($daysUntilExpiry -le 0) { 'Expired' }
                    ($daysUntilExpiry -le 7) { 'Expiring Soon' }
                    default { 'Valid' }
                }
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved password status for $($results.Count) users" -Level Info
        return $results | Sort-Object -Property PasswordLastSet -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve password status: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADGroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$GroupName,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Properties = @(
            'Name',
            'SamAccountName',
            'DisplayName',
            'Enabled',
            'LastLogonDate',
            'Description',
            'Department',
            'Title'
        ),
        
        [Parameter(Mandatory=$false)]
        [switch]$Recursive,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeNestedGroups,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADGroupMembers")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving members of group '$GroupName'" -Level Info
        
        $group = Get-ADGroup -Identity $GroupName -ErrorAction Stop
        $members = @()
        
        if ($Recursive) {
            $members = Get-ADGroupMember -Identity $GroupName -Recursive -ErrorAction Stop
        } else {
            $members = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop
        }
        
        $results = @()
        
        foreach ($member in $members) {
            if ($member.objectClass -eq 'user') {
                $user = Get-ADUser -Identity $member.SamAccountName -Properties $Properties -ErrorAction Stop
                $results += [PSCustomObject]@{
                    Name = $user.Name
                    SamAccountName = $user.SamAccountName
                    DisplayName = $user.DisplayName
                    Enabled = $user.Enabled
                    LastLogonDate = $user.LastLogonDate
                    Description = $user.Description
                    Department = $user.Department
                    Title = $user.Title
                    ObjectClass = 'User'
                    MemberOf = $GroupName
                }
            }
            elseif ($IncludeNestedGroups -and $member.objectClass -eq 'group') {
                $nestedGroup = Get-ADGroup -Identity $member.SamAccountName -Properties Description -ErrorAction Stop
                $results += [PSCustomObject]@{
                    Name = $nestedGroup.Name
                    SamAccountName = $nestedGroup.SamAccountName
                    Description = $nestedGroup.Description
                    ObjectClass = 'Group'
                    MemberOf = $GroupName
                }
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved $($results.Count) members from group '$GroupName'" -Level Info
        return $results | Sort-Object -Property ObjectClass, Name
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve group members: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADComputersInOU {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$SearchBase,
        
        [Parameter(Mandatory=$false)]
        [string]$Filter,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Properties = @(
            'Name',
            'DNSHostName',
            'OperatingSystem',
            'OperatingSystemVersion',
            'LastLogonDate',
            'Description',
            'Location',
            'ManagedBy',
            'Created',
            'Modified'
        ),
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeDisabled,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADComputersInOU")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving computers in OU" -Level Info
        
        $params = @{
            Filter = "ObjectClass -eq 'computer'"
            Properties = $Properties
            ErrorAction = 'Stop'
        }
        
        if ($SearchBase) {
            $params['SearchBase'] = $SearchBase
        }
        
        if ($Filter) {
            $params['Filter'] = "($($params['Filter'])) -and ($Filter)"
        }
        
        if (-not $IncludeDisabled) {
            $params['Filter'] = "($($params['Filter'])) -and (Enabled -eq `$true)"
        }
        
        $computers = Get-ADComputer @params
        
        $results = $computers | ForEach-Object {
            $computer = $_
            $lastLogon = if ($computer.LastLogonDate) { $computer.LastLogonDate } else { "Never" }
            $daysSinceLastLogon = if ($lastLogon -ne "Never") { [math]::Round((Get-Date - $lastLogon).TotalDays) } else { $null }
            
            [PSCustomObject]@{
                Name = $computer.Name
                DNSHostName = $computer.DNSHostName
                OperatingSystem = $computer.OperatingSystem
                OperatingSystemVersion = $computer.OperatingSystemVersion
                LastLogonDate = $lastLogon
                DaysSinceLastLogon = $daysSinceLastLogon
                Description = $computer.Description
                Location = $computer.Location
                ManagedBy = $computer.ManagedBy
                Created = $computer.Created
                Modified = $computer.Modified
                Status = switch ($true) {
                    ($daysSinceLastLogon -gt 90) { 'Long Term Inactive' }
                    ($daysSinceLastLogon -gt 30) { 'Inactive' }
                    ($daysSinceLastLogon -le 7) { 'Recently Active' }
                    default { 'Active' }
                }
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved $($results.Count) computers" -Level Info
        return $results | Sort-Object -Property LastLogonDate -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve computers: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADDeletedObjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$Days = 30,
        
        [Parameter(Mandatory=$false)]
        [string[]]$ObjectTypes = @('user', 'computer', 'group'),
        
        [Parameter(Mandatory=$false)]
        [string]$SearchBase,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility with additional requirements
    $additionalRequirements = @{
        RequiredFeatures = @('RSAT-AD-PowerShell', 'AD-Domain-Services')
        ServerOnly = $true  # Recycle bin operations require Server OS
    }
    
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADDeletedObjects" -AdditionalRequirements $additionalRequirements)) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving deleted AD objects" -Level Info
        
        $cutoffDate = (Get-Date).AddDays(-$Days)
        $results = @()
        
        foreach ($objectType in $ObjectTypes) {
            $params = @{
                Filter = "ObjectClass -eq '$objectType'"
                IncludeDeletedObjects = $true
                Properties = @(
                    'Name',
                    'ObjectClass',
                    'Deleted',
                    'LastKnownParent',
                    'whenChanged',
                    'whenCreated',
                    'Description'
                )
                ErrorAction = 'Stop'
            }
            
            if ($SearchBase) {
                $params['SearchBase'] = $SearchBase
            }
            
            $objects = Get-ADObject @params | Where-Object { $_.Deleted -and $_.whenChanged -gt $cutoffDate }
            
            foreach ($object in $objects) {
                $results += [PSCustomObject]@{
                    Name = $object.Name
                    ObjectClass = $object.ObjectClass
                    LastKnownParent = $object.LastKnownParent
                    DeletedDate = $object.whenChanged
                    CreatedDate = $object.whenCreated
                    Description = $object.Description
                    DaysSinceDeletion = [math]::Round((Get-Date - $object.whenChanged).TotalDays)
                    Status = switch ($true) {
                        ($object.whenChanged -gt (Get-Date).AddDays(-7)) { 'Recently Deleted' }
                        ($object.whenChanged -gt (Get-Date).AddDays(-30)) { 'Deleted' }
                        default { 'Long Term Deleted' }
                    }
                }
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved $($results.Count) deleted objects" -Level Info
        return $results | Sort-Object -Property DeletedDate -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve deleted objects: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Set-ADUserPassword {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [securestring]$NewPassword,
        
        [Parameter(Mandatory=$false)]
        [switch]$Reset,
        
        [Parameter(Mandatory=$false)]
        [switch]$RequireChange,
        
        [Parameter(Mandatory=$false)]
        [int]$PasswordLength = 16,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    
    # Check function compatibility with additional requirements
    $additionalRequirements = @{
        RequiredFeatures = @('RSAT-AD-PowerShell')
        ServerOnly = $false  # Can run on client with RSAT
        RequiredPermissions = @('Account Operators', 'Domain Admins')
    }
    
    if (-not (Test-ADFunctionCompatibility -FunctionName "Set-ADUserPassword" -AdditionalRequirements $additionalRequirements)) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Setting password for user $Identity" -Level Info
        
        # Verify user exists
        $user = Get-ADUser -Identity $Identity -ErrorAction Stop
        
        if ($Reset -and -not $NewPassword) {
            # Generate a secure random password
            $passwordChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?'
            $random = New-Object System.Random
            $password = -join (1..$PasswordLength | ForEach-Object { $passwordChars[$random.Next(0, $passwordChars.Length)] })
            $NewPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
            
            Write-LogMessage -Message "Generated new password for $Identity" -Level Info
        }
        
        if (-not $NewPassword) {
            throw "No password provided and Reset not specified"
        }
        
        $action = if ($Reset) { "Reset password" } else { "Change password" }
        if ($PSCmdlet.ShouldProcess($Identity, $action)) {
            Set-ADAccountPassword -Identity $Identity -NewPassword $NewPassword -Reset:$Reset -ErrorAction Stop
            
            if ($RequireChange) {
                Set-ADUser -Identity $Identity -ChangePasswordAtLogon $true -ErrorAction Stop
                Write-LogMessage -Message "Password change required at next logon for $Identity" -Level Info
            }
            
            if ($Reset) {
                Write-LogMessage -Message "Password reset successful for $Identity" -Level Info
                return [PSCustomObject]@{
                    Identity = $Identity
                    Action = "Password Reset"
                    RequireChange = $RequireChange
                    Status = "Success"
                }
            } else {
                Write-LogMessage -Message "Password change successful for $Identity" -Level Info
                return [PSCustomObject]@{
                    Identity = $Identity
                    Action = "Password Change"
                    RequireChange = $RequireChange
                    Status = "Success"
                }
            }
        }
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to set password: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADUserLoginHistory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [int]$Days = 30,
        
        [Parameter(Mandatory=$false)]
        [string]$DomainController,
        
        [Parameter(Mandatory=$false)]
        [switch]$Detailed,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADUserLoginHistory")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving login history for $Identity" -Level Info
        
        # Verify user exists
        $user = Get-ADUser -Identity $Identity -ErrorAction Stop
        
        $startTime = (Get-Date).AddDays(-$Days)
        $results = @()
        
        # Get domain controllers if not specified
        if (-not $DomainController) {
            $dcs = Get-ADDomainController -Filter * -ErrorAction Stop
        } else {
            $dcs = @(Get-ADDomainController -Identity $DomainController -ErrorAction Stop)
        }
        
        foreach ($dc in $dcs) {
            try {
                $events = Get-WinEvent -ComputerName $dc.HostName -FilterHashtable @{
                    LogName = 'Security'
                    ID = 4624  # Successful logon
                    StartTime = $startTime
                } -ErrorAction Stop | Where-Object {
                    $_.Properties[5].Value -eq $user.SamAccountName
                }
                
                foreach ($event in $events) {
                    $loginInfo = @{
                        Time = $event.TimeCreated
                        DomainController = $dc.HostName
                        User = $user.SamAccountName
                        LogonType = $event.Properties[10].Value
                        Workstation = $event.Properties[13].Value
                        IPAddress = $event.Properties[18].Value
                    }
                    
                    if ($Detailed) {
                        $loginInfo.Add('ProcessName', $event.Properties[9].Value)
                        $loginInfo.Add('AuthenticationPackage', $event.Properties[10].Value)
                        $loginInfo.Add('FailureReason', $event.Properties[8].Value)
                    }
                    
                    $results += [PSCustomObject]$loginInfo
                }
            } catch {
                Write-LogMessage -Message "Failed to get events from $($dc.HostName): $_" -Level Warning
            }
        }
        
        if ($ExportPath) {
            $results | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved $($results.Count) login events for $Identity" -Level Info
        return $results | Sort-Object -Property Time -Descending
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve login history: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADUserSID {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeHistory,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADUserSID")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving SID information for $Identity" -Level Info
        
        $user = Get-ADUser -Identity $Identity -Properties @(
            'Name',
            'SamAccountName',
            'SID',
            'ObjectSID',
            'SIDHistory',
            'Created',
            'Modified'
        ) -ErrorAction Stop
        
        $results = @{
            Name = $user.Name
            SamAccountName = $user.SamAccountName
            CurrentSID = $user.SID.Value
            Created = $user.Created
            Modified = $user.Modified
            SIDHistory = @()
        }
        
        if ($IncludeHistory -and $user.SIDHistory) {
            foreach ($sid in $user.SIDHistory) {
                try {
                    $sidAccount = Get-ADObject -Filter "ObjectSID -eq '$($sid.Value)'" -Properties Name, ObjectClass -ErrorAction Stop
                    $results.SIDHistory += [PSCustomObject]@{
                        SID = $sid.Value
                        Name = $sidAccount.Name
                        ObjectClass = $sidAccount.ObjectClass
                        Status = "Historical"
                    }
                } catch {
                    $results.SIDHistory += [PSCustomObject]@{
                        SID = $sid.Value
                        Name = "Unknown"
                        ObjectClass = "Unknown"
                        Status = "Orphaned"
                    }
                }
            }
        }
        
        $output = [PSCustomObject]$results
        
        if ($ExportPath) {
            $output | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved SID information for $Identity" -Level Info
        return $output
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve SID information: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Set-ADComputerDescription {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true)]
        [string]$Description,
        
        [Parameter(Mandatory=$false)]
        [switch]$Append,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Set-ADComputerDescription")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Setting description for computer $ComputerName" -Level Info
        
        $computer = Get-ADComputer -Identity $ComputerName -Properties Description -ErrorAction Stop
        
        $newDescription = if ($Append) {
            "$($computer.Description) | $Description"
        } else {
            $Description
        }
        
        if ($PSCmdlet.ShouldProcess($ComputerName, "Set description to '$newDescription'")) {
            Set-ADComputer -Identity $ComputerName -Description $newDescription -ErrorAction Stop
            
            $result = [PSCustomObject]@{
                ComputerName = $ComputerName
                OldDescription = $computer.Description
                NewDescription = $newDescription
                Modified = Get-Date
                Status = "Success"
            }
            
            if ($ExportPath) {
                $result | Export-Csv -Path $ExportPath -NoTypeInformation -Append
                Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
            }
            
            Write-LogMessage -Message "Updated description for $ComputerName" -Level Info
            return $result
        }
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to set computer description: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADPDCStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$IncludeEvents,
        
        [Parameter(Mandatory=$false)]
        [int[]]$EventID,
        
        [Parameter(Mandatory=$false)]
        [int]$Hours = 24,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility with additional requirements
    $additionalRequirements = @{
        RequiredFeatures = @('RSAT-AD-PowerShell')
        ServerOnly = $false  # Can run on client with RSAT
    }
    
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADPDCStatus" -AdditionalRequirements $additionalRequirements)) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving PDC status" -Level Info
        
        $pdc = Get-ADDomainController -Discover -Service "PrimaryDC" -ErrorAction Stop
        $startTime = (Get-Date).AddHours(-$Hours)
        
        $status = @{
            ComputerName = $pdc.HostName
            IPAddress = $pdc.IPv4Address
            Site = $pdc.Site
            OperatingSystem = $pdc.OperatingSystem
            OperatingSystemVersion = $pdc.OperatingSystemVersion
            LastUpdate = Get-Date
            Status = "Online"
            Events = @()
        }
        
        # Test connectivity
        try {
            $testConnection = Test-Connection -ComputerName $pdc.HostName -Count 1 -Quiet
            $status.Status = if ($testConnection) { "Online" } else { "Offline" }
        } catch {
            $status.Status = "Error"
            $status.Error = $_.Exception.Message
        }
        
        if ($IncludeEvents) {
            try {
                $filter = @{
                    LogName = 'System'
                    StartTime = $startTime
                }
                
                if ($EventID) {
                    $filter['ID'] = $EventID
                }
                
                $events = Get-WinEvent -ComputerName $pdc.HostName -FilterHashtable $filter -ErrorAction Stop
                
                foreach ($event in $events) {
                    $status.Events += [PSCustomObject]@{
                        Time = $event.TimeCreated
                        ID = $event.Id
                        Level = $event.LevelDisplayName
                        Source = $event.ProviderName
                        Message = $event.Message
                    }
                }
            } catch {
                Write-LogMessage -Message "Failed to get events from PDC: $_" -Level Warning
            }
        }
        
        $result = [PSCustomObject]$status
        
        if ($ExportPath) {
            $result | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved PDC status from $($pdc.HostName)" -Level Info
        return $result
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve PDC status: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

function Get-ADUserLastLogon {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [switch]$IncludeDCInfo,
        
        [Parameter(Mandatory=$false)]
        [string]$ExportPath
    )
    
    # Check function compatibility
    if (-not (Test-ADFunctionCompatibility -FunctionName "Get-ADUserLastLogon")) {
        throw "This function is not compatible with the current system configuration. See logs for details."
    }
    
    try {
        Write-LogMessage -Message "Retrieving last logon information for $Identity" -Level Info
        
        $user = Get-ADUser -Identity $Identity -ErrorAction Stop
        $dcs = Get-ADDomainController -Filter * -ErrorAction Stop
        $results = @()
        
        foreach ($dc in $dcs) {
            try {
                $userDC = Get-ADUser -Identity $Identity -Server $dc.HostName -Properties LastLogon -ErrorAction Stop
                
                $logonInfo = @{
                    DomainController = $dc.HostName
                    LastLogon = if ($userDC.LastLogon) { [DateTime]::FromFileTime($userDC.LastLogon) } else { $null }
                    User = $user.SamAccountName
                }
                
                if ($IncludeDCInfo) {
                    $logonInfo.Add('Site', $dc.Site)
                    $logonInfo.Add('IPAddress', $dc.IPv4Address)
                    $logonInfo.Add('OperatingSystem', $dc.OperatingSystem)
                }
                
                $results += [PSCustomObject]$logonInfo
            } catch {
                Write-LogMessage -Message "Failed to get last logon from $($dc.HostName): $_" -Level Warning
            }
        }
        
        # Get the most recent logon across all DCs
        $latestLogon = $results | Where-Object { $_.LastLogon } | Sort-Object -Property LastLogon -Descending | Select-Object -First 1
        
        $output = [PSCustomObject]@{
            User = $user.SamAccountName
            LatestLogon = $latestLogon.LastLogon
            LatestLogonDC = $latestLogon.DomainController
            DaysSinceLastLogon = if ($latestLogon.LastLogon) { [math]::Round((Get-Date - $latestLogon.LastLogon).TotalDays) } else { $null }
            Status = switch ($true) {
                ($null -eq $latestLogon.LastLogon) { 'Never Logged On' }
                ($latestLogon.LastLogon -gt (Get-Date).AddDays(-7)) { 'Recently Active' }
                ($latestLogon.LastLogon -gt (Get-Date).AddDays(-30)) { 'Active' }
                ($latestLogon.LastLogon -gt (Get-Date).AddDays(-90)) { 'Inactive' }
                default { 'Long Term Inactive' }
            }
            DomainControllers = if ($IncludeDCInfo) { $results } else { $null }
        }
        
        if ($ExportPath) {
            $output | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-LogMessage -Message "Exported results to $ExportPath" -Level Info
        }
        
        Write-LogMessage -Message "Retrieved last logon information for $Identity" -Level Info
        return $output
        
    } catch {
        $errorDetails = Get-ErrorDetails -ErrorRecord $_
        Write-LogMessage -Message "Failed to retrieve last logon information: $($errorDetails.ExceptionMessage)" -Level Error
        throw
    }
}

# Export all functions
Export-ModuleMember -Function * 