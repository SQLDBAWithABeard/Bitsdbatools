<#
Will dbatools and SQLServerModule run against Linux?
#>

<#

YES IT WILL!

to install SQL on Linux just follow these steps

https://www.microsoft.com/en-us/sql-server/sql-server-downloads

you will be amazed how easy and how quick it is to install

#>

. .\Setup\MachineVars.ps1

#region Connecting to Linux
## Lets look at the Hyper-V VMs we have
Get-VM

## We have one called Bolton

Import-Module Posh-SSH

$Cred = Get-Credential -UserName rob -Message "EnterPassword"
$Bolton = New-SSHSession -ComputerName Bolton -Credential $Cred

(Invoke-SSHCommand -SSHSession $Bolton -Command "uname").Output
(Invoke-SSHCommand -SSHSession $Bolton -Command "systemctl status mssql-server").Output

## switch to powershell and not integrated terminal

<#
bash

ssh rob@10.0.0.2

sqlcmd -S. -USA

SELECT host_platform, host_distribution, host_release, host_service_pack_level FROM sys.dm_os_host_info;

select name from sys.databases
select name from sys.syslogins

exit x2
#>

## So we have an instance of SQL Server running on Linux :-)
## Lets connect to it with dbatools

#$sacred = Import-Clixml -Path C:\MSSQL\sa.cred
$LinuxSQL = Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred
$SQL2017 =  Get-DbaInstance  -SqlInstance $Destination2017

$LinuxSQL | Select Name, Version, Edition, HostDistribution, Hostrelease
$SQL2017 | Select Name, Version, Edition, HostDistribution, Hostrelease

#endregion

#region Comparing Sp_Configure
# Imagine you wanted to set up your Linux SQL test box with the same configuration as your Windows SQL box

## Then we shall create a simple function to compare the two spconfigures with Get-DbaSpConfigure
Function Compare-SPConfigs
{
    $LinuxSQL.Refresh()
    $SQL2017.Refresh()
    #Get the configurations
    $WindowsConfig = Get-DbaSpConfigure -SqlInstance $SQL2017
    $LinuxConfig = Get-DbaSpConfigure -SqlInstance $LinuxSQL
#Compare them
$propcompare = foreach ($prop in $WindowsConfig) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'Windows setting' = $prop.RunningValue
    'Linux Setting' = $LinuxConfig  | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
    }
}
## Put them in Out-GridView
$propcompare | ogv
}

Compare-SPConfigs

## lets look at the default backup compression setting
## SO Windows and Linux settings are different
## We can simply copy them using the Copy-DbaSpConfigure command that Jonathan showed you

Copy-DbaSpConfigure -Source $SQL2017 -Destination $LinuxSQL -ConfigName DefaultBackupCompression

# and now when we test them again

Compare-SPConfigs

## Supposing you did not have your Linux box built with SQL installed yet
## Lets reset the backup compression (This is how easy you can work with SQL and PowerShell)

$LinuxSQL.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$LinuxSQL.Configuration.Alter()

# Just to prove it we'll compare

Compare-SPConfigs

# This time we will export the sp_config to a file ready for building our new Linux server

Export-DbaSpConfigure -SqlInstance $SQL2017 -Path C:\temp\WindowsConfig.sql

# Fast forward in time now our Linux SQL Server is built
# What I can do is run

Import-DbaSpConfigure -SqlInstance $LinuxSQL -Path C:\temp\WindowsConfig.sql

Compare-SPConfigs

# But I also have the sql file so if I reset the value again

$LinuxSQL.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$LinuxSQL.Configuration.Alter()

# Just to prove it we'll compare

Compare-SPConfigs

# and open the file in VS Code I can just run it with CTRL + SHIFT + E and create a new connection

code-insiders C:\temp\WindowsConfig.sql

# and a final compare

Compare-SPConfigs

#endregion

#region Other Commands on Linux SQL
##Lets run through some other commands just to show that they work

Get-DbaDefaultPath -SqlInstance $LinuxSQL

Get-DbaAgentLog -SqlInstance  $LinuxSQL | Out-GridView

Get-DbaSqlLog -SqlInstance  $LinuxSQL | Out-GridView

Get-DbaDbMailLog -SqlInstance  $LinuxSQL ## I dont have any mail logs :-(

## What about my Jobs?

Get-DbaAgentJobHistory -SqlInstance $LinuxSQL -StartDate (Get-Date).AddDays(-2)

## Backup history?
Get-DbaBackupHistory -SqlInstance $LinuxSQL

#More Detail
Get-DbaBackupHistory -SqlInstance $LinuxSQL  | select -First 1 | Select *

#Restore History ?
Get-DbaRestoreHistory -SqlInstance $LinuxSQL -Last

## more detail
Get-DbaRestoreHistory -SqlInstance $LinuxSQL -Last | select -First 1 | Select *

# Alerts
Get-DbaAgentAlert -SqlInstance $LinuxSQL

# SQL Server access to path

Test-DbaSqlPath -SqlInstance $LinuxSQL -Path /var/opt/mssql/data/

# Can we see files from a SQL point of view?
Get-DbaFile -SqlInstance $LinuxSQL -Path /var/opt/mssql/data/$($LinuxSQL.Name)/msdb/FULL

#endregion