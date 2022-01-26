
#Requires -Version 5
#Requires -module dbatools
$VerbosePreference = 'Continue'
## Navigate to Local path for repo

## Navigate to Local path for repo

# if ($Env:COMPUTERNAME -eq 'ROB-XPS') {
#     # Rob
#     Set-Location Git:\PSConfAsiaPreCon
# }
# ## Your Machine name is foundry?
# elseif ($Env:COMPUTERNAME -eq 'FOUNDRY') {
#     # Jonathan
#     Set-Location Git:\PSConfAsiaPreCon
# }
# else {
#     Write-Warning "Whose machine are you using folks?"
#     break
# }
switch ($Env:COMPUTERNAME) {
    'ROB-XPS' { Set-Location Git:\PSConfAsiaPreCon } # ROB
    'FOUNDRY' { Set-Location Git:\PSConfAsiaPreCon } # JONATHAN
    Default {
        Write-Warning "Whose machine are you using folks?"
        break}
}

## Set the local variables

. .\Setup\MachineVars.ps1

# Create SMO Objects

try {
    Write-Verbose  "Creating 2016 SMO Object"
    $2016SMO = Get-DbaInstance  -SqlInstance $Source2016
}
catch {
    Write-Warning "FAILED - Creating 2016 SMO Object"
    break
}
try {
    Write-Verbose  "Creating 2017 SMO Object"
    $2017SMO = Get-DbaInstance  -SqlInstance $Destination2017
}
catch {
    Write-Warning "FAILED - Creating 2017 SMO Object"
    break
}
try {
    Write-Verbose  "Creating Linux SMO Object"
    $Linux = Get-DbaInstance  -SqlInstance $LinuxHyperV -Credential $sacred
}
catch {
    Write-Warning "FAILED - Creating Linux SMO Object"
    break
}

## Cleanup Migration setup


## Drop from Source
## Logins

Write-Verbose  "Dropping Logins from $Source2016"
$2016SMO.Logins.refresh()
foreach ($login in $2016SMO.Logins.Where{$_.Name -like 'UserForSingaporeDemo*'}) {
    try {
        $Login.Drop()
        Write-Verbose  "Dropped $($login.name)"
    }
    catch {
        Write-Warning "Failed to drop $($login.name)"
    }

}

## credential

Write-Verbose  "Dropping Credentials from $Source2016"
$2016SMO.Credentials.Refresh()
$creds = $2016SMO.Credentials.Where{$_.Name -like '*Singapore*'}
try {
    $creds | ForEach-Object {$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop credentials"
}

## Audit

Write-Verbose  "Dropping Audits from $Source2016"
$2016SMO.Audits.Refresh()
try {
    $2016SMO.Audits.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop Audits"
}


## Audit Specification

Write-Verbose  "Dropping Audit Specification from $Source2016"
$2016SMO.ServerAuditSpecifications.Refresh()
try {
    $2016SMO.ServerAuditSpecifications.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop Audit Specification"
}

## Linked server

Write-Verbose  "Dropping Linked Server from $Source2016"
$2016SMO.LinkedServers.Refresh()
try {
    $2016SMO.LinkedServers.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists($true)}
}
catch {
    Write-Warning "Failed to drop Linked Server"
}


## Proxy

Write-Verbose  "Dropping Proxy from $Source2016"
$Proxy = $2016SMO.JobServer.ProxyAccounts['SingaporeDemoProxy']
if ($Proxy) {
    try {
        $Query = "EXEC msdb.dbo.sp_delete_proxy @proxy_name=N'SingaporeDemoProxy'"
        Invoke-Sqlcmd -ServerInstance $Source2016 -Database msdb -Query $Query
    }
    catch {
        Write-Warning "Failed to drop Proxy"
    }
}
else {
    Write-Verbose "No Proxy to drop"
}


## Drop from Destination
## Logins

Write-Verbose  "Dropping Logins from $Destination2017"
$2017SMO.Logins.refresh()
foreach ($login in $2017SMO.Logins.Where{$_.Name -like 'UserForSingaporeDemo*'}) {
    try {
        $Login.Drop()
        Write-Verbose  "Dropped $($login.name)"
    }
    catch {
        Write-Warning "Failed to drop $($login.name)"
    }

}

## credential

Write-Verbose  "Dropping Credentials from $Destination2017"
$2017SMO.Credentials.Refresh()
$creds = $2017SMO.Credentials.Where{$_.Name -like '*Singapore*'}
try {
    $creds | ForEach-Object {$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop credentials"
}

## Audit

Write-Verbose  "Dropping Audits from $Destination2017"
$2017SMO.Audits.Refresh()
try {
    $2017SMO.Audits.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop Audits"
}


## Audit Specification

Write-Verbose  "Dropping Audit Specification from $Destination2017"
$2017SMO.ServerAuditSpecifications.Refresh()
try {
    $2017SMO.ServerAuditSpecifications.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists()}
}
catch {
    Write-Warning "Failed to drop Audit Specification"
}

## Linked server

Write-Verbose  "Dropping Linked Server from $Destination2017"
$2017SMO.LinkedServers.Refresh()
try {
    $2017SMO.LinkedServers.Where{$_.Name -like '*Singapore*'}.foreach{$_.DropIfExists($true)}
}
catch {
    Write-Warning "Failed to drop Linked Server"
}


## Proxy

Write-Verbose  "Dropping Proxy from $Destination2017"
$Proxy = $2017SMO.JobServer.ProxyAccounts['SingaporeDemoProxy']
if ($Proxy) {
    try {
        $Query = "EXEC msdb.dbo.sp_delete_proxy @proxy_name=N'SingaporeDemoProxy'"
        Invoke-Sqlcmd -ServerInstance $Source2017 -Database msdb -Query $Query
    }
    catch {
        Write-Warning "Failed to drop Proxy"
    }
}
else {
    Write-Verbose  "No Proxy to drop on $Destination2017"
}

## Local User
if (Get-LocalUser -Name sqldemoaccount -ErrorAction SilentlyContinue) {
    Remove-LocalUser -Name SQLDemoAccount
}
else {
    Write-Verbose "No Local User to Remove"
}
$VerbosePreference = 'SilentlyContinue'