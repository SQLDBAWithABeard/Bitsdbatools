<# 
 _____                   _               _____ _     _                 
/  __ \                 (_)             |_   _| |   (_)                
| /  \/ ___  _ __  _   _ _ _ __   __ _    | | | |__  _ _ __   __ _ ___ 
| |    / _ \| '_ \| | | | | '_ \ / _` |   | | | '_ \| | '_ \ / _` / __|
| \__/\ (_) | |_) | |_| | | | | | (_| |   | | | | | | | | | | (_| \__ \
 \____/\___/| .__/ \__, |_|_| |_|\__, |   \_/ |_| |_|_|_| |_|\__, |___/
            | |     __/ |         __/ |                       __/ |    
            |_|    |___/         |___/                       |___/     
#>

# Copying things is where dbatools made its entry into the world

cls

# What databases do we have on our instances?
# Also even though it is named SqlInstance it can accept many Sql Instances !

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table

# ok so everything on one side.

# How about if we copied them all to our new instance >? 41 seconds browser

$sharedPath = '/shared'
Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table

# Wait?













# You don't want to have both versions in play and available at the same time ?

# We got you.

# No confirm - remove them from dbatools2

Get-DbaDatabase -SqlInstance $dbatools2 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# ok copy and leave the source offline - 41 seconds browser

Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases -SetSourceOffline

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Format-Table














# NO NO NO NO - NOt offline - I meant ReadOnly








# No confirm - remove them from dbatools2

Get-DbaDatabase -SqlInstance $dbatools2 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# Better bring them back online

Set-DbaDbState -SqlInstance $dbatools1 -Online -AllDatabases

# ok now copy and leave the source readonly 48 seconds browser

Copy-DbaDatabase -Source $dbatools1 -Destination $dbatools2 -BackupRestore -SharedPath $sharedPath -AllDatabases -SetSourceReadOnly

# What do we have now ?

Get-DbaDatabase -SqlInstance $dbatools1, $dbatools2 -ExcludeSystem | Select ComputerName, Name, Status, ReadOnly

Get-DbaDbState  -SqlInstance $dbatools1, $dbatools2 | Format-Table

# No confirm - remove them from dbatools2

Get-DbaDatabase -SqlInstance $dbatools2 -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

# Better bring them back to readwrite

Set-DbaDbState -SqlInstance $dbatools1 -ReadWrite -AllDatabases

# what about spconfigure

# Compare the spconfig on two instances with a custom function

Compare-SPConfig -Source $dbatools1 -Destination $dbatools2 

# Set the backup compression config to true on dbatools1

Set-DbaSpConfigure -SqlInstance $dbatools1 -Name DefaultBackupCompression -Value 1

# Compare the spconfig on two instances

Compare-SPConfig -Source $dbatools1 -Destination $dbatools2 

# Copy the spconfigure setting to the other instance

Copy-DbaSpConfigure -Source $dbatools1 -Destination $dbatools2 -ConfigName DefaultBackupCompression

# Compare the spconfig on two instances

Compare-SPConfig -Source $dbatools1 -Destination $dbatools2 

# Lets export the configuration

$export = Export-DbaSpConfigure -SqlInstance $dbatools2 -Path /tmp
code $export.FullName

# lets set the value back on dbatools1

Set-DbaSpConfigure -SqlInstance $dbatools1 -Name DefaultBackupCompression -Value 0

# Compare the spconfig on two instances

Compare-SPConfig -Source $dbatools1 -Destination $dbatools2 

# now we can import from file

Import-DbaSpConfigure -Path $export.FullName -SqlInstance $dbatools1

# Compare the spconfig on two instances

Compare-SPConfig -Source $dbatools1 -Destination $dbatools2 


# Now what else can we copy ....................................

Write-Output $allofTheThings

Find-DbaCommand -Pattern Copy | ocgv

Get-DbaLogin -SqlInstance $dbatools1,$dbatools2|Format-Table

Get-DbaAgentJob  -SqlInstance $dbatools1,$dbatools2|Format-Table


# Choose your adventure
Get-GameTimeRemaining

Get-Index