Describe "Testing System" {
    It "Should have the SqlServer Module Loaded" {
        (Get-Module -Name SqlServer).Length | Should Be 1
    }
    It "Should not have the SqlPS Module Loaded" {
        (Get-Module -Name SqlPS).Length | Should Be 0
    }
    It "Should have a duff Linux registered server" {
        (Get-ChildItem 'SQLSERVER:\SQLRegistration\Database Engine Server Group\Rob-XPS\*linux*').Name | Should be '01 - Linux'
    }
    It "SSMS should be open" {
        (Get-Process ssms).Count | Should beGreaterthan 0
    }
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
}