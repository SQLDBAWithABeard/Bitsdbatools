# To get started
Update-Module Pester -SkipPublisherCheck
Import-Module Pester -Force

# Do a check
Invoke-DbcCheck -SqlInstance sql2017 -Checks SuspectPage, LastBackup

# Make a server list
$servers = "sql2017", "sqlcluster", "sql2005"
$servers = Get-DbaRegisteredServer -SqlInstance sql2017
$servers = Get-Content C:\scripts\servers.txt
$servers = Get-ADComputer -Filter "name -like '*sql*'"

# Run statically - set once
Set-DbcConfig -Name app.sqlinstance -Value sql2016, sql2017, sql2008, sql2008\express
Set-DbcConfig -Name app.computername -Value sql2016, sql2017, sql2008
Invoke-DbcCheck -Checks SuspectPage, LastBackup
Invoke-DbcCheck -Checks DiskSpace

# Or Dynamically
Invoke-DbcCheck -SqlInstance $servers -Checks SuspectPage, LastBackup
Invoke-DbcCheck -ComputerName $servers -Checks DiskSpace

# How do we know which configs exist?
Get-DbcConfig

# How do we know which checks exist and if we should specify SqlInstance or ComputerName?
Get-DbcCheck
Get-DbcCheck -Pattern *disk*

# A little more advanced which runs all Database Checks except backups - also passes an alternative credential
Invoke-DbcCheck -Check Database -ExcludeCheck Backup -SqlInstance sql2016 -SqlCredential (Get-Credential sqladmin)

# Run checks and export its JSON
Invoke-DbcCheck -SqlInstance sql2017 -Checks SuspectPage, LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource

# Launch Power BI then hit refresh
Start-DbcPowerBi

# You can also split it up by environment
Invoke-DbcCheck -SqlInstance $prod -Checks LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Enviornment Production
Invoke-DbcCheck -SqlInstance $dev -Checks LastBackup -Show Summary -PassThru  | Update-DbcPowerBiDataSource -Enviornment Development
Invoke-DbcCheck -SqlInstance $test -Checks LastBackup -Show Summary -PassThru | Update-DbcPowerBiDataSource -Enviornment Test

# Prefer email? Also easy:
Invoke-DbcCheck -SqlInstance sql2017 -Checks SuspectPage, LastBackup -OutputFormat NUnitXml -PassThru |
Send-DbcMailMessage -To clemaire@dbatools.io -From nobody@dbachecks.io -SmtpServer smtp.ad.local

# Have specific requirements and want to add your own checks? Add your own repo! *
Set-DbcConfig -Name app.checkrepos -Value C:\temp\checks -Append

##################################################################################
#
#                            Advanced Usage
#
##################################################################################

# Set a global, persistent credential
Set-DbcConfig -Name app.sqlcredential -Value (Get-Credential sa)

# Modify the underlying commands - skip the C: drive
Set-Variable -Name PSDefaultParameterValues -Value @{ 'Get-DbaDiskSpace:ExcludeDrive' = 'C:\' } -Scope Global
Invoke-DbcCheck -Check Storage

