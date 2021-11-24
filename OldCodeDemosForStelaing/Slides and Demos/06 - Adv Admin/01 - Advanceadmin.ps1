## Set the local variables
. .\Setup\MachineVars.ps1


#region Trace Flags

## Trace Flags

Get-DbaTraceFlag -SqlInstance $SQLInstances -SqlCredential $sacred 

## we dont need those backup success messages
Enable-DbaTraceFlag -SqlInstance $Instance1 -TraceFlag 3226

## we have a large table and want to update stats at a lower threshhold
Enable-DbaTraceFlag -SqlInstance $Instance1 -TraceFlag 2371

## Capture deadlocks to the error log ?

Enable-DbaTraceFlag -SqlInstance $Instance1 -TraceFlag 1204

Get-DbaTraceFlag -SqlInstance $SQLInstances -SqlCredential $sacred 

## remove them

Disable-DbaTraceFlag -SqlInstance $Instance1 -TraceFlag 3226,2371,1204

Get-DbaTraceFlag -SqlInstance $SQLInstances -SqlCredential $sacred 

#endregion

#region Execution Plans

Invoke-Item 'C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\DBAReports Demo\DBA Reports Demo\DBA Reports Demo\01 - DBA Reports Demo.sql'

Get-DbaExecutionPlan -SqlInstance $Instance3 -Database DEMOdbareports | OGV

Get-DbaExecutionPlan -SqlInstance $Instance3 -Database DEMOdbareports -Force

Get-DbaExecutionPlan -SqlInstance $Instance3 - | Export-DbaExecutionPlan -Path c:\temp\exportplan.sql


#endregion

#region Query Store

Get-DbaDbQueryStoreOptions -SqlInstance $instance3 | ogv

$setDbaDbQueryStoreOptionsSplat = @{
    CaptureMode = 'Auto'
    SqlInstance = $Instance3
    FlushInterval = 900
    CollectionInterval = 60
    MaxSize = 100
    Database = 'Database'
    State = 'Off'
}
Set-DbaDbQueryStoreOptions @setDbaDbQueryStoreOptionsSplat 

Get-DbaDbQueryStoreOptions -SqlInstance $Instance3 -Database Database

#endregion

#region XEvents

Get-DbaXEventSession -SqlInstance $Instance3

Read-DbaXEventFile -Path C:\MSSQL\BACKUP\Basic_Trace_0_131518780835570000.xel

Read-DbaXEventFile -Path C:\MSSQL\BACKUP\Basic_Trace_0_131518780835570000.xel | ConvertTo-Json -Depth 3

#endregion

Reset-DbaAdmin -SqlInstance $Instance2 -Login RobsMagicLogin 

Read-DbaTraceFile -SqlInstance $Instance3 

#region
#wanna read a transaction log - Live ??

Read-DbaTransactionLog -SqlInstance $Instance3 -Database DEMOdbareports 
Read-DbaTransactionLog -SqlInstance $Instance3 -Database DEMOdbareports |ogv

Read-DbaBackupHeader -SqlInstance $Instance3 -Path C:\MSSQL\BACKUP\ROB-XPS\DEMOdbareports\DIFF\ROB-XPS_DEMOdbareports_DIFF_20170921_072547.bak
#endregion

#region Delete a database
# SAFELY!!

Remove-DbaDatabaseSafely -SqlInstance $Instance3 -Database $database -BackupFolder $MachineShare 

#endregion

#region Trouble at mill? Whats Running?
$query = "SELECT * FROM Production.TransactionHistory th
INNER JOIN Production.TransactionHistoryArchive tha ON th.Quantity = tha.Quantity"
$query | clip ## then run in SSMS
Invoke-DbaWhoisActive -SqlInstance $Instance3 -ShowSleepingSpids 1|Out-GridView

Get-DbaTopResourceUsage -SqlInstance $Instance3 -Type CPU | Out-GridView
Get-DbaTopResourceUsage -SqlInstance $Instance3 -Type IO | Out-GridView
## How about something cool with Glenn Berrys Diagnostic Queries ? (NOt for SQL2017)

Invoke-DbaDiagnosticQuery -SqlInstance $Instance1 | Out-GridView

## Great Rob - I want to save it to look at it and analyse it though

$Suffix = 'Singapore_' + (Get-Date -Format yyyy-MM-dd_HH-mm-ss)
Invoke-DbaDiagnosticQuery -SqlInstance $Instance1 | Export-DbaDiagnosticQuery -Path C:\temp\Diagnostics -Suffix $Suffix
explorer c:\temp\diagnostics

#endregion

#region Dependancies

#What depends on this table? Which table? I'll know it when I see it (bottom one)

Get-DbaTable -SqlInstance $Instance3  -Database WideWorldImporters | Out-GridView -PassThru | Get-DbaDependency

## What does that table depend on? (OrderLines)
$Depends = Get-DbaTable -SqlInstance $Instance3 -Database WideWorldImporters | Out-GridView -PassThru | Get-DbaDependency -Parents
$Depends

# but the object returns more than that lets look at the first 1
$Depends| Select -First 1 | Select *

#endregion

#region Permissions

Get-DbaUserLevelPermission -SqlInstance $Instance1 | Out-GridView

Get-DbaPermission -SqlInstance $Instance1 | Out-GridView
#endregion
get-help Clear-DbaWaitStatistics


