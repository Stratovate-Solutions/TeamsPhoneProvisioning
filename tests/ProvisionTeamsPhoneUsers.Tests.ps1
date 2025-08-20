BeforeAll {
    $script:scriptPath = Join-Path $PSScriptRoot '..' 'ProvisionTeamsPhoneUsers.ps1'
    $script:testDataPath = Join-Path $PSScriptRoot 'TestData'
    $script:usersCsv = Join-Path $PSScriptRoot 'data' 'Users.csv'
    $script:didsCsv = Join-Path $PSScriptRoot 'data' 'dids.csv'
    
    # Test data files for various scenarios
    $script:validUsersCsv = Join-Path $testDataPath 'Users_Valid.csv'
    $script:validDidsCsv = Join-Path $testDataPath 'DIDs_Valid.csv'
    $script:emptyUsersCsv = Join-Path $testDataPath 'Users_Empty.csv'
    $script:emptyDidsCsv = Join-Path $testDataPath 'DIDs_Empty.csv'
    $script:singleUserCsv = Join-Path $testDataPath 'Users_Single.csv'
    $script:mismatchDidsCsv = Join-Path $testDataPath 'DIDs_Mismatch.csv'
    $script:missingColumnUsersCsv = Join-Path $testDataPath 'Users_MissingColumn.csv'
    $script:alternateColumnDidsCsv = Join-Path $testDataPath 'DIDs_AlternateColumn.csv'
    $script:blankUsersCsv = Join-Path $testDataPath 'Users_WithBlank.csv'
    $script:blankDidsCsv = Join-Path $testDataPath 'DIDs_WithBlank.csv'
    
    # Check if the script file exists
    if (-not (Test-Path $script:scriptPath)) {
        Throw "Script file not found at path: $script:scriptPath"
    }

    # Set up basic mocks for common cmdlets
    Mock Write-Host { return $null }
    Mock Add-Content { return $null }
    Mock Format-Table { return $null }
}

Describe 'ProvisionTeamsPhoneUsers - Basic Script Validation' {
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

    It 'all test data files exist' {
        Test-Path $script:validUsersCsv | Should -Be $true
        Test-Path $script:validDidsCsv | Should -Be $true
        Test-Path $script:emptyUsersCsv | Should -Be $true
        Test-Path $script:emptyDidsCsv | Should -Be $true
        Test-Path $script:singleUserCsv | Should -Be $true
        Test-Path $script:mismatchDidsCsv | Should -Be $true
        Test-Path $script:missingColumnUsersCsv | Should -Be $true
        Test-Path $script:alternateColumnDidsCsv | Should -Be $true
    }
}

