<#
  _____ _            _____ _                            __           _                 _       
 |_   _| |          /  ___| |                          / _|         | |               (_)      
   | | | |__   ___  \ `--.| |_ ___  _ __ _   _    ___ | |_    __ _  | |     ___   __ _ _ _ __  
   | | | '_ \ / _ \  `--. \ __/ _ \| '__| | | |  / _ \|  _|  / _` | | |    / _ \ / _` | | '_ \ 
   | | | | | |  __/ /\__/ / || (_) | |  | |_| | | (_) | |   | (_| | | |___| (_) | (_| | | | | |
   \_/ |_| |_|\___| \____/ \__\___/|_|   \__, |  \___/|_|    \__,_| \_____/\___/ \__, |_|_| |_|
                                          __/ |                                   __/ |        
                                         |___/                                   |___/         
#>
# The story of a login

cls

#region set up 

if (-not (Get-DbaDatabase -SqlInstance $dbatools1 -Database SockFactoryApp)) {
    New-DbaDatabase -SqlInstance $dbatools1 -Name SockFactoryApp 
}

$Password = ConvertTo-SecureString SockFactoryApp_User -AsPlainText -Force
New-DbaLogin -SqlInstance $dbatools1 -Login SockFactoryApp_User -SecurePassword $Password | Out-Null
New-DbaDbUser -SqlInstance $dbatools1 -Database SockFactoryApp -Login SockFactoryApp_User -Username SockFactoryApp_User  | Out-Null
Remove-DbaLogin -SqlInstance $dbatools1 -Login SockFactoryApp_User -Force   | Out-Null

$Global:PSDefaultParameterValues.CLear()
$sqladminPassword = ConvertTo-SecureString 'dbatools.IO' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ('SockFactory_App', $sqladminpassword)
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Query "SELECT @@SERVER" -WarningAction SilentlyContinue
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Query "SELECT @@SERVER" -WarningAction SilentlyContinue
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Query "SELECT @@SERVER" -WarningAction SilentlyContinue
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Query "SELECT @@SERVER" -WarningAction SilentlyContinue
$Global:PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $continercredential
    "*dba*:SourceSqlCredential"      = $continercredential
    "*dba*:DestinationSqlCredential" = $continercredential
    "*dba*:DestinationCredential"    = $continercredential
    "*dba*:PrimarySqlCredential"     = $continercredential
    "*dba*:SecondarySqlCredential"   = $continercredential
}
cls
Write-Output "Setup finished"
#endregion

# 3am Tuesday Morning
Write-Output $Italwaysis
# You receive a call out because the Sock Factory has shut down and
# 
# It's the database's fault
# The connection is failing
# 
# Amongst your troubleshooting steps (perhaps they could/should be in a notebook so the results get saved?) You look in the error log for failed logins
# 
# You can do this with dbatools (on windows)

Get-DbaErrorLog -SqlInstance $dbatools1 -Text  Login | Select LogDate, Source, Text  

# but we are in a container so we use our T-SQL Knowledge and

Invoke-DbaQuery -SqlInstance $dbatools1 -Database master -Query "EXEC sp_readerrorlog"

# No login? Interesting.
# 
# Then you remember a new replica was added to the Availability Group at the weekend.
# 
# Maybe the DBA did not add the logins correctly
# 
# You need to check for the login

Get-DbaLogin -SqlInstance $dbatools1 -Login SockFactoryApp_User

# No response means no login :-(
# 
# It's ok, just create a new login using the password from the secure password vault

$Password = ConvertTo-SecureString SockFactoryApp_User -AsPlainText -Force
New-DbaLogin -SqlInstance $dbatools1 -Login SockFactoryApp_User -SecurePassword $Password

# Quick email back to the user and all is well (we'll also simulate the app)

#region email back
Write-Output "Email - Subject - No Worries the Beard Fixed it"
$Global:PSDefaultParameterValues.CLear()
$sqladminPassword = ConvertTo-SecureString 'SockFactoryApp_User' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ('SockFactoryApp_User', $sqladminpassword)
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Database SockFactoryApp -Query "PRINT 'All is Well'" -WarningAction SilentlyContinue
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Database SockFactoryApp -Query "PRINT 'All is Well'" -WarningAction SilentlyContinue
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Database SockFactoryApp -Query "PRINT 'All is Well'" -WarningAction SilentlyContinue
$Global:PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $continercredential
    "*dba*:SourceSqlCredential"      = $continercredential
    "*dba*:DestinationSqlCredential" = $continercredential
    "*dba*:DestinationCredential"    = $continercredential
    "*dba*:PrimarySqlCredential"     = $continercredential
    "*dba*:SecondarySqlCredential"   = $continercredential
}
cls
Write-Output "Email - Subject - No Worries the Beard Fixed it"
Write-Output "Email has been sent"
#endregion

