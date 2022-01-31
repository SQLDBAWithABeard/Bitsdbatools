
$FolderPath = $Env:USERPROFILE + '\Documents\dbatoolsdemo'
$containercreds = Import-Clixml -Path $FolderPath\sqladmin.cred

$containers = 'localhost,15592', 'localhost,15593'

$nuffink = Reset-DbcConfig 
Set-DbcConfig -Name app.sqlinstance -Value $containers
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
Set-DbcConfig -Name skip.connection.remoting -Value $true
Set-DbcConfig -Name database.exists -Value 'pubs','AdventureWorks2017','NorthWind'

Invoke-DbcCheck -SqlCredential $containercreds -Check InstanceConnection,DatabaseExists