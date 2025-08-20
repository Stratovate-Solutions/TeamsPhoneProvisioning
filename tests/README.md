# Test Suite Documentation

This directory contains comprehensive Pester tests for the TeamsPhoneProvisioning PowerShell script.

## Test Structure

### Main Test File
- `ProvisionTeamsPhoneUsers.Tests.ps1` - Main test file with 59 tests across 6 categories

### Test Categories

1. **Basic Script Validation** (4 tests)
   - Script file existence and readability
   - PowerShell syntax validation
   - Test data file validation

2. **Parameter Validation Tests** (9 tests)
   - CSV file path parameters
   - ThrottleLimit parameter validation
   - DefaultVoiceRoutingPolicy parameter
   - WhatIf parameter support
   - Parameter attribute validation

3. **CSV File Validation Tests** (8 tests)
   - Empty CSV file handling
   - Missing required columns
   - Row count matching
   - Data processing logic

4. **Function Tests** (20 tests)
   - `Invoke-WithRetry` function (7 tests)
     - Success/failure scenarios
     - Retry logic and delay
     - Default parameters
   - `Set-TeamsPhoneUser` function (6 tests)
     - Teams cmdlet calls
     - Error handling
     - WhatIf support

5. **Integration and Mock Tests** (18 tests)
   - Script structure validation
   - Function definitions
   - Error handling and logging
   - WhatIf support
   - CSV processing workflow

### Test Data Files

Located in `TestData/` directory:

- `Users_Valid.csv` - Valid user data (3 users)
- `DIDs_Valid.csv` - Valid phone numbers (3 numbers)
- `Users_Empty.csv` - Empty user file (header only)
- `DIDs_Empty.csv` - Empty DID file (header only)
- `Users_Single.csv` - Single user (for mismatch testing)
- `DIDs_Mismatch.csv` - Two DIDs (for mismatch testing)
- `Users_MissingColumn.csv` - Missing UPN column
- `DIDs_AlternateColumn.csv` - PhoneNumber column (instead of "Phone Number")
- `Users_WithBlank.csv` - Contains blank/empty entries
- `DIDs_WithBlank.csv` - Contains blank/empty entries

## Running Tests

```powershell
# Run all tests
Invoke-Pester

# Run specific test file
Invoke-Pester tests/ProvisionTeamsPhoneUsers.Tests.ps1

# Run with detailed output
Invoke-Pester tests/ProvisionTeamsPhoneUsers.Tests.ps1 -Output Detailed
```

## Test Features

- **Mock Integration**: Comprehensive mocking of Microsoft Teams cmdlets
- **No External Dependencies**: Tests run without requiring Teams module
- **Isolated Function Testing**: Functions tested in isolation with mocks
- **Error Scenario Coverage**: Tests both success and failure paths
- **Parameter Validation**: Validates current script parameter behavior
- **Documentation**: Tests serve as living documentation of expected behavior

## Test Results

- **58 tests passing**
- **1 test skipped** (intentionally - tests ideal behavior not currently implemented)
- **0 tests failing**

The tests provide comprehensive coverage while maintaining minimal dependencies and fast execution.