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
    if ((Get-service -Name $SQLService).status -ne 'Running') {
        Write-Verbose "Starting $SQLService Service"
        Start-Service -Name $SQLService
    }
    if ((Get-service  -Name $AgentService).Status -ne 'Running') {
        Write-Verbose "Stopping $AgentService Service"
        Stop-Service -Name $AgentService -Force
    }
    
    Set-DbaSpConfigure -SqlInstance $ServerInstance  -ConfigName 'DefaultBackupCompression' -Value 0
}

$VerbosePreference = 'SilentlyContinue'