#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$PSDefaultParameterValues = @{
    "*dba*:SqlCredential" = $continercredential
    "*dba*:SourceSqlCredential" = $continercredential
    "*dba*:DestinationSqlCredential" = $continercredential
}

$containers =  $SQLInstances = $dbatools1,$dbatools2 = 'dbatools1', 'dbatools2'
#endregion

# Lets take a look at the databases on the first instance

Get-DbaDatabase -SqlInstance $dbatools1

# we can get particular properties 

Get-DbaDatabase -SqlInstance $dbatools1 |Select Name, Status, LastFullBackup

# Added PowerShell bonus, you can see which properties you can 'select' (The columns on a table) with Get-Member

Get-DbaDatabase -SqlInstance $dbatools1 |Get-Member

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

Get-DbaDatabase -SqlInstance $dbatools1 -ExycludeSystem | Remove-DbaDatabase -Confirm

# so what do we have ?

Get-DbaDatabase -SqlInstance $dbatools1 | Format-Table

# just the system databases

# OH NO A DISASTER HAS BEFALLEN US
# Can you restore all the databases please
# One line of code

Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1

# You can even restore with the same backup to numerous databases

0..10 | ForEach-Object {
    $dbname = 'pubs-{0}' -f $psitem
    Restore-DbaDatabase -SqlInstance $dbatools1 -Path /var/opt/mssql/data/backups/dbatools1/pubs -DatabaseName $dbname -DestinationFilePrefix $psitem -ReplaceDbNameInFile 
}

# Super super easy - it will even do this, when the files are more complicated

# lets get all fo our databases now
$databases = Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem 

# define a path and do a full backup fdor each
$RandomPath = '/var/opt/mssql/data/backups/dbatools1/random'
Backup-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath -CompressBackup -Database $databases.Name

# Then create a random number of types of backups for our databases
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

ls -l $RandomPath

# Oh - YOur estate doesnt have all the backups in one directory (we know some that do)

# ok

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

# Still only one line of code 

Restore-DbaDatabase -SqlInstance $dbatools1 -Path $RandomPath

# So what happened ?

Get-DbaDbRestoreHistory -SqlInstance $dbatools1 | Format-Table

# Those were the simple ones - How complex do you want to get ?

Get-Help Invoke-DbaAdvancedRestore