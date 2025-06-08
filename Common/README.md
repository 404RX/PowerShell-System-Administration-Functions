# Common PowerShell Module

This module provides common functions used across all other modules in the organization's PowerShell toolkit.

## Requirements

- PowerShell 5.1 or later
- Windows 10/Server 2016 or later

## Functions

### Write-LogMessage
Writes messages to both console and log file with different severity levels.

```powershell
Write-LogMessage -Message "Operation completed" -Level Info
Write-LogMessage -Message "Warning condition detected" -Level Warning
Write-LogMessage -Message "Critical error occurred" -Level Error
```

### Test-Administrator
Checks if the current session is running with administrator privileges.

```powershell
if (Test-Administrator) {
    # Run administrative tasks
}
```

### Get-ErrorDetails
Retrieves detailed information about an error record.

```powershell
try {
    # Some operation
} catch {
    $errorDetails = Get-ErrorDetails -ErrorRecord $_
    # Process error details
}
```

### Test-RequiredModule
Verifies if a required module is installed and meets version requirements.

```powershell
if (Test-RequiredModule -ModuleName "ActiveDirectory" -MinimumVersion "1.0.0") {
    # Module is available and meets version requirement
}
```

## Usage

Import the module in your scripts:

```powershell
Import-Module .\Common
```

## Logging

By default, logs are written to `.\logs\YYYY-MM-DD.log`. You can specify a different log file path when calling `Write-LogMessage`.

## Error Handling

The module provides standardized error handling and logging capabilities. Always use `Write-LogMessage` for logging and `Get-ErrorDetails` for error information.

## Contributing

When adding new common functions:
1. Add the function to Common.psm1
2. Update the FunctionsToExport list in Common.psd1
3. Update this README with function documentation
4. Add appropriate error handling and logging 