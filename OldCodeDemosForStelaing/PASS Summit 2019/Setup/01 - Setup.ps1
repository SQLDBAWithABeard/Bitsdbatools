function Start-Setup {
    #region Navigate to Local path for repo

    if ($Env:COMPUTERNAME -eq 'BEARDXPS') {
        # Rob
        Set-Location 'GIT:\PASS Summit 2019'
    }
    elseif ($Env:COMPUTERNAME -like '*labmachine*' -or $Env:COMPUTERNAME -eq 'DESKTOP-V8G9S2O') {
        Set-Location 'GIT:\PASS Summit 2019'
    }
    else {
        Write-Warning "Whose machine are you using folks?"
        break
    }
    #endregion
    #region docker
    docker-compose -f .\docker\docker-compose.yml up -d
    Start-Sleep -Seconds 30
    #endregion

    $password = ConvertTo-SecureString "Password0!" -AsPlainText -Force
    $sacred = New-Object System.Management.Automation.PSCredential ('sa', $password)
    $query = "CREATE LOGIN [sqladmin] WITH PASSWORD = 0x02004655C1D65FA47CC10F4544048D810E5820A1978DF8750708B3AAE6F039240AD275961BFD9FBCE961ED84B69B4B2A93D62C4C32AF953312EE5B3C189901D92D52438E9E10 HASHED,  DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF, DEFAULT_LANGUAGE = [us_english]
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sqladmin];
Grant CONNECT SQL TO [sqladmin]  AS [sa];"
    Invoke-DbaQuery -SqlInstance 'localhost,16001' -Query $query -SqlCredential $sacred


    #region load variables
    . .\Setup\vars.ps1
    #endregion

    #region SetUp Env

    $command = "Get-Service MSSQLSERVER,SQLSERVERAGENT | Start-Service"
    Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs

    (Get-DbaLinkedServer -SqlInstance $sql0).Drop($true)

    $query = "EXEC master.dbo.sp_addlinkedserver @server = N'TheOldBeardApplication', @srvproduct=N'SQL Server'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'TheOldBeardApplication',
@useself=N'False',@locallogin=NULL,@rmtuser=N'sqladmin',@rmtpassword='dbatools.IO'"

    Invoke-DbaQuery -SqlInstance $sql0 -Query $query

    #endregion

    #region azure sql database

    # create resource group if it doesn't exist
Login-AzAccount
    $RGName = 'beardsqldemos'
    $azsqlserver = 'beardazsqlserver'
if(-not (Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue)){
    $newAzResourceGroupSplat = @{
        Name = $RGName
        Tag = @{ Owner="Beard"; Environment="demos" }
        Location = 'West Europe'
    }
    New-AzResourceGroup @newAzResourceGroupSplat
}

$cred = Import-Clixml C:\MSSQL\BACKUP\sqladmin.cred
$newAzSqlServerSplat = @{
    ResourceGroupName = $RGName
    SqlAdministratorCredentials = $cred
    ServerName = $azsqlserver
    location = 'West Europe'
}
New-AzSqlServer @newAzSqlServerSplat

$newAzSqlDatabaseSplat = @{
    Edition = 'Basic'
    DatabaseName = 'AdventureWorks'
    Tags = @{ Owner="Beard"; Environment="demos" }
    SampleName = 'AdventureWorksLT'
    ResourceGroupName = $RGName
    ServerName = $azsqlserver
}
New-AzSqlDatabase @newAzSqlDatabaseSplat


    #endregion
}
Clear-Host
Start-Setup

Invoke-Pester '.\Setup\05 - Setup.Tests.ps1'
    #region load variables
    . .\Setup\vars.ps1
    #endregion
Set-DbcConfig -Name app.sqlinstance -Value $estate
Set-DbcConfig -Name policy.connection.authscheme -Value SQL
Set-DbcConfig -Name skip.connection.ping -Value $true
Set-DbcConfig -Name skip.connection.remoting -Value $true
Invoke-DbcCheck -SqlInstance $estate -SqlCredential $cred -Check InstanceConnection
$ShowAzure = $false
$ShowGit = $false
$PSDefaultParameterValues += @{
    "*dba*:SqlCredential" = $cred
    "*dba*:SourceSqlCredential" = $cred
    "*dba*:DestinationSqlCredential" = $cred
}
$Error.Clear()