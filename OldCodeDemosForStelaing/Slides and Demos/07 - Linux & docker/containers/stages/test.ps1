Write-Debug "Running test stage."
Write-Debug "Verify anything we want here."
. .\constants.ps1

$ips = Get-DockerSqlServer

foreach ($ip in $ips){    
    $ServerName = "$($ip.InternalIPAddress),$($ip.InternalPort)"
   $null =  Get-DbaAgentJob -SqlInstance $ServerName -SqlCredential $UserCred
}