Describe "Presentation Machine" {
    Context "Programmes" {
        It "Should have Code Insiders Open" {
            (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not Be 0
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'SQL Server Administration Made Easy with dbatools.pptx - PowerPoint'
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
    }
}

Describe "SQL State" {
    Context "localhost" {
        It "DEFAULT Instance should be running" {
            (Get-DbaService -InstanceName MSSQLSERVER -Type Engine).STate | SHould -Be 'Running' -Because 'We need this for the demos'
        }
        It "DEFAULT SQL Agent should be running" {
            (Get-DbaService -InstanceName MSSQLSERVER -Type Agent).STate | SHould -Be 'Running' -Because 'We need this for the demos'
        }
    }
}







<#

# Create SMO Objects

## Pester for General Administration

Invoke-Pester -Script '.\Slides and Demos\04 - Basic Administration\AdminPester.ps1'

## Pester for Migrations

Invoke-Pester -Script '.\Slides and Demos\03 - Migrations\MigrationsPester.ps1'

## Pester For Linux Demo

Invoke-Pester -Script '.\Slides and Demos\07 - Linux & docker\LinuxDemoPester.ps1'

## Pester For Pester Demo

Invoke-Pester '.\Slides and Demos\08 - Pester\PesterforSetup.ps1'
#>