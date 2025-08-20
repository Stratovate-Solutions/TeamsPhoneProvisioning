# Teams Phone Provisioning - GitHub Copilot Instructions

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Dependencies
- Install PowerShell and Teams module:
  - Run `./setup.sh` -- takes 15-20 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
  - Note: MicrosoftTeams module installation may fail in some environments due to repository access. This is expected.
  - Alternative: Manually register PS repository with `pwsh -Command "Register-PSRepository -Default -InstallationPolicy Trusted"`

### Build and Test Process
- No traditional "build" step required - this is a PowerShell script repository
- Validate syntax: `pwsh -Command "$ast = [System.Management.Automation.Language.Parser]::ParseFile('./ProvisionTeamsPhoneUsers.ps1', [ref]$null, [ref]$null); if ($ast) { 'Syntax OK' } else { 'Syntax Error' }"` -- takes 0.3 seconds
- Run tests: `Invoke-Pester` or `pwsh -Command "Invoke-Pester -Path ./tests/"` -- takes 0.5 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
- All 3 existing tests should pass (script exists, test data exists, syntax validation)

### Running the Application
- **CRITICAL KNOWN ISSUE**: The main script has a parameter conflict with WhatIf that prevents execution
- Script parameters have validation issues that must be addressed before use
- The script requires interactive credentials which blocks automation scenarios
- For testing parameter validation without execution, use syntax parsing instead

### Key Project Structure
- **Main script**: `ProvisionTeamsPhoneUsers.ps1` - PowerShell script for bulk Teams phone provisioning
- **Setup script**: `setup.sh` - Linux environment setup for PowerShell and modules  
- **Tests**: `tests/ProvisionTeamsPhoneUsers.Tests.ps1` - Pester tests with test data in `tests/data/`
- **Documentation**: Comprehensive guides in `IMPLEMENTATION_GUIDE.md`, `CODE_REVIEW_SUGGESTIONS.md`, `readme.md`

## Validation

### Mandatory Validation Steps
After making ANY changes to PowerShell files:
1. **Syntax Check**: `pwsh -Command "$ast = [System.Management.Automation.Language.Parser]::ParseFile('./ProvisionTeamsPhoneUsers.ps1', [ref]$null, [ref]$null)"` -- 0.3 seconds
2. **Run All Tests**: `Invoke-Pester` -- 0.5 seconds  
3. **Parameter Validation**: Inspect parameter definitions manually due to Help system conflict: `Get-Content ./ProvisionTeamsPhoneUsers.ps1 | Select-String -Pattern "Parameter|Param"`
4. **CSV Processing**: Validate with test data files in `tests/data/`

### Manual Testing Scenarios
Since the main script cannot currently execute due to parameter conflicts, validation must focus on:
- PowerShell syntax correctness via AST parsing
- Parameter definition validation  
- CSV file format validation with test data
- Function scope and dependency analysis
- Documentation consistency with code behavior

### Expected Timing
- **Syntax validation**: 0.3 seconds
- **Test suite**: 0.5 seconds (3 tests)  
- **Complete validation workflow**: 2 seconds
- **Setup script**: 15-20 seconds  
- **Documentation reading**: < 1 second per file

## Common Commands Reference

### Repository Setup
```bash
# Clone and setup (first time)
git clone <repository-url>
cd TeamsPhoneProvisioning
./setup.sh
```

### Daily Development Workflow  
```powershell
# Complete validation workflow (recommended after any change)
pwsh -Command "$ast = [System.Management.Automation.Language.Parser]::ParseFile('./ProvisionTeamsPhoneUsers.ps1', [ref]$null, [ref]$null); if ($ast) { '✓ Syntax OK' }"
pwsh -Command "Invoke-Pester -Path ./tests/ -Quiet"
echo "✓ Complete validation passed"

# Individual validation steps
pwsh -Command "Invoke-Pester"  # Full test output
Get-Content ./ProvisionTeamsPhoneUsers.ps1 | Select-String -Pattern "Parameter|Param"
```

### Testing Individual Components
```powershell
# Test CSV parsing logic manually
$users = Import-Csv ./tests/data/Users.csv
$dids = Import-Csv ./tests/data/dids.csv
Write-Output "Users: $($users.Count), DIDs: $($dids.Count)"

# Test function definitions
(Get-Content ./ProvisionTeamsPhoneUsers.ps1) -match "^function|^Function"
```

## Critical Issues and Workarounds

### Known Parameter Conflict
The script defines both `[CmdletBinding(SupportsShouldProcess = $true)]` and `[Switch] $WhatIf` causing a conflict. This prevents script execution entirely.

### MicrosoftTeams Module Dependency  
The script requires the MicrosoftTeams PowerShell module which may not be available in all environments. The setup.sh script attempts installation but may fail due to repository access.

### Interactive Credential Prompting
Line 17 of the main script calls `Get-Credential` which blocks automation scenarios. This prevents non-interactive testing.

## High-Priority Fixes Needed

1. **Remove duplicate WhatIf parameter** - Remove `[Switch] $WhatIf` from Param block (line 13)
2. **Fix parameter validation contradictions** - Remove `[Parameter(Mandatory)]` from parameters with default values
3. **Add proper scope handling** - Pass `$DefaultVoiceRoutingPolicy` as parameter to `Set-TeamsPhoneUser` function  
4. **Replace Throw with Write-Error** - Use proper PowerShell error handling patterns

## File Locations Quick Reference

```
TeamsPhoneProvisioning/
├── ProvisionTeamsPhoneUsers.ps1     # Main script (3,715 bytes)
├── setup.sh                         # Environment setup (670 bytes) 
├── tests/
│   ├── ProvisionTeamsPhoneUsers.Tests.ps1  # Pester tests
│   └── data/
│       ├── Users.csv                # Test user data (2 users)
│       └── dids.csv                 # Test DID data (2 numbers)
├── readme.md                        # Usage documentation (134 lines)
├── IMPLEMENTATION_GUIDE.md          # Step-by-step improvement guide (230 lines)
├── CODE_REVIEW_SUGGESTIONS.md       # Detailed code issues (376 lines)  
└── CODE_REVIEW_CHECKLIST.md         # Review checklist (104 lines)
```

## Development Best Practices

- Always run syntax validation before committing changes
- Test parameter definitions carefully - PowerShell parameter validation is strict
- Use existing test data in `tests/data/` for validation
- Follow patterns established in `IMPLEMENTATION_GUIDE.md` for improvements
- Maintain compatibility with PowerShell 7.1+ as specified in documentation
- Validate CSV file processing with the provided test data files

---

*These instructions prioritize working commands and known limitations to prevent wasted time on broken functionality.*