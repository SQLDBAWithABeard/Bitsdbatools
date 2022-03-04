<# 
______            _                                  _  ______          _                 
| ___ \          | |                                | | | ___ \        | |                
| |_/ / __ _  ___| | ___   _ _ __     __ _ _ __   __| | | |_/ /___  ___| |_ ___  _ __ ___ 
| ___ \/ _` |/ __| |/ / | | | '_ \   / _` | '_ \ / _` | |    // _ \/ __| __/ _ \| '__/ _ \
| |_/ / (_| | (__|   <| |_| | |_) | | (_| | | | | (_| | | |\ \  __/\__ \ || (_) | | |  __/
\____/ \__,_|\___|_|\_\\__,_| .__/   \__,_|_| |_|\__,_| \_| \_\___||___/\__\___/|_|  \___|
                            | |                                                           
                            |_|                                                           
#>

cls

# Lets take a look at the databases on the first instance

Get-DbaDatabase -SqlInstance $dbatools1

# we can get particular properties 

Get-DbaDatabase -SqlInstance $dbatools1 | Select Name, Status, LastFullBackup

# Added PowerShell bonus, you can see which properties you can 'select' (The columns on a table) with Get-Member

Get-DbaDatabase -SqlInstance $dbatools1 | Get-Member

# Lets check the file system from the viewpoint of the SQL Instance Service Account

Get-DbaFile -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/firstbackup

# not like ls ;-)

ls /var/opt/mssql/data/backups/firstbackup

ls /var/opt/mssql/data

# No result means nothing to see - Lets back up the entire instance in one quick line of code

Backup-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/firstbackup
Backup-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/firstbackup -Type Log

# Lets check the file system from the viewpoint of the SQL Instance Service Account again

Get-DbaFile -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/firstbackup

# and from the OS just so you can see there is nothing up our sleeves

ls /var/opt/mssql/data/backups/firstbackup

ls -l -R /var/opt/mssql/data

# now if we check the user databases last backup time 

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Select Name, Status, LastFullBackup | Format-Table

# or we could use

Get-DbaLastBackup -SqlInstance $dbatools1 

# What was that Warning?

# or 

Get-DbaDbBackupHistory -SqlInstance $dbatools1

# Lets back up the entire instance in one quick line of code but this time put things in separate directories

Backup-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1 -CreateFolder

# Lets check the file system from the viewpoint of the SQL Instance Service Account again

Get-DbaFile -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1 

ls -l /var/opt/mssql/data/backups/dbatools1

ls -l /var/opt/mssql/data/backups/dbatools1/pubs

# How about restoring databases

# Well PowerShell and therefore dbatools is very very powerful so lets teach you about WhatIf first

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -WhatIf

# So we can ensure that a user makes good decisions by ensuring they use confirm (dbatools does this by default ....)

# ALSO - NEVER RUN THIS IN PROD UNLESS YOUR CV IS UP TO DATE - EVEN IF YOUR CV IS UP TO DATE

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -Confirm

# so what do we have ?

Get-DbaDatabase -SqlInstance $dbatools1 | Format-Table

# just the system databases

# OH NO A DISASTER HAS BEFALLEN US
# Can you restore all the databases please
# One line of code - 10 seconds in browser

Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1 

# what were those warnings??????

# You can even restore with the same backup to numerous databases 23 seconds browser

0..10 | ForEach-Object -Parallel {
    $securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
    $continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)
    $dbname = 'pubs-{0}' -f $psitem
    Restore-DbaDatabase -SqlInstance $using:dbatools1 -SqlCredential $continercredential -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName $dbname -DestinationFilePrefix $psitem -ReplaceDbNameInFile 
} 

<# 
If we were not in PowerShell Core we could do this

0..10 | ForEach-Object {
    $dbname = 'pubs-{0}' -f $psitem
    Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName $dbname -DestinationFilePrefix $psitem -ReplaceDbNameInFile 
}
#>

# Super super easy - it will even do this, when the files are more complicated

# lets get all of our databases now
$databases = Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem 

$databases | Select Name

# define a path and do a full backup for each 11 seconds browser
$RandomPath = '/var/opt/backups/dbatools1/random'
Backup-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath -CompressBackup -Database $databases.Name

# Then create a random number of types of backups for our databases - 5.8 seconds Robs desktop - 23 seconds browser

0..50 | ForEach-Object -Parallel {
    $securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
    $continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)
    $db = Get-Random $Using:databases.Name
    $type = Get-Random 'Full', 'Diff', 'Log'
    Backup-DbaDatabase -SqlInstance $Using:dbatools1 -SqlCredential $continercredential -Database $db -Path $Using:RandomPath -CompressBackup -Type $type
}

<# 
#Windows PowerShell Version
# 15 secs - Robs desktop 33 seconds browser
$x = 50
while ($x -ge 0) {
    $db = Get-Random $databases.Name
    $type = Get-Random 'Full','Diff','Log'
    Backup-DbaDatabase -SqlInstance $dbatools1 -Database $db -Path $RandomPath -CompressBackup -Type $type
    $x --    
}
#>


Get-ChildItem $RandomPath

# Looks complicated to get those all restored in the right order ?

# Remove the databases - no confirm this time

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# ONE

# LINE

# OF

# CODE - 1 minute 6 seconds in the browser 18 seconds Robs desktop 46 seconds Robs laptop

Restore-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath

ls -l $RandomPath

# Oh - Your estate doesn't have all the backups in one directory (we know some that do)

# ok lets backup with create folder and get some more files to play with 9 seconds - Robs desktop 56 seconds browser

$databases = Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem 

$databases.Name

0..100 | ForEach-Object -Parallel {
    $securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
    $continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)
    $db = Get-Random $Using:databases.Name
    $type = Get-Random 'Full', 'Diff', 'Log'
    Backup-DbaDatabase -SqlInstance $Using:dbatools1 -SqlCredential $continercredential -Database $db -Path $Using:RandomPath -CompressBackup -Type $type -CreateFolder

    if ($_ % 10 -eq 0) {
        $BackupName = "{0}_{1}_TestForJA_DoNotDELETE.bak" -f $db, $_
        Backup-DbaDatabase -SqlInstance $Using:dbatools1 -SqlCredential $continercredential -Database $db -Path $Using:RandomPath -CompressBackup -Type Full -CreateFolder -CopyOnly -FilePath  $BackupName 
        Write-Output "I did a special backup $BackupName"
    }
    if ($_ % 15 -eq 0) {
        $BackupName = "{0}_{1}_ForUpgrade.bak" -f $db, $_
        Backup-DbaDatabase -SqlInstance $Using:dbatools1 -SqlCredential $continercredential -Database $db -Path $Using:RandomPath -CompressBackup -Type Full -CreateFolder -CopyOnly -FilePath  $BackupName 
        Write-Output "I did a special backup $BackupName"
    }
    if ($_ % 20 -eq 0) {
        $BackupName = "{0}_TestingCode_.bak" -f $_
        Backup-DbaDatabase -SqlInstance $Using:dbatools1 -SqlCredential $continercredential -Database $db -Path $Using:RandomPath -CompressBackup -Type Full -CopyOnly -FilePath  $BackupName 
        Write-Output "I did a special backup $BackupName"
    }
}

