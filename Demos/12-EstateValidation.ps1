<#
_____    _        _         _   _       _ _     _       _   _             
|  ___|  | |      | |       | | | |     | (_)   | |     | | (_)            
| |__ ___| |_ __ _| |_ ___  | | | | __ _| |_  __| | __ _| |_ _  ___  _ __  
|  __/ __| __/ _` | __/ _ \ | | | |/ _` | | |/ _` |/ _` | __| |/ _ \| '_ \ 
| |__\__ \ || (_| | ||  __/ \ \_/ / (_| | | | (_| | (_| | |_| | (_) | | | |
\____/___/\__\__,_|\__\___|  \___/ \__,_|_|_|\__,_|\__,_|\__|_|\___/|_| |_|
#>

cls

# How do we know our estate is in the perfect state?

# dbachecks is the sister module to dbatools
# It is Rob's baby and uses the PowerShell module Pester to validate the estate
# we have been using it all day, you just haven't seen it!

# You install it in the same way as any PowerShell module

# Install-Module dbachecks

# You have a number of checks. These are unique - 
# Yes or No, True or False, Passed or Failed
# tests 

Get-DbcCheck

# That was a lot - let's just look at the Database group
Get-DbcCheck -Group Database

# Find any checks that mention backup
Get-DbcCheck -Pattern *Backup*

# Can find any checks with the Backup tag
Get-DbcCheck -Tag Backup

# Also works for unique tags
Get-DbcCheck -Tag LastFullBackup

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


# We have default config values that we think make sense
# or are recommended by people you know and trust and whose blogs you read
# but everything is configurable

# Lets configure a check

#Run some checks!
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled

# Let's review the check info for Sa
Get-DbcCheck -Tag SaDisabled | Format-List

# Let's get the current config settings
Get-DbcConfig -Name (Get-DbcCheck -Tag SaDisabled).Config.Split(' ')

# The SaDisabled check is set to be skipped let's change that
Set-DbcConfig -Name skip.security.sadisabled -Value $false

# Let's get the current config settings
Get-DbcConfig -Name (Get-DbcCheck -Tag SaDisabled).Config.Split(' ')

#Rerun those checks!
Invoke-DbcCheck -SqlInstance $SQLInstances -Check AutoClose, SaDisabled

# You can also look at the CIS work that Tracey Boggiano has done for
# adding CIS checks to dbachecks

Get-DbcCheck -Tag CIS

Get-DbcConfig -Name (Get-DbcCheck -Tag CIS).Config.Split(' ') | Where Name -ne 'app.sqlinstance'

# there are a lot of Skip trues there!!

Invoke-DbcCheck -SqlInstance $dbatools1 -Tag CIS

# So Tracey wrote a function to help

Set-DbcCisConfig 

# and now we can do

$CisChecks = Invoke-DbcCheck -SqlInstance $dbatools1 -Tag CIS -PassThru

# Rob likes best to store these in a database, so whilst you can use Start-DbcPowerBi 
# to open a PowerBi File which will use the natively stored json results that we do behind the scene

# I like to do this
# Convert-DbcResult tkaes the Pester results and does a little parsing of the data to set the computername
# Sql Instance Name and database name and allows you to add a label.
# Now you can have a historical record of your checks :-)
# Write-DbcTable will do two things
# Create a lookup table with the latest checks and create two tables dbo.CheckResults and dbo.dbachecksChecks

$CisChecks | Convert-DbcResult -Label CIS | Write-DbcTable -SqlInstance $dbatools1 -SqlCredential $continercredential  -Database Validation 

Get-DbaDbTable -SqlInstance $dbatools1 -Database Validation | Format-Table

# Show the reporting database in ADS

# Show the PowerBi - needs a seperate session because we are inside the container here!.
# We need to add the hostname localhost,7433
# user sqladmin
# password dbatools.IO

# Peek behind the scenes of these demos...

Get-GameTimeRemaining

# What else would you like to learn ?

# Choose your adventure

Get-Index