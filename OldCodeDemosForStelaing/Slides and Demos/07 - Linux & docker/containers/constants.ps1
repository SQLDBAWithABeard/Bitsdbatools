Write-Debug "Constants importing."
function Get-Dbatools {
    Remove-Module dbatools -ErrorAction SilentlyContinue -Verbose:$false -Debug:$false
    $FailedInstall = $false
    $FailedImport = $false
    $FailedWeb = $false
if((Get-Module dbatools -ListAvailable -ErrorAction SilentlyContinue) -and (!(Get-Module dbatools))){
    try {
        Import-Module dbatools -Verbose:$false -Debug:$false
    }
    catch [FileNotFoundException] {
        Write-Verbose "Failed to import module, it either had an error or failed to install."
        $FailedImport = $true
    }
    catch {
        throw
    }
}
else {
    $FailedImport = $true
}
    if ($FailedImport -eq $true) {
        try {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            Install-Module dbatools -Scope CurrentUser
            Import-Module dbatools -Verbose:$false -Debug:$false
        }
        catch {
            Write-Verbose "Failed to install and then import module"
            $FailedInstall = $true
        }
    }

    if ($FailedInstall -eq $true) {
        try {
            Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://dbatools.io/in)
        }
        catch {
            Write-Verbose "Failed to install from web fallback."
            $FailedWeb = $true
        }
    }

    if ($FailedWeb -eq $true) {
        Write-Error "Could not install dbatools on your machine."
    }
}

Get-dbatools

function Invoke-Process {
    <#
    .SYNOPSIS
    Lazily runs executables for me in PowerShell and returns their output all in one big pile.
    .PARAMETER Command
    The program you want to run.
    .PARAMETER Arguments
    The fairly unadulterated arguments to that program.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
    param
    (
        $Command,
        $Arguments
    )
    begin {
        Write-Debug 'Invoke-Process'
        $output = ""        
    }

    process {
        if ($pscmdlet.ShouldProcess($Arguments, $Command)) {
            Write-Debug "$Command $Arguments"
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = $Command
            $pinfo.RedirectStandardError = $true
            $pinfo.RedirectStandardOutput = $true
            $pinfo.UseShellExecute = $false
            $pinfo.Arguments = $Arguments
            $pinfo.WorkingDirectory = $PWD.ProviderPath
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()
            $output = $p.StandardOutput.ReadToEnd()
            $output += $p.StandardError.ReadToEnd()
            $pinfo = $p = $null
            # from https://stackoverflow.com/questions/8925323/redirection-of-standard-and-error-output-appending-to-the-same-log-file
        }
    }

    end {
        return $output
    }
}
function Get-DockerSqlServer {
    Write-Debug "Get-DockerSqlServer"
    Get-NetNatStaticMapping | Where-Object { $_.InternalPort -eq 1433 } |
        Select-Object InternalIPAddress,
    InternalPort,
    ExternalIPAddress,
    ExternalPort,
    @{
        Name       = "Connection";
        Expression = { "$($_.InternalIPAddress),$($_.InternalPort)"}
    }
}
function Get-InsecureCredential {
    param ($Username, $Password)
    Write-Debug "Get-InsecureCredential"
    $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
    return $Credential
}
function Get-DockerContainers {
    Write-Debug "Get-DockerContainers"
    $ContainerList = (Invoke-Process -command "docker" -arguments "ps --format `"{{.ID}}`"").Split([Environment]::NewLine) | ? {$_}
    return , $ContainerList
}
function Start-StopWatch {
    Write-Debug "Start-StopWatch"
    return , [system.diagnostics.stopwatch]::startNew()
}

function Start-DockerSqlAgent {
    param ( $SqlInstance, $Credential )
    Write-Debug "Start-DockerSqlAgent $SqlInstance"
    $EnabledAdvancedOptions = "exec sp_configure @ConfigName = 'show advanced options', @ConfigValue = 1;"
    $Reconfigure = 'RECONFIGURE;'
    $EnabledAgent = "exec sp_configure @ConfigName = 'Agent XPs', @configValue = 1 "
    $Server = Connect-DbaSqlServer $SqlInstance -Credential $UserCred
    $Server.Databases['Master'].query($EnabledAdvancedOptions)
    $Server.Databases['Master'].query($Reconfigure)
    $Server.Databases['Master'].query($EnabledAgent)
    $Server.Databases['Master'].query($Reconfigure)
}


$User = 'sa'
$Password = 'yourStrongPassword123#'
$UserCred = Get-InsecureCredential -Username $User -Password $Password
$dbasql1 = Get-DockerSqlServer | Select-Object -ExpandProperty Connection -First 1
$dbasql2 = Get-DockerSqlServer | Select-Object -ExpandProperty Connection -Skip 1
Write-Debug "Constants imported."