<#
To set the instance names etc for the whole Pester and Demos
#>
$VerbosePreference = 'SilentlyContinue'
if ($Env:COMPUTERNAME -eq 'ROB-XPS') {
    # Rob
    Set-Location Git:\PSConfAsiaPreCon
    # Source 2016 instance
    $Instance1Name = 'SQL2016'
    # Destination 2017 instance
    $Instance2Name = 'DAVE'
    # Another instance for Pester
    $Instance3Name = 'MSSQLSERVER'
    # Linux
    $Instance4Name = $LinuxHyperV = 'BOLTON'
    $LinuxInstance = 'MSSQLSERVER'

    $DBAAdmin = 'DBA-Admin'
    $database = 'database'
    # I store my creds using Get-Credential | Export-CLIXML (for demos only!!)
    $sacred = Import-Clixml -Path C:\MSSQL\sa.cred
}
## Your Machine name is foundry? # Jonathan
elseif ($Env:COMPUTERNAME -eq 'FOUNDRY') {
    if (!(Get-PSDrive git -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name Git -PSProvider FileSystem -Root "C:\Users\Jonathan\Documents\GitHub"
    }

    Set-Location Git:\PSConfAsiaPreCon
    # I store my creds using Get-Credential | Export-CLIXML (for demos only!!)
    $sacred = Import-Clixml "E:\HyperV\sa.cred"

    # Source 2016 instance
    $Instance1Name = 'SQL2016'
    # Destination 2017 instance
    $Instance2Name = 'SQL2017'
    # Instance 3 Name for Pestering
    $Instance3Name = $Instance2Name
    # Linux
    $Instance4Name = $LinuxHyperV = 'Singapore'
    $LinuxInstance = 'MSSQLSERVER'

    $DBAAdmin = 'DBAAdmin'
    $database = 'testdatabase'
}
elseif($Env:COMPUTERNAME -like '*labmachine*' -or $Env:COMPUTERNAME -eq 'SingaporeBase'){
        # Lab
        New-PSDrive -Name GIT -Root C:\PreCon -PSProvider FileSystem -Description "PSDRIVE for Lab demo location"
        Set-Location Git:\

        # I store my creds using Get-Credential | Export-CLIXML (for demos only!!)
       $sacred = Import-Clixml GIT:\sa.cred
       # Source 2016 instance
       $Instance1Name = 'SQL2016'
       # Destination 2017 instance
       $Instance2Name = 'MSSQLSERVER'
       # Instance 3 Name for Pestering
       $Instance3Name = 'SQL2014'
       # Linux
       $Instance4Name = $LinuxHyperV = 'LInux'
       $LinuxInstance = 'MSSQLSERVER'
   
       $DBAAdmin = 'DBAAdmin'
       $database = 'testdatabase'
}
else {
    Write-Warning "Whose machine are you using folks?"
    break
}

## Naming ?
$Source2016 = "$Env:COMPUTERNAME\$Instance1Name"
$Destination2017 = "$Env:COMPUTERNAME\$Instance2Name"
$Instance1 = "$Env:COMPUTERNAME\$Instance1Name"
$Instance2 = "$Env:COMPUTERNAME\$Instance2Name"
$Instance3 = "$Env:COMPUTERNAME\$Instance3Name"
$SQLInstances = $Instance1,$Instance2,$Instance3
$MachineShare = "\\$Env:COMPUTERNAME\Singapore"
$WindowsUser = "$Env:COMPUTERNAME\SQLDemoAccount"

Write-Output  "MACHINEVARS: We will be using this as Source $Source2016 "
Write-Output  "MACHINEVARS: We will be using this as Destination $Destination2017"