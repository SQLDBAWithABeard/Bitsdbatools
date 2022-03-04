<# 
  ___             _ _       _     _ _ _ _           _____                           
 / _ \           (_) |     | |   (_) (_) |         |  __ \                          
/ /_\ \_   ____ _ _| | __ _| |__  _| |_| |_ _   _  | |  \/_ __ ___  _   _ _ __  ___ 
|  _  \ \ / / _` | | |/ _` | '_ \| | | | __| | | | | | __| '__/ _ \| | | | '_ \/ __|
| | | |\ V / (_| | | | (_| | |_) | | | | |_| |_| | | |_\ \ | | (_) | |_| | |_) \__ \
\_| |_/ \_/ \__,_|_|_|\__,_|_.__/|_|_|_|\__|\__, |  \____/_|  \___/ \__,_| .__/|___/
                                             __/ |                       | |        
                                            |___/                        |_|        
#>

cls

# OK OK OK - We are running in a container so these are not REAL Availability Groups as many of you wil be used to but

# Lets see how easy it is to create an Availability Group with dbatools - Open SSMS as well here and show the dashboard

$AgName = 'NotOnHolidayNowAreYouJess' 
$AvailabilityGroupConfig = @{
    Name         = $AgName 
    SharedPath   = '/var/opt/backups' 
    Primary      = $dbatools1
    Secondary    = $dbatools2
    ClusterType  = 'None' # External. Wsfc
    Database     = 'pubs'
    SeedingMode  = 'Automatic' # or you guessed it - Manual
    FailoverMode = 'Manual' # or automatic or External
    Confirm      = $false
}
New-DbaAvailabilityGroup @AvailabilityGroupConfig

# lets add a database to the Availability Group

$AddAgDbConfig = @{
    SqlInstance       = $dbatools1 
    AvailabilityGroup = $AgName  
    Database          = 'NorthWind'
    SeedingMode       = 'Automatic' 
    SharedPath        = '/var/opt/backups' 
    Secondary         = $dbatools2
}
Add-DbaAgDatabase @AddAgDbConfig

# POwerShell is not magic ;-)

Backup-DbaDatabase -SqlInstance $dbatools1 -Database Northwind -Path /shared -Type Full
Backup-DbaDatabase -SqlInstance $dbatools1 -Database Northwind -Path /shared -Type Log
# lets add a database to the Availability Group

$AddAgDbConfig = @{
    SqlInstance       = $dbatools1 
    AvailabilityGroup = $AgName  
    Database          = 'NorthWind'
    SeedingMode       = 'Automatic' 
    SharedPath        = '/var/opt/backups' 
    Secondary         = $dbatools2
}
Add-DbaAgDatabase @AddAgDbConfig

# And then how to add some more databases to it 52 seconds browser

$databases = Get-DbaDatabase -SqlInstance $dbatools1  -ExcludeSystem -ExcludeDatabase pubs, NorthWind

$AddAgDbConfig = @{
    SqlInstance       = $dbatools1 
    AvailabilityGroup = $AgName  
    Database          = $databases.Name 
    SeedingMode       = 'Automatic' 
    SharedPath        = '/var/opt/backups' 
    Secondary         = $dbatools2
}
Add-DbaAgDatabase @AddAgDbConfig

# You can use dbatools to examine the Availability Groups

Get-DbaAgHadr -SqlInstance $SQLInstances

# SHow the databases

Get-DbaAgDatabase -SqlInstance $SQLInstances | Format-Table

# The listeners

Get-DbaAgListener -SqlInstance $SQLInstances

# Ah we don't have a listener - Lets fix that

$ListenerConfig = @{
    SqlInstance       = $dbatools1 
    AvailabilityGroup = $AgName 
    Name              = 'Maldives' 
    IPAddress         = '172.22.0.4' 
    SubnetMask        = '255.255.255.0' 
    Port              = 54321 
}
Add-DbaAgListener @ListenerConfig


# The listeners

Get-DbaAgListener -SqlInstance $SQLInstances

#The replicas

Get-DbaAgReplica -SqlInstance $SQLInstances | Format-Table

# You can even failover the Availability group

Invoke-DbaAgFailover -SqlInstance $dbatools1 -AvailabilityGroup $AgName 



# of course, we are in containers so we need to force

Invoke-DbaAgFailover -SqlInstance $dbatools1 -AvailabilityGroup $AgName -Force

# But we tell you if you are doing wrong and that you need to connect to the other instance

Invoke-DbaAgFailover -SqlInstance $dbatools2 -AvailabilityGroup $AgName -Force

# Take a look from dbatools1

Get-DbaAvailabilityGroup -SqlInstance $dbatools1

# Take a look from dbatools2

Get-DbaAvailabilityGroup -SqlInstance $dbatools2

# Look at the database status

Get-DbaAgDatabase -SqlInstance $SQLInstances | Format-Table

# SOmething weird with containers but we can also Resume the Movement

Resume-DbaAgDbDataMovement -SqlInstance $dbatools1 -AvailabilityGroup $AgName

# Look at the database status

Get-DbaAgDatabase -SqlInstance $SQLInstances | Format-Table

# or suspend for a single database 

Suspend-DbaAgDbDataMovement -SqlInstance $dbatools1 -AvailabilityGroup $AgName -Database pubs-7 

# Look at the database status

Get-DbaAgDatabase -SqlInstance $SQLInstances | Format-Table

# and as you would expect resume

Resume-DbaAgDbDataMovement -SqlInstance $dbatools1 -AvailabilityGroup $AgName -Database pubs-7 

# Keeping things in sync - this takes a minute to check all the things ;-)
# We are doing a WhatIf so you can see what it would do

Sync-DbaAvailabilityGroup -Primary $dbatools2 -Secondary $dbatools1 -AvailabilityGroup $AgName -WhatIf

# lets create a new login on our primary instance to fix a bug

New-DbaLogin -SqlInstance $dbatools2 -Login arcade -SecurePassword $continercredential.Password -DefaultDatabase pubs-7 

# take a look at our Logins

Get-DbaLogin -SqlInstance $SQLInstances -ExcludeSystemLogin  | Format-Table

# Lets sync our replicas - takes a few but worth it.

Sync-DbaAvailabilityGroup -Primary $dbatools2 -Secondary $dbatools1 -AvailabilityGroup $AgName 

# take a look at our Logins

Get-DbaLogin -SqlInstance $SQLInstances -ExcludeSystemLogin  | Format-Table

# Ok - you want the logins from dbatools1 moved over ?

# of course, we need to fail the ag over to do this - This is why  you need to think about things carefully

# but this is a demo in a training day so we cna ask for permission to fail over in the busiest part of th day and

Invoke-DbaAgFailover -SqlInstance $dbatools1 -AvailabilityGroup $AgName -Force

# SOmething weird with containers but we will Resume the Movement again

Resume-DbaAgDbDataMovement -SqlInstance $dbatools2 -AvailabilityGroup $AgName -Confirm:$false

# Validate the database status

Get-DbaAgDatabase -SqlInstance $SQLInstances | Format-Table

# and resync

# Lets sync our replicas

Sync-DbaAvailabilityGroup -Primary $dbatools1 -Secondary $dbatools2 -AvailabilityGroup $AgName 

# take a look at our Logins

Get-DbaLogin -SqlInstance $SQLInstances -ExcludeSystemLogin  | Format-Table

# We will show you Agent jobs syncing in the agent job chapter

Get-DbaAgBackupHistory -SqlInstance $SQLInstances -AvailabilityGroup $AgName 

# Choose your adventure
Get-GameTimeRemaining

Get-Index