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

# Copying things is where dbatools made its entry into the world

# What databases do we have on our instances?
# Also even thoguh it is named SqlInstance it can accept many Sql Instances !

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table

# ok so everythign on one side.

# How about if we copied them all to our new instance >?

$sharedPath = '/shared'
Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table

# Wait?

# You dont want to have both versions in play and available at the same time ?

# We got you.

# No confirm - remove them from dbatools2

Get-DbaDatabase -SqlInstance $dbatools2 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# ok copy and leeave the source offline

Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases -SetSourceOffline

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table

# NO NO NO NO - NOt offline - I meant ReadOnly

# No confirm - remove them from dbatools2

Get-DbaDatabase -SqlInstance $dbatools2 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# Better bring them back online

Set-DbaDbState -SqlInstance $dbatools1 -Online -AllDatabases

# ok now copy and leeave the source readonly

Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases -SetSourceReadOnly

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select ComputerName, Name, Status, ReadOnly