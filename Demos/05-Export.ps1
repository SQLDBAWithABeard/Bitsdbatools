# get connection info
. ./Demos/00-ConnectionInfo.ps1

# Documentation for Everyone
$instanceSplat = @{
    SqlInstance   = $dbatools1, $dbatools2
    Path          = '.\Export\'
    Exclude       = 'ReplicationSettings'
}
Export-DbaInstance @instanceSplat

# Compare the two sp_configure files

# export into a source controlled folder & track changes