<#
  ___      _                               _  ___  ____                 _   _                 
  / _ \    | |                             | | |  \/  (_)               | | (_)                
  / /_\ \ __| |_   ____ _ _ __   ___ ___  __| | | .  . |_  __ _ _ __ __ _| |_ _  ___  _ __  ___ 
  |  _  |/ _` \ \ / / _` | '_ \ / __/ _ \/ _` | | |\/| | |/ _` | '__/ _` | __| |/ _ \| '_ \/ __|
  | | | | (_| |\ V / (_| | | | | (_|  __/ (_| | | |  | | | (_| | | | (_| | |_| | (_) | | | \__ \
  \_| |_/\__,_| \_/ \__,_|_| |_|\___\___|\__,_| \_|  |_/_|\__, |_|  \__,_|\__|_|\___/|_| |_|___/
                                                          __/ |                                
                                                         |___/                                 
#>

# What if things are a little more complicated?
    # Our database is too big to wait for the backup\restore
    # The business can't afford *any* downtime

##################################################################################
# Jess - go start the application - otherwise this is going to be a bit boring...#
##################################################################################

# Let's see what databases we have available here
Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

# before downtime we'll stage most of the data
$copySplat = @{
    Source          = $dbatools1
    Destination     = $dbatools2
    Database        = 'Pubs'
    SharedPath      = '/shared'
    BackupRestore   = $true
    NoRecovery      = $true # leave the database ready to receive more restores
    NoCopyOnly      = $true # this will break our backup chain!
    OutVariable     = 'CopyResults'
}
Copy-DbaDatabase @copySplat

# This DateTime is going to be important...
$CopyResults | Select-Object *

# How are our databases looking now?
Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

#################################
## DOWNTIME WINDOWS STARTS NOW ##
#################################
# App team will stop the app running...

# Activity hasn't stopped from our applciation 
# Get Processes
$processSplat = @{
    SqlInstance = $dbatools1, $dbatools2
    Database    = 'Pubs'
}
Get-DbaProcess @processSplat |
    Select-Object Host, login, Program

# Kill any left over processes
Get-DbaProcess @processSplat | Stop-DbaProcess

# What's our newest order?
Invoke-DbaQuery -SqlInstance $dbatools1 -Database Pubs -Query 'select @@servername AS [SqlInstance], count(*)NumberOfOrders, max(ord_date) as NewestOrder from pubs.dbo.sales' -OutVariable 'sourceSales'

# Let's take a differential to get any changes
$diffSplat = @{
    SqlInstance = $dbatools1
    Database    = 'pubs'
    Path        = '/shared'
    Type        = 'Differential'
}
$diff = Backup-DbaDatabase @diffSplat

# Set the source database offline
$offlineSplat = @{
    SqlInstance = $dbatools1
    Database    = 'pubs'
    Offline     = $true
    Force       = $true
}
Set-DbaDbState @offlineSplat

# Let's check on our databases
Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

# restore the differential and bring the destination online
$restoreSplat = @{
    SqlInstance = $dbatools2
    Database    = 'Pubs'
    Path        = $diff.Path
    Continue    = $true
}
Restore-DbaDatabase @restoreSplat

# Let's check on our databases
Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

# Let's check our data
Invoke-DbaQuery -SqlInstance $dbatools2 -Database Pubs -Query 'select @@servername AS [SqlInstance], count(*)NumberOfOrders, max(ord_date) as NewestOrder from pubs.dbo.sales' -OutVariable 'destSales'

# Compare these dates and orders
$sourceSales, $destSales

# Choose your adventure

Get-Index