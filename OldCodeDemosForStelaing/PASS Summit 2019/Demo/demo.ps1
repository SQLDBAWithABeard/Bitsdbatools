$Error.Clear()
Clear-Host
# panel on right -- CTRL and then TAB and then Right Arrow --> --> -- Because I have set a keyboard shortcut
#region getting things
    #region which get and how to
    # There are a lot of Gets - Use these to investigate one or many instances
    Get-Command -Module dbatools Get-Dba*
    (Get-Command -Module dbatools Get-Dba*).Count

    # To use any PowerShell command use Get-Help

    Get-Help Get-DbaDatabase
    Get-Help Get-DbaDatabase -Examples
    Get-Help Get-DbaDatabase -Detailed
    Get-Help Get-DbaDatabase -Online

    #endregion

    #region Getting Databases
    # So Get the databases
    Get-DbaDatabase -SqlInstance $sql0 -ExcludeSystem -ExcludeDatabase NOrthWind -NoFullBackup -IncludeLastUsed

    # Get only the user databases
    $getDbaDatabaseSplat = @{
        ExcludeSystem = $true
        SqlInstance = $sql0
    }
    Get-DbaDatabase @getDbaDatabaseSplat | Format-Table

    # Get all the user databases owned by sa
    $getDbaDatabaseSplat = @{
        SqlInstance = $sql0
        ExcludeSystem = $true
        Owner = 'sa'
    }
    Get-DbaDatabase @getDbaDatabaseSplat |Format-Table

    # All the databases with out a full backup
    $getDbaDatabaseSplat = @{
        NoFullBackup = $true
        SqlInstance = $sql0
    }
    Get-DbaDatabase @getDbaDatabaseSplat

    # Restore database with No Recovery
    $restoreDbaDatabaseSplat = @{
        SqlInstance = 'localhost'
        NoRecovery = $true
        Path = 'C:\MSSQL\BACKUP\KEEP\AdventureWorks2012.bak'
        DatabaseName = 'ADRestoring'
        DestinationFileSuffix = 'restoring'
    }
    Restore-DbaDatabase @restoreDbaDatabaseSplat -

    # Get all database with a state of restoring
    $getDbaDatabaseSplat = @{
        Status = 'Restoring'
        SqlInstance = 'localhost'
    }
    Get-DbaDatabase @getDbaDatabaseSplat

    # maybe you can use this to check an instance (but you can use dbachecks for that)
    $invokeDbcCheckSplat = @{
        Check = 'DatabaseStatus'
        SqlInstance = 'localhost'
    }
    Invoke-DbcCheck @invokeDbcCheckSplat

    # You can also take actions with Gets ¯\_(ツ)_/¯
    $getDbaDatabaseSplat = @{
        Database = 'ADRestoring'
        SqlInstance = 'localhost'
    }
    Get-DbaDatabase @getDbaDatabaseSplat | Get-Member -MemberType Method

    # So you can drop the database
    (Get-DbaDatabase @getDbaDatabaseSplat).DropIfExists()

    # Don't do that - use Remove-DbaDatabase instead ! But you can investigate Gets to find methods you can use
    # But the database is gone
    Invoke-DbcCheck @invokeDbcCheckSplat
    $Error.Clear()
    #endregion

    #region More Gets
    # As well as SQL objects there are some interesting Gets
    # explore the file system on the instance
    Get-DbaFile -SqlInstance $sql0
    Get-DbaFile -SqlInstance $sql0 -Path /var/opt/mssql
    Get-DbaFile -SqlInstance $sql0 -Path /var/opt/mssql/log

    # get the builds
    Get-DbaBuildReference -SqlInstance $estate

    # We can use this command alongside Test-DbaBuild

    Test-DbaBuild -SqlInstance $sql0 -Latest

    # Set some variables
    $LatestBuild = (Test-DbaBuild -SqlInstance $sql0 -Latest)
    $BuildTarget = $LatestBuild.BuildTarget

    # Get the Build reference for that build
    Get-DbaBuildReference -Build $BuildTarget

    # Set the latest kblevel
    $LatestKbUpdate = (Get-DbaBuildReference -Build $BuildTarget).KbLevel

    # Get the details for the KB
    Get-DbaKbUpdate -Name $LatestKbUpdate

    # Download the file
    $KbDownload = (Get-DbaKbUpdate -Name $LatestKbUpdate).link
    $file = $KbDownload.Split('/')[-1] -replace '_.*','.exe'
    Invoke-WebRequest -Uri $KbDownload -OutFile C:\MSSQL\Updates\2017\$file

    # This is what would happen if you ran this update
    $Command = "Update-DbaInstance -ComputerName localhost -InstanceName MSSQLSERVER -Path C:\MSSQL\Updates\2017 -ExtractPath C:\MSSQL\Updates\2017\Temp -WhatIf"
    Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs

    # get features in use
    Get-DbaFeature

    # get information on the indexes
    Get-DbaHelpIndex -SqlInstance $sql0 -Database pubs

    # get the instance properties
    Get-DbaInstanceProperty -SqlInstance $sql0 | Out-GridView
    #endregion

#endregion

