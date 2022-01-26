## Reset the values for Robs Machine

#Requires -Version 5
#Requires -module dbatools

$VerbosePreference = 'Continue'

$SQLInstances = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'

## Stop the SQL Services
foreach ($ServerInstance in $SQLInstances) {
    if ($ServerInstance.Contains('\')) {
        $ServerName, $Instance = $ServerInstance.Split('\')
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
    if ((Get-service -Name $SQLService).status -ne 'Stopped') {
        Write-Verbose "Stopping $SQLService Service"
        Stop-Service -Name $SQLService -Force
    }
    if ((Get-service  -Name $AgentService).Status -ne 'Stopped') {
        Write-Verbose "Stopping $AgentService Service"
        Stop-Service -Name $AgentService -Force
    }
    if ((Get-service -Name $SQLService).startType -ne 'Manual') {
        Write-Verbose "Setting Startup for $SQLService to Manual"
        Get-Service -Name $SQLService | Set-Service -StartupType Manual
    }
    if ((Get-service  -Name $AgentService).startType -ne 'Manual') {
        Write-Verbose "Setting Startup for $AgentService to Manual"
        Get-Service -Name $AgentService  |Set-Service -StartupType Manual
    }
}


cd Presentations:\ 

$SQLInstances = 'ROB-XPS','ROB-XPS\DAVE', 'ROB-XPS\SQL2016'

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
            It "$Server  DBEngine should be Stopped" {
                $DBEngine.Status | Should Be 'Stopped'
            }
            $Agent = Get-service -ComputerName $Servername -Name $AgentService
            It "$Server Agent should be Stopped" {
                $Agent.Status | Should Be 'Stopped'
            }

        It "SQL Service Startup Type should be Manual"{
            $DBEngine.startType | Should -Be 'Manual'
        }
        It "Agent Startup Type should be Manual"{
            $Agent.startType | Should -Be 'Manual'
        }
            
        }
    }
} #end describe


$VerbosePreference = 'SilentlyContinue'