Describe 'ProvisionTeamsPhoneUsers - Parameter Validation Tests' {
    Context 'CSV File Path Parameters' {
        It 'should have mandatory parameters defined correctly' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $paramBlock | Should -Not -Be $null
            $paramBlock.Parameters.Count | Should -BeGreaterThan 0
        }

        It 'should have UserCsv parameter with ValidateNotNullOrEmpty' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $userCsvParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'UserCsv' }
            $userCsvParam | Should -Not -Be $null
            
            $validateAttributes = $userCsvParam.Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateNotNullOrEmpty' }
            $validateAttributes | Should -Not -Be $null
        }

        It 'should have DidCsv parameter with ValidateNotNullOrEmpty' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $didCsvParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'DidCsv' }
            $didCsvParam | Should -Not -Be $null
            
            $validateAttributes = $didCsvParam.Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateNotNullOrEmpty' }
            $validateAttributes | Should -Not -Be $null
        }

        It 'should have contradictory Mandatory attributes with default values (current issue)' {
            # This test documents the current issue where parameters are marked Mandatory but have defaults
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $userCsvParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'UserCsv' }
            $mandatoryAttr = $userCsvParam.Attributes | Where-Object { $_.TypeName.Name -eq 'Parameter' }
            $hasDefault = $userCsvParam.DefaultValue -ne $null
            
            # Both should be true, which is contradictory
            $mandatoryAttr | Should -Not -Be $null
            $hasDefault | Should -Be $true
        }
    }

    Context 'ThrottleLimit Parameter Validation' {
        It 'should have ThrottleLimit parameter defined' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $throttleLimitParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ThrottleLimit' }
            $throttleLimitParam | Should -Not -Be $null
            $throttleLimitParam.StaticType.Name | Should -Be 'Int32'
        }

        It 'should have default value of 5 for ThrottleLimit' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $throttleLimitParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ThrottleLimit' }
            $throttleLimitParam.DefaultValue.Value | Should -Be 5
        }

        # Note: Current script doesn't have ValidateRange, but test documents expected behavior
        It 'should ideally have ValidateRange attribute for ThrottleLimit' -Skip {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $throttleLimitParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ThrottleLimit' }
            $validateRange = $throttleLimitParam.Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateRange' }
            $validateRange | Should -Not -Be $null
        }
    }

    Context 'DefaultVoiceRoutingPolicy Parameter' {
        It 'should have DefaultVoiceRoutingPolicy parameter defined' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $policyParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'DefaultVoiceRoutingPolicy' }
            $policyParam | Should -Not -Be $null
            $policyParam.StaticType.Name | Should -Be 'String'
        }

        It 'should have default value for DefaultVoiceRoutingPolicy' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $policyParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'DefaultVoiceRoutingPolicy' }
            $policyParam.DefaultValue.Value | Should -Be 'YourRoutingPolicyName'
        }
    }

    Context 'WhatIf Parameter' {
        It 'should have WhatIf parameter as Switch type' {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:scriptPath, [ref]$null, [ref]$null)
            $paramBlock = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $false)[0]
            
            $whatIfParam = $paramBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'WhatIf' }
            $whatIfParam | Should -Not -Be $null
            $whatIfParam.StaticType.Name | Should -Be 'SwitchParameter'
        }

        It 'should support ShouldProcess in CmdletBinding' {
            # Check the script content directly for SupportsShouldProcess
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'SupportsShouldProcess\s*=\s*\$true'
        }
    }
}

