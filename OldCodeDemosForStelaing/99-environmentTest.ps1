
# Test file to show connecting to our instances & viewing the databases

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$credential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$instances = 'dbatools2','dbatools1' 

Connect-DbaInstance -SqlInstance $instances -SqlCredential $credential

<#
ComputerName Name      Product              Version   HostPlatform IsAzure IsClustered ConnectedAs
------------ ----      -------              -------   ------------ ------- ----------- -----------
dbatools2    dbatools2 Microsoft SQL Server 15.0.4198 Linux        False   False       sqladmin
dbatools1    dbatools1 Microsoft SQL Server 15.0.4198 Linux        False   False       sqladmin
#>

Get-DbaDatabase -SqlInstance $instances -SqlCredential $credential -ExcludeSystem | Select SqlInstance,Name

<#
SqlInstance Name
----------- ----
mssql1      Northwind
mssql1      pubs
#>