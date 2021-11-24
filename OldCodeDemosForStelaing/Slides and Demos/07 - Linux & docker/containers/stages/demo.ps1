Write-Debug "Running run stage. Mostly dbatools code and verifying we can do what we want."
. .\constants.ps1


if ((Get-Module dbatools) -ne $null){
    $S1 = Get-DockerSqlServer | Select-Object -First 1 -ExpandProperty Connection
    $S2 = Get-DockerSqlServer | Select-Object -Last 1 -ExpandProperty Connection

    $startDbaMigrationSplat = @{
        DestinationSqlCredential = $UserCred
        Source = $S1
        NoLinkedServers = $true
        Destination = $S2
        NoLogins = $true
        NoCredentials = $true
        NoDatabases = $true
        NoExtendedEvents = $true
        ErrorVariable = 'MigrationErrors'
        NoSysDbUserObjects = $true
        SourceSqlCredential = $UserCred
    }
    # Start-DbaMigration @startDbaMigrationSplat
    
    $InterestingErrors = ($MigrationErrors | where { $_.Message -notlike 'System error.*'} | select *)
    $InterestingErrors | fl 
    Write-Output "There were $($InterestingErrors.Count) errors."

    Write-Debug "Congratulations - if everything went smoothy your dbatools lab is configured and ready to go!"
    Write-Debug ""
    Write-Debug "You have two SQL Servers available:"
    Write-Debug "dbasql1 - IpAddress $dbasql1 - User $User - Password $Password"
    Write-Debug "dbasql2 - IpAddress $dbasql2 - User $User - Password $Password"
    Write-Debug ""
    Write-Debug "Dot source useful variables with . .\constants.ps1"
    Write-Debug "This will load:"
    Write-Debug "$dbasql1 and $dbasql2 - Your Server IPs."
    Write-Debug "$UserCred - Your Credential Object."
    Write-Debug "$User - Your SQL Server username."
    Write-Debug "$Password - Your SQL Server password."

}
else {
    Write-Output "Could not run tests, dbatools could not be installed and is not available.s"
}