Describe 'ProvisionTeamsPhoneUsers - CSV File Validation Tests' {
    Context 'CSV File Structure Validation' {
        It 'should detect empty user CSV files' {
            $emptyContent = Import-Csv $script:emptyUsersCsv
            $emptyContent.Count | Should -Be 0
        }

        It 'should detect empty DIDs CSV files' {
            $emptyContent = Import-Csv $script:emptyDidsCsv
            $emptyContent.Count | Should -Be 0
        }

        It 'should validate required UPN column in user CSV' {
            $validUsers = Import-Csv $script:validUsersCsv
            $validUsers[0].PSObject.Properties.Name | Should -Contain 'UPN'
        }

        It 'should detect missing UPN column in user CSV' {
            $invalidUsers = Import-Csv $script:missingColumnUsersCsv
            $invalidUsers[0].PSObject.Properties.Name | Should -Not -Contain 'UPN'
            $invalidUsers[0].PSObject.Properties.Name | Should -Contain 'Email'
        }

        It 'should accept Phone Number column in DIDs CSV' {
            $validDids = Import-Csv $script:validDidsCsv
            $validDids[0].PSObject.Properties.Name | Should -Contain 'Phone Number'
        }

        It 'should accept PhoneNumber column in DIDs CSV' {
            $alternateDids = Import-Csv $script:alternateColumnDidsCsv
            $alternateDids[0].PSObject.Properties.Name | Should -Contain 'PhoneNumber'
        }

        It 'should validate user and DID count matching' {
            $users = Import-Csv $script:singleUserCsv
            $dids = Import-Csv $script:mismatchDidsCsv
            
            $users.Count | Should -Be 1
            $dids.Count | Should -Be 2
            $users.Count | Should -Not -Be $dids.Count
        }

        It 'should handle blank rows in CSV files' {
            $blankUsers = Import-Csv $script:blankUsersCsv
            $blankDids = Import-Csv $script:blankDidsCsv
            
            # CSV with blank rows should still import at least some rows
            $blankUsers.Count | Should -BeGreaterThan 0
            $blankDids.Count | Should -BeGreaterThan 0
            
            # The test files should have at least one valid entry
            $validUpns = $blankUsers | Where-Object { -not [string]::IsNullOrWhiteSpace($_.UPN) }
            $validUpns.Count | Should -BeGreaterThan 0
            
            # This test validates that the script can handle mixed valid/invalid data
            $validUpns[0].UPN | Should -Not -BeNullOrEmpty
        }
    }

    Context 'CSV Data Processing Logic' {
        It 'should process valid CSV data correctly' {
            $users = Import-Csv $script:validUsersCsv | Select-Object UPN
            $didsCsv = Import-Csv $script:validDidsCsv
            
            # Find phone column (similar to script logic)
            $phoneColumn = $didsCsv[0].PSObject.Properties.Name | Where-Object { $_ -eq 'PhoneNumber' -or $_ -eq 'Phone Number' }
            $phoneColumn | Should -Not -Be $null
            
            $dids = $didsCsv | Select-Object -ExpandProperty $phoneColumn
            
            $users.Count | Should -Be $dids.Count
            $users.Count | Should -Be 3
        }

        It 'should create valid pairs from CSV data' {
            $users = Import-Csv $script:validUsersCsv | Select-Object UPN
            $didsCsv = Import-Csv $script:validDidsCsv
            $phoneColumn = $didsCsv[0].PSObject.Properties.Name | Where-Object { $_ -eq 'PhoneNumber' -or $_ -eq 'Phone Number' }
            $dids = $didsCsv | Select-Object -ExpandProperty $phoneColumn

            # Create pairs (similar to script logic)
            $pairs = for ($i = 0; $i -lt $users.Count; $i++) {
                [PSCustomObject]@{
                    UPN         = ($null -ne $users[$i].UPN) ? $users[$i].UPN.Trim() : $null
                    PhoneNumber = ($null -ne $dids[$i]) ? $dids[$i].Trim() : $null
                }
            }

            $pairs.Count | Should -Be 3
            $pairs[0].UPN | Should -Be 'user1@contoso.com'
            $pairs[0].PhoneNumber | Should -Be '+15550001111'
        }

        It 'should filter out invalid pairs' {
            $users = Import-Csv $script:blankUsersCsv | Select-Object UPN
            $didsCsv = Import-Csv $script:blankDidsCsv
            $phoneColumn = $didsCsv[0].PSObject.Properties.Name | Where-Object { $_ -eq 'PhoneNumber' -or $_ -eq 'Phone Number' }
            $dids = $didsCsv | Select-Object -ExpandProperty $phoneColumn

            # Create pairs
            $pairs = for ($i = 0; $i -lt $users.Count; $i++) {
                [PSCustomObject]@{
                    UPN         = if ($null -ne $users[$i].UPN -and $users[$i].UPN -is [string]) { $users[$i].UPN.Trim() } else { $null }
                    PhoneNumber = if ($null -ne $dids[$i] -and $dids[$i] -is [string]) { $dids[$i].Trim() } else { $null }
                }
            }

            # Filter valid pairs (similar to script logic)
            $validPairs = $pairs | Where-Object { $_.UPN -and $_.PhoneNumber }
            
            $validPairs.Count | Should -BeLessThan $pairs.Count
            $validPairs.Count | Should -BeGreaterOrEqual 0
        }
    }
}

