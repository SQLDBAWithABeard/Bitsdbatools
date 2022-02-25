# dbachecks is the sister module to dbatools
# It is Rob's baby and uses the PowerShell module Pester
# to validate the estate
# we have been using it all day, you just havent seen it!

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


