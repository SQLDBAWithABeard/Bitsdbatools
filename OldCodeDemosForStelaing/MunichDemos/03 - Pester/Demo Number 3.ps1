## Test Cases and Tags

## You need to look in the tests.ps1 file to see how this works. Invoke-Pester  will run all of the tests in a folder in files named .Tests.ps1 - The tags let you specify which ones you run.

## So you can write tests for Prod, for test, for Dev, for sharepoint, for junior dev, for first thing in the morning, for emergency, DR testing, after patching, leave them all in the same folder and run them like this



Invoke-Pester -Tag Backup
 
Invoke-Pester -Tag DiskSpace

Invoke-Pester -Tag DBCC
 
Invoke-Pester -Tag VLF

Invoke-Pester -Tag Latency
 
Invoke-Pester -Tag Memory

Invoke-Pester -Tag TempDB
Test-DbaTempDbConfiguration -SqlInstance $SQL0
 
Invoke-Pester -Tag ServerName
 
Invoke-Pester -Tag LinkedServer

Invoke-Pester -Tag Connection
 
Invoke-Pester -Tag JobOwner
 
Invoke-Pester -Tag PowerPlan
 
Invoke-Pester -Tag AdHoc
 
Invoke-Pester -Tag Owner

Invoke-Pester -Tag Server

Invoke-Pester -Tag Instance

Invoke-Pester