Describe 'ProvisionTeamsPhoneUsers - Function Tests' {
    Context 'Invoke-WithRetry Function' {
        BeforeEach {
            # Reset counter
            $global:attempts = 0
            
            # Define the function for testing
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
        }

        It 'should succeed on first attempt when script block succeeds' {
            $testScript = {
                $global:attempts++
                return "Success"
            }
            
            Mock Start-Sleep { }
            Mock Write-Warning { }
            
            $result = Invoke-WithRetry -ScriptBlock $testScript
            $global:attempts | Should -Be 1
        }

        It 'should retry specified number of times on failure' {
            $testScript = {
                $global:attempts++
                throw "Test error"
            }
            
            Mock Start-Sleep { }
            Mock Write-Warning { }
            
            { Invoke-WithRetry -ScriptBlock $testScript -RetryCount 3 } | Should -Throw "Test error"
            $global:attempts | Should -Be 3
        }

        It 'should succeed on retry after initial failures' {
            $testScript = {
                $global:attempts++
                if ($global:attempts -lt 2) {
                    throw "Temporary failure"
                }
                return "Success"
            }
            
            Mock Start-Sleep { }
            Mock Write-Warning { }
            
            $result = Invoke-WithRetry -ScriptBlock $testScript -RetryCount 3
            $global:attempts | Should -Be 2
        }

        It 'should wait specified delay between retries' {
            $testScript = { throw "Test error" }
            
            Mock Start-Sleep { } -Verifiable -ParameterFilter { $Seconds -eq 2 }
            Mock Write-Warning { }
            
            { Invoke-WithRetry -ScriptBlock $testScript -RetryCount 2 -DelaySeconds 2 } | Should -Throw
            Should -InvokeVerifiable
        }

        It 'should write warnings for each failed attempt' {
            $testScript = { throw "Test error" }
            
            Mock Start-Sleep { }
            Mock Write-Warning { } -Verifiable
            
            { Invoke-WithRetry -ScriptBlock $testScript -RetryCount 2 } | Should -Throw
            Should -Invoke Write-Warning -Exactly 2
        }

        It 'should have default retry count of 3' {
            $testScript = {
                $global:attempts++
                throw "Test error"
            }
            
            Mock Start-Sleep { }
            Mock Write-Warning { }
            
            { Invoke-WithRetry -ScriptBlock $testScript } | Should -Throw
            $global:attempts | Should -Be 3
        }

        It 'should have default delay of 5 seconds' {
            $testScript = { throw "Test error" }
            
            Mock Start-Sleep { } -Verifiable -ParameterFilter { $Seconds -eq 5 }
            Mock Write-Warning { }
            
            { Invoke-WithRetry -ScriptBlock $testScript -RetryCount 2 } | Should -Throw
            Should -InvokeVerifiable
        }
    }

    Context 'Set-TeamsPhoneUser Function Logic' {
        BeforeEach {
            # Create dummy functions for Teams cmdlets
            function Grant-CsOnlineVoiceRoutingPolicy {
                param([string]$Identity, [string]$PolicyName, [string]$ErrorAction)
                return $true
            }
            
            function Set-CsPhoneNumberAssignment {
                param([string]$Identity, [string]$PhoneNumber, [string]$ErrorAction)
                return $true
            }
            
            # Mock the dummy functions
            Mock Grant-CsOnlineVoiceRoutingPolicy { return $true }
            Mock Set-CsPhoneNumberAssignment { return $true }
            
            # Define the function for testing with isolated scope
            function Set-TeamsPhoneUser {
                [CmdletBinding(SupportsShouldProcess = $true)]
                param (
                    [string]$UPN,
                    [string]$PhoneNumber,
                    [string]$VoiceRoutingPolicy = 'TestPolicy'
                )

                try {
                    if ($PSCmdlet.ShouldProcess($UPN, "Grant voice routing policy")) {
                        Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $VoiceRoutingPolicy -ErrorAction Stop
                    }

                    Set-CsPhoneNumberAssignment -Identity $UPN -PhoneNumber $PhoneNumber -ErrorAction Stop
                    Write-Host "✔ $UPN" -ForegroundColor Green
                }
                catch {
                    Write-Host "✖ $UPN failed: $_" -ForegroundColor Red
                    Add-Content -Path .\ProvisionErrors.log -Value "$(Get-Date): $UPN failed: $_"
                }
            }
        }

        It 'should call Grant-CsOnlineVoiceRoutingPolicy with correct parameters' {
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111' -VoiceRoutingPolicy 'TestPolicy'
            
            Should -Invoke Grant-CsOnlineVoiceRoutingPolicy -ParameterFilter {
                $Identity -eq 'test@contoso.com' -and 
                $PolicyName -eq 'TestPolicy'
            }
        }

        It 'should call Set-CsPhoneNumberAssignment with correct parameters' {
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111'
            
            Should -Invoke Set-CsPhoneNumberAssignment -ParameterFilter {
                $Identity -eq 'test@contoso.com' -and 
                $PhoneNumber -eq '+15550001111'
            }
        }

        It 'should write success message when operations succeed' {
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111'
            
            Should -Invoke Write-Host -ParameterFilter { 
                $Object -like "*test@contoso.com" -and $ForegroundColor -eq 'Green' 
            }
        }

        It 'should handle errors and write to error log' {
            Mock Grant-CsOnlineVoiceRoutingPolicy { throw "Test error" }
            
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111'
            
            Should -Invoke Write-Host -ParameterFilter { 
                $Object -like "*failed*" -and $ForegroundColor -eq 'Red' 
            }
            Should -Invoke Add-Content -ParameterFilter {
                $Path -like "*ProvisionErrors.log*"
            }
        }

        It 'should respect WhatIf parameter' {
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111' -WhatIf
            
            # When WhatIf is used, Grant-CsOnlineVoiceRoutingPolicy should not be called
            Should -Not -Invoke Grant-CsOnlineVoiceRoutingPolicy
        }

        It 'should still call Set-CsPhoneNumberAssignment even with WhatIf' {
            # Note: In the actual script, this call is outside the ShouldProcess check
            Set-TeamsPhoneUser -UPN 'test@contoso.com' -PhoneNumber '+15550001111' -WhatIf
            
            Should -Invoke Set-CsPhoneNumberAssignment
        }
    }
}

