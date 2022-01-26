Return 'Oi Beardy or Hair pay attention you need to be the right user'
New-PSDrive -Name SQLBitsPreCon -Root 'C:\Users\mrrob\OneDrive\Documents\GitHub\SQLBitsPreCon\Slides and Demos\03 - Pester Introduction' -PSProvider FileSystem
cd SQLBitsPreCon:\

## ROB Set "powershell.integratedConsole.focusConsoleOnExecute" to false

#region Getting the latest Pester

## This is how you get the latest Pester

## because Pester came installed with PowerShell you can't use Install-Module Pester on its own
## You will get Red Text :-(

Install-Module Pester -SkipPublisherCheck -Force ## -Scope CurrentUser # if not in admin session

## You will need to import it

Import-Module Pester

## Check you have the correct version loaded into your session

Get-Module Pester

## Check all available Pester Modules 

Get-Module Pester -ListAvailable

#endregion

$Instance = 'ROB-XPS'
$Database = 'WideWorldImporters'

## This is the basic syntax Describe, Context, It

#region Describe
## All Pester tests must start with a Describe Block

Describe "This is my set of tests"
{

}

## That is my favourite error message :-)
## You have to put the curly braces on teh same line as the Describe
## ............ and the Context...............and the It

Describe "This is my set of tests" {

}
#endregion

#region Context
## The Context enables us to scope our tests within our Describe block

Describe "This is my set of tests for testing my SQL Servers" {
    Context "Windows Set Up" {

    }

    Context "SQL Logins" {

    }

    Context "SQL Configuration" {

    }
    Context "Backups" {

    }
    Context "Agent Jobs"{

    }
}

#endregion

#region It
# It is The test

## It can live in a Describe block by itself or with others

Describe "Testing a backup" { 
    It "Should have a file" {
        Test-Path 'C:\MSSQL\BACKUP\ROB-XPS$DAVE\test\FULL\ROB-XPS$DAVE_test_FULL_20170903_093014.bak' | Should -Be $True
    }
}

## It can live in a Context block by itself or with others

Describe "Testing a backup solution" {
    Context "Testing Dave backups" {
        It "Should have a file" {
            Test-Path 'C:\MSSQL\BACKUP\ROB-XPS$DAVE\test\FULL\ROB-XPS$DAVE_test_FULL_20170903_093014.bak' | Should Be $True
        }
    }
}
#endregion

#region Should

# Should could take a whole hour by itself!
# Should is the most important command of all
https://github.com/pester/Pester/wiki/Should
# Should is the command that enables you to pass or fail a test The assertion
# Should has a number of operators 

(Get-Command Should).Parameters.Keys

