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

$containers = $SQLInstances = 'dbatools1', 'dbatools2'
#endregion

Get-DbaDatabase -SqlInstance $SQLInstances[0]

Get-DbaFile -SqlInstance $SQLInstances[0] -Path /var/opt/mssql/data/backups

Backup-DbaDatabase -SqlInstance $SQLInstances[0] -Path /var/opt/mssql/data/backups

Get-DbaFile -SqlInstance $SQLInstances[0] -Path /var/opt/mssql/data/backups

Get-DbaDatabase -SqlInstance $SQLInstances[0] -ExcludeSystem | Select Name, Status, LastFullBackup | Format-Table


Get-DbaDatabase -SqlInstance $SQLInstances[0] -ExcludeSystem | Remove-DbaDatabase -Confirm:$false

Get-DbaDatabase -SqlInstance $SQLInstances[0] -ExcludeSystem 

Get-DbaDatabase -SqlInstance $SQLInstances[0] | Format-Table

Restore-DbaDatabase -SqlInstance $SQLInstances[0] -Path /var/opt/mssql/data/backups

Copy-DbaDatabase -Source $SQLInstances[0] -Destination $SQLInstances[1] -Database pubs -BackupRestore -SharedPath /var/opt/backups


$AvailabilityGroupConfig = @{
    Name                   = 'NotOnHolidayNowAreYouJess' 
    SharedPath             = '/var/opt/backups' 
    Primary                = $SQLInstances[0]
    Secondary              = $SQLInstances[1] 
    PrimarySqlCredential   = $continercredential
    SecondarySqlCredential = $continercredential
    ClusterType            = 'None' 
    Database               = 'Northwind', 'pubs' 
    SeedingMode            = 'Automatic' 
    FailoverMode           = 'Manual' 
    Confirm                = $false
}
New-DbaAvailabilityGroup @AvailabilityGroupConfig

$OlaCOnfig = @{
    SqlInstance =  $SQLInstances 
    Database =  'master' 
    BackupLocation =  '/var/opt/backups' 
    CleanupTime =  70 
    LogToTable =  $true
    InstallJobs =  $true
    InstallParallel = $true
}
Install-DbaMaintenanceSolution @OlaCOnfig -ReplaceExisting

Get-DbaAgentJob -SqlInstance $SQLInstances[0] | Select Name

Start-DbaAgentJob -SqlInstance $SQLInstances[0] -Job 'DatabaseBackup - USER_DATABASES - FULL'

Get-DbaFile -SqlInstance $SQLInstances[0] -Path '/var/opt/backups' 
Get-DbaFile -SqlInstance $SQLInstances[0] -Path '/var/opt/backups/NotOnHolidayNowAreYouJess'











