# PSScriptAnalyzerSettings.psd1
# Settings for PSScriptAnalyzer invocation.
@{
    Rules = @{
        PSUseCompatibleCommands = @{
            # Turns the rule on
            Enable = $false

            # Lists the PowerShell platforms we want to check compatibility with
            TargetProfiles = @(
                'win-8_x64_10.0.17763.0_6.1.3_x64_4.0.30319.42000_core',
                'ubuntu_x64_18.04_6.1.3_x64_4.0.30319.42000_core'
            )
        }
        PSUseCompatibleSyntax = @{
            # This turns the rule on (setting it to false will turn it off)
            Enable = $false

            # Simply list the targeted versions of PowerShell here
            TargetVersions = @(
                '6.1',
                '6.2'
            )
        }
    }
    ExcludeRules = @(
        # Currently Scoop widely uses Write-Host to output colored text.
        'PSAvoidUsingWriteHost',
        # Temporarily allow uses of Invoke-Expression,
        # this command is used by some core functions and hard to be removed.
        'PSAvoidUsingInvokeExpression',
        # PSUseDeclaredVarsMoreThanAssignments doesn't currently work due to:
        # https://github.com/PowerShell/PSScriptAnalyzer/issues/636
        'PSUseDeclaredVarsMoreThanAssignments',
        # Do not check functions whose verbs change system state
        'PSUseShouldProcessForStateChangingFunctions'
'PSAvoidUsingConvertToSecureStringWithPlainText'
    )
}