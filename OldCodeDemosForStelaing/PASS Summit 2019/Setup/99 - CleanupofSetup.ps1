function Destroy-SetUp {
    #region Navigate to Local path for repo

    if ($Env:COMPUTERNAME -eq 'BEARDXPS') {
        # Rob
        Set-Location 'GIT:\PASS Summit 2019'
    }elseif ($Env:COMPUTERNAME -like '*labmachine*' -or $Env:COMPUTERNAME -eq 'DESKTOP-V8G9S2O') {
        Set-Location 'GIT:\PASS Summit 2019'
    }    else {
        Write-Warning "Whose machine are you using folks?"
        break
    }
    #endregion

    docker-compose -f .\docker\docker-compose.yml down

    #region files
    $files = 'C:\temp\linkedserver.sql', 'C:\temp\locallinkedserver.sql','C:\temp\logins.sql','C:\temp\xesession.sql','C:\temp\agentjob.sql'

    Foreach($file in $files){
        If(Test-Path $file){
            Remove-Item -Path $file -Force
        }
    }

    Get-ChildItem c:\temp\exportinstance | Remove-Item -Recurse -Force

    #endregion

    #region services
    $command = "Get-Service SQLSERVERAGENT,MSSQLSERVER | Stop-Service -Force" 
    Start-Process powershell.exe "-NoExit -Command", ('"{0}"' -f $Command) -Verb RunAs 
    #endregion

    #region Azure
# connect to Azure
Connect-AzAccount

$RGName = 'BeardStorage'
$StorageAccountName = 'beardsqlbackups'
$Location = 'West Europe'
$accesskeysqlbackups = 'accesskeysqlbackups'
$sharedaccesssqlbackups = 'sharedaccesssqlbackups'
$publicEndpoint = 'beardmi.public.e7ea892e35af.database.windows.net,3342'

Remove-AzStorageAccount -ResourceGroupName $RGName -Name $accesskeysqlbackups
Remove-AzStorageAccount -ResourceGroupName $RGName -Name $sharedaccesssqlbackups

Get-DbaDatabase -SqlInstance $publicEndpoint -ExcludeSystem |Remove-DbaDatabase -Confirm:$false
Get-DbaAgentJob -SqlInstance $publicEndpoint| Remove-DbaAgentJob 
(Get-DbaCredential -SqlInstance $publicEndpoint).Drop()

$RGName = 'beardsqldemos'
if((Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue)){
    Remove-AzResourceGroup -Name $RGName -Force
}


    #endregion

    Set-DbatoolsConfig -FullName formatting.size.style -Value Dynamic
}
Destroy-SetUp