# Sure enough the user is back pretty quickly

# CHeck the error log (if we were on windows we would do this)

Get-DbaErrorLog -SqlInstance $dbatools1 -Text  Login | Select LogDate, Source, Text  | Format-List

# but we are in a container so we use our T-SQL Knowledge and

Invoke-DbaQuery -SqlInstance $dbatools1 -Database master -Query "EXEC sp_readerrorlog" | Where ProcessInfo -eq 'Logon'

# Hmmm
# 
# Failed to open the explicitly specified database 'SockFactoryApp'
# 
# Does the user exist?

Get-DbaDbUser -SqlInstance $dbatools1 -Database SockFactoryApp -ExcludeSystemUser

# So the user exists but we can't login

# Whats going on ? 

# Pop quiz ..............
















































































# If you guessed Orphaned user

# Let's check that with dbatools

Get-DbaDbOrphanUser -SqlInstance $dbatools1

# We have an orphaned user :-(

# We can fix all Orphaned Users with one command

Repair-DbaDbOrphanUser -SqlInstance $dbatools1

# lets quickly run a command as that user just to be sure

$Global:PSDefaultParameterValues.CLear()

$sqladminPassword = ConvertTo-SecureString 'SockFactoryApp_User' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ('SockFactoryApp_User', $sqladminpassword)
Invoke-DbaQuery -SqlInstance $dbatools1 -SqlCredential $cred -Database SockFactoryApp -Query "SELECT SUSER_SNAME() + ' Is my Name' as 'Everything is Fine'" -WarningAction SilentlyContinue

$Global:PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $continercredential
    "*dba*:SourceSqlCredential"      = $continercredential
    "*dba*:DestinationSqlCredential" = $continercredential
    "*dba*:DestinationCredential"    = $continercredential
    "*dba*:PrimarySqlCredential"     = $continercredential
    "*dba*:SecondarySqlCredential"   = $continercredential
}

# Now this instance is (or isn't if you chose a different path)
# part of an availability group
# so if we fail over what would happen?
# How could we fix it?



# Who loves Excel ???????????????



#Check for modules and install - Here is some code to help you if you need to install modules
$Modules = 'dbatools', 'ImportExcel'

if ((Get-PsRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Write-Output "The PowerShell Gallery is not trusted so I will trust it so that we can install the modules without interaction"
    try {
        Set-PsRepository -Name PSGallery -InstallationPolicy Trusted
    }
    catch {
        Write-Output " Failed to trust the gallery, trying to force it and also add package provider"
        Install-PackageProvider NuGet -Force
        Import-PackageProvider NuGet -Force
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    
}
else {
    Write-Output "The PowerShell Gallery is trusted I will continue"
}
$Modules.ForEach{
    If (-not(Get-Module $psitem -ListAvailable)) {
        Write-Output "We don't have the $psitem module so we will install it"
        Install-Module $psitem -Scope CurrentUser -Force
    }
    else {
        Write-Output "We have the $psitem module already"
    }
}


$ExcelDirectory = '/shared' # Alter this to the directory you want the file created
$SQlinstance = $dbatools1  # Alter this for the SQL Instance you want to get permissions for

Write-Output "Processing $sqlinstance"

$InstanceName = $SQlinstance.Split('\').Split('.').Split('\').Split(',') -join '_'
$ExcelFile = $ExcelDirectory + '\' + $InstanceName + '_Permissions_OneTab_' + (Get-Date).ToString('yyyy-MM-dd') + '.xlsx'

Write-Output "    FileName is $ExcelFile"

$WorkSheetName = "Permissions"

$excel = Get-DbaUserPermission -SqlInstance $sqlinstance | Export-Excel -Path $ExcelFile -WorksheetName $WorkSheetName -AutoSize -FreezeTopRow -AutoFilter -PassThru
  
$rulesparam = @{
    Address   = $excel.Workbook.Worksheets[$WorkSheetName].Dimension.Address
    WorkSheet = $excel.Workbook.Worksheets[$WorkSheetName] 
    RuleType  = 'Expression'      
}

Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("sysadmin",$G1)))' -BackgroundColor Yellow -StopIfTrue
Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("db_owner",$G1)))' -BackgroundColor Yellow -StopIfTrue
Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("SERVER LOGINS",$E1)))' -BackgroundColor PaleGreen 
Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("SERVER SECURABLES",$E1)))' -BackgroundColor PowderBlue 
Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("DB ROLE MEMBERS",$E1)))' -BackgroundColor GoldenRod 
Add-ConditionalFormatting @rulesparam -ConditionValue 'NOT(ISERROR(FIND("DB SECURABLES",$E1)))' -BackgroundColor BurlyWood 

