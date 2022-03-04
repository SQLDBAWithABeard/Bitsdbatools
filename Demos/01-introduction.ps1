
<# 

 _____      _                 _            _   _               _____           _ _           _              _     
|_   _|    | |               | |          | | (_)             |_   _|         | | |         | |            | |    
  | | _ __ | |_ _ __ ___   __| |_   _  ___| |_ _  ___  _ __     | | ___     __| | |__   __ _| |_ ___   ___ | |___ 
  | || '_ \| __| '__/ _ \ / _` | | | |/ __| __| |/ _ \| '_ \    | |/ _ \   / _` | '_ \ / _` | __/ _ \ / _ \| / __|
 _| || | | | |_| | | (_) | (_| | |_| | (__| |_| | (_) | | | |   | | (_) | | (_| | |_) | (_| | || (_) | (_) | \__ \
 \___/_| |_|\__|_|  \___/ \__,_|\__,_|\___|\__|_|\___/|_| |_|   \_/\___/   \__,_|_.__/ \__,_|\__\___/ \___/|_|___/

#>

#region Searching and using commands

cls

Return 'Oi Beardy, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'


## Lets look at the commands
Get-Command -Module dbatools 

## How many commands?
(Get-Command -Module dbatools).Count

## How do we find commands?
Find-DbaCommand -Tag Backup
Find-DbaCommand -Tag Restore
Find-DbaCommand -Tag Migration
Find-DbaCommand -Tag Agent
Find-DbaCommand -Pattern User 
Find-DbaCommand -Pattern linked

## How do we use commands?

## ALWAYS ALWAYS use Get-Help

Get-Help Test-DbaLinkedServerConnection -Full


## Here a neat trick - works on Windows PowerShell

Find-DbaCommand -Pattern role | Out-GridView -PassThru | Get-Help -Full 

# or we use Microsoft.PowerShell.ConsoleGuiTools for this in Powershell 7
Get-Help (Find-DbaCommand -Pattern role |Select CommandName, Synopsis | Out-ConsoleGridView).CommandName 

# Lets take a look at some things

# Databases

Get-DbaDatabase -SqlInstance $dbatools1

Get-DbaDatabase -SqlInstance $dbatools1 | Select ComputerName,InstanceName,SqlInstance,Name,Status,db_owner

# Logins
Get-DbaLogin -SqlInstance $dbatools1

Get-DbaLogin -SqlInstance $dbatools1 |Format-Table

# We can put multiple instances in any SqlInstance parameter

Get-DbaLogin -SqlInstance $dbatools1, $dbatools2 |Format-Table

# We can pipe commands together

Get-DbaDatabase -SqlInstance $dbatools1,$dbatools2 -ExcludeSystem | Get-DbaDbFile 

# What else would you like to look at on an instance ?

# 

$builds = Get-DbaBuildReference -SqlInstance $SQLInstances 

$Builds | Format-Table

Get-DbaBuildReference -Build 10.0.6000,10.50.6000 |Format-Table

# Choose your adventure
Get-GameTimeRemaining

Get-Index
