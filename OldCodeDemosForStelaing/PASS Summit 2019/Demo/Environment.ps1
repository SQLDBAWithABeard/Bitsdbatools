#region setup

$VMs = 'SQL2005Ser2003', 'SQL2008Ser12R2', 'SQL2012Ser08AG1', 'SQL2014Ser12R2', 'SQL2016N1', 'SQL2016N2', 'SQL2016N3'
$VMS | Start-Vm

Remove-DbaLogin -SqlInstance 'sql2016n1' -Login HammetKirk , HetfieldJames , TheManager , TrujilloRobert, UlrichLars, Cricket, Rob, THEBEARD\SVC_DBADatabase  -Force
Remove-DbaLogin -SqlInstance 'sql2016n2' -Login THEBEARD\Administrator, Cricket, Rob, THEBEARD\SVC_DBADatabase -Force
Remove-DbaLogin -SqlInstance 'sql2016n3' -Login HammetKirk , HetfieldJames , TheManager , TrujilloRobert, UlrichLars, THEBEARD\Administrator  -Force

Get-DbaAgentJob 'sql2016n2' | Where name -like *ration* | Remove-DbaAgentJob -Confirm:$false
Get-DbaAgentJob 'sql2016n3' | Where name -like *ration* | Remove-DbaAgentJob -Confirm:$false

Remove-DbaAgentJob -SqlInstance 'SQL2016N1', 'SQL2016N2', 'SQL2016N3' -Job 'Copy Objects between replicas in the AG'
#endregion

#region Find Instances

Find-DbaInstance -DiscoveryType Domain -Verbose

$AdComputers = 'SQL2005Ser2003', 'SQL2008Ser12R2', 'SQL2012Ser08AG1', 'SQL2012Ser08AG2', 'SQL2014Ser12R2', 'SQL2016N1', 'SQL2016N2'
$AdComputers | Get-ADComputer | Find-DbaInstance

#EndRegion

#region to give me more resources!
$VMs = 'SQL2005Ser2003', 'SQL2008Ser12R2', 'SQL2012Ser08AG1', 'SQL2014Ser12R2'
$VMS | Stop-VM
#endregion

#region Availability Groups

# lets take a look at our Availability Group
Get-DbaAvailabilityGroup -SqlInstance 'sql2016n1'

# Get the replicas
Get-DbaAgReplica -SqlInstance sql2016n1

# Get the databases
Get-DbaAgDatabase -SqlInstance sql2016n1 

#Get the listener
Get-DbaAgListener -SqlInstance sql2016n1

#Check for primary
Get-DbaAvailabilityGroup -SqlInstance 'sql2016n1' -IsPrimary
Get-DbaAvailabilityGroup -SqlInstance 'sql2016n2' -IsPrimary

#endregion

#region Copying Logins manual

$Node1 = 'sql2016n1'
$Node2 = 'sql2016n2'
$Node3 = 'sql2016n3'

# lets look at the logins on each node
Get-DbaLogin -SqlInstance $Node1 -ExcludeSystemLogin | Select Name
Get-DbaLogin -SqlInstance $Node2 -ExcludeSystemLogin | Select Name
Get-DbaLogin -SqlInstance $Node3 -ExcludeSystemLogin | Select Name

# We can compare them with Compare Object
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin)
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)
Compare-Object -ReferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)

# It's an Availability Group so we need to ensure all the logins are the same
# lets copy node 1 to node 2 and node 2 to node 1
Copy-DbaLogin -Source $Node1 -Destination $Node2
Copy-DbaLogin -Source $Node2 -Destination $Node1

# Now we can compare node 1 and node 2
Compare-Object -ReferenceObject (Get-DbaLogin $node1) -DifferenceObject (Get-DbaLogin $node2)
# we wont worry about these two system logins

# compare node 2 and node 3
Compare-Object -ReferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)

# Copy them
Copy-DbaLogin -Source $Node2 -Destination $Node3
Copy-DbaLogin -Source $Node3 -Destination $Node2