#switch to bottom panel  -- CTRL and then TAB and then Right Arrow --> -- Because I have set a keyboard shortcut
#region Exporting things
    # get the linked servers on SQL0
    Get-DbaLinkedServer -SqlInstance $sql0

    # we can script out the linked server
    $exportDbaLinkedServerSplat = @{
        FilePath = 'C:\temp\linkedserver.sql'
        SqlInstance = $sql0
    }
    Export-DbaLinkedServer @exportDbaLinkedServerSplat
    azuredatastudio.cmd C:\temp\linkedserver.sql

    # no password - well we had an error and it was a Linux Container
    $Error.Clear()
    $exportDbaLinkedServerSplat = @{
        FilePath = 'C:\temp\locallinkedserver.sql'
        SqlInstance = 'localhost'
    }
    Export-DbaLinkedServer @exportDbaLinkedServerSplat
    # This is because I am running on localhost and need to run as Admin when targetting localhost, for remote instances I do not need to do this
    # but if we run PowerShell as Admin
    $Command = "Export-DbaLinkedServer -SqlInstance localhost -FilePath C:\temp\locallinkedserver.sql"
    Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs
    azuredatastudio.cmd C:\temp\locallinkedserver.sql

    # You can also script out many other objects
    # like logins
    $exportDbaLoginSplat = @{
        FilePath = 'C:\temp\logins.sql'
        SqlInstance = $Sql0
    }
    Export-DbaLogin @exportDbaLoginSplat
    azuredatastudio.cmd C:\temp\logins.sql

    # and XE sessions
    $exportDbaXESessionSplat = @{
        FilePath = 'C:\temp\xesession.sql'
        SqlInstance = $sql0
    }
    Export-DbaXESession @exportDbaXESessionSplat
    azuredatastudio.cmd C:\temp\xesession.sql

    # You can be more specific with your scripting options
    $options = New-DbaScriptingOption

    # Have a look at them with Get-Member panel on right  -- CTRL and then TAB and then Right Arrow --> --> -- Because I have set a keyboard shortcut
    $options | Get-Member -MemberType Property
    $options.IncludeIfNotExists = $true
    $options.ScriptSchema = $true
    $options.IncludeDatabaseContext  = $true
    $Options.ScriptBatchTerminator = $true
    $options.NonClusteredIndexes = $true
    $options.DriDefaults = $true
    $Options.AnsiFile = $true
    $options.TargetServerVersion = "Version80"

    $getDbaDbTableSplat = @{
        SqlInstance = $sql0
        Database = 'pubs'
        Table = 'authors'
    }
    Get-DbaDbTable @getDbaDbTableSplat | Export-DbaScript -FilePath c:\temp\table80.sql -ScriptingOptionsObject $options
    azuredatastudio.cmd C:\temp\table.sql

    # or even your entire instance

    $exportDbaInstanceSplat = @{
        Path = 'c:\temp\exportinstance'
        SqlInstance = $sql0
    }
    Export-DbaInstance @exportDbaInstanceSplat

    # There were some errors as it is a container again but if we run against localhost
    $Command = "Export-DbaInstance -SqlInstance localhost -Path c:\temp\exportinstance"
    Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs
    azuredatastudio.cmd c:\temp\exportinstance
    $Error.Clear()
#endregion

# panel on right -- CTRL and then TAB and then Right Arrow --> --> -- Because I have set a keyboard shortcut
#region Copying things
    # lets check the Agent Jobs on SQL1
    Get-DbaAgentJob -SqlInstance $sql1

    # lets check the Agent Jobs on SQL0
    Get-DbaAgentJob -SqlInstance $sql0

    # Imagine SQL1 and SQL0 are in an Availability Group We need these to be the same
    # sure we can export the script and run it but we can also copy the Job

    Copy-DbaAgentJob -Source $sql0 -Destination $sql1

    # If you run it again it will only add new jobs
    Copy-DbaAgentJob -Source $sql0 -Destination $sql1

    # unless you use the force
    $copyDbaAgentJobSplat = @{
        Force = $true
        Destination = $sql1
        Source = $sql0
        DisableOnDestination = $true
    }
    Copy-DbaAgentJob @copyDbaAgentJobSplat

#endregion

#region Trace Flags
Get-DbaTraceFlag -SqlInstance $estate

## we dont need those backup success messages
Enable-DbaTraceFlag -SqlInstance $estate -TraceFlag 3226
Get-DbaTraceFlag -SqlInstance $estate | Format-Table

## we have a large table and want to update stats at a lower threshhold
Enable-DbaTraceFlag -SqlInstance $sql0 -TraceFlag 2371
Get-DbaTraceFlag -SqlInstance $sql0 | Format-Table

## Capture deadlocks to the error log ?
Enable-DbaTraceFlag -SqlInstance $sql0 -TraceFlag 1204
Get-DbaTraceFlag -SqlInstance $sql0| Format-Table

## remove them
Disable-DbaTraceFlag -SqlInstance $estate -TraceFlag 3226,2371,1204
Get-DbaTraceFlag -SqlInstance $estate
#endregion

#region whoisactive

# Lets restore a database for some demos

Restore-DbaDatabase -SqlInstance $BeardContainer -Path /var/opt/mssql/backups/AdventureWorks2012.bak

# Now we can install whoisactive

Install-DbaWhoIsActive -SqlInstance $BeardContainer -Database master

Invoke-DbaWhoIsActive -SqlInstance $BeardContainer -Database master

$command = "Set-Location 'Git:\Pass Summit 2019'
`$password = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force
`$sacred = New-Object System.Management.Automation.PSCredential ('sqladmin', `$password)
. ..\Functions\Invoke-RandomWorkload.ps1
`$invokeRandomWorkloadSplat = @{
    SqlInstance = '$BeardContainer'
    Database = 'AdventureWorks2012'
    SqlCredential = `$sacred
    NumberOfJobs = 500
    Throttle = 5
    PathToScript = 'C:\Users\mrrob\OneDrive\Documents\Scripts\Adventureworks load test\AdventureWorks BOL Workload.sql'
    # Showoutput = `$true
}
Invoke-RandomWorkload @invokeRandomWorkloadSplat
"
$command | clip # to terminal ?
# Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command)

Invoke-DbaWhoIsActive -SqlInstance $BeardContainer -Database master 
#endregion

