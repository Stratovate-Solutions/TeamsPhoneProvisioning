[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $UserCsv                   = '.\Users.csv',

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $DidCsv                    = '.\dids.csv',

    [string] $DefaultVoiceRoutingPolicy = 'YourRoutingPolicyName',
    [int]    $ThrottleLimit             = 5,
    [Switch] $WhatIf
)

# Step 1: Prompt for credentials
$credential = Get-Credential -Message 'Enter Teams admin credentials'

# Step 2: Load and validate CSVs
if (-not (Test-Path $UserCsv)) {
    Throw "User CSV file not found: $UserCsv"
}
if (-not (Test-Path $DidCsv)) {
    Throw "DID CSV file not found: $DidCsv"
}

$users = Import-Csv $UserCsv | Select-Object UPN
$didsCsv = Import-Csv $DidCsv
$phoneColumn = $didsCsv[0].PSObject.Properties.Name | Where-Object { $_ -eq 'PhoneNumber' -or $_ -eq 'Phone Number' }
if (-not $phoneColumn) {
    Throw "The DIDs.csv file must contain a 'PhoneNumber' or 'Phone Number' column."
}
$dids = $didsCsv | Select-Object -ExpandProperty $phoneColumn


if ($users.Count -eq 0) {
    Throw "The Users.csv file is empty or does not contain a valid 'UPN' column."
}
if ($dids.Count -eq 0) {
    Throw "The DIDs.csv file is empty or does not contain valid phone numbers."
}

if ($users.Count -ne $dids.Count) {
    Throw "User count ($($users.Count)) does not match DID count ($($dids.Count))."
}

$pairs = for ($i = 0; $i -lt $users.Count; $i++) {
    [PSCustomObject]@{
        UPN         = ($null -ne $users[$i].UPN) ? $users[$i].UPN.Trim() : $null
        PhoneNumber = ($null -ne $dids[$i]) ? $dids[$i].Trim() : $null
    }
}

if ($pairs.Count -eq 0) {
    Throw "No valid user and phone number pairs were created. Check the input CSV files."
}

$validPairs = $pairs | Where-Object { $_.UPN -and $_.PhoneNumber }
if ($validPairs.Count -eq 0) {
    Throw "No valid pairs found after filtering. Ensure the CSV files contain valid data."
}

Write-Host "Valid Pairs:" -ForegroundColor Yellow
$validPairs | Format-Table

# Step 3: Parallel provisioning
if (-not (Get-Module -Name MicrosoftTeams -ListAvailable)) {
    Import-Module MicrosoftTeams -ErrorAction Stop
}
Connect-MicrosoftTeams -Credential $credential -ErrorAction Stop

function Invoke-WithRetry {
    param (
        [scriptblock]$ScriptBlock,
        [int]$RetryCount = 3,
        [int]$DelaySeconds = 5
    )
    for ($i = 1; $i -le $RetryCount; $i++) {
        try {
            & $ScriptBlock
            return
        }
        catch {
            Write-Warning "Attempt $i of $RetryCount failed: $_"
            if ($i -eq $RetryCount) {
                throw
            }
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

Function Set-TeamsPhoneUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$UPN,
        [string]$PhoneNumber
    )

    try {
        if ($PSCmdlet.ShouldProcess($UPN, "Grant voice routing policy")) {
            Invoke-WithRetry {
                Grant-CsOnlineVoiceRoutingPolicy `
                  -Identity $UPN `
                  -PolicyName $DefaultVoiceRoutingPolicy `
                  -ErrorAction Stop `
                  -WhatIf:$WhatIf
            }
        }

        Set-CsPhoneNumberAssignment `
          -Identity $UPN `
          -PhoneNumber $PhoneNumber `
          -ErrorAction Stop `
          -WhatIf:$WhatIf

        Write-Host "✔ $UPN" -ForegroundColor Green
    }
    catch {
        Write-Host "✖ $UPN failed: $_" -ForegroundColor Red
        Add-Content -Path .\ProvisionErrors.log -Value "$(Get-Date): $UPN failed: $_"
    }
}

$validPairs | ForEach-Object -Parallel {
    Set-TeamsPhoneUser -UPN $_.UPN -PhoneNumber $_.PhoneNumber
} -ThrottleLimit $ThrottleLimit
