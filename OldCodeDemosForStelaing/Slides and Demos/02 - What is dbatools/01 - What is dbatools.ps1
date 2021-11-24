cd presentations:\
Return 'Oi Beardy, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

## What is dbatools?

## There are a number of ways to install dbatools

## The easiest way if you have PowerShell v5 and have access to the PowerShell Gallery
## and are allowed to install software from the internet

#region Installing dbatools (and other modules)
## Find dbatools (or any other module) from the gallery

Find-Module dbatools

## If you are a local administrator
Import-Module dbatools 

## if you are not - this will install to your user home directory

Install-Module dbatools -Scope CurrentUser

## If you don't have access to the internet
## use another machine

Save-Module dbatools -Path 'Path-to-save'

## copy the module to the machine and save in one of the paths available at 

($Env:PSModulePath).Split(';')

## Use the scripted installer from Github for older systems (Win7, Win8)

Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://dbatools.io/in) 

## If you want to manually install

Invoke-WebRequest https://dbatools.io/zip -Outfile dbatools.zip
Expand-Archive dbatools.zip -DestinationPath .
Import-Module .\dbatools-master\dbatools.psd1 

## This also lets you use the deelopment branch using a different URL

Invoke-WebRequest https://dbatools.io/devzip -Outfile dbatools.zip
Expand-Archive dbatools.zip -DestinationPath .
Import-Module .\dbatools-master\dbatools.psd1 

## or you can use the -beta switch in the install.ps1 script in the module folder

#endregion

#region Finding Commands in dbatools (and other modules)
## Lets look at the commands
Get-Command -Module dbatools 

## How many Commands?
(Get-Command -Module dbatools).Count

## How do we find commands?
Find-DbaCommand -Tag Backup
Find-DbaCommand -Tag Restore
Find-DbaCommand -Tag Migration
Find-DbaCommand -Tag Agent
Find-DbaCommand -Pattern User 
Find-DbaCommand -Pattern linked
#endregion

#region Using dbatools commands
## How do we use commands?

## ALWAYS ALWAYS use Get-Help

Get-Help Test-DbaLinkedServerConnection -Full

## Here a neat trick

Find-DbaCommand -Pattern Index | Out-GridView -PassThru | Get-Help -Full 

## Take a look at the community presentations 

Start-Process 'https://github.com/sqlcollaborative/community-presentations'

#endregion

#region A quick example
## Lets look at how easy it is to get information about one or many sql server instances from the command line with one line of code

## What are my default paths ?

Get-DbaDefaultPath -SqlInstance $Instance1Name, $Instance2Name, $Instance3Name

## You could use Pester to repeatedly test instances

Describe "Testing my Defaults" {
    Context "Paths" {
        $Instances = $Instance1Name, $Instance2Name, $Instance3Name, $Instance4Name
        $testCases = @()
        $Instances.ForEach{$testCases += @{Instance = $_}}
        $default = [pscustomobject]@{Data = 'C:\MSSQL\DATA'
            Log = 'C:\MSSQL\LOGS'
            Backup = 'C:\MSSQL\Backup'
        }
        It "<Instance> Should have default paths" -TestCases $TestCases {
            param($Instance)
            $InstanceDefaults = Get-DbaDefaultPath -SqlInstance $Instance -SqlCredential $sacred
            $InstanceDefaults.Data | Should Be $default.Data 
            $InstanceDefaults.Log | Should Be $default.Log  
            $InstanceDefaults.Backup | Should Be $default.Backup
        }
    }
}

## Yep It works with SQL on Linux too :-)
#endregion

