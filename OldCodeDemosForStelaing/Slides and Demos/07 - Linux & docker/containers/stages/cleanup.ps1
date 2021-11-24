Write-Debug "Running clean stage."
. .\constants.ps1

$old = $ErrorActionPreference
$ErrorActionPreference = "Continue"

# need to support a purge/no purge option.
Write-Debug "Stop, Down, Remove"
Invoke-Process -Command "docker-compose" -Arguments "stop"
Invoke-Process -Command "docker-compose" -Arguments "down"
Invoke-Process -Command "docker-compose" -Arguments "rm --force"

# docker-compose down --rmi 'all'
Write-Debug "Loop and delete."
$DockerImages = (Invoke-Process -Command docker -Arguments "ps -q") | ? { $_ }
foreach ($Image in $DockerImages){
    Write-Verbose "Removing $Image"
    Invoke-Process -Command "docker" -Arguments "rm -f $Image"
}
$ErrorActionPreference = $old