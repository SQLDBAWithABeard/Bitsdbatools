
cd Presentations:\ 

Describe "Testing Machine $($ENV:COMPUTERNAME) for Pester Demo" {
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
} #end describe

Describe "Testing for Presentation" {
    Context "Rob-XPS" {        
        It "Shoudl have Code Insiders Open" {
            (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty 
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not BeNullOrEmpty 
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Green is Good - Red is Bad - PowerPoint'
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
        It "Prompt should be Presentations" {
            (Get-Location).Path | Should Be 'Presentations:\'
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
        It "Bolton should be running" {
            (Get-VM -Name Bolton).State | Should Be 'Running'
        }
        It "Bolton Should respond to ping" {
            Test-Connection Bolton -Count 1 -Quiet -ErrorAction SilentlyContinue |Should Be $true
        }
        It "Should have Pester version 4.0.3 imported" {
            (Get-Module Pester).Version | Should Be '4.0.3'
        }
        It "Should have dbatools version 0.9.25 imported" {
            (Get-Module dbatools).Version | Should Be '0.9.25'
        }
    }
}


Describe "Testing for Demo" {
    Context "Shares and Files" {
        It "The Backup Share exists and is accessible" {
            Test-Path $($MachineShare) | Should Be $true
        }
        It "Should have the txt file" {
            Test-Path $MachineShare\FolderCheck\TestFile.Txt | should be $true
        }
        It "Should have only 25 txt files in folder" {
            (Get-ChildItem $MachineShare\FileCheck\*.txt).Count | Should Be 25
        }
        
        It "Exe should be of this version" {
            (Get-ChildItem "C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\SQLPS.exe").VersionInfo.FileVersion | Should Be '14.0.900.75 ((SQL_Main).170727-1527)'
        }
        It "File should have been created on this date"{
            (Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.25\dbatools.psm1').CreationTime | Should Be '08/10/2017 12:24:10'
        }
        It "File should not have been modified since this date"{
            (Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.25\functions\Remove-DbaDatabaseSafely.ps1').LastWriteTime| Should BeLessThan '09 August 2017 23:37:17'
        }
    }

    Context "Programmes"{
        BeforeAll{
            $Programmes = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
        }
        It "Should have Google Chrome" {
            $Programmes.Where{'Google Chrome'} | Should Not BeNullOrEmpty
        }
        It "Should have SSMS 2016" {
            $Programmes.Where{$_.displayname -eq 'SQL Server 2016 Management Studio'} | Should Not BeNullOrEmpty
        }
        It "Should have SSMS 17 RC" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.2'} | Should Not BeNullOrEmpty
        }
        It "SSMS 17 RC should be version 14.0.17177.0" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.2'}.DisplayVersion | Should Be 14.0.17177.0
        }

    It "Should have DNS Servers for correct interface - not if v6" {
        (Get-DnsClientServerAddress -InterfaceAlias 'vEthernet (Beard Internal)').Serveraddresses | Should Be @('10.0.0.1')
    }
    It "Should have correct gateway for alias - not if v6 " {
        (Get-NetIPConfiguration -InterfaceAlias 'vEthernet (Beard Internal)').Ipv4DefaultGateway.NextHop | Should Be '0.0.0.0'
    }
}