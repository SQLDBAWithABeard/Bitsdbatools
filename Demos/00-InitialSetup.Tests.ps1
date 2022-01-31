#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$containers = 'dbatools1', 'dbatools2'
#endregion


$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check InstanceConnection 

$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbatools1-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check DatabaseExists

$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbatools2-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check DatabaseExists

