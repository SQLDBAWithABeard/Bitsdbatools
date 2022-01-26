<#
This is our main setup at the begining of the day
Once this is run then we should be able to run the Set up Pester test without issue
The challenge is to then make sure that anything we add in our demos is added
 to the Pester test to make sure each part of the demo works as expect

Requirements to be created

 2 or 3 instances
We both have SQL 2016 and SQL2017 instances and I will have a hyper V running Ubuntu SQL 2017 RC

Databases

I have WideWorldImporters and Adventureworks 2014 we could add a couple of other smaller ones that
we make if needed

Anything with a * there is already setup and pester in manchester dbatools that can be altered to fit what we need

Users*
Credentials*
Audit*
Audit Specification*
Linked Server*
Proxy*
Operator
Agent Jobs/categories/schedules
Alerts
CMS ? - I dont like it but lots of people use it and dbatools can make use of it easily
Endpoint
Extended Event - We will need that for your session anyways?
Resource Governor?
Triggers
SPConfigure - This will be good for your migrations bit
Mail Profiles?
SSIS?

Have I missed anything?

#>


#Requires -Version 5
#Requires -module dbatools

## Set the local variables

. .\Setup\MachineVars.ps1

## Start Linux VM if not running
If ((Get-VM -Name $LinuxHyperV).State -ne 'Running') {
    Get-VM -Name $LinuxHyperV | Start-VM
    Write-Output "Starting VM"
}

## Naming ?
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

# Create SMO Objects

try {
    Write-Output "Creating 2016 SMO Object"
    $2016SMO = Get-DbaInstance  -SqlInstance $Source2016
}
catch {
    Write-Warning "FAILED - Creating 2016 SMO Object"
    break
}
try {
    Write-Output "Creating 2017 SMO Object"
    $2017SMO = Get-DbaInstance  -SqlInstance $Destination2017
}
catch {
    Write-Warning "FAILED - Creating 2017 SMO Object"
    break
}
try {
    Write-Output "Creating Linux SMO Object"
    $Linux = Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred
}
catch {
    Write-Warning "FAILED - Creating Linux SMO Object"
    break
}


## 03 Migrations
## Ensure all required objects in SQL2016

## Add Windows User

New-LocalUser -Name SQLDemoAccount -Description "Test user for Singapore Demo" -Password $sacred.Password

## Add logins

Write-Output "Adding logins to $Source2016"
$Password = 'DuffPassword01'
$i = 9
While ($i -gt 0)
{
    $User = 'UserForSingaporeDemo_' + [string]$i
    $Pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
    Add-SqlLogin -ServerInstance $Source2016 -LoginName $User -LoginType SqlLogin -DefaultDatabase tempdb -Enable -GrantConnectSql -LoginPSCredential $Credential
    $i --
}

## Add Credential

Write-Output "Adding Credential to $Source2016"
$Script = @"
CREATE CREDENTIAL [SingaporeCredential] WITH IDENTITY = N'$WindowsUser', SECRET = N'$($sacred.GetNetworkCredential().Password)'
"@
Invoke-Sqlcmd -ServerInstance $Source2016 -Database master -Query $script

