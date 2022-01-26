
cd Presentations:\ 

$SQLInstances = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'

Describe "Testing Machine $($ENV:COMPUTERNAME) for Pester Demo" {
    foreach ($ServerInstance in $SQLInstances) {
        Context "Checking SQL $ServerInstance " {
            if ($ServerInstance.Contains('\')) {
                $ServerName = $ServerInstance.Split('\')[0]
                $Instance = $ServerInstance.Split('\')[1]
            }
            else {
                $Servername = $ServerInstance
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
            It "$ServerInstance  DBEngine should be Started" {
                $DBEngine.Status | Should Be 'Running'
            }
            $Agent = Get-service -ComputerName $Servername -Name $AgentService
            It "$ServerInstance  Agent should be Stopped" {
                $Agent.Status | Should Be 'Stopped'
            }

            It "$ServerInstance SQL Service Startup Type should be Manual" {
                $DBEngine.startType | Should -Be 'Manual'
            }
            It "$ServerInstance Agent Startup Type should be Manual" {
                $Agent.startType | Should -Be 'Manual'
            }
            It "BackupCompression should be off" {
                (Get-DbaSpConfigure -SqlInstance $ServerInstance -ConfigName 'DefaultBackupCompression').ConfiguredValue |Should -Be 0
            }
        }
    }
} #end describe
