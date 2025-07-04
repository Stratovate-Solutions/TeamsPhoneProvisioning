# Code Review Checklist

Use this checklist when reviewing PowerShell scripts, especially for Microsoft Teams automation.

## ✅ Parameter Validation
- [ ] Parameters with defaults should not be marked as `[Parameter(Mandatory)]`
- [ ] Numeric parameters have appropriate `[ValidateRange()]` attributes
- [ ] File path parameters use `[ValidateScript({Test-Path $_})]`
- [ ] String parameters that must follow patterns have `[ValidatePattern()]`
- [ ] All mandatory parameters are properly documented

## ✅ Error Handling
- [ ] Use `Write-Error` with `-ErrorAction Stop` instead of `Throw`
- [ ] Error messages are descriptive and actionable
- [ ] Errors are logged to appropriate locations (not hardcoded paths)
- [ ] Sensitive information is not exposed in error messages
- [ ] Retry logic is implemented for transient failures

## ✅ Function Design
- [ ] Functions don't rely on parent scope variables
- [ ] All required parameters are explicitly passed to functions
- [ ] Functions have proper `[CmdletBinding()]` attributes
- [ ] Functions support `SupportsShouldProcess` when making changes
- [ ] Functions have comprehensive help documentation

## ✅ Security
- [ ] Credentials are handled securely (not hardcoded)
- [ ] Script supports non-interactive authentication for automation
- [ ] Sensitive data is not logged or exposed
- [ ] Input validation prevents injection attacks
- [ ] Least privilege principle is followed

## ✅ Performance
- [ ] Large datasets are processed in batches or streams
- [ ] Parallel processing is used appropriately
- [ ] Progress reporting is provided for long-running operations
- [ ] Resource usage is monitored and controlled
- [ ] Unnecessary operations are avoided

## ✅ Code Organization
- [ ] Script has comprehensive header documentation
- [ ] Functions are defined before they're used
- [ ] Magic numbers and strings are defined as constants
- [ ] Code is logically organized into sections
- [ ] Version and requirements are clearly specified

## ✅ Testing
- [ ] Unit tests cover core functionality
- [ ] Parameter validation is tested
- [ ] Error scenarios are tested
- [ ] WhatIf mode is tested
- [ ] Tests use proper mocking for external dependencies

## ✅ Documentation
- [ ] Script purpose and usage are clearly documented
- [ ] All parameters are documented with examples
- [ ] Prerequisites and dependencies are listed
- [ ] Known limitations are documented
- [ ] Examples cover common use cases

## ✅ Maintenance
- [ ] Logging provides adequate troubleshooting information
- [ ] Configuration is externalized from code
- [ ] Script is compatible with target PowerShell versions
- [ ] Dependencies are clearly specified
- [ ] Update/upgrade path is considered

## Quick Validation Commands

```powershell
# Syntax validation
$ast = [System.Management.Automation.Language.Parser]::ParseFile('script.ps1', [ref]$null, [ref]$null)

# Parameter validation test
.\script.ps1 -InvalidParameter -WhatIf

# Help documentation check
Get-Help .\script.ps1 -Full

# Test WhatIf mode
.\script.ps1 -WhatIf

# Run tests
Invoke-Pester
```

## Common Issues to Watch For

❌ **Avoid These Patterns:**
- `[Parameter(Mandatory)] [string] $Param = 'default'` ← Contradictory
- `Throw "Error message"` ← Use Write-Error instead
- `.\hardcoded-path.log` ← Use dynamic paths
- Functions accessing `$script:variable` ← Pass parameters explicitly
- No input validation ← Always validate user input

✅ **Prefer These Patterns:**
- `[Parameter()] [ValidateNotNullOrEmpty()] [string] $Param = 'default'`
- `Write-Error "Error message" -ErrorAction Stop`
- `Join-Path $PSScriptRoot "log_$(Get-Date -Format 'yyyyMMdd').log"`
- Explicit parameter passing to functions
- Comprehensive parameter validation

---

*Use this checklist to ensure consistent, high-quality PowerShell scripts.*