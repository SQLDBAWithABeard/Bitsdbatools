
$SQLInstances = $Source2016 , $Destination2017
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
}