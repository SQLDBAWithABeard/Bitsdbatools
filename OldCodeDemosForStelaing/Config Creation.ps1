$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$containers = 'dbatools1','dbatools2'

# set up all instances tests
$null = Reset-DbcConfig 
Set-DbcConfig -Name app.sqlinstance -Value $containers
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
Set-DbcConfig -Name skip.connection.remoting -Value $true
Export-DbcConfig -Path /workspace/Demos/dbachecksconfigs/initial-config.json

# set up dbatools2 tests

Set-DbcConfig -Name app.sqlinstance -Value 'dbatools2'
Export-DbcConfig -Path /workspace/Demos/dbachecksconfigs/initial-dbatools2-config.json

# set up dbatools1 tests

Set-DbcConfig -Name app.sqlinstance -Value 'dbatools1'
Set-DbcConfig -Name database.exists -Value 'pubs','NorthWind' -Append
Export-DbcConfig -Path /workspace/Demos/dbachecksconfigs/initial-dbatools1-config.json