## Add Audit
Write-Output "Adding audit to $Source2016"
$script = @"
CREATE SERVER AUDIT [SingaporeDemoSQLAudit]
TO FILE
(	FILEPATH = N'C:\TEMP'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

"@
Invoke-Sqlcmd -ServerInstance $Source2016 -Database master -Query $script

## Add server audit specification
Write-Output "Adding audit specification to $Source2016"
$Script = @"
CREATE SERVER AUDIT SPECIFICATION [SingaporeAuditSpecification]
FOR SERVER AUDIT [SingaporeDemoSQLAudit]
ADD (FAILED_LOGIN_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (BACKUP_RESTORE_GROUP),
ADD (DBCC_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP)
"@
Invoke-Sqlcmd -ServerInstance $Source2016 -Database master -Query $script

# Create linked server
Write-Output "Adding linked server to $Source2016"
$script = @"
EXEC master.dbo.sp_addlinkedserver @server = N'SingaporeDAVE', @srvproduct=N'SQL Server'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'SingaporeDAVE', @locallogin = NULL , @useself = N'False'
"@
Invoke-Sqlcmd -ServerInstance $Source2016 -Database master -Query $script

## Create Proxy
Write-Output "Adding proxy to $Source2016"

$Script = @"
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'SingaporeDemoProxy',@credential_name=N'SingaporeCredential',
		@enabled=1
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'SingaporeDemoProxy', @subsystem_id=12
"@
Invoke-Sqlcmd -ServerInstance $Source2016 -Database master -Query $script

## Remove all databases from Destination Server
Write-Output "Remove Databases from $Destination2017"
foreach($db in $2017SMO.Databases.Where{$_.IsSystemObject -eq $false}){
    $db.Name
    $db.DropIfExists()
}

## Remove all logins from Destination
#Rob
$exclude = '#MS_PolicyEventProcessingLogin##', '##MS_PolicyTsqlExecutionLogin##', 'NT AUTHORITY\SYSTEM'
$exclude = 'NT SERVICE\SQLWriter','NT SERVICE\Winmgmt','ROB-XPS\mrrob','sa'
$exclude += 'NT Service\MSSQL$SQL2017','NT SERVICE\SQLAgent$SQL2017','NT SERVICE\SQLTELEMETRY$SQL2017'
# JA
$exclude += 'NT Service\MSSQL$SQL2017CTP2','NT SERVICE\SQLAgent$SQL2017CTP2'
$exclude += 'NT SERVICE\SQLTELEMETRY$SQL2017CTP2', 'Foundry\Jonathan'

foreach ($login in $2017SMO.Logins.Where{$_.Name -notin $exclude}) {
    $Login.Drop()
}

# Remove all jobs from Singapore
$Jobs =  (Get-DbaAgentJob -SqlInstance $2017SMO.Name).Where{$_.Name -notlike '*syspolicy*'}
$Jobs.DropIfExists()

# Remove all Alerts from Singapore
$Alerts = Get-DbaAgentAlert -SqlInstance $2017SMO.Name
$Alerts.DropIfExists()

## remove Operator form Singapore

$ops = Get-DbaAgentOperator -SqlInstance $2017SMO.Name
$ops.DropIfExists()

## Remove proxy from Singapore
$2017SMO.JobServer.ProxyAccounts['SingaporeDemoProxy'].DropIfExists()

## remove credntials
$creds = $2017SMO.Credentials
$creds | ForEach-Object {$_.DropIfExists()}

## remove audit

(Get-DbaServerAudit -SqlInstance $2017SMO.Name).dropifexists()

## remove audit specification

(Get-DbaServerAuditSpecification -SqlInstance $2017SMO.Name).dropifexists()

## Remove linked server from Destination

$links = $2017SMO.LinkedServers.Where{$_.Name -like '*Singapore*'}
$Links | ForEach-Object {$_.DropIfExists($true)}

## Remove table from DBA-Admin

# (Get-DbaTable -SqlInstance Rob-XPS\SQL2016 -Database DBA-Admin -Table SingaporeDemo).Drop()

## 06 Linux Setup

## Set the Default backup compression

if ($Linux.Version) {
    try {
        Write-Output "Altering backup compression on linux box"
        $Linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
        $Linux.Configuration.Alter()
    }
    catch {
        Write-Warning "Failed to set Linux backup compression Configuration"
        $_ | fl -Force
        break
    }

}
else {
    Write-Warning "Hmm Linux SQL not started??????"
    break
}

# start the backup jobs so there is history :-)
if ($Linux.Version) {
    try {
        Write-Output "Starting Linux Agent Jobs"
        (Get-DbaAgentJob -SqlInstance $Linux ).Where{$_.Name -like '*DatabaseBackup*' -and $_.Name -notlike '*NAS*'}.start()
    }
    catch {
        Write-Warning "FAILED - Starting Linux SQL Agent Jobs"
        break
    }
}
else {
    Write-Warning "Hmm Linux SQL not started??????"
    break
}

