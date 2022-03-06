<#
  _____                      _   _              __   __                 _____          _                       
 |  ___|                    | | (_)             \ \ / /                |_   _|        | |                      
 | |____  ___ __   ___  _ __| |_ _ _ __   __ _   \ V /___  _   _ _ __    | | _ __  ___| |_ __ _ _ __   ___ ___ 
 |  __\ \/ / '_ \ / _ \| '__| __| | '_ \ / _` |   \ // _ \| | | | '__|   | || '_ \/ __| __/ _` | '_ \ / __/ _ \
 | |___>  <| |_) | (_) | |  | |_| | | | | (_| |   | | (_) | |_| | |     _| || | | \__ \ || (_| | | | | (_|  __/
 \____/_/\_\ .__/ \___/|_|   \__|_|_| |_|\__, |   \_/\___/ \__,_|_|     \___/_| |_|___/\__\__,_|_| |_|\___\___|
           | |                            __/ |                                                                
           |_|                           |___/                                                                 
#>

cls

# Documenting our SQL Server estates is super important for:
  # Rebuilding in DR situation
  # Easier onboarding of new team members
  # Knowing what's changed from one day to the next (every had someone mysteriously lose access - that they never really had?)
    # Source control anyone?

# Export all tables
Get-DbaDbTable -SqlInstance $dbatools1 -Database Northwind | Export-DbaScript -OutVariable Export
code $export.fullname

# Export all tables to a specific file
Get-DbaDbTable -SqlInstance $dbatools1 -Database Northwind | Export-DbaScript -FilePath ./Export/Tables.Sql -OutVariable Export
code $export.fullname

# We can control the scripts with Microsoft.SqlServer.Management.Smo.ScriptingOptions
$options = New-DbaScriptingOption

# see what we change
$options | Get-Member

# lets script out indexes too
$options.DriIndexes = $true
Get-DbaDbTable -SqlInstance $dbatools1 -Database Northwind | Export-DbaScript -FilePath ./Export/TablesWithIndexes.Sql -ScriptingOptionsObject $options -OutVariable Export
code $export.fullname

# lets script out drop statements for our tables
$options.ScriptDrops = $true
Get-DbaDbTable -SqlInstance $dbatools1 -Database Northwind | Export-DbaScript -FilePath ./Export/Drops.Sql -ScriptingOptionsObject $options -OutVariable Export
code $export.fullname

# Lots more scripting options here:
# https://docs.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.scriptingoptions?view=sql-smo-160

# What if we only need one table
Get-DbaDbTable -SqlInstance $dbatools1 -Database Northwind -Table Customers | Export-DbaScript -OutVariable Export
code $export.fullname


# Documentation your whole environment with one script
# export into a source controlled folder & track changes
$path = '.\SourceControl'

Get-ChildItem $path| Remove-Item -Recurse 

# Export
$instanceSplat = @{
    SqlInstance     = $dbatools1, $dbatools2
    Path            = $path
    Exclude         = 'ReplicationSettings','CentralManagementServer'
    NoPrefix        = $true
    ExcludePassword = $true
}
Export-DbaInstance @instanceSplat

# Remove date from folders
(Get-ChildItem $path -Directory).Foreach{ 
  Move-Item $psitem.fullname $psitem.fullname.split('-')[0] 
}

# Compare the two sp_configure files
# Look for new changes in the environment - PR = documentation
# Blinky thinks they've lost access - promises he had sysadmin yesterday and it's already been approved in the past....promise

# Choose your adventure
Get-GameTimeRemaining

Get-Index