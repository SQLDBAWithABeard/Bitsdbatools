Return 'Oi Beardy/Non-Beardy pay attention you need to be the right user'
## Set the local variables and change path
. .\Setup\MachineVars.ps1

## How do we find Migration related commands?

# we can use the -Tag text that we have seen earlier today
Find-DbaCommand -Tag Migration

## How do we use these commands?

## ALWAYS ALWAYS use Get-Help (Always)

Get-Help Copy-DbaLogin -Full | clip | notepad.exe # no ShowWindow in VSCode

## it takes a login name, how does it help us there?

Copy-DbaLogin -Source $server -Login logninnamehere -WhatIf

## So, we can see all the things that we can copy, lets see it in action
## Lets look at the two instances in SSMS
"We have $Source2016 as a 'source' server and $Destination2017 as a 'destination' server" | Write-Output
Start-Process ssms.exe

# Let's migrate the Logins and SQLAgent jobs
Copy-DbaLogin -Source $Source2016 -Destination $Destination2017 -WhatIf

Copy-DbaAgentJob -Source $Source2016 -Destination $Destination2017 -WhatIf

# Happy with the changes? then let's move those objects :)
Copy-DbaLogin -Source $Source2016 -Destination $Destination2017

Copy-DbaAgentJob -Source $Source2016 -Destination $Destination2017

# check the results in ssms Jonathan


## Now lets migrate EVERYTHING from one to the other with one line of code :-)

Start-DbaMigration -Source $Source2016 -Destination $Destination2017 -BackupRestore -NetworkShare $MachineShare

# back to the slides
# excluding objects swithc etc