Close-ExcelPackage $excel


Write-Output ""
Write-Output "Finished Processing $sqlinstance"

$Excel = Open-ExcelPackage -Path $ExcelFile
Add-Worksheet -ExcelPackage $Excel -WorksheetName 'Title' -MoveToStart | Out-Null

$TitleSheet = $excel.Workbook.Worksheets['Title']
$Date = (Get-Date).ToLongDateString()
$TitleSheet.Cells["A1"].value = "This Worksheet shows the User Permissions for each database on $sqlinstance at $Date "
Set-ExcelRange -Worksheet $TitleSheet -Range "A:1" -Bold -FontSize 22 -Underline -UnderLineType Double

$TitleSheet.Cells["B3"].Value = "The Cells are colour coded as follows :-"
Set-ExcelRange -Worksheet $TitleSheet -Range "B3" -Bold -FontSize 18 
$TitleSheet.Cells["E5"].Value = "The Yellow Cells show members of the sysadmin role who have permission to do and access anything on the instance "
$TitleSheet.Cells["E6"].Value = "The Green Cells show the logins on the server"
$TitleSheet.Cells["E7"].Value = "The Blue Cells show the instance level permissions that have been granted to the logins"
$TitleSheet.Cells["E8"].Value = "The Orange Cells show the database role membership for the login"
$TitleSheet.Cells["E9"].Value = "The Brown Cells show specific database permissions that have been granted for the logins"

$TitleSheet.Cells["B11"].Value = "You can filter by Database on the Object column"
Set-ExcelRange -Worksheet $TitleSheet -Range "C11" -FontSize 18

$TitleSheet.Cells["B12"].Value = "You can filter by User/Group/Login on the Member column"
Set-ExcelRange -Worksheet $TitleSheet -Range "C12" -FontSize 18

Set-ExcelRange -Worksheet $TitleSheet -Range  "C5" -BackgroundColor Yellow
Set-ExcelRange -Worksheet $TitleSheet -Range  "C6" -BackgroundColor PaleGreen
Set-ExcelRange -Worksheet $TitleSheet -Range  "C7" -BackgroundColor PowderBlue 
Set-ExcelRange -Worksheet $TitleSheet -Range  "C8" -BackgroundColor GoldenRod 
Set-ExcelRange -Worksheet $TitleSheet -Range  "C9" -BackgroundColor BurlyWood 

Close-ExcelPackage $excel


Write-Output "                ###############                  "
Write-Output "        FileName is $ExcelFile            "
Write-Output "                ###############                  "
Write-Output ""

# run this in Windows Terminal to see the windows explorer view

# explorer \\wsl.localhost\docker-desktop-data\version-pack-data\community\docker\volumes\bitsdbatools_devcontainer_shared\_data

# To AutoFit column width:CTRL A and then Alt + H, then O, and then I.

# Choose your adventure
Get-GameTimeRemaining

Get-Index