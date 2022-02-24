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