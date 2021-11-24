## Whats the fundamental process that every DBA should do?
## DATABASE BACKUPS!
## Navigate to Local path for repo


## Set the local variables
. .\Setup\MachineVars.ps1

Return 'Oi Beardy/Non-Beardy pay attention you need to be the right user'

#region Backups, Restores and Testing them
## Everyone tests their restores, correct?

# So when were the last backups done?
Find-DbaCommand -Tag backup | Out-GridView -PassThru | Get-Help -Detailed

Get-DbaBackupHistory -SqlInstance $Source2016

## Lets back up those new databases to a local share

Backup-DbaDatabase -SqlInstance $Source2016 -BackupDirectory "$MachineShare\Backups" -CreateFolder

#Open up the default file location of our destination
Import-Module SqlServer
Invoke-Item (Get-Item SQLSERVER:\SQL\$Source2016).DefaultFile

# and test ALL of our backups :-)
Test-DbaLastBackup -SqlInstance $Source2016 | Out-GridView

## You 'could' just verify them
Test-DbaLastBackup -SqlInstance $Source2016 -Destination $Destination2017 -VerifyOnly | Out-GridView

## So you can see there are a lot of backup and restore and copy commands available. I urge you to explore them
## Use Find-DbaCommand -Tag Backup

#endregion

#region Logs, History and Information
## Lets look at how easy it is to get information about one or many sql server instances from the command line with one line of code

## Where are my Error logs?

Get-DBAErrorLogPath -Instance $Source2016 -Agent

## I want to read my logs too

Get-DbaAgentLog -SqlInstance $Source2016 | Out-GridView

Get-DbaSqlLog -SqlInstance $Source2016  | Out-GridView

Get-DbaDbMailLog -SqlInstance $Source2016 ## I dont have any mail logs :-(

## What about my Jobs?

Get-DbaAgentJobHistory -SqlInstance $Source2016 -StartDate (Get-Date).AddDays(-2)

## Backup history?
Get-DbaBackupHistory -SqlInstance $Source2016

#More Detail
Get-DbaBackupHistory -SqlInstance $Source2016  | select -First 1 | Select *

#Restore History ?
Get-DbaRestoreHistory -SqlInstance $Source2016 -Last

## more detail
Get-DbaRestoreHistory -SqlInstance $Source2016 -Last | select -First 1 | Select *

# I dont have any but you can also check DbMail History
Get-DbaDbMailHistory -SqlInstance $Source2016

## Who changed my database and what did they do?
## This relies on the default trace so it wont be permanent
Get-DbaSchemaChangeHistory -SqlInstance $Source2016 -Database $DBAAdmin

#endregion

#region Alerts
## Are my alerts set up ?

Get-DbaAgentAlert -SqlInstance $Source2016

## Excellent - Perhaps I need a pester test for those for my default setup

Describe "Testing my Defaults" {
    Context "Alerts" {
        $cred = Import-Clixml C:\MSSQL\sa.cred
        $Instances = $SQLInstances
        $testCases = @()
        $Instances.ForEach{$testCases += @{Instance = $_}}
        It "<Instance> Should have at least 12 Alerts" -TestCases $TestCases {
            param($Instance)
            (Get-DbaAgentAlert -SqlInstance $Instance -SqlCredential $cred).Count |Should BeGreaterThan 11

        }
        $Alerts = 'custom alert', 'Error Number 823', 'Severity 016', 'Severity 017', 'Severity 018', 'Severity 019', 'Severity 020', 'Severity 021', 'Severity 022', 'Severity 023', 'Severity 024', 'Severity 025'
        foreach ($alert in $Alerts) {
            It "<Instance> Should have Alert - $Alert" -TestCases $TestCases {
                param($Instance)
                (Get-DbaAgentAlert -SqlInstance $Instance -SqlCredential $cred).Name.Contains($Alert) | Should Be $True
            }
        }
    }
}

#endregion

#region Views, UDF's, Partitions
## Show me the views in a database (now we will use the SQL on Linux server because we can - but they work on Windows too!!)
## JA NEEDS THE LINUX INSTANCE REBUILT
Get-DbaDatabaseView -SqlInstance $LinuxHyperV -SqlCredential $cred -Database WideWorldImporters -ExcludeSystemView

## Show Me UDFs in database or on an instance
Get-DbaDatabaseUdf -SqlInstance $Source2016 -SqlCredential $cred -Database WideWorldImporters -ExcludeSystemUdf

