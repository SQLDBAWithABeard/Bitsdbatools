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

## Navigate to Local path for repo

if ($Env:COMPUTERNAME -eq 'ROB-XPS') {
    # Rob
    Set-Location Git:\PSConfAsiaPreCon
}
## Your Machine name is foundry?
elseif ($Env:COMPUTERNAME -eq 'FOUNDRY') {
    # Jonathan
    Set-Location Git:\PSConfAsiaPreCon
}
elseif($Env:COMPUTERNAME -like '*labmachine*' -or $Env:COMPUTERNAME -eq 'SingaporeBase'){
    Set-Location GIT:\
}
else {
    Write-Warning "Whose machine are you using folks?"
    break
}

## Set the local variables

. .\Setup\MachineVars.ps1


$SQLInstances = $Source2016 , $Destination2017

Describe "Presentation Machine" {
    Context "Programmes" {
        It "Shoudl have Code Insiders Open" {
            (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not Be 0
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'RobAndJonathanVisitSingaporeForAConference - PowerPoint'
        }
        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should BE 0
        }
    }
    Context "Hyper-V" {
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "$LinuxHyperV Should Be Running" {
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

## Pester for General Administration

Invoke-Pester -Script '.\Slides and Demos\04 - Basic Administration\AdminPester.ps1'

## Pester for Migrations

Invoke-Pester -Script '.\Slides and Demos\03 - Migrations\MigrationsPester.ps1'

## Pester For Linux Demo

Invoke-Pester -Script '.\Slides and Demos\07 - Linux & docker\LinuxDemoPester.ps1'

## Pester For Pester Demo

Invoke-Pester '.\Slides and Demos\08 - Pester\PesterforSetup.ps1'
