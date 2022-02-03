#region Set up connection
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$PSDefaultParameterValues = @{
    "*dba*:SqlCredential" = $continercredential
    "*dba*:SourceSqlCredential" = $continercredential
    "*dba*:DestinationSqlCredential" = $continercredential
    "*dba*:PrimarySqlCredential" = $continercredential
    "*dba*:SecondarySqlCredential" = $continercredential
}


$containers =  $SQLInstances = $dbatools1,$dbatools2 = 'dbatools1', 'dbatools2'
#endregion