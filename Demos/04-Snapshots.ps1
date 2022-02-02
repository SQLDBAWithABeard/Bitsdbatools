# get connection info
. ./Demos/00-ConnectionInfo.ps1

Get-DbaDatabase -SqlInstance $dbatools1 -ExcludeSystem | Select-Object SqlInstance, Name, Status, SizeMB

# Take a snapshot - a read-only copy of your database - changes are stored in a sparse file
$snapshotSplat = @{
    SqlInstance = $dbatools1
    Database    = 'Northwind'
}
New-DbaDbSnapshot @snapshotSplat -OutVariable northwindSnap

# View snapshots for the Northwind database
Get-DbaDbSnapshot @snapshotSplat

# What happens if someone goes rogue

# Some data about our employees
Invoke-DbaQuery @snapshotSplat -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'

# Jut need to update a phone number... 
Invoke-DbaQuery @snapshotSplat -Query "UPDATE [Northwind].[dbo].[Employees] SET [HomePhone] = '(330)-329-6691'"

# Uhoh 
Invoke-DbaQuery @snapshotSplat -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'

# The good data is still there in our snapshot
Invoke-DbaQuery -SqlInstance $dbatools1 -Database $northwindSnap.Name -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'

# kill processes to allow us to revert snapshot
Get-DbaProcess @snapshotSplat | Format-Table SqlInstance, Spid, Login, Host, Database, Command
Get-DbaProcess @snapshotSplat | Stop-DbaProcess

# revert snapshot
Restore-DbaDbSnapshot @snapshotSplat -Force

# All good - phew
Invoke-DbaQuery @snapshotSplat -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'

# what if we only want to fix the data we broke?

# Jut need to update a phone number... 
Invoke-DbaQuery @snapshotSplat -Query "UPDATE [Northwind].[dbo].[Employees] SET [HomePhone] = '(330)-329-6691'"

# Uhoh 
Invoke-DbaQuery @snapshotSplat -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'


Copy-DbaDbTableData -SqlInstance $dbatools1 -Destination $dbatools1 -Database $northwindSnap.Name -DestinationDatabase Northwind -Table Employees -Truncate

#Script out the foreign keys
$fks = Get-DbaDbForeignKey -SqlInstance $dbatools1 -Database Northwind | Where-Object ReferencedTable -eq Employees 
$fks | Select-Object SqlInstance,Database,Table, Name, ReferencedKey, ReferencedTable
$fks | Export-DbaScript -FilePath Export/ForeignKeys.sql

# drop the foreign keys
$fks.drop()

# try the copy again
Copy-DbaDbTableData -SqlInstance $dbatools1 -Destination $dbatools1 -Database $northwindSnap.Name -DestinationDatabase Northwind -Table Employees -Truncate

# run the script to re-create foreign keys
Invoke-DbaQuery -SqlInstance $dbatools1 -Database Northwind -File ./Export/ForeignKeys.sql

# Check the data and the FKs
Invoke-DbaQuery @snapshotSplat -Query 'SELECT [EmployeeID],[LastName],[FirstName],[HomePhone] FROM [dbo].[Employees]'
Get-DbaDbForeignKey -SqlInstance $dbatools1 -Database Northwind | Where-Object ReferencedTable -eq Employees | Select-Object SqlInstance,Database,Table, Name, ReferencedKey, ReferencedTable

# clean up snapshot
Get-DbaDbSnapshot @snapshotSplat | Remove-DbaDbSnapshot -Confirm:$false