<#
______ _           _ _               _____ _     _                 
|  ___(_)         | (_)             |_   _| |   (_)                
| |_   _ _ __   __| |_ _ __   __ _    | | | |__  _ _ __   __ _ ___ 
|  _| | | '_ \ / _` | | '_ \ / _` |   | | | '_ \| | '_ \ / _` / __|
| |   | | | | | (_| | | | | | (_| |   | | | | | | | | | | (_| \__ \
\_|   |_|_| |_|\__,_|_|_| |_|\__, |   \_/ |_| |_|_|_| |_|\__, |___/
                              __/ |                       __/ |    
                             |___/                       |___/     
#>

cls

# This is an ironic chapter because my wife would tell you I can't find any things.. ever.. even if I'm looking right at them

<#
    WE HAVE A P1 INCIDENT IN OUR DEMO ENVIRONMENT!!!!

    Order details are mysteriously disappearing!!! 

    We need to find what might be causing this!
#>

# Let's first look at our stored procedures - and see if there is any code we should be concerned with!

# Find Find commands

Find-DbaCommand -Pattern 'find-'

# Find commands relating to stored procedures
Find-DbaCommand '*Stored Procedures*'

# Look for procedures the touch the [order details] table
Find-DbaStoredProcedure -SqlInstance $dbatools1 -Pattern 'order details' | Format-Table

# Get that stored proc
Get-DbaDbStoredProcedure -SqlInstance $dbatools1 -Database Northwind | Where-Object Name -eq 'SP_FindMe' -OutVariable FindMeSP

# There is more than meets the eye with a lot of the objects returned
$FindMeSP
$FindMeSP | Get-Member 
$FindMeSP | Format-List TextHeader, TextBody

# WAIT - where did $FindMeSP come from Jess ?

# What if there are other objects that aren't SP's? Perhaps Functions, Triggers, etc.

# Lets get the Northwind Database object
Get-DbaDatabase -SqlInstance $dbatools1 -Database Northwind -OutVariable NorthwindDB

# Again - there is more than meets the eye
$NorthwindDB 
$NorthwindDB | Get-Member

# Database triggers
$NorthwindDB.Triggers

# NB - You can also use Get-DbaDbTrigger of course to get database level triggers
Get-DbaDbTrigger -SqlInstance dbatools1 -Database Northwind

# Functions
$NorthwindDB.UserDefinedFunctions | 
    Where-Object TextBody -like '*order details*' | 
    Select-Object Name, TextHeader, TextBody | 
    Format-List

# What about table level triggers
$NorthwindDB.Tables[0] | Get-Member

$NorthwindDB.Tables.Where{$_.Name -eq 'order details'}.Triggers | 
    Select-Object Name, TextHeader, TextBody |
    Format-List

# NB - You can also use Find-DbaTrigger of course
Find-DbaTrigger -SqlInstance dbatools1 -Database Northwind -Pattern 'trg'
Get-DbaDbObjectTrigger -SqlInstance dbatools1 -Database Northwind

# We can also look for SQL Agent Jobs - perhaps things are missing or failing

# Find jobs across instances
Get-DbaAgentJob -SqlInstance $SQLInstances -Job 'DatabaseBackup - USER_DATABASES - FULL'

Get-Help Find-DbaAgentJob -Full | Out-String | code -

# Find Failing jobs
Find-DbaAgentJob -SqlInstance $SQLInstances -IsFailed

# View why they failed
Get-DbaAgentJobHistory -SqlInstance $dbatools2 -Job IamBroke

# Choose your adventure
Get-GameTimeRemaining

Get-Index 