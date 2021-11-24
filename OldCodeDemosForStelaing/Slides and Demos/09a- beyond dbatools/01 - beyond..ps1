## Lets spin up a 2012 instance in Docker - This is how I did it but we will use a pre-loaded image

#region Create custom image
<#
docker run -d -i -p 14567:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 --name 2012 dbafromthecold/sqlserver2012express:rtm

## Need to stop it to copy files
docker stop 2012

# Copy files
docker cp C:\Users\mrrob\OneDrive\Documents\GitHub\ClonedForked\OpenQueryStore 2012:c:\OpenQueryStore
docker cp 'C:\MSSQL\BACKUP\AdventureWorks2012-Full Database Backup.bak' 2012:c:\OpenQueryStore

# Now start it again

docker start 2012

# Now lets install Open Query Store and create adventure works database

docker exec -it 2012 powershell

## need to copy and paste this Rob

SQLCMD -USA

RESTORE DATABASE [AdventureWorks] FROM  DISK = N'C:\OpenQueryStore\AdventureWorks2012-Full Database Backup.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2012_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012_Data.mdf',  MOVE N'AdventureWorks2012_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Log\AdventureWorks2012_log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

CREATE DATABASE [OQS]
quit

cd openQueryStore
.\Install.ps1 -SqlInstance . -Database OQS -OQSMode Centralized -SchedulerType 'Service Broker'                  

# connect via sqlcmd run execute and update 

EXECUTE [master].[dbo].[open_query_store_startup]
GO
UPDATE [OQS].[oqs].[collection_metadata] 
SET [collection_active] = 1
GO

INSERT INTO [OQS].[oqs].[monitored_databases] ([database_name]) VALUES ('AdventureWorks'),('tempdb'),('OQS')


quit

docker stop 2012 
docker commit 2012 2012adventureoqs

#>
#endregion

## Spin up the container from the custom image
docker run -d -i -p 14567:1433 --env ACCEPT_EULA=Y --env SA_PASSWORD=Testing1122 --name 2012 2012adventureoqs

docker exec -it 2012 powershell

cd openquerystore

.\demo\aw etc

# do a docker inspect to get IPAddress
# run custom reports against tempdb from openquerystore folder

# Go off and do next demo and come back - leave the cmd running

# Then pick a query ID and run

DECLARE @queryID SMALLINT = 19;

SELECT TOP 1
   rs.[query_id]
   ,rs.[interval_id]
   ,rs.[last_execution_time]
   ,rs.[execution_count]
   ,rs.[avg_rows]
   ,rs.[last_logical_reads]
   ,rs.[avg_logical_reads]
   ,rs.[last_logical_writes]
   ,rs.[avg_logical_writes]
   ,q.[query_statement_text]
   ,p.[plan_handle]
   ,p.[plan_executionplan]
FROM [oqs].[query_runtime_stats] rs
INNER JOIN [oqs].[Queries] q ON rs.[query_id] = q.[query_id]
INNER JOIN [oqs].[Plans] p ON q.[plan_id] = p.[plan_id]
WHERE rs.[query_id] = @queryID
ORDER BY rs.[interval_id] DESC;
GO