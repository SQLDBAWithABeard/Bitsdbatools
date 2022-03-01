# dbachecks is the sister module to dbatools
# It is Rob's baby and uses the PowerShell module Pester
# to validate the estate
# we have been using it all day, you just haven't seen it!

# You install it in the same way as any PowerShell module

# You have a number of checks. These are unique - 
# Yes or No, True or False, Passed or Failed
# tests 

Get-DbcCheck

Get-DbcCheck | ocgv

# The checks are grouped by Agent,Database,Domain,HADR,Instance, LogShipping,MaintenanceSolution and Server

# Many checks have configuration

Get-DbcConfig | ocgv

# you have the same functionality as dbatools to search for checks

Get-DbcCheck -Pattern backup

# we can choose a check and run it with

# Invoke-DbcCheck -SqlInstance SQLINSTANCE -Check UNIQUETAG, A TAG, GROUP

Invoke-DbcCheck -SqlInstance $dbatools1 -Check LastBackup

# checks are tab completable

Invoke-DbcCheck -SqlInstance $dbatools1 -Check AdHocWorkload

# you can run against multiple instances

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check AdHocWorkload

# I love this so much. You can quickly do your morning checks

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check FailedJob

# Hmmm

Get-DbaAgentJob -SqlInstance $dbatools1 | Start-DbaAgentJob

# I love this so much. You can quickly do your morning checks

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check FailedJob

# A disaster has happened - your VMWare admin comes over to see you and says
# Can you check if all your instances are up and running ?

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check InstanceConnection

# oh look there are some failed

# we actually need to set our config 

Set-DbcConfig -Name policy.connection.authscheme -Value SQL

#and run again

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check InstanceConnection

# ok another one failed that should have succeeded
# now we can talk about skips

Set-DbcConfig -Name skip.connection.remoting -Value $true

# and run again

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check InstanceConnection

# you think you can do all of this in T-SQL ??
# one of my all time favourite checks

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check LastGoodCheckDb

# but you can also use it to validate that your settings are correct

# FOr Example - You might choose to ensure that auto-close is always set on to save on (well I dont know hwy you would but ..)

Invoke-DbcCheck -SqlInstance $dbatools1,$dbatools2 -Check auto-close

# So we have default config values that we think make sense
# or are recommended by people you know and trust and whose blogs you read
# but everything is configurable


<#
_____    _        _         _   _       _ _     _       _   _             
|  ___|  | |      | |       | | | |     | (_)   | |     | | (_)            
| |__ ___| |_ __ _| |_ ___  | | | | __ _| |_  __| | __ _| |_ _  ___  _ __  
|  __/ __| __/ _` | __/ _ \ | | | |/ _` | | |/ _` |/ _` | __| |/ _ \| '_ \ 
| |__\__ \ || (_| | ||  __/ \ \_/ / (_| | | | (_| | (_| | |_| | (_) | | | |
\____/___/\__\__,_|\__\___|  \___/ \__,_|_|_|\__,_|\__,_|\__|_|\___/|_| |_|
#>

# How do we know our estate is in the perfect state?

# dbachecks!
Import-Module dbachecks

# What can we check
Get-DbcCheck 

# That was a lot - let's just look at the Database group
Get-DbcCheck -Group Database

# Find any checks that mention backup
Get-DbcCheck -Pattern *Backup*

# Can find any checks with the Backup tag
Get-DbcCheck -Tag Backup

# Also works for unique tags
Get-DbcCheck -Tag LastFullBackup

# Run some checks - are we doing backups
Invoke-DbcCheck -SqlInstance $SQLInstances -Check LastFullBackup

# Do we have AutoClose turned off - and is the SA account disabled
    # combining instance level & database level checks
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled

# But only show us what we care about
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled -Show Fails

# Let's review the check info
Get-DbcCheck -Tag SaDisabled | Format-List

# Let's get the current config settings
Get-DbcConfig -Name (Get-DbcCheck -Tag SaDisabled | Select-Object -Expand Config).Split(' ')

<#
Name                     Value  Description
----                     -----  -----------
app.sqlinstance                 List of SQL Server instances that SQL-based tests will run against
skip.security.sadisabled True   Skip the check for if the sa login is disabled
#>

# The SaDisabled check is set to be skipped let's chance that
Set-DbcConfig -Name skip.security.sadisabled -Value $false

# Let's get the current config settings
Get-DbcConfig -Name (Get-DbcCheck -Tag SaDisabled | Select-Object -Expand Config).Split(' ')

#Rerun those checks!
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled

# Can also store these results in a database for reporting!
New-DbaDatabase -SqlInstance $dbatools1 -Name dbachecks

# This breaks in the container... 
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled -PassThru |
Convert-DbcResult -Label 'BitsTesting' |
Write-DbcTable -SqlInstance $dbatools1 -Database dbachecks

# Show the reporting...

# Peek behind the scenes of these demos...
