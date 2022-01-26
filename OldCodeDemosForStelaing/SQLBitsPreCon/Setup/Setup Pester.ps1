<#
The Pester Test for the beginning of the day - We will take snippets of it
out for the beginnign of each session so that we will know if we have broken
something earlier in the day!
#>

<#

Set these depending on the machine
The runs as administrator is only becuase we will be working localy
- Important to tell the folks that it is not required for "usual" work
#>

#Requires -RunAsAdministrator
#Requires -Version 5
#Requires -module dbatools
#requires -module sqlserver

## Set the local variables

. .\Setup\MachineVars.ps1
$VerbosePreference = 'SilentlyContinue'

$SQLInstances = $Instance1, $Instance2, $Instance3 

Describe "Presentation Machine" {
    Context "Hyper-V" {
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "$LinuxHyperVShould Be Running" {
            (Get-VM $LinuxHyperV -ErrorAction SilentlyContinue).State | Should Be 'Running'
        }
    }
}

Describe "SQL State" {
    foreach ($ServerInstance in $SQLInstances) {
        Context "Checking SQL $ServerInstance " {
            if ($ServerInstance.Contains('\')) {
                $ServerName = $ServerInstance.Split('\')[0]
                $Instance = $ServerInstance.Split('\')[1]
            }
            else {
                $Servername = $Server
                $Instance = 'MSSQLSERVER'
            }
            If ($Instance -eq 'MSSQLSERVER') {
                $SQLService = $Instance
                $AgentService = 'SQLSERVERAGENT'
            }
            else {
                $SQLService = "MSSQL$" + $Instance
                $AgentService = "SQLAgent$" + $Instance
            }
            $DBEngine = Get-service -ComputerName $Servername -Name $SQLService
            It "$Server  DBEngine should be running" {
                $DBEngine.Status | Should Be 'Running'
            }
            $Agent = Get-service -ComputerName $Servername -Name $AgentService
            It "$Server Agent should be running" {
                $Agent.Status | Should Be 'Running'
            }
        }
    }
    It "Should have SQL Browser running" {
        (Get-Service SQLBrowser).Status | Should Be 'Running'
    }
    It "Should have SSIS running" {
        (Get-Service MsDtsServer140).Status | Should Be 'Running'
    }
    It "Should have $LinuxHyperV  Linux SQL running" {
        {Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred} | Should Not Throw
    }
}

# Create SMO Objects

try {
    $2016SMO = Get-DbaInstance  -SqlInstance $Source2016
    $2017SMO = Get-DbaInstance  -SqlInstance $Destination2017
    $Linux = Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred
}
catch {
    Write-Warning "Failed to get SMO Objects - Some tests are going to FAIL!!"
}

## Pester for dbatools intro

Invoke-Pester -Script '.\Slides and Demos\02 - What is dbatools\dbatoolsintropester.ps1'

## Pester for Migrations

Invoke-Pester -Script '.\Slides and Demos\03 - Migrations\MigrationsPester.ps1'

## Pester for Basic Administration

Invoke-Pester -Script '.\Slides and Demos\04 - Basic Administration\AdminPester.ps1'

## Pester for SQL Server module

Invoke-Pester -Script '.\Slides and Demos\05 - sqlserver module\SQLSErverModulePesterforSetup.ps1'

## Pester for Advanced Admin 

Invoke-Pester -Script '.\Slides and Demos\06 - Adv Admin\advadminpester.ps1'

## Pester For Linux Containers Demo

Invoke-Pester -Script '.\Slides and Demos\07 - Linux & docker\LinuxDemoPester.ps1'

## Pester for Pester Demo

Invoke-Pester -Script '.\Slides and Demos\08 - Pester\Pester Test.ps1'