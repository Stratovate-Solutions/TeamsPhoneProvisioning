# Teams Phone Provisioning Script

A PowerShell 7.1+ script to bulk-provision Microsoft Teams phone users in parallel.  
It reads two CSVs—one for user UPNs, one for DIDs—and assigns phone numbers concurrently.

---

## Table of Contents

- [Teams Phone Provisioning Script](#teams-phone-provisioning-script)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Script Parameters](#script-parameters)
  - [CSV Formats](#csv-formats)
    - [Users.csv](#userscsv)
    - [dids.csv](#didscsv)
  - [Logging \& Output](#logging--output)
  - [Example Commands](#example-commands)

---

## Prerequisites

- Windows, PowerShell 7.1 or later
- Teams PowerShell module
- Permissions to run Teams cmdlets (e.g. Teams Admin)

You can install these dependencies automatically by running the provided
`setup.sh` script on a compatible Linux system:

```bash
./setup.sh
```

---

## Usage

```powershell
Set-Location '...\TeamsPhoneProvisioning'

.\ProvisionTeamsPhoneUsers.ps1 `
  -UserCsv '.\Users.csv' `
  -DidCsv  '.\dids.csv' `
  -DefaultVoiceRoutingPolicy 'YourRoutingPolicyName' `
  -ThrottleLimit 5 `
  -WhatIf
```

---

## Script Parameters

- **-UserCsv** `<string>`  
  Path to the user CSV (default: `.\Users.csv`).  
- **-DidCsv** `<string>`  
  Path to the DID CSV (default: `.\dids.csv`).  
- **-DefaultVoiceRoutingPolicy** `<string>`  
  Name of voice routing policy to apply (default: `YourRoutingPolicyName`).  
- **-ThrottleLimit** `<int>`  
  Number of parallel runspaces (default: `5`).  
- **-WhatIf**  
  Switch to simulate actions without making changes.

---

## CSV Formats

### Users.csv

Must include a `UPN` column (and optional license/policy columns):

```csv
UPN,LicenseSku,CallingPolicy,VoiceRoutingPolicy,EmergencyRoutingPolicy
user1@contoso.com,abc123,PolicyA,PolicyB,PolicyC
user2@contoso.com,abc123,PolicyA,PolicyB,PolicyC
```

### dids.csv

Must include a `Phone Number` column:

```csv
Phone Number
+12025550123
+12025550124
```

---

## Logging & Output

- Status printed to console (✔️ success / ❌ failure).  
- Errors appended to `ProvisionErrors.log` in the script directory.  
- To disable logging, comment out or remove the `Add-Content` calls in the script.

---

## Example Commands

```powershell
# 1) Dry-run with default settings
.\ProvisionTeamsPhoneUsers.ps1 -WhatIf

# 2) Dry-run with a higher degree of parallelism
.\ProvisionTeamsPhoneUsers.ps1 `
  -WhatIf `
  -ThrottleLimit 10

# 3) Full provisioning using a custom routing policy
.\ProvisionTeamsPhoneUsers.ps1 `
  -DefaultVoiceRoutingPolicy 'ContosoVoicePolicy' `
  -ThrottleLimit 8

# 4) Point to CSVs in another folder
.\ProvisionTeamsPhoneUsers.ps1 `
  -UserCsv 'C:\Data\UsersToProvision.csv' `
  -DidCsv  'C:\Data\DIDsToAssign.csv'

# 5) Run non-interactively (e.g. from CI/CD)
pwsh -File .\ProvisionTeamsPhoneUsers.ps1 `
  -UserCsv .\Users.csv `
  -DidCsv  .\dids.csv `
  -DefaultVoiceRoutingPolicy 'YourRoutingPolicyName' `
  -ThrottleLimit 5
```

## Running Tests

Run all Pester tests from the repository root:
```powershell
Invoke-Pester
```