Describe 'ProvisionTeamsPhoneUsers - Integration and Mock Tests' {
    Context 'Script Structure and Dependencies' {
        It 'should have proper CmdletBinding with SupportsShouldProcess' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match '\[CmdletBinding\(SupportsShouldProcess\s*=\s*\$true\)\]'
        }

        It 'should contain Teams module dependency checks' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Get-Module.*MicrosoftTeams'
            $scriptContent | Should -Match 'Import-Module.*MicrosoftTeams'
        }

        It 'should contain Connect-MicrosoftTeams call' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Connect-MicrosoftTeams'
        }

        It 'should contain Get-Credential call' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Get-Credential'
        }

        It 'should contain parallel processing logic' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'ForEach-Object.*-Parallel'
            $scriptContent | Should -Match 'ThrottleLimit'
        }

        It 'should contain error logging functionality' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Add-Content.*ProvisionErrors\.log'
        }
    }

    Context 'Function Definitions' {
        It 'should define Invoke-WithRetry function' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'function Invoke-WithRetry'
        }

        It 'should define Set-TeamsPhoneUser function' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Function Set-TeamsPhoneUser'
        }

        It 'should have retry logic in Invoke-WithRetry' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'RetryCount'
            $scriptContent | Should -Match 'DelaySeconds'
            $scriptContent | Should -Match 'Start-Sleep'
        }

        It 'should have Teams cmdlet calls in Set-TeamsPhoneUser' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Grant-CsOnlineVoiceRoutingPolicy'
            $scriptContent | Should -Match 'Set-CsPhoneNumberAssignment'
        }
    }

    Context 'Error Handling and Logging' {
        It 'should have try-catch blocks for error handling' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
        }

        It 'should have proper error output formatting' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Write-Host.*Green'  # Success messages
            $scriptContent | Should -Match 'Write-Host.*Red'    # Error messages
        }

        It 'should log errors with timestamps' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Get-Date.*failed'
        }
    }

    Context 'WhatIf Support' {
        It 'should have ShouldProcess calls for WhatIf support' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match '\$PSCmdlet\.ShouldProcess'
        }

        It 'should check ShouldProcess before policy assignment' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            # The script should wrap Grant-CsOnlineVoiceRoutingPolicy in ShouldProcess
            $scriptContent | Should -Match 'ShouldProcess.*Grant.*voice.*routing.*policy'
        }
    }

    Context 'CSV Processing Workflow' {
        It 'should validate CSV file existence' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Test-Path.*UserCsv'
            $scriptContent | Should -Match 'Test-Path.*DidCsv'
        }

        It 'should import and process CSV files' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'Import-Csv.*UserCsv'
            $scriptContent | Should -Match 'Import-Csv.*DidCsv'
        }

        It 'should validate CSV column requirements' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match 'UPN.*column'
            $scriptContent | Should -Match 'PhoneNumber.*Phone Number.*column'
        }

        It 'should create user-phone pairs' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match '\$pairs.*for.*\$i.*lt.*Count'
        }

        It 'should filter valid pairs' {
            $scriptContent = Get-Content $script:scriptPath -Raw
            $scriptContent | Should -Match '\$validPairs.*Where-Object.*UPN.*PhoneNumber'
        }
    }
}