Describe "Looking at Should" {
   Context "Should Bees - :-) " {
        It "could be a number" {
       (Get-ChildItem 'C:\agent\_work\2\s\SSDT Database\').Count | Should -Be 6
        }
        It "could be a string" {
            (Get-ChildItem 'C:\agent\_work\2\s\SSDT Database\')[0].Name | Should -Be 'bin'
        }
        It "could be true or false - In Pester 4.2 there is a BeTrue" {
            Test-Path 'C:\agent\_work\2\s\SSDT Database\' | Should -BeTrue
        }
    }

    Context "Should Be Exactly" {
        It "Matches case sensitivity" {
            "Chrissy has great Hair" | Should -BeExactly "Chrissy has great hair"
        }
    }
    Context "Should Be Like (innit?)" {
        It "Allows for PowerShell Liking" {
            "Chrissy has great Hair" | Should -BeLike "*has great hair"
        }
    }
    Context "Should Exactly Like" {
        It "Allows for PowerShell Liking with case sensitivity" {
            "Chrissy has great Hair" | Should -BeLikeExactly "*has great hair"
        }
    }
    Context "Play Your Cards Right" {
        It "Should be Higher" {
            9 | Should -BeGreaterThan 8
        }
        It "Should Be Lower - Err what ?? 'Ace of Spades' | Should -BeLessThan 'Jack of Spades'" {
            'Ace of Spades' | Should -BeLessThan 'Jack of Spades'
        }
        It "Should Be Lower - Huh?" {
            'Jack of Spades' | Should -BeLessThan 'Ace of Spades'
        }
        It "Should Be Lower - B should be less than A" {
            'B' | Should -BeLessThan 'A'
        }
        It "Should Be Lower - Alphabetical - A should be less than B" {
            'A' | Should -BeLessThan 'B'
        }
        It "Should Be Lower - Alphabetical - BA should be less than BB" {
            'BA' | Should -BeLessThan 'BB'
        }
    }
    Context "Check your types" {
        It "Should have a type of database - more suited to TDD" {
            Get-DbaDatabase -SqlInstance $Instance -Database $Database | Should -BeOfType [Microsoft.SqlServer.Management.Smo.Database]
        }
    }
    Context "Existence" {
        It "Should be there - Hmm not like this" {
            Get-DbaDatabase -SqlInstance $Instance -Database $Database | Should -Exist
        }
        It "Should be there - just check the path" {
            (Get-DbaDefaultPath -SqlInstance $Instance).Backup | Should -Exist
        }
    }
    Context "Whats in the file" {
        It "Should have this message - Dah its not a file" {
            (Get-DbaSqlLog -SqlInstance $Instance).Text | Should -FileContentMatch "Detected 16272 MB of RAM"
        }
        It "Should have this message " {
        "$((Connect-DbaInstance -SqlInstance $Instance).ErrorLogPath)\ERRORLOG"| Should -FileContentMatch "Detected 16272 MB of RAM"
        }
        It "Should have exactly this message " {
        "$((Connect-DbaInstance -SqlInstance $Instance).ErrorLogPath)\ERRORLOG"| Should -FileContentMatchExactly "Detected 16272 MB of Ram"
        }
        It "Should have this message using regex " {
        "$((Connect-DbaInstance -SqlInstance $Instance).ErrorLogPath)\ERRORLOG"| Should -FileContentMatch ".*Detected\s16272\sMB\sof\sRAM.*"
        }
        It "Should have exactly this message on multilines - notice the `$([System.Environment]::NewLine) and the .*" {
        $Message = "Detected 16272 MB of RAM.*$([System.Environment]::NewLine).*Using conventional memory in the memory manager"
        "$((Connect-DbaInstance -SqlInstance $Instance).ErrorLogPath)\ERRORLOG"| Should -FileContentMatchMultiline $Message
        }
        (Get-DbaDatabase -SqlInstance $Instance -Status Normal -ExcludeDatabase tempdb).ForEach{
            It "Error log says Database $($PsItem.Name) started and Check DB ran successfully" {
                "$((Connect-DbaInstance -SqlInstance $Instance).ErrorLogPath)\ERRORLOG" | Should -FileContentMatch "CHECKDB for database '$($PsItem.Name)' finished without errors"
            } 
        }
    }
    Context "Matches" {
        It "Matches strings as well" {
            (Get-DbaSqlLog -SqlInstance $Instance).Text |Out-String | Should -Match "Starting up database 'AdventureWorks2014'"
        }
        It "Matches strings exactly as well" {
            (Get-DbaSqlLog -SqlInstance $Instance).Text |Out-String | Should -Match "Starting up database 'adventureWorks2014'"
        }
        
    }
    Context "If you want to Throw - again normally a TDD assertion" {
        It "I want it to Throw - cant divide by zero - the script needs to be curly braces" {
            {1/0} | Should -Throw
        }
        It "I want it to Throw with a message - cant divide by zero - the script needs to be curly braces" {
            {1/0} | Should -Throw -ExpectedMessage 'Attempted to divide by zero.'
        }
        It "I want it to Throw a particular exception - cant divide by zero - the script needs to be curly braces" {
            {1/0} | Should -Throw -ErrorId RuntimeException
        }
    }
    Context "Null or Empty" {
        It "Can test for Empty strings" {
            '' | Should -BeNullOrEmpty
        }
        It "Can test for PowerShell Null" {
            $null | Should -BeNullOrEmpty
        }
        It "Can test for SQL Null (but be careful and test) - (This is a PowerShell Null) `$null != [System.DBNull]::Value (this is a SQL Null)" {
            $query = "SELECT TOP 1 [AlternateContactPersonID]
            FROM [Sales].[Customers]
            WHERE [AlternateContactPersonID] IS NULL"
            (Invoke-DbaSqlCmd -SqlInstance $Instance -Database $Database -Query $query).AlternateContactPersonID | Should -BeNullOrEmpty
        }
        It "Expected PowerShell Null `$null to be the same as a SQL Null [System.DBNull]::Value" {
            $null | Should -Be [System.DBNull]::Value
        }
        It "To Be Honest most of the time you will use NOT with this one" {
            (Get-DbaDefaultPath -SqlInstance $Instance).Backup | Should -Not -BeNullOrEmpty
        }
    }
}

#endregion

#region Invoke-Pester Show and Tag
## Invoke-Pester Can run a file

Invoke-Pester '.\A File.ps1'

# You get a little bit more info about the tests

# Invoke-Pester will run any .ps1 scripts in a folder named *.Tests.ps1

# This means you can also use the Tag parameter for your Describe block

# Look in Pester.Tests.ps1 file There are 2 Describe blocks with a Tag

# Only run the tests with a Tag of Backup
Invoke-Pester -Tag Backup 

# Only run the tests with a Tag of Identity
# This is where the -Show parameter is useful
# Did you see the failed tests?
# Imagine I ran 80000 tests instead of 852 and 3 failed
# How long did it take ? 35.46s
Invoke-Pester -Tag Identity

# Show enables you to reduce the output on the screen

Invoke-Pester -Tag Backup -Show Header,Summary
Invoke-Pester -Tag Backup -Show Fails
# How long does this take? 26.17s
Invoke-Pester -Tag Identity -Show Fails

# You can even show None!
Invoke-Pester -Tag backup -Show None
# Why would you do that?
$TestResults = Invoke-Pester -Tag Backup -Show None -PassThru

$TestResults
$TestResults.TestResult

# Output to an XML for consumption by a CI server or Build or Release Server

Invoke-Pester -Tag Identity -Show Fails -OutputFile .\TestOutput.xml -OutputFormat NUnitXml
code-insiders .\TestOutput.xml

#endregion

#region Pre-Release Pester and PowerShell Core

## Lets look at some New Pre-Release Features

## Switch to PowerShell Core 

## Lets try the latest Pre-Release

## this requires the latest version of PowerShellGet installed on PowerShell v6 

## on earlier versions you will need to run this

## In An Admin session
##  Install-Module  PowerShellGet 
## Install-Module -Name Pester -AllowPrerelease

Import-Module Pester

## Check it is the latest version

Get-Module Pester

Get-Command -Module Pester

# Now we can use the Because parameter to give reasons for our failures

# $Speaker = 'Rob'

$Speaker = 'Chrissy'

Describe "The Speaker" {
    Context "Facial Appearance" {
        It "The Speaker Should have a Beard" {
            $Speaker | Should -Be 'Rob' -Because "Beards Are Awesome"
        }
    }
    Context "Some new Assertions" {
        It "Can have a BeTrue" {
            $false | Should -BeTrue -Because "it is a new assertion"
        }
        It "Can have a BeFalse" {
            $true | Should -BeFalse -Because "it is a new assertion"
        }
    }
}

# A silly example just so that you can see the because in action
# Think about what you can use it for
Import-Module 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules\SmbShare\SmbShare.psd1'
Describe "My System" {
    Context "Server" {
        It "Should be using XP SP3" {
            (Get-CimInstance -ClassName win32_operatingsystem).Version | Should -Be '5.1.2600' -Because "We have failed to bother to update the App and it only works on XP"
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should -Be 'rob-xps\mrrob' -Because "This is the user with the permissions"
        }
        It "Should have SMB1 enabled" {
            (Get-SmbServerConfiguration).EnableSMB1Protocol | Should -BeTrue -Because "We don't care about the risk"
        }
    }
}
#endregion

## ROB Set "powershell.integratedConsole.focusConsoleOnExecute" to true