Write-Debug "Building build stage. This builds and makes containers and dbtools available."
. .\constants.ps1
$DebugPreference = "Continue"
$s = Start-StopWatch

# From testing it appears that the ports on the containers will be available right away
# But the containers themselves might still need time to get their services up. 

$ImportTime = $s.ElapsedMilliseconds
$s.Stop()
Write-Verbose "dbatools imported."
Write-Verbose "Building..."
$s.Start()
$results = Invoke-Process -Command "docker-compose" -Arguments "build"
$BuildTime = $s.ElapsedMilliseconds
$s.Stop()
$results
if ($results -like "*failed to build*"){
    throw "Error building, failed."
}
Write-Verbose "Standing up..."
$s.Start()
Invoke-Process -Command "docker-compose" -Arguments "up -d"
$s.Stop()
$StandingTime = $s.ElapsedMilliseconds
Write-Verbose "Listing images..."
$s.Start()
Invoke-Process -Command "docker" -Arguments "ps"
$s.Stop()
$psTime = $s.ElapsedMilliseconds

$s.Start()
Write-Debug "Waiting for docker SQL Servers to be available, looping over Get-DockerSqlServer."
$RetryCount = 60
while ((Get-DockerSqlServer).Count -lt 2){    
    Start-Sleep -Seconds 5 # Wait a little for the windows networking to launch.
    $RetryCount--
    if ($RetryCount -lt 1){
        throw "The SQL Servers took $(5*$RetryCount) and still did not come online, please try again or investigate logs."
    }
}
$s.Stop()
Write-Debug "Waited $($s.ElapsedMilliseconds)ms for instances to be available."

$s.Start()
$S1Availble = $false
$S2Available = $false
$dbasql1 =  Get-DockerSqlServer | Select-Object -ExpandProperty Connection -First 1
$dbasql2 =  Get-DockerSqlServer | Select-Object -ExpandProperty Connection -Skip 1
Write-Debug "Pinging servers until they are available"
while ($S1Availble -eq $false){
    if ((Get-DbaDatabase -SqlInstance $dbasql1 -SqlCredential $UserCred -WarningAction SilentlyContinue).Count -gt 1){
        Write-Debug "Detected available databases in $dbasql1"
        $S1Availble = $true
    }
    else {
        Write-Debug "Pinging Container - Please hold"
        Start-Sleep 5 # gfw
    }
}

while ($S2Available -eq $false){
    if ((Get-DbaDatabase -SqlInstance $dbasql2 -SqlCredential $UserCred -WarningAction SilentlyContinue).Count -gt 1){
        Write-Debug "Detected available databases in $dbasql2"
        $S2Available = $true
    }
    else {
        Write-Debug "Pinging Container - Please hold"
        Start-Sleep 5
    }
}
$s.Stop()
$AvailableTime = $s.ElapsedMilliseconds

# Enable agent on both machines. 
$s.Start()
Start-DockerSqlAgent -SqlInstance $dbasql1 -Credential $UserCred
Start-DockerSqlAgent -SqlInstance $dbasql2 -Credential $UserCred

# Create an agent job on the first one 
$null = New-DbaAgentJob -Job "dbasql1 Job" -SqlInstance $dbasql1 -SqlCredential $UserCred -Description "This job was made on dbasql1"

#Verify job only exists on the first one
Write-Debug "There are $((Get-DbaAgentJob -SqlInstance $dbasql1 -SqlCredential $UserCred).Count) jobs on the first server."
Write-Debug "There are $((Get-DbaAgentJob -SqlInstance $dbasql2 -SqlCredential $UserCred).Count) jobs on the second server."
$s.Stop()
$AgentTime = $s.ElapsedMilliseconds

Write-Debug "Import: $ImportTime ms."
Write-Debug "Build: $BuildTime ms."
Write-Debug "Stand-Up: $StandingTime ms."
Write-Debug "Enumeration: $psTime ms."
Write-Debug "Availibility: $AvailableTime ms."
Write-Debug "SQL Agent: $AgentTime ms."