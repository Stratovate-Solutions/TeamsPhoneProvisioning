$scriptPath = Join-Path $PSScriptRoot '..' 'ProvisionTeamsPhoneUsers.ps1'
$usersCsv   = Join-Path $PSScriptRoot 'data' 'Users.csv'
$didsCsv    = Join-Path $PSScriptRoot 'data' 'dids.csv'

# Debugging: Verify resolved script path
Write-Host "Resolved script path: $scriptPath"

# Check if the script file exists
if (-not (Test-Path $scriptPath)) {
    Throw "Script file not found at path: $scriptPath"
}

Describe 'ProvisionTeamsPhoneUsers script' {
    BeforeAll {
        function Get-Credential {
            param([string]$Message)
            $secure = ConvertTo-SecureString 'pass' -AsPlainText -Force
            New-Object System.Management.Automation.PSCredential('user',$secure)
        }
        function Import-Module {
            param([string]$Name)
        }
        function Connect-MicrosoftTeams {}
        function Grant-CsOnlineVoiceRoutingPolicy {}
        function Set-CsPhoneNumberAssignment {}
        function Add-Content {}
    }
    It 'runs in WhatIf mode without errors' {
        { & $scriptPath -UserCsv $usersCsv -DidCsv $didsCsv -ThrottleLimit 1 -WhatIf } | Should -Not -Throw
    }
}