# compare node 2 and node 3 again
Compare-Object -ReferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)

# compare node 1 and node 3
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)

# Copy those as well
Copy-DbaLogin -Source $Node1 -Destination $Node3
Copy-DbaLogin -Source $Node3 -Destination $Node1

# compare node 1 and node 3
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)
# ok we are good
#endregion
 
#region Copying Agent Jobs manual
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node1) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node2)

# same process - but we will ignore the SSIS job as SSIS is only on node1

Copy-DbaAgentJob -Source $Node1 -Destination $node2 -ExcludeJob 'SSIS Server Maintenance Job'
Copy-DbaAgentJob -Source $Node2 -Destination $node1 -ExcludeJob 'SSIS Server Maintenance Job'
Copy-DbaAgentJob -Source $Node2 -Destination $node3 -ExcludeJob 'SSIS Server Maintenance Job'
Copy-DbaAgentJob -Source $Node3 -Destination $node2 -ExcludeJob 'SSIS Server Maintenance Job'
Copy-DbaAgentJob -Source $Node1 -Destination $node3 -ExcludeJob 'SSIS Server Maintenance Job'
Copy-DbaAgentJob -Source $Node3 -Destination $node1 -ExcludeJob 'SSIS Server Maintenance Job'


#Compare nodes
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node1) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node2)
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node2) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node3)
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node1) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node3)

#endregion

#region Lets automate this !
# Thats all very good but what if we add another node?
# We are going to go and have to add so much more logic
# 3 nodes = 3x2x1 = 6 combinations
# 4 nodes = 4x3x2x1 = 24
# 5 nodes = 5x4x3x2x1 = 120
# PS did you know PowerShell can do maths?
6 * 5 * 4 * 3 * 2 * 1

# Anyway

# we can get the replicas in an Availability Group
$replicas = (Get-DbaAgReplica -SqlInstance sql2016n1).name
$replicas

# We can identify the other replicas
foreach ($replica in $replicas) {
    Write-Output "For this replica $replica this is what we shal do"
    $replicastocopy = $replicas | Where-Object { $_ -ne $replica }
    Write-Output "We will copy to $replicastocopy"
}

# So we can copy from each replica to the other

# Reset the logins
Remove-DbaLogin -SqlInstance 'sql2016n1' -Login HammetKirk , HetfieldJames , TheManager , TrujilloRobert, UlrichLars, Cricket, Rob, THEBEARD\SVC_DBADatabase  -Force
Remove-DbaLogin -SqlInstance 'sql2016n2' -Login THEBEARD\Administrator, Cricket, Rob, THEBEARD\SVC_DBADatabase -Force
Remove-DbaLogin -SqlInstance 'sql2016n3' -Login HammetKirk , HetfieldJames , TheManager , TrujilloRobert, UlrichLars, THEBEARD\Administrator  -Force

# Then 

foreach ($replica in $replicas) {
    Write-Output "For this replica $replica"
    $replicastocopy = $replicas | Where-Object { $_ -ne $replica }
    Write-Output "We will copy to $replicastocopy"
    foreach ($Replicatocopy in $replicastocopy) {
        Write-Output "For this replica $Replicatocopy"
        Copy-DbaLogin -Source $replica -Destination $replicatocopy -WhatIf
    }
}

#endregion

#region Automation :-)
# So we can save this script in a location accessible to each node 
# and create a job on node 1 to call it and run ona schedule
# http://dbatools.io/agent

Param(
    $excludejobs = $null,
    $excludelogins = $null
)
# Script to copy logins and jobs (add anything else that you need) between replicas 
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues += @{
    "dba:EnableException" = $true
}
try {
    $replicas = (Get-DbaAgReplica -SqlInstance $ENV:ComputerName).name
}
catch {
    [System.Environment]::Exit(1)
}


