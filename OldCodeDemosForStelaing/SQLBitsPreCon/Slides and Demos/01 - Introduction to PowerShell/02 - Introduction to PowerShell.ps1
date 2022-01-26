# Let's turn you into PowerShell Ninjas!!

cd Git:\SQLBitsPreCon

#region IDEs

# Yes you can use ISE - Development frozen by MS
# Yes you can use PowerShell Studio from Sapien - Expensive

# I will say use VS Code

# Why? It's free
# It's updated regularly
# The vscode-powershell extension is open source and updated regularly
# You can use all sorts of languages with intellisens
# You can use all sorts of extensions like Docker and Azure Cloud Shell
# Beautiful integration with GitHub and VSTS for source control
# Customisable as a customisable thing

#region This is VS Code

# We are in the editor
# CTRL + N and we have a new file
# CTRL + K abnd then M and we can change the language

# If we write markdown we can use VS Code

code-insiders '.\Slides and Demos\01 - Introduction to PowerShell\markdown.md'

## If we write T-SQL we can use VS Code

code-insiders '.\Slides and Demos\01 - Introduction to PowerShell\TSQL.sql'

## We can connect to GitHub and work with Source Control.
## With the GitLens Extension we can see what has changed and who changed it

code-insiders '..\dbatools\functions\Remove-DbaDatabaseSafely.ps1'

## There is great debugging built in

## There is intellisense - Type Get-DbaDat


## You can add snippets - type ifs and try and foreach

## You can change the version of PowerShell you are using

## You can open as many new sessions as you want with CTRL + Shift and '

#endregion VS Code

#endregion IDEs

#region What Command ?

# We want to find a command for agent jobs

Get-Command *Agent*

# hmm maybe we will just look in the dbatools module only

Get-Command *Agent* -Module dbatools

# ok I only want to Get information

Get-Command Get*Agent* -module dbatools

#endregion

#region HELP

# Excellent I want to Get-DbaAgentJob - How do I use it?

Get-Help Get-DbaAgentJob

Get-Help Get-DbaAgentJob -Examples

# copy an example and run it

Get-Help Get-DbaAgentJobHistory -Detailed

#endregion

#region Exploring an object

# Lets go back to our Agent Job
# Use this trick with any command at all

$Jobs = Get-DbaAgentJob -SqlInstance localhost

# There is no output

$Jobs | Gm

# SELECT Name, OwnerLoginName,LastRunDate FROM Jobs
$Jobs | Select-Object Name, OwnerLoginName,LastRunDate

# SELECT Name, 
# OwnerLoginName,
# LastRunDate 
# FROM Jobs 
# WHERE NAME LIKE '%Backup%'

$Jobs | Where-Object {$_.Name -like '*Backup*'} | Select-Object Name, OwnerLoginName,LastRunDate

# SELECT Name AS JobName, 
# OwnerLoginName AS Owner,
# LastRunDate AS LastRun 
# FROM Jobs 
# WHERE NAME LIKE '%Backup%'

$Name = @{Name = 'JobName'; Expression = {$_.Name}}
$Owner = @{Name = 'Owner'; Expression = {$_.OwnerLoginName}}
$LastRun = @{Name = 'LastRun'; Expression = {$_.LastRunDate}}
$Jobs | Where-Object {$_.Name -like '*Backup*'} | Select-Object $Name, $Owner,$LastRun

## The Expression is much cleverer than just renaming Column Headings
# You can do calculations or Concatanations in there too


# SELECT Name + '-' + OwnerLoginName AS 'Job And Owner',
# DATEDIFF(Hour,GetDate(),LastRunDate ) AS LastRun
# FROM Jobs 
# WHERE NAME LIKE '%Backup%'

$NameOwner = @{Name = 'Job And Owner'; Expression = {$_.Name + '-' + $_.OwnerLoginName}}
$SinceLastRun = @{Name = 'LastRun'; Expression = {((Get-date) - $_.LastRunDate).TotalHours}}
$Jobs | Where-Object {$_.Name -like '*Backup*'} | Select-Object $NameOwner,$SinceLastRun

# Methods

$Jobs.Where{$_.Name -eq 'DatabaseBackup - SYSTEM_DATABASES - FULL'}.Start()
Get-DBAAgentJob -SqlInstance localhost -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL'

#endregion