<# 
#Windows PowerShell Version
#- 32 secs - Robs desktop 1 minute 10 in the browser
$x = 100
while ($x -ge 0) {
    $db = Get-Random $databases.Name
    $type = Get-Random 'Full','Diff','Log'
    Backup-DbaDatabase -SqlInstance $dbatools1 -Database $db -Path $RandomPath -CompressBackup -Type $type -CreateFolder
    $x --    
}
#>

## so this is more realistic correct?

# More like the last estate that you worked with (not your current one because you are all pros but your last one)

Get-ChildItem $RandomPath

Get-ChildItem $RandomPath -Recurse

(Get-ChildItem $RandomPath -Recurse).count

<# 
# run this in Windows Terminal to see the windows explorer view

explorer \\wsl.localhost\docker-desktop-data\version-pack-data\community\docker\volumes\bitsdbatools_devcontainer_mydata\_data\dbatools1

#>

# Remove the databases - no confirm this time

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# Still only one line of code 23 seconds - Robs Desktop - 1 minute 5 seconds browser

Restore-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath

# So what happened ? Lets take a look

Get-DbaDbRestoreHistory -SqlInstance $dbatools1 | Format-Table

# There is no sorting here so

Get-DbaDbRestoreHistory -SqlInstance $dbatools1 | Sort-Object Date | Format-Table