## Show me Database Partition functions
Get-DbaDatabasePartitionFunction -SqlInstance $Source2016 -SqlCredential $cred -Database WideWorldImporters

# more detail
Get-DbaDatabasePartitionFunction -SqlInstance $Source2016 -SqlCredential $cred -Database WideWorldImporters | Select *

## Show Database Partition Schemes
Get-DbaDatabasePartitionScheme -SqlInstance $Source2016 -SqlCredential $cred -Database WideWorldImporters

# more detail
Get-DbaDatabasePartitionScheme -SqlInstance $Source2016 -SqlCredential $cred -Database WideWorldImporters | Select *

#endregion

#region Output objects to T-SQL Files
# Export the create tables TSQL for my database please
if (!($DBAAdmin)) {

    if (!(Test-Path c:\temp\$DBAAdmin)) {
        New-Item c:\temp\$DBAAdmin -ItemType Directory
    }

    if (!(Test-Path c:\temp\$DBAAdmin\Tables)) {
        New-Item c:\temp\$DBAAdmin\Tables -ItemType Directory
    }
    cd c:\temp\$DBAAdmin\Tables
    $tables = Get-DbaTable -SqlInstance $Source2016 -Database $DBAAdmin
    foreach ($t in $tables) {
        $file = $t.Schema + $t.Name + '.sql'
        $T | Export-DbaScript -Path $file ## Export-DbaScript works with any SMO object
    }
    Explorer C:\temp\$DBAAdmin

}
else {
    "No $DBAAdmin variable value." | Write-Output
    break
}

## You could do the same with Views, triggers, stored procedures etc

#endregion

#region Robs Favourite - DBCC CheckDb
## How do you get the last DBCC CheckDB date ? DBCC DBINFO([DBA-Admin]) WITH TABLERESULTS

## So How long to get the Last Known Good Check DB Date for many databases on many instances?

## This long for 3 instances and 32 databases :-)
$db = (Get-DbaDatabase -SqlInstance $SQLInstances).Count
$i = $SQLInstances.Count

$t = (Measure-Command {Get-DbaLastGoodCheckDb -SqlInstance $SQLInstances | Out-GridView})
"Checked DBCC CHECKDB on $i instances with $db databases in $($t.seconds) seconds." | Write-Output

## Of course I wrote a Pester Test for this :-)
## You can find them on my blog or https:\\github.com\SQLDBAWithABeard\dbatools-scripts

Describe "SQL Server Tests" {
    Context "DBCC Checks" {
        foreach ($Server in $SQLInstances) {
            $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -SqlCredential $cred -ExcludeDatabase tempdb -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            foreach ($DBCCTest in $DBCCTests) {
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a successful CheckDB" {
                    $DBCCTest.Status | Should Be 'Ok'
                }
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a CheckDB run in the last 7 days" {
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan 7
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should Not BeNullOrEmpty
                }
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) has Data Purity Enabled" {
                    $DBCCTest.DataPurityEnabled| Should Be $true
                }
            }
        }
    }
}

## Of course, those new databases wont have

#endregion

#region Getting and finding things
(Get-DbaAgentJob -SqlInstance $Source2016 -Job 'DatabaseIntegrityCheck - SYSTEM_DATABASES', 'DatabaseIntegrityCheck - USER_DATABASES').Start()
Get-DbaAgentJob -SqlInstance $Source2016 -Job 'DatabaseIntegrityCheck - SYSTEM_DATABASES', 'DatabaseIntegrityCheck - USER_DATABASES'

## There are a WHOLE load more Gets
Get-Command -module dbatools Get*

## How about Finding things

## Can you find me the Agent jobs without a schedule

Find-DbaAgentJob -SqlInstance $Instance1 -NoSchedule

## Can you find me the Duplicate indexes please
Find-DbaDuplicateIndex -SqlInstance $Instance1 -Database AdventureWorks2016

## Can you find that stored procedure please, you know, the one with the email address, I think its on that Linux instance
Find-DbaStoredProcedure -SqlInstance $Instance1 -Pattern '\w+@\w+\.\w+'

## Can you find me the view with the sensor data?
Find-DbaView -SqlInstance $Instance1 -Pattern sensor

## Can you find me the trigger with TotalPurchaseYTD
Find-DbaTrigger -SqlInstance $Instance1 -Pattern TotalPurchaseYTD

## There are plenty more Finds - I like Find-DbALoginInGroup
Find-DbaCommand Find*

#endregion

