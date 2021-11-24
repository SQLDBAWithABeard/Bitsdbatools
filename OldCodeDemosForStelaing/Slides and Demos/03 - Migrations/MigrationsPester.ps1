<#
Pester for the Migrations Demo
#>
## Set the local variables

. .\Setup\MachineVars.ps1

Describe "Host Machine" {
    It "Share should exist" {
        Test-Path -Path "\\$($ENV:COMPUTERNAME)\Singapore" | Should Be $True
        
    }
    It "Source SQL Should have access to the Share" {
        Test-DbaSqlPath -SqlInstance $Source2016 -Path "\\$($ENV:COMPUTERNAME)\Singapore" | Should Be $True
    }
    It "Destination SQL Should have access to the Share" {
        Test-DbaSqlPath -SqlInstance $Destination2017 -Path "\\$($ENV:COMPUTERNAME)\Singapore" | Should Be $True
    }
}

try {
    $SQL2016 = Get-DbaInstance  -SqlInstance $Source2016
    $SQL2017 = Get-DbaInstance  -SqlInstance $Destination2017 
}
catch {
    Write-Warning "Failed to get SMO Objects - Some tests are going to FAIL!!"
}

Describe "Testing for Demo - $Source2016 Instance" {

    It "Should have the correct Demo Logins" {
        (Get-DbaLogin -SqlInstance $Source2016).Where{$_.Name -like '*SingaporeDemo*'}.Count | Should Be 9
    }
    It "Should have the correct credential" {
        (Get-DbaCredential -SqlInstance $Source2016).Where{$_.Name -like '*Singapore*'}.Count | Should Be 1
    }
    It "Should have an audit" {
        (Get-DbaServerAudit -SqlInstance $Source2016).Where{$_.Name -like '*Singapore*'}.Count | Should Be 1
    }
    It "Should have an audit specification" {
        (Get-DbaServerAuditSpecification -SqlInstance $Source2016).Where{$_.Name -like '*Singapore*'}.Count | Should Be 1
    }
    It "Should have a linked Server" {
        $SQL2016.LinkedServers.Where{$_.Name -like '*Singapore*'}.Count | Should Be 1
    }
    It "Should have Agent Jobs" {
        (Get-DbaAgentJob -SqlInstance $Source2016).Count | Should BeGreaterThan 14
    }
    It "Should have Agent Alerts" {
        (Get-DbaAgentAlert -SqlInstance $Source2016).Count| Should BeGreaterThan 13
    }
    It "Should have Operators" {
        (Get-DbaAgentOperator -SqlInstance $Source2016).Count | Should BeGreaterThan 1
    }
    It "Should have a proxy" {

        $SQL2016.JobServer.ProxyAccounts.Count | Should BeGreaterThan 0
    }
}

Describe "Testing for Demo - $Destination2017 Instance" {
    It "Should have the correct Demo Logins" {
        $exclude = '##MS_PolicyEventProcessingLogin##', '##MS_PolicyTsqlExecutionLogin##', 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators', 'NT AUTHORITY\NETWORK SERVICE', 'sa', 'NT Service\MSSQL$BOLTON', 'NT SERVICE\SQLAgent$BOLTON', 'NT SERVICE\SQLTELEMETRY$BOLTON', 'NT SERVICE\SQLWriter', 'NT SERVICE\Winmgmt', 'ROB-XPS\mrrob','NT SERVICE\SQLAgent$DAVE' ,'Singaporebase\Singapore','NT SERVICE\SQLTELEMETRY','NT SERVICE\SQLSERVERAGENT'
        (Get-DbaLogin -SqlInstance $Destination2017 ).Where{$_.Name -notin $exclude}.Count | Should Be 0
    }
    It "Should have the correct number of credentials" {
        (Get-DbaCredential -SqlInstance $Destination2017 ).Count | Should Be 0
    }
    It "Should not have an audit" {
        (Get-DbaServerAudit -SqlInstance $Destination2017 -Silent).Count | Should Be 0
    }
    It "Should not have an audit specification" {
        (Get-DbaServerAuditSpecification -SqlInstance $Destination2017).Count | Should Be 0
    }
    It "Should Not have a linked Server" {
        $SQL2017.LinkedServers.Where{$_.Name -like '*Singapore*'}.Count | Should Be 0
    }
    It "Should have only one Agent Job" {
        (Get-DbaAgentJob -SqlInstance $Destination2017 ).Count | Should Be 1
    }
    It "Should not have Agent Alerts" {
        (Get-DbaAgentAlert -SqlInstance $Destination2017 ).Count| Should Be 0
    }
    It "Should not have Operators" {
        (Get-DbaAgentOperator -SqlInstance $Destination2017 ).Count | Should Be 0
    }
    It "Should not have a proxy" {
        $SQL2017.JobServer.ProxyAccounts.Count | Should Be 0
    }
}

