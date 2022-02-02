$containercreds = Get-Credential

$containers = 'dbatools1','dbatools2'

$nuffink = Reset-DbcConfig 
Set-DbcConfig -Name app.sqlinstance -Value $containers
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
Set-DbcConfig -Name skip.connection.remoting -Value $true
Set-DbcConfig -Name database.exists -Value 'pubs','AdventureWorks2017','NorthWind'

Invoke-DbcCheck -SqlCredential $containercreds -Check InstanceConnection,DatabaseExists