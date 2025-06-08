# Active Directory Management Module

A PowerShell module for managing Active Directory users, groups, and related operations.

## Features

- User account management and reporting
- Group membership management
- Password status monitoring
- Inactive user detection
- Login status tracking
- Account lockout management

## Compatibility Requirements

### Operating System Requirements
- Windows Server 2019 (10.0.17763) or later
- Windows 10 1809 (10.0.17763) or later with RSAT tools
- Note: Some functions require a Server OS due to Active Directory dependencies

### PowerShell Requirements
- PowerShell 5.1 or later
- PowerShell Core 7.0 or later (Desktop edition)
- Required PowerShell modules:
  - Common (version 1.0.0 or later)
  - ActiveDirectory (version 1.0.0.0 or later)

### Windows Features
- RSAT-AD-PowerShell (for client operating systems)
- Active Directory Domain Services (for domain controllers)

### Permissions
- Domain Users group membership (minimum)
- Additional permissions may be required for specific functions:
  - User account management: Account Operators or Domain Admins
  - Group management: Group Policy Creator Owners or Domain Admins
  - Password management: Account Operators or Domain Admins
  - Computer management: Domain Computers or Domain Admins

## Installation

1. Ensure all compatibility requirements are met
2. Install required Windows features:
   ```powershell
   # For Windows 10/11 clients
   Add-WindowsFeature RSAT-AD-PowerShell
   
   # For Windows Server
   Add-WindowsFeature AD-Domain-Services
   ```

3. Install required PowerShell modules:
   ```powershell
   Install-Module -Name Common -RequiredVersion 1.0.0
   Install-Module -Name ActiveDirectory -RequiredVersion 1.0.0.0
   ```

4. Copy the module to your PowerShell modules directory:
   ```powershell
   Copy-Item -Path ".\ActiveDirectoryManagement" -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\" -Recurse
   ```

## Usage

### Basic Usage
```powershell
# Import the module
Import-Module ActiveDirectoryManagement

# Get user account information
Get-ADUserAccountInfo -Identity "username"

# Get group members
Get-ADGroupMembers -GroupName "GroupName" -Recursive

# Check password status
Get-ADPasswordStatus -ExpiringInDays 30
```

### Function-Specific Requirements

#### Get-ADUserAccountInfo
- Requires: Domain Users group membership
- Optional: Account Operators for detailed information
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

#### Get-ADInactiveUsers
- Requires: Domain Users group membership
- Optional: Account Operators for detailed information
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

#### Get-ADUserLoginStatus
- Requires: Domain Users group membership
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

#### Get-ADLockedOutUsers
- Requires: Account Operators or Domain Admins
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

#### Get-ADPasswordStatus
- Requires: Account Operators or Domain Admins
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

#### Get-ADGroupMembers
- Requires: Domain Users group membership
- Optional: Group Policy Creator Owners for nested group information
- Compatible with: Windows Server 2019+, Windows 10 1809+ (with RSAT)

## Troubleshooting

### Common Issues

1. **Module not found**
   - Ensure the module is in the correct PowerShell modules directory
   - Verify the module manifest (ActiveDirectoryManagement.psd1) exists
   - Check PowerShell module path: `$env:PSModulePath`

2. **Active Directory cmdlets not available**
   - Verify RSAT-AD-PowerShell is installed on client systems
   - Check Active Directory Domain Services on server systems
   - Ensure running as administrator when installing features

3. **Permission denied errors**
   - Verify user has required group memberships
   - Check function-specific permission requirements
   - Run PowerShell as administrator if needed

4. **Compatibility warnings**
   - Check OS version meets minimum requirements
   - Verify PowerShell version is 5.1 or later
   - Ensure all required modules are installed

### Logging

The module uses the Common module's logging functionality. Logs can be found in:
- Windows Event Log (Application)
- Module-specific log file (if configured)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under your organization's license agreement.

## Support

For support, please contact your organization's IT support team or raise an issue in the repository. 