foreach ($replica in $replicas) {
    Write-Output "For this replica $replica"
    $replicastocopy = $replicas | Where-Object { $_ -ne $replica }
    foreach ($Replicatocopy in $replicastocopy) {
        Write-Output "We will copy logins from $replica to $Replicatocopy"
        try {
          $output =  Copy-DbaLogin -Source $replica -Destination $replicatocopy -ExcludeLogin $excludelogins -ExcludeSystemLogins
        }
        catch {
            $CopyError = $error[0..5] | fl -force
            $CopyError = $CopyError | OUt-String
            Write-Error $CopyError
            [System.Environment]::Exit(1)
        }
        if ($output.Status -contains 'Failed') {
            $CopyError = $error[0..5] | fl -force
                $CopyError = $CopyError | OUt-String
                Write-Error $CopyError
            [System.Environment]::Exit(1)
            }
            
        Write-Output "We will copy Jobs from $replica to $Replicatocopy"
        try {
           $output = Copy-DbaAgentJob -Source $replica -Destination $replicatocopy -ExcludeJob $excludejobs
        }
        catch {
            $CopyError = $error[0..5] | fl -force
                $CopyError = $CopyError | OUt-String
                Write-Error $CopyError
            [System.Environment]::Exit(1)
        }
        if ($output.Status -contains 'Failed') {
            $CopyError = $error[0..5] | fl -force
                $CopyError = $CopyError | OUt-String
                Write-Error $CopyError
            [System.Environment]::Exit(1)
            }
            
        
    }
}

# And create the job

$newDbaAgentJobSplat = @{
    SqlInstance = $node1
    Description = ' This job will copy the Agent Jobs and the logins between the Availability Group replicas to ensure that they are consistent'
    Category = 'Availability Group Synchronisation'
    OwnerLogin = "$($env:USERDOMAIN)\$($ENV:USERNAME)"
    Job = 'Copy Objects between replicas in the AG'
    Force = $true
}
New-DbaAgentJob @newDbaAgentJobSplat 

$Command = "powershell.exe -File \\BEARDNUC\SQLBackups2\AG\CopyBetweenReplicas.ps1 -ExcludeJobs 'SSIS Server Maintenance Job'"
$newDbaAgentJobStepSplat = @{
    Subsystem = 'CmdExec'
    SqlInstance = $node1
    StepName = 'Run the copy objects PowerShell'
    OnSuccessAction = 'QuitWithSuccess'
    Database = 'master'
    Job = 'Copy Objects between replicas in the AG'
    Command = $command
    OnFailAction = 'QuitWithFailure'
    StepId = 0
}
New-DbaAgentJobStep @newDbaAgentJobStepSplat 

#Compare nodes
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node1) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node2)
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node2) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node3)
Compare-Object -ReferenceObject (Get-DbaAgentJob -SqlInstance $Node1) -DifferenceObject (Get-DbaAgentJob -SqlInstance $Node3)
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin)
Compare-Object -ReferenceObject (Get-DbaLogin $node1 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)
Compare-Object -ReferenceObject (Get-DbaLogin $node2 -ExcludeSystemLogin) -DifferenceObject (Get-DbaLogin $node3 -ExcludeSystemLogin)

# Start the job
(Get-DbaAgentJob -SqlInstance $node1 -Job 'Copy Objects between replicas in the AG').Start()

# Get the job
Get-DbaAgentJob -SqlInstance $node1 -Job 'Copy Objects between replicas in the AG'

# Get job history

(Get-DbaAgentJobHistory -SqlInstance $node1 -Job 'Copy Objects between replicas in the AG').Message
#endregion

#region create an Avaialbility Group
$params = @{
    Primary = $node1
    Secondary = $node2
    Name = 'beard-ag'
    Database = 'BeardedAg_db'
    ClusterType = 'Wsfc'
    SeedingMode = 'Automatic'
    FailoverMode = 'Automatic'
    Confirm = $false
    }
 New-DbaAvailabilityGroup @params 

 Remove-DbaAvailabilityGroup -SqlInstance $node1 -AvailabilityGroup beard-ag  -Confirm:$false
 Remove-DbaDatabase -SqlInstance $node2 -Database 'BeardedAg_db'

 #endregion

 