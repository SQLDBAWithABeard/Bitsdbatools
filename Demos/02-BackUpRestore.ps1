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

# Lets check the file system from the viewpoint of the SQL Instance Service Account again

Get-DbaFile -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/firstbackup

# and from the OS just so you can see there is nothing up our sleeves

ls /var/opt/mssql/data/backups/firstbackup

ls -l  /var/opt/mssql/data

# now if we check the user databases last backup time 

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Select Name, Status, LastFullBackup | Format-Table

# or we could use

Get-DbaLastBackup -SqlInstance $dbatools1 

# or 

Get-DbaDbBackupHistory -SqlInstance $dbatools1

# Lets back up the entire instance in one quick line of code but this time put things in seperate directories

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
# One line of code

Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1

# You can even restore with the same backup to numerous databases 26 seconds robs desktop

0..10 | ForEach-Object {
    $dbname = 'pubs-{0}' -f $psitem
    Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName $dbname -DestinationFilePrefix $psitem -ReplaceDbNameInFile 
}

# Can we use parallel? - this crashes my PowerShell terminal 
0..10 | ForEach-Object -Parallel {
    $dbname = 'pubs-{0}' -f $psitem
    Restore-DbaDatabase -SqlInstance $using:dbatools1 -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName $dbname -DestinationFilePrefix $psitem -ReplaceDbNameInFile 
} 

# Super super easy - it will even do this, when the files are more complicated

# lets get all of our databases now
$databases = Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem 

# define a path and do a full backup for each
$RandomPath = '/var/opt/mssql/data/backups/dbatools1/random'
Backup-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath -CompressBackup -Database $databases.Name

# Then create a random number of types of backups for our databases - 15 secs - Robs desktop
$x = 50
while ($x -ge 0) {
    $db = Get-Random $databases.Name
    $type = Get-Random 'Full','Diff','Log'
    Backup-DbaDatabase -SqlInstance $dbatools1 -Database $db -Path $RandomPath -CompressBackup -Type $type
    $x --    
}

Get-ChildItem $RandomPath

# Looks complicated to get those all restored in the right order ?

# Remve the databases - no confirm this time

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# ONE

# LINE

# OF

# CODE

Restore-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath

# what were those warnings??????

ls -l $RandomPath

# Oh - YOur estate doesnt have all the backups in one directory (we know some that do)

# ok lets backup with create folder and get some more files to play with - 32 secs - Robs desktop

$x = 100
while ($x -ge 0) {
    $db = Get-Random $databases.Name
    $type = Get-Random 'Full','Diff','Log'
    Backup-DbaDatabase -SqlInstance $dbatools1 -Database $db -Path $RandomPath -CompressBackup -Type $type -CreateFolder
    $x --    
}

Get-ChildItem $RandomPath

Get-ChildItem $RandomPath -Recurse

# Remove the databases - no confirm this time

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# Still only one line of code 23 seconds - Robs Desktop

Restore-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath

# So what happened ?

Get-DbaDbRestoreHistory -SqlInstance $dbatools1 | Format-Table

# There is no sorting here so

Get-DbaDbRestoreHistory -SqlInstance $dbatools1 | Sort-Object Date | Format-Table

# Those were the simple ones - How complex do you want to get ?

Get-Help Invoke-DbaAdvancedRestore