# So we can take backups, we can perform restores but 

# we don't know if the backups are valid until we have tested them

# Far better to ensure that they are ok and dbatools just loves to help you with that

# Even if you only have a single instance, you can still test your backups. There is no excuse

Test-DbaLastBackup -SqlInstance $dbatools1

# What did it do?

# Maybe we want to put it into a database and we have a dedicated instance for testing?

Test-DbaLastBackup -SqlInstance $dbatools1 -Destination $dbatools2 | Write-DbaDataTable -SqlInstance $dbatools1 -Database pubs -Table BackupTests -AutoCreateTable

$Query = "SELECT  [SourceServer]
,[TestServer]
,[Database]
,[FileExists]
,[Size]
,[RestoreResult]
,[DbccResult]
,[RestoreStart]
,[RestoreEnd]
,[RestoreElapsed]
,[DbccMaxDop]
,[DbccStart]
,[DbccEnd]
,[DbccElapsed]
,[BackupDates]
,[BackupFiles]
FROM [pubs].[dbo].[BackupTests]
"

Invoke-DbaQuery -SqlInstance $dbatools1 -Database pubs -Query $Query



# So the databases were backed up to a place that was not available to the second instance. 
# Lets make it work so you can see, but this is something you will need to consider.

Backup-DbaDatabase -SqlInstance $dbatools1 -Path /shared/BackupTest

Test-DbaLastBackup -SqlInstance $dbatools1 -Destination $dbatools2 | Write-DbaDataTable -SqlInstance $dbatools1 -Database pubs -Table BackupTests -AutoCreateTable

# Check in ADS or with PowerShell :-)

# Lets really mess with it and see what happens
# http://stevestedman.com/2015/04/corruption-challenge-1-how-i-corrupted-the-database/

# First lets create a database to corrupt

Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName corruptme -DestinationFilePrefix corrupt -ReplaceDbNameInFile 

# Lets find the page of a Clustered index to break

$Page = (Invoke-DbaQuery -SqlInstance $dbatools1 -Query "DBCC IND(corruptme,'authors', 1) with no_infomsgs;" |Where-Object IndexLevel -eq 0 |Where-Object Pagetype -eq 1).PagePID

# Lets turn on DBCC TRACEON -- 3604 turn on the DBCC output for commands like DBCC page

Enable-DbaTraceFlag -SqlInstance $dbatools1 -TraceFlag 3604 

# I'm going to make a guess at 128 as the location as that has worked

# This is using DBCC WritePage SO BE CAREFUL














# I MEAN IT












# NO I REALLY MEAN IT



# YOu have to choose to run this by uncommenting or selecting




# # Invoke-DbaQuery -SqlInstance $dbatools1 -Query "DBCC WritePage(corruptme, 1, $Page , 128, 3, 0x616161)"

# Awesome a failure

Invoke-DbaQuery -SqlInstance $dbatools1 -Query "DBCC CheckDB();" -Database corruptme

# SO we have a corrupt database, but we have not noticed and have backed it up

Backup-DbaDatabase -SqlInstance $dbatools1 -Database corruptme -Path /shared/BackupTest

Test-DbaLastBackup -SqlInstance $dbatools1 -Destination $dbatools2 | Write-DbaDataTable -SqlInstance $dbatools1 -Database pubs -Table BackupTests -AutoCreateTable

$Query = "SELECT  [SourceServer]
,[TestServer]
,[Database]
,[FileExists]
,[Size]
,[RestoreResult]
,[DbccResult]
,[RestoreStart]
,[RestoreEnd]
,[RestoreElapsed]
,[DbccMaxDop]
,[DbccStart]
,[DbccEnd]
,[DbccElapsed]
,[BackupDates]
,[BackupFiles]
FROM [pubs].[dbo].[BackupTests]
WHERE [Database] = 'corruptme'
"

Invoke-DbaQuery -SqlInstance $dbatools1 -Database pubs -Query $Query

# You can just set this running as an agent job and run a report on the data or an alert when a corrupt database was found


# Those were the simple ones - How complex do you want to get ?

Get-Help Invoke-DbaAdvancedRestore

# Choose your adventure
Get-GameTimeRemaining

Get-Index