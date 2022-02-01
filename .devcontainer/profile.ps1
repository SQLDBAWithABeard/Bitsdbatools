if ($Host.Name -eq 'Visual Studio Code Host') {
    if (Get-Module -Name EditorServicesCommandSuite -ListAvailable) {
        Import-Module EditorServicesCommandSuite -ErrorAction SilentlyContinue #workaround
        Import-Module EditorServicesCommandSuite
        Import-EditorCommand -Module EditorServicesCommandSuite -ErrorAction SilentlyContinue
        }
}

######## POSH-GIT
# with props to https://bradwilson.io/blog/prompt/powershell
# ... Import-Module for posh-git here ...
ipmo posh-git

Import-Module dbatools



# maybe we can add something here if we want a path?if (-not (Get-PSDrive -Name Git -ErrorAction SilentlyContinue)) {
# maybe we can add something here if we want a path?    $Error.Clear()
# maybe we can add something here if we want a path?    $null = New-PSDrive -Name Git -PSProvider FileSystem -Root $GitRoot
# maybe we can add something here if we want a path?}

$ShowError = $false
$ShowKube = $false
$ShowAzure = $false
$ShowAzureCli = $false
$ShowGit = $true
$ShowPath = $true
$ShowDate = $true
$ShowTime = $true
$ShowUser = $true
$ShowCountDown = $false
$CountDownMessage = "Set `$CountDownMessage and `$CountDownEndDate Rob"
$CountDownEndDate = 0
# Background colors

$GitPromptSettings.AfterStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.AfterStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeIndex.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStash.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BeforeStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchBehindStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchGoneStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.BranchIdenticalStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.DefaultColor.BackgroundColor = [ConsoleColor]::DarkCyan
$GitPromptSettings.DelimStatus.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.ErrorColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.IndexColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalDefaultStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalStagedStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.LocalWorkingStatusSymbol.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.StashColor.BackgroundColor = [ConsoleColor]::DarkGray
$GitPromptSettings.WorkingColor.BackgroundColor = [ConsoleColor]::DarkGray


# Foreground colors

$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.BranchGoneStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.DefaultColor.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.DelimStatus.ForegroundColor = [ConsoleColor]::Blue
$GitPromptSettings.IndexColor.ForegroundColor = [ConsoleColor]::Cyan
$GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::Yellow
$GitPromptSettings.BranchBehindStatusSymbol.ForegroundColor = [ConsoleColor]::Black
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::Black
# Prompt shape

$GitPromptSettings.AfterStatus.Text = " "
$GitPromptSettings.BeforeStatus.Text = "  "
$GitPromptSettings.BranchAheadStatusSymbol.Text = " "
$GitPromptSettings.BranchBehindStatusSymbol.Text = " "
$GitPromptSettings.BranchGoneStatusSymbol.Text = ""
$GitPromptSettings.BranchBehindAndAheadStatusSymbol.Text = ""
$GitPromptSettings.BranchIdenticalStatusSymbol.Text = ""
$GitPromptSettings.BranchUntrackedText = ""
$GitPromptSettings.DelimStatus.Text = " ॥"

$GitPromptSettings.EnableStashStatus = $false
$GitPromptSettings.ShowStatusWhenZero = $false

######## PROMPT

