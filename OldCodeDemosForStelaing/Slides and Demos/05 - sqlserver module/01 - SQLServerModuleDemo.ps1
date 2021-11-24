Return "This is a demo Beardy!"
## The SQL Server Provider is just like Object Explorer in SSMS (Sort of)
##

## Set the local variables and change path
. .\Setup\MachineVars.ps1

## Need to run the setup to get the errors
& '.\Slides and Demos\05 - sqlserver module\SQLSErverModulePesterforSetup.ps1'

#region Getting the module and PSDrive
## NOTE: Get the SSMS latest release from here https://sqlps.io/dl
## You can also use Install-Module sqlserver now :-) :-) !

Import-Module SqlServer

## PowerShell has PSDrives which enable you to navigate resources like directories

Get-PSDrive

## See the SQLSERVER Drive? Lets navigate to that

CD SQLSERVER:\
DIR;
#endregion

#region Registered Servers
## What's inside SQLRegistration?

Set-Location SQLSERVER:\SQLRegistration
Get-ChildItem

## Try and tab this :-(
Set-Location 'Database Engine Server Group'
Get-ChildItem

## Its my registered servers - note multiple SSMS versions can make this tricky!

Set-Location Rob-xps

Set-Location Rob-XPS

Get-ChildItem | Select -First 1 | Select *

## you remove them from the registered servers list too

gci *linux* | remove-item 

#endregion

#region Getting some information using the registered servers and dbatools
## Want a list of server names

$allInstances = (Get-ChildItem).ServerName

## so you could ping them all to check 

Test-Connection (Get-ChildItem).ServerName -count 1

## If you have instance names use this

(Get-ChildItem).ServerName.Foreach{Test-Connection $_.Split('\')[0] -count 1}

# Use the dbatools module from https://dbatools.io to quickly get information using the provider
# Simply because it is so beautiful and everyone should know about it

# How long has my estate been up?

Get-DbaUptime -SqlServer $allInstances.Where{$_ -ne $LinuxHyperV} | ogv

# Which port?

Get-DbaTcpPort -SqlServer $allinstances -Credential $sacred | ogv

## My latency 

Test-SqlNetworkLatency  $allinstances -SqlCredential $sacred  | ogv

## Last backup?

Get-DbaLastBackup  $allinstances -SqlCredential $sacred | Out-GridView

## Last Good CheckDB ?

Get-DbaLastGoodCheckDb  $allinstances -SqlCredential $sacred| ogv

#endregion

#region Connecting to SQL Instance
## Lets Connect to SQL Server

Set-Location SQLSERVER:\SQL 

## Thats the local machine lets have look inside that 'folder'

$SQLServer = $env:COMPUTERNAME
Get-ChildItem .\$SQLServer

## I have Two Instances

Get-ChildItem SQLSERVER:\SQL\$SQLServer\DEFAULT

## NOTE: You can connect to remote servers too

# Get-ChildItem SQLSERVER:\SQL\SQL2016N1\Instance1

## What do we have ?

Get-Item SQLSERVER:\SQL\$SQLServer\DEFAULT | Get-Member -Static

## Just an SMO Server which we can do with as we please :-)

## NOTE: You can create SQL Authentication SQL SERVER PSDrives as well 
## Lets connect to SQL Server on Linux


# New-PSDrive -Name  SA-XPS -PSProvider SqlServer -Credential (Get-Credential -UserName SA -Message 'Enter SA Credentials') -Root "SQLSERVER:\SQL\$SQLServer\Default"

New-PSDrive -Name  SA-XPS -PSProvider SqlServer -Credential $sacred -Root "SQLSERVER:\SQL\$SQLServer\Default"

Set-Location SA-XPS:\

(Get-PSDrive).Name

Get-item .

ls

## Can we connect to linux? 
Set-Location SQLSERVER:\SQL\$LinuxHyperV

## This is the best way to create a SMO Server object now

$linux = Get-DbaInstance $LinuxHyperV -credential $sacred
$linux.HostDistribution
$Linux.HostPlatform
$linux.HostRelease

#endregion

#region Database information
## Lets create a database for this demo. This code will download a 4Mb .bak file 
## to your default backup directory and restore it as ProviderDemo using your default file paths
Set-Location SQLSERVER:\SQL\$SQLServer
$Instance = Get-Item DEFAULT
CD PRESENTATIONS:\  
$defaultbackup = $Instance.BackupDirectory
$BackupFile = "$defaultbackup\ProviderDemo.bak" 
Invoke-WebRequest -Uri 'https://onedrive.live.com/download?cid=C802DF42025D5E1F&resid=C802DF42025D5E1F%21418412&authkey=ACrHu72Apu0dIsQ' -OutFile $BackupFile
$DataFile = $($Instance.DefaultFile) + 'ProviderDemo.mdf'
$LogFile = $($Instance.DefaultLog) + 'ProviderDemo.ldf'
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("ProviderDemo", $DataFile)
$RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("ProviderDemo_Log", $LogFile)
Restore-SqlDatabase -ServerInstance $SQLServer -Database ProviderDemo -BackupFile $BackupFile -ReplaceDatabase -RestoreAction Database -RelocateFile @($RelocateData,$RelocateLog) 

#Using Script parameter you can see its just T-SQL

Restore-SqlDatabase -ServerInstance $SQLServer -Database ProviderDemo -BackupFile $BackupFile -ReplaceDatabase -RestoreAction Database -RelocateFile @($RelocateData,$RelocateLog) -script


## But for now we will stick with a local machine and the PSDrive
## Lets take a look at the databases on this machines default instance

Set-Location SQLSERVER:\SQL\$SQLServer\DEFAULT
Get-ChildItem .\Databases |ft -AutoSize -Wrap

## So we can navigate these as if they were a file structure and they 
## basically match the Object Explorer

$DbName = 'ProviderDemo' ## Change this if you are not using the demo database

## Database
Set-Location Databases\$DbName 
Get-ChildItem
Get-Item . | Select-Object Name , CreateDate, LastBackupDate
## Tables
Set-Location Tables
Get-ChildItem

## A Table
Set-Location dbo.InstanceList
Get-ChildItem

## Columns
Set-Location Columns
Get-ChildItem

## Or Indexes

Set-Location .\..\Indexes
Get-ChildItem 

## OK thats cool, we can see those things but what else?
## Lets go back to databases

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases

## So we can display some properties just like in SSMS (Show in SSMS here)

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-Item $DbName | Select-Object Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable

## Lets have a look at some tables

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex |
Format-Table -AutoSize

## You can output this to Out-GridView for a different experience which allows you to filter

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex |
Out-GridView

## This can be really useful for enabling user choice

## BUT YOU WONT BE ABLE TO DO IT IN PowerShell 6 as it stands right now

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |Out-GridView -Title 'Choose a table and press ok' -PassThru |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex 

## Not sure which property you want? (Select * isnt bad here :-) )

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-Item $DbName  | Select *

## Brilliant, we can get properties, we can enable user choice, I want to DO something

## Lets script out our table using Out-GridView to choose the table
Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
$MeTable = Get-ChildItem .\$DbName\Tables |Out-GridView -Title 'Choose a table and press ok' -PassThru 
$MeTable.script()

## And put the script in a file

$MeTable.script() | Out-File C:\Temp\$($MeTable.Name).sql
Invoke-Item C:\Temp\$($MeTable.Name).sql

$tables = Get-ChildItem .\$DbName\Tables

## Get the statistics details

$tables.Foreach{ $_.Statistics.Foreach{ $_ | Select Parent, Name, LastUpdated } }

## Cool lets update the statistics on the databases table
$tables.Where{$_.Name -like 'Databas*'}.UpdateStatistics()

## Now lets check

$tables.Where{$_.Name -like 'Databas*'}.Statistics.LastUpdated

## Hang on Didnt we just update those Statistics ?
## NOTE: The object doesnt update with changes - Just like SSMS doesn't - You have to press refresh :-)
## Theres a method for that

$tables.Statistics.Refresh()
$tables.Where{$_.Name -like 'Databas*'}.Statistics.LastUpdated

#endregion

#region Polices

## Lets set a server SMO to be a variable - we'll need it in a minute

$srv = Get-Item SQLSERVER:\SQL\$SQLServer\DEFAULT

cd SQLSERVER:\

cd SQLPolicy\$SQLServer\DEFAULT

ls

cd Policies

gci 'SQL S*' ## GRRRRRRRR

(gci).Where{$_.Name -like 'SQL S*'}.Name 

## Lets evaluate our Policies - this is why we needed the SMO Server object

(gci).Where{$_.Name -like 'SQL S*'}.Foreach{$_.Name;$_.Evaluate('Check',$srv)}

#endregion

#region SSIS
## Lets look at SSIS

cd SQLSERVER:\SSIS\$SQLServer\DEFAULT

## GRRRRR

Add-Type -Path 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SSIS\140\Binn\Microsoft.SqlServer.Management.IntegrationServices.dll'

## Lets look at SSIS

cd SQLSERVER:\SSIS\$SQLServer\DEFAULT

## So we can navigate to the SSISDB catalog 

cd catalogs\ssisdb

ls

gci -Recurse

# Curse and recurse ;-)

ls 'Folders\SSIS Database Demo\Projects\SSIS Database Demo\packages\'| select Name

(ls 'Folders\SSIS Database Demo\Projects\SSIS Database Demo\packages\').Where{$_.Name -like '*Customers*'} | gm -membertype methods | ft -wrap

(ls 'Folders\SSIS Database Demo\Projects\SSIS Database Demo\packages\').Where{$_.Name -like '*Customers*'}.Execute(32,$Null)

## Look in SSMS to see it has just run

## lets get the parameters of the package

ls 'Folders\SSIS Database Demo\Projects\SSIS Database Demo\packages\ExportCustomers%2Edtsx\parameters' | Select DisplayName, ObjectName,DesignDefaultvalue | ft

 ## Lets look at the executions

 ls Executions | Select id, FolderName,ProjectName, PackageName,startTime, EndTime, Completed, Status | ft

 (ls Executions).ForEach{$_.Refresh()}

 ## Want a bit more information?

 cd  Executions

(ls).Messages.message

#endregion

#region Xevents

cd SQLSERVER:\Xevent\$SQLServer\DEFAULT

gci

## look at the sessins

ls Sessions

$sessions = Get-ChildItem .\sessions 
$sessions[0].ScriptCreate().GetScript()
## look at the targets
(ls sessions).Where{$_.Name -eq 'system_health'}.targets

## read the data
(ls sessions).Where{$_.Name -eq 'system_health'}.targets[1].GetTargetData()

## output to a file
(ls sessions).Where{$_.Name -eq 'system_health'}.targets[1].GetTargetData() |Out-File c:\temp\system_health.xml
code-insiders c:\temp\system_health.xml

## save to a variable
[xml]$xml = (ls sessions).Where{$_.Name -eq 'system_health'}.targets[0].gettargetdata()


 # For SQL 2014/6/7 you have to add the reference to Microsoft.SqlServer.XE.Core.dll. You don't need this for SQL 2012

Add-Type -Path 'C:\Program Files\Microsoft SQL Server\130\Shared\Microsoft.SqlServer.XE.Core.dll'
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\130\Shared\Microsoft.SqlServer.XEvent.Linq.dll'

$ExEventsFile = $xml.EventFileTarget.File.Name
$events = New-Object Microsoft.SqlServer.XEvent.Linq.QueryableXEventData($ExEventsFile)

$error_number = @{Name = 'error_number'; Expression = {$_.Fields['error_number'].Value}}
$severity     = @{Name = 'severity' ; Expression = {$_.Fields['severity'].Value}}
$state        = @{Name = 'state'; Expression = {$_.Fields['state'].Value }}
$category     = @{Name = 'category '; Expression = {$_.Fields['category'].Value }}
$message      = @{Name = 'message '; Expression = {$_.Fields['message'].Value }}

## choose some entries where the error numbers are not empty and the state is not 1
$events | Select Name, TimeStamp, $error_number, $severity,$state,$category,$message | ogv -PassThru | Select * | ft -Wrap

## See how many there are
$events | Foreach-Object { $_.Fields | Where-Object { $_.Name -eq 'severity' } } | Group-Object Value

#endregion

#region A little bit of fun with Out-GridView
$srv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $SQLServer
$db = $srv.Databases['AdventureWorks2014']

## Findi the biggest tables, bet it is in there

$db.Tables | Sort DataSpaceUsed -Descending | select Schema, Name ,DataSpaceUsed, RowCount -First 1

## We'll grab all of the data into Out-GridView
$query = "SELECT * FROM Person.Person"
$results = Invoke-sqlcmd2 -ServerInstance $SQLServer -Database AdventureWorks2014 -Query $query
$results | ogv

#endregion

#region  SQL Server Provider Lab Questions and Answers

## 1 
## Using the SQLServer Provider list the logins on the default server
## 2
## List the logins that are disabled showing their Name, Default Database, Create Date and Login type
## 3
## List the name of the two oldest created Logins on the server
## 4
## Use Out-GridView to select 3 logins and display their name, if they have connect permissions and 
## their SID and then save that information to a file
## 5
## Using the SQL Provider list the members of the sysadmin role and
##  as good exams say, show your working out


## SQL Server Provider Answers

## 1

## To list the logins
$SQLServer = $env:COMPUTERNAME
$InstanceName = 'DEFAULT'
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName
Get-ChildItem .\Logins

## 2
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Where-Object {$_.IsDisabled -eq $true} | Select Name, DefaultDatabase, CreateDate, LoginType

## 3

Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Sort-Object CreateDate -descending | Select-Object -first 2 | Select-Object Name

## 4 

Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Out-GridView -PassThru | Select Name, HasAccess,SID |Out-File c:\temp\answer4.txt
Invoke-Item c:\temp\answer4.txt 

## 5
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\
Get-ChildItem
Set-Location   Roles
Get-ChildItem | Get-Member
$sysadmin = Get-ChildItem | Where-Object {$_.Name -eq 'sysadmin'}
## also an acceptable answer 
$roles = Get-ChildItem
$sysadmin = $roles['sysadmin']
$sysadmin | Get-Member
$sysadmin.EnumMemberNames()

#endregion