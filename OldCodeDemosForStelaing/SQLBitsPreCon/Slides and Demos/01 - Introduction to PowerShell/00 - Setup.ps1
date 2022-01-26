

## 
$Instance1Name = 'SQL2016'
$Instance2Name = 'MSSQLSERVER'
$Source2016 = "$Env:COMPUTERNAME\$Instance1Name"
$Destination2017 = "$Env:COMPUTERNAME\$Instance2Name"

$SQLInstances = $Source2016 , $Destination2017


## Start the SQL Services
foreach ($ServerInstance in $SQLInstances) {
    if ($ServerInstance.Contains('\')) {
        $ServerName, $Instance = $ServerInstance.Split('\')
        #$ServerName = $ServerInstance.Split('\')[0] # delete when above change is working
        #$Instance = $ServerInstance.Split('\')[1] # delete when above change is working
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
        Write-Output "Starting $SQLService Service"
        Start-Service -Name $SQLService
    }
    if ((Get-service  -Name $AgentService).Status -ne 'Running') {
        Write-Output "Starting $AgentService Service"
        Start-Service -Name $AgentService
    }


}

## Start SQL Browser

if ((Get-Service SQLBrowser).Status -ne 'Running') {
    Start-Service -Name SQLBrowser
    Write-Output "Starting SQLBrowser Service"
}


Write-Output  "We will be using this as Source $Source2016 "
Write-Output  "We will be using this as Destination $Destination2017"