set-content Function:prompt {
    if ($ShowDate) {
        Write-Host " $(Get-Date -Format "ddd dd MMM HH:mm:ss")" -ForegroundColor Black -BackgroundColor DarkGray -NoNewline
    }

    # Reset the foreground color to default
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultColor.ForegroundColor

    if($ShowUser){
        Write-Host " " -NoNewLine
        Write-Host "  " -NoNewLine -BackgroundColor DarkYellow -ForegroundColor Black
        Write-Host  (whoami)  -NoNewLine -BackgroundColor DarkYellow -ForegroundColor Black
    }
    # Write ERR for any PowerShell errors
    if ($ShowError) {
        if ($Error.Count -ne 0) {
            Write-Host " " -NoNewLine
            Write-Host " $($Error.Count) ERR " -NoNewLine -BackgroundColor DarkRed -ForegroundColor Yellow
            # $Error.Clear()
        }
    }

    # Write non-zero exit code from last launched process
    if ($LASTEXITCODE -ne "") {
        Write-Host " " -NoNewLine
        Write-Host " x $LASTEXITCODE " -NoNewLine -BackgroundColor DarkRed -ForegroundColor Yellow
        $LASTEXITCODE = ""
    }

    if ($ShowKube) {
        # Write the current kubectl context
        if ((Get-Command "kubectl" -ErrorAction Ignore) -ne $null) {
            $currentContext = (& kubectl config current-context 2> $null)
            $nodes = kubectl get nodes -o json | ConvertFrom-Json

            $nodename = ($nodes.items.metadata |Where labels  -like '*master*').name
            Write-Host " " -NoNewLine
            Write-Host "" -NoNewLine -BackgroundColor DarkGray -ForegroundColor Green
            #Write-Host " $currentContext " -NoNewLine -BackgroundColor DarkYellow -ForegroundColor Black
            Write-Host " $([char]27)[38;5;112;48;5;242m  $([char]27)[38;5;254m$currentContext - $nodename $([char]27)[0m" -NoNewLine
        }
    }

    if ($ShowAzureCli) {
        # Write the current public cloud Azure CLI subscription
        # NOTE: You will need sed from somewhere (for example, from Git for Windows)
        if (Test-Path ~/.azure/clouds.config) {
            if ((Get-Command "sed" -ErrorAction Ignore) -ne $null) {
                $currentSub = & sed -nr "/^\[AzureCloud\]/ { :l /^subscription[ ]*=/ { s/.*=[ ]*//; p; q;}; n; b l;}" ~/.azure/clouds.config
            }
            else {
                $file = Get-Content ~/.azure/clouds.config
                $currentSub = ([regex]::Matches($file, '^.*subscription\s=\s(.*)').Groups[1].Value).Trim()
            }
            if ($null -ne $currentSub) {
                $currentAccount = (Get-Content ~/.azure/azureProfile.json | ConvertFrom-Json).subscriptions | Where-Object { $_.id -eq $currentSub }
                if ($null -ne $currentAccount) {
                    Write-Host " " -NoNewLine
                    Write-Host "" -NoNewLine -BackgroundColor DarkCyan -ForegroundColor Yellow
                    $currentAccountName = ($currentAccount.Name.Split(' ') | Foreach { $_[0..5] -join '' }) -join ' '
                    Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($currentAccount.name) $([char]27)[0m"  -NoNewLine -BackgroundColor DarkBlue -ForegroundColor Yellow
                }
            }
        }
    }

    if ($ShowAzure) {
        $context = Get-AzContext
        Write-Host "$([char]27)[38;5;227;48;5;30m  $([char]27)[38;5;254m$($context.Account.Id) in $($context.subscription.name) $([char]27)[0m"  -NoNewLine -BackgroundColor DarkBlue -ForegroundColor Yellow
    }
    if ($ShowGit) {
        # Write the current Git information
        if ((Get-Command "Get-GitDirectory" -ErrorAction Ignore) -ne $null) {
            if (Get-GitDirectory -ne $null) {
                Write-Host (Write-VcsStatus) -NoNewLine
            }
        }
    }

    if ($ShowPath) {
        # Write the current directory, with home folder normalized to ~
        # $currentPath = (get-location).Path.replace($home, "~")
        # $idx = $currentPath.IndexOf("::")
        # if ($idx -gt -1) { $currentPath = $currentPath.Substring($idx + 2) }
        if ($IsLinux) {
            $currentPath = $($pwd.path.Split('/')[-2..-1] -join '/')
        }
        else {
            $currentPath = $($pwd.path.Split('\')[-2..-1] -join '\')
        }
        Write-Host " " -NoNewLine
        Write-Host "$([char]27)[38;5;227;48;5;28m  $([char]27)[38;5;254m$currentPath $([char]27)[0m " -NoNewline -BackgroundColor DarkGreen -ForegroundColor Black

    }
    # Reset LASTEXITCODE so we don't show it over and over again
    $global:LASTEXITCODE = 0

    if ($ShowTime) {
        try {
            Write-Host " " -NoNewline
            $history = Get-History -ErrorAction Ignore
            if ($history) {
                if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type) {
                    $timemessage =  " " + ( [Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime))
                    Write-Host $timemessage -ForegroundColor DarkYellow -BackgroundColor DarkGray -NoNewline
                }
                else {
                    Write-Host " $([Math]::Round(($history[-1].EndExecutionTime - $history[-1].StartExecutionTime).TotalMilliseconds,2))" -ForegroundColor DarkYellow -BackgroundColor DarkGray  -NoNewline
                }
            }
            Write-Host " " -ForegroundColor DarkBlue -NoNewline
        }
        catch { }
    }
    # Write one + for each level of the pushd stack
    if ((get-location -stack).Count -gt 0) {
        Write-Host " " -NoNewLine
        Write-Host (("+" * ((get-location -stack).Count))) -NoNewLine -ForegroundColor Cyan
    }

    # Newline
    Write-Host ""

    if ($ShowCountDown) {
        $Date = Get-Date
        $Mins = ($CountDownEndDate - $Date).TotalMinutes
        Write-Host $CountDownMessage -ForegroundColor DarkGreen -NoNewline
        switch ($Mins) {
            { $_ -ge 30 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time $ToGo Mins to go" -ForegroundColor DarkGreen -NoNewline
            }
            { $_ -lt 30 -and $_ -gt 10 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time " -ForegroundColor DarkGreen -NoNewline
                Write-Host " $ToGo Mins to go" -ForegroundColor Yellow -NoNewline
            }
            { $_ -le 10 } {
                $ToGo = [Math]::Round($mins, 1)
                $Time = $Date.ToShortTimeString()
                Write-Host " $Time " -ForegroundColor DarkGreen -NoNewline
                Write-Host " $ToGo Mins to go" -ForegroundColor Red -BackgroundColor DarkYellow -NoNewline
            }
            Default { }
        }
        # Newline
        Write-Host ""
    }

    # Determine if the user is admin, so we color the prompt green or red
    $isAdmin = $false
    $isDesktop = ($PSVersionTable.PSEdition -eq "Desktop")

    if ($isDesktop -or $IsWindows) {
        $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal = new-object 'System.Security.Principal.WindowsPrincipal' $windowsIdentity
        $isAdmin = $windowsPrincipal.IsInRole("Administrators") -eq 1
    }
    else {
        $isAdmin = ((& id -u) -eq 0)
    }

    if ($isAdmin) { $color = $color = "`e[38;5;9;48;5;237m"; }
    else { $color = "`e[38;5;231;48;5;27m "; }


    # Write PS> for desktop PowerShell, pwsh> for PowerShell Core
    if ($isDesktop) {
        Write-Host " PS5>" -NoNewLine -ForegroundColor $color
    }
    else {
        $version = $PSVersionTable.PSVersion.ToString()
        #Write-Host " pwsh $Version>" -NoNewLine -ForegroundColor $color
        Write-Host "$($color)pwsh $Version>" -NoNewLine
    }

    # Always have to return something or else we get the default prompt
    return " "
}

    function whatsmyip  {
        [CmdletBinding()]
        param (
            [Parameter()]
            [switch]
            $clip
        )
        if($clip){
            (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content | Set-Clipboard
        } else{
            (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
        }
    }