#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$PSDefaultParameterValues = @{
    "*dba*:SqlCredential" = $continercredential
}

$containers =  $SQLInstances = 'dbatools1', 'dbatools2'
#endregion

#region Searching and using commands

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

## Here a neat trick - needs to be run not in a container because of OGV

Find-DbaCommand -Pattern linked | Out-GridView -PassThru | Get-Help -Full 







## Lets look at the linked servers on sql0

Get-DbaLinkedServer -SqlInstance $SQLInstances[0] | Format-Table

## I wonder if they are all working correctly

Test-DbaLinkedServerConnection -SqlInstance $sql0 

## Lets have a look at the linked servers on sql1

Get-DbaLinkedServer -SqlInstance $sql1

## Ah - There is an Availability Group here
## I probably want to make sure that each instance has the same linked servers
## but they have sql auth and passwords - where are the passwords kept ?

(Get-DbaLinkedServer -sqlinstance $sql0)[0] | Select-Object SQLInstance, Name, RemoteServer, RemoteUser

## I can script out the T-SQL for the linked server
(Get-DbaLinkedServer -sqlinstance $sql0)[0] | Export-DbaScript 

## But I cant use the password :-(
Get-ChildItem *sql0-LinkedServer-Export* | Open-EditorFile

## Its ok, with dbatools I can just copy them over anyway :-) Dont need to know the password

Copy-DbaLinkedServer -Source $sql0 -Destination $sql1

## Now lets look at sql1 linked servers again

Get-DbaLinkedServer -SqlInstance $sql1 | Format-Table

## Lets test them to show we have the Password passed over as well

Test-DbaLinkedServerConnection -SqlInstance $sql1

#endregion

#region Look at Builds

    $builds = Get-DbaBuildReference -SqlInstance $SQLInstances 

$Builds | Format-Table

Get-DbaBuildReference -Build 10.0.6000,10.50.6000 |Format-Table

#endregion
