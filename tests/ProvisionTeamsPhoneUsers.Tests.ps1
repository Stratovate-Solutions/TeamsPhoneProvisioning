BeforeAll {
    $script:scriptPath = Join-Path $PSScriptRoot '..' 'ProvisionTeamsPhoneUsers.ps1'
    $script:usersCsv   = Join-Path $PSScriptRoot 'data' 'Users.csv'
    $script:didsCsv    = Join-Path $PSScriptRoot 'data' 'dids.csv'
    
    # Check if the script file exists
    if (-not (Test-Path $script:scriptPath)) {
        Throw "Script file not found at path: $script:scriptPath"
    }
}

Describe 'ProvisionTeamsPhoneUsers script' {
    It 'script file exists and is readable' {
        Test-Path $script:scriptPath | Should -Be $true
        { Get-Content $script:scriptPath } | Should -Not -Throw
    }
    
    It 'test data files exist' {
        Test-Path $script:usersCsv | Should -Be $true
        Test-Path $script:didsCsv | Should -Be $true
    }
    
    It 'script has proper PowerShell syntax' {
        { 
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $ast | Should -Not -Be $null
        } | Should -Not -Throw
    }
}
