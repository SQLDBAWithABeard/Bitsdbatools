# Valid estate is as we expect

$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check InstanceConnection 

$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbatools1-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check DatabaseExists

$null = Reset-DbcConfig 

$null = Import-DbcConfig /workspace/Demos/dbachecksconfigs/initial-dbatools2-config.json
Invoke-DbcCheck -SqlCredential $continercredential -Check DatabaseExists

# add a